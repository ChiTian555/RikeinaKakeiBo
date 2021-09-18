//
//  CheckMoneyViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/29.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import RealmSwift
import PKHUD
import UserNotifications
import Instructions
import SwiftDate

class CheckMoneyVC: MainBaceVC {
    
    private let realm = try! Realm()
    private let ud = UserDefaults.standard
    private let notificationCenter = NotificationCenter.default
    
    var sumMoney = Int()
    
    var icTypeTitles : [String] =
        ["交通系IC", "楽天Edy", "nanaco","WAON","大学生協プリペードカード"]
    var userBudget: [String] = ["おこづかい","貯金"]
    var budgetsLavel = [UILabel]()
//    var balances: [Int] = []
//    var balanceList = [Int]()
    
    // 通知削除のため
    var uuID = String()
    
    var startStepCells = [(cell: UITableViewCell,Name: String)]()
    
    @IBOutlet var checkMoneyTableView: UITableView!
    //Cellデータ格納変数
    var accountLists: Results<Account>!
    var budgetsValue = [Int]()
    
    
    
    var coachController = CoachMarksController()
    /// .0: step3, .1: step4 初期ステップのうむを格納
    private var condition = (false,false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationCenter.addObserver(self, selector: #selector(willResignActive),
                                       name: UIApplication.willResignActiveNotification,
                                       object: nil)
        notificationCenter.addObserver(self, selector: #selector(becameActive),
                                       name: UIApplication.didBecomeActiveNotification,
                                       object: nil)
        checkMoneyTableView.estimatedRowHeight = 50
        checkMoneyTableView.rowHeight = UITableView.automaticDimension
        checkMoneyTableView.dataSource = self
        checkMoneyTableView.delegate = self
        checkMoneyTableView.tableFooterView = UIView()
        checkMoneyTableView.set()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        print("ViewWillApareが呼ばれた")
    }
    
    //tableView更新
    func reloadData() {
        accountLists = Account.readAll()
        let pocketMoney = ud.integer(forKey: .pocketMoney) ?? 0
        budgetsValue = [pocketMoney, accountLists.sum(ofProperty: "balance") - pocketMoney]
        checkMoneyTableView.reloadData()
    }
    
    private var getCurrentTF: [UITextField]? {
        print(":getCurrentTF")
        if let aC = self.presentedViewController as? UIAlertController {
            if let tF = aC.textFields { return tF }
        }; return nil
    }
    
}

// MARK: TableView DataSource

extension CheckMoneyVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if accountLists?.isEmpty != false {
            return userBudget.count + 1
        }
        //UserButget計算に関するリセット
        budgetsLavel = []
        sumMoney = 0
        //スタートステップに関するリセット
        startStepCells = []
        
        return accountLists.count + userBudget.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var font = UIFont()
        if ud.bool(forKey: .isCordMode) { font = UIFont(name: "cordFont", size: 25)! }
        else { font = UIFont.systemFont(ofSize: 20, weight: .semibold) }
        var cell: UITableViewCell!
        if indexPath.row < userBudget.count {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell1")!.create()
            let labelName = cell.viewWithTag(1) as! UILabel
            let labelBudget = cell.viewWithTag(2) as! UILabel
            labelName.text = userBudget[indexPath.row]
            labelBudget.font = font
            labelBudget.text = "¥\(budgetsValue[indexPath.row])"
            labelBudget.textColor = budgetsValue[indexPath.row] < 0 ? .systemRed : .label
            
            if indexPath.row == 0 {
                //初期ステップ3
                if ud.stringArray(forKey: .startSteps)!.first == "3" {
                    startStepCells.append((cell,"condition3"))
                }
            } else { cell.selectionStyle = .none }
            
        } else if accountLists.count >= 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell2")!.create()
            let nameLabel = cell.viewWithTag(1) as! UILabel
            let balanceLabel = cell.viewWithTag(2) as! UILabel
            let typeLabel = cell.viewWithTag(3) as! UILabel
            let checkLabel = cell.viewWithTag(4) as! UILabel
            balanceLabel.font = font
            let nowAccount =  accountLists[indexPath.row - userBudget.count]
            nameLabel.text = nowAccount.name
            typeLabel.text = nowAccount.type
            
            let lastCheck = nowAccount.newCheck
            let checkedMonth: String = lastCheck != nil ? "\(lastCheck!.checkDate.inDefaultRegion().month)" : "--"
            let checkedDay: String = lastCheck != nil ? "\(lastCheck!.checkDate.inDefaultRegion().day)" : "--"
            let checkedBalance: String = lastCheck != nil ? "\(lastCheck!.balance)" : "--"
            let attriStr = NSMutableAttributedString()
            let isCredit = nowAccount.type.first == "④"
            let title = isCredit ? ("最終引き落とし日","金額") : ("最終確認日","残高")
            
            if ud.bool(forKey: .isCordMode) {
                attriStr.append(
                    NSAttributedString(string: "\(title.0): \(checkedMonth)/\(checkedDay)\n\(title.1): ")
                )
                attriStr.append(
                    NSAttributedString(string: "¥\(checkedBalance)",
                                       attributes: [NSAttributedString.Key.font :
                                                        UIFont(name: "cordFont", size: 20)!])
                )
            } else {
                attriStr.append(
                    NSAttributedString(string: "\(title.0): \(checkedMonth)/\(checkedDay)\n\(title.1): ¥\(checkedBalance)")
                )
            }
            checkLabel.attributedText = attriStr
            balanceLabel.textColor = nowAccount.balance < 0 ? .systemRed : .label
            balanceLabel.text = "¥\(nowAccount.balance)"
            balanceLabel.textAlignment = .right
            if nowAccount.isMustCheck() {
                startStepCells.append((cell, nowAccount.type))
            }
            
        } else {
            //まだ口座登録されてない時
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell3")!.create()
            let label = cell.viewWithTag(1) as! UILabel
            label.textAlignment = .center
            label.text = "まだ、口座が登録されていません！\n設定->口座管理から、まず、\n現金を登録してみてください。"
            cell.selectionStyle = .none
        }
        
        return cell.set()
    }
}

// MARK: TableView Delegate

extension CheckMoneyVC: UITableViewDelegate {
    
    private func moveSetting() {
        
        let alert = MyAlert("通知許可がなされていません","設定画面に移りますか？")
        alert.addActions("いいえ", type: .cancel) { _ in
            HUD.flash(.labeledError(title: "Error", subtitle: "確認できませんでした"))
        }
        alert.addActions("はい") { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        self.present(alert.controller, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return ![0,1].contains(indexPath.row) && accountLists.count != 0
    }
    
    //後方スワイプ
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let row = indexPath.row - userBudget.count
        let action = UIContextualAction(style: .destructive,
                                        title: "口座タイプ\n変更"){ (ctxAction, view, completionHandler) in
            let myAlert = MyAlert("設定", "変更後のタイプを\n選択してください？")
            myAlert.addTextField("タップして選択") { [self] (tF) in
                let pickerView = UIPickerView()
                pickerView.delegate = self
                pickerView.selectRow(pickerTitle.firstIndex(of: accountLists[row].type)!,
                                     inComponent: 0, animated: false)
                tF.inputView = pickerView
                tF.text = accountLists[row].type
                let toolBar = MyToolBar(self, type: .done(done: #selector(done)))
                tF.inputAccessoryView = toolBar
            }
            myAlert.addActions("キャンセル", type: .cancel) { _ in completionHandler(false) }
            myAlert.addActions("変更", type: .destructive) { (alert) in
                guard let text = alert.tFs.first?.text, text != "" else {
                    HUD.flash(.labeledError(title: "Error", subtitle: "空欄があります")) { _ in
                        self.present(alert.controller, animated: true, completion: nil)
                    }
                    return
                }
                if text.first == "②" {
                    completionHandler(false)
                    let alert = MyAlert("ICカードを確認します","カードの種類を\nお選びください")
                    alert.addTextField("タップして入力") { (tF) in
                        tF.text = self.icTypeTitles.first
                        let icTypepicker = UIPickerView()
                        icTypepicker.dataSource = self
                        icTypepicker.delegate = self
                        icTypepicker.tag = 1
                        tF.inputView = icTypepicker
                        let toolBar = MyToolBar(self,type: .done(done: #selector(self.done)))
                        tF.inputAccessoryView = toolBar
                    }
                    alert.addActions("キャンセル", type: .cancel, nil)
                    alert.addActions("決定") { (myAlert) in
                        let icTypeName = myAlert.tFs.first?.text ?? ""
                        guard let icTypeNom = self.icTypeTitles.firstIndex(of: icTypeName) else {
                            HUD.flash(.error)
                            self.present(alert.controller, animated: true, completion: nil)
                            return
                        }
                        NFCReader(type: FeliCaCardType(icTypeNom + 1)!) { (balance, error)  in
                            if let error = error {
                                HUD.flash(.label("予期せぬエラーです。\n\(error.localizedDescription)"))
                                return
                            }
                            if balance < 0 {
                                HUD.flash(.label("カードが読み取れません"), delay: 1.0) {_ in
                                    HUD.flash(.label("再度スキャンしてください"), delay: 1.0) {_ in
                                        self.present(alert.controller, animated: true, completion: nil)
                                    }
                                }
                            } else {
                                HUD.flash(.label("カードを確認しました。"))
                                let icType = icTypeNom + 1
                                let res = self.accountLists[row].write { (me) in
                                    me.type = text
                                    me.icType = icType
                                }
                                if res { self.reloadData(); completionHandler(true) }
                                else { HUD.flash(.error, delay: 2.0)
                                    completionHandler(false)}
                            }
                        }.start()
                    }
                    self.present(alert.controller, animated: true, completion: nil)
                    return
                }
                
                let res = self.accountLists[row].write { (me) in me.type = text}
                if res { self.reloadData(); completionHandler(true) }
                else { HUD.flash(.error, delay: 2.0) ; completionHandler(false)}
            }
            self.present(myAlert.controller, animated: true, completion: nil)
        }
        
        let easyPay = UIContextualAction(style: .normal, title: "スマート入金") { (ctxAction, view, completionHandler) in
            
            //ここで、簡単入金の画面に移る
            
            completionHandler(false)
        }
        
        var actions = [UIContextualAction]()
        
        if accountLists[row].type.first == "④" {
            actions = []
        } else {
            actions = [action]
        }
        
        let swipeAction = UISwipeActionsConfiguration(actions: actions)
        
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    // MARK: TableView Tapped Func
    
    // cellがタップされた
    // ここが、むちゃくちゃに、長い。笑
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            desidePocketMoney()
            tableView.deselectRow(at: indexPath, animated: true); return
        }
        if indexPath.row < userBudget.count {
            //初期ステップ3->4
            if condition.0 {
                self.ud.deleteArrayElement("3", forKey: .startSteps)
                condition.0 = false
                let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
                tbc.setStartStep()
            }
            tableView.deselectRow(at: indexPath, animated: true); return
        }
        
        if accountLists.isEmpty != false {
            tableView.deselectRow(at: indexPath, animated: true); return
        }
        
        // 残高チェックのコード
        let row = indexPath.row - userBudget.count
        let account = accountLists[row]
        
        switch account.type.first {
        case "①":
            if !ud.bool(forKey: .canUseNotification) {
                checkMoneyTableView.deselectRow(at: indexPath, animated: true)
                moveSetting(); return
            }
            let alert = MyAlert("確認モード", "画面を閉じてください")
            alert.addActions("キャンセル", type: .cancel) { _ in
                tableView.deselectRow(at: indexPath, animated: true)
                SceneDelegate.shared.isCheckMode = false
            }
            self.present(alert.controller, animated: true, completion: nil)
            SceneDelegate.shared.isCheckMode = true
            break
        case "②":
            //            self.checkSearchIcCard(index: indexPath)
            let alert = MyAlert("確認モード", "ICカードを\nスキャンします")
            alert.addActions("キャンセル", type: .cancel) { _ in
                self.checkMoneyTableView.deselectRow(at: indexPath, animated: true)
            }
            alert.addActions("OK") { _ in
                self.checkMoneyTableView.deselectRow(at: indexPath, animated: true)
                self.checkICCard(account: account)
            }
            present(alert.controller, animated: true, completion: nil)
            break
        case "③":
            let checkAlert = MyAlert("残高確認", "残金は一致しましたか？")
            checkAlert.addActions("いいえ", type: .cancel) { (alert) in
                let alert = MyAlert("残高調整", "現在の残高を入力してください。")
                alert.addTextField("タップして入力")
                alert.addActions("キャンセル", type: .cancel, nil)
                alert.addActions("完了") { (alert) in
                    guard let trueBalance = Int(alert.tFs.first?.text ?? "") else {
                        HUD.flash(.labeledError(title: "Error", subtitle: "数値を入力してください"), delay: 1.5)
                        return
                    }
                    let adjustBalance = trueBalance - account.balance
                    self.adjustBalance(account: account, adjustBalance: adjustBalance)
                }
                self.present(alert.controller, animated: true, completion: nil)
                self.checkMoneyTableView.deselectRow(at: indexPath, animated: true)
            }
            checkAlert.addActions("はい") { (alert) in
                self.checkMoneyTableView.deselectRow(at: indexPath, animated: true)
                //最終確認日を更新
                HUD.flash(.labeledSuccess(title: "成功", subtitle: "残高を更新します"))
                //最終確認日を更新
                let newCheck = Check()
                newCheck.balance = account.balance
                account.newCheck = newCheck
                self.reloadData()
                
                if account.isMustCheck(checked: true) {
                    let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
                    tbc.setStartStep()
                }
            }
            self.present(checkAlert.controller, animated: true, completion: nil)
            break
        case "④":
            let checkAlert = MyAlert("支払", "\(account.chargeAccount)から\n引き落とし登録行いますか？")
            checkAlert.addActions("キャンセル", type: .cancel) { _ in
                tableView.deselectRow(at: indexPath, animated: true)
            }
            checkAlert.addActions("はい") { _ in
                tableView.deselectRow(at: indexPath, animated: true)
                self.desideCreditPay(account: account)
            }
            self.present(checkAlert.controller, animated: true, completion: nil)
            break
        default:
            HUD.flash(.labeledError(title: "予期せぬエラー", subtitle: nil), delay: 1)
        }
    }
    
    // 決定ボタン押下
    @objc func done() {
        guard let tF = getCurrentTF?.first(where: {$0.isFirstResponder}) else { return }
        if let dPicker = tF.inputView as? UIDatePicker {
            tF.text = dPicker.date.toFormat("yyyy-MM-dd")
        }; tF.resignFirstResponder()
    }
    
    @objc func goNext() {
        guard let tFs = getCurrentTF else { return }
        if let i = tFs.firstIndex(where: {$0.isFirstResponder}) {
            if let dPicker = tFs[safe:i]?.inputView as? UIDatePicker {
                tFs[safe:i]?.text = dPicker.date.toFormat("yyyy-MM-dd")
            }
            tFs[safe:i + 1]?.becomeFirstResponder()
        }
    }
    
    // MARK: Check PocketMoney
    
    /// お小遣いを入力させる関数。
    func desidePocketMoney() {
        let myAlert = MyAlert("設定", "今月のお小遣い額を\n決定しますか？")
        myAlert.addActions("いいえ", type: .cancel, nil)
        myAlert.addActions("はい") { (alert) in
            //今月のお小遣いをもう設定してしまってるかどうか判定
            let updateDate = self.ud.string(forKey: .pocketMoneyAdded)
            if Date().toFormat("yyyy-MM") == updateDate {
                let message = "\(Date().month)月分のお小遣いは\n既に設定済みです"
                HUD.flash(.labeledError(title: "Error", subtitle: message))
                return
            }
            let textAlert = MyAlert("お小遣い設定", "今月のお小遣いを\n入力してください")
            textAlert.addTextField("金額を入力")
            textAlert.addActions("キャンセル",type: .cancel) { (alert) in
                HUD.flash(.label("キャンセルしました"))
            }
            textAlert.addActions("確定") { (tAlert) in
                guard let price = Int(tAlert.tFs.first?.text ?? "") else {
                    HUD.flash(.labeledError(title: "Error", subtitle: "入力にミスがあります")){_ in
                        self.present(tAlert.controller, animated: true, completion: nil)
                    }; return
                }
                let checkAlert = MyAlert("金額:¥\(price)", "変更できませんがいいですか？")
                checkAlert.addActions("訂正", type: .cancel) { (alert) in
                    self.present(tAlert.controller, animated: true, completion: nil)
                }
                checkAlert.addActions("はい") { _ in
                    self.ud.deleteArrayElement("3", forKey: .startSteps)
                    let nowPoketMoney = self.ud.integer(forKey: .pocketMoney) ?? 0
                    self.ud.setInteger(nowPoketMoney + price, forKey: .pocketMoney)
                    self.ud.setString(Date().toFormat("yyyy-MM"), forKey: .pocketMoneyAdded)
                    self.reloadData()
                    let message = "\(Date().month)月分のお小遣いを\n入力完了しました"
                    HUD.flash(.labeledSuccess(title: "設定完了", subtitle: message))
                }
                self.present(checkAlert.controller, animated: true, completion: nil)
            }
            self.present(textAlert.controller, animated: true, completion: nil)
        }
        self.present(myAlert.controller, animated: true, completion: nil)
    }
    
    // MARK: Deside CreditPay
    
    private func desideCreditPay(account: Account) {
        let inputAlert = MyAlert("クレジットカードの締め日","本引き落としの締め日を\n入力してください。")
        
        inputAlert.addTextField("タップして締め日を入力") { [self] (tF) in
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
            datePicker.maximumDate = Date()
            tF.inputView = datePicker
            let bar = MyToolBar(self, type: .doneAndNext(done: #selector(done),
                                                         next: #selector(goNext)))
            bar.tag = 2
            tF.inputAccessoryView = bar
        }
        inputAlert.addTextField("実際の引き落し金額を入力") { [self] (tF) in
            tF.keyboardType = .numberPad
            let toolbar = MyToolBar(self, type: .done(done: #selector(done)))
            tF.inputAccessoryView = toolbar
        }
        inputAlert.addActions("キャンセル", type: .cancel, nil)
        inputAlert.addActions("OK") { (myAlert) in
            guard let strDay = myAlert.tFs.first?.text, strDay != "" else {
                HUD.flash(.labeledError(title: "空欄があります",
                                        subtitle: "日付を選択してください"))
                self.present(myAlert.controller, animated: true, completion: nil)
                return
            }
            
            guard let endDate = strDay.toDate("yyyy-MM-dd")?.date else {
                HUD.flash(.labeledError(title: "エラー",
                                        subtitle: "日付入力に\nミスがあります"))
                self.present(myAlert.controller, animated: true, completion: nil)
                return
            }
            guard let price = Int(myAlert.tFs[1].text ?? "") else {
                HUD.flash(.labeledError(title: "エラー",
                                        subtitle: "引き落とし金額に\n入力ミスがあります"))
                self.present(myAlert.controller, animated: true, completion: nil)
                return
            }
            //<0
            let sum = Payment.getCreditPaymentSum(account, endDate: endDate)
            
            print("price:",price,"\nsum:",sum)
            
            if price == sum * -1 {
                HUD.flash(.label("引き落とし金額と、家計簿の記録が一致しました。")) { _ in
                    HUD.flash(.labeledSuccess(title: "引き落とし登録完了",
                                              subtitle: "家計簿を更新しました。。"))
                    let newPayment = Payment.make()
                    newPayment.mainCategoryNumber = 2
                    newPayment.price = sum * -1 //>0
                    newPayment.paymentMethod = account.name
                    newPayment.withdrawal = account.chargeAccount
                    newPayment.save()
                    let newCheck = Check()
                    newCheck.balance = sum
                    account.newCheck = newCheck
                    self.reloadData()
                }
            } else {
                if account.newCheck == nil {
                    let message = "\(account.chargeAccount)残高から\n" +
                        "家計簿開始前の出費分\n¥\((price + sum) * -1)を除きますか?"
                    let alert = MyAlert("初回引き落とし登録",message)
                    alert.addActions("キャンセル", type: .cancel, nil)
                    alert.addActions("OK") { _ in
                        let newPayment = Payment.make()
                        newPayment.mainCategoryNumber = 2
                        newPayment.price = sum * -1
                        newPayment.paymentMethod = account.name
                        newPayment.withdrawal = account.chargeAccount
                        newPayment.save()
                        guard let charge = Account.readValue(name: account.chargeAccount) else { return }
                        _ = charge.write({$0.balance += (price + sum) * -1})
                        let newCheck = Check()
                        newCheck.balance = sum
                        account.newCheck = newCheck
                        HUD.flash(.labeledSuccess(title: "引き落とし登録完了",
                                                  subtitle: "家計簿を更新しました。。"))
                        self.reloadData()
                    }
                    HUD.flash(.label("引き落とし金額と、家計簿の記録が一致しません。")) {_ in
                        self.present(alert.controller,
                                     animated: true, completion: nil)
                    }
                } else {
                    let message = "\(account.chargeAccount)残高から\n" +
                        "家計簿未記入の出費分¥\((price + sum) * -1)を\n" +
                        "紛失額として登録しますか?"
                    let alert = MyAlert("残高調整",message)
                    alert.addActions("キャンセル", type: .cancel, nil)
                    alert.addActions("OK") { _ in
                        // 返済の登録
                        let newPayment = Payment.make()
                        newPayment.mainCategoryNumber = 2
                        newPayment.price = sum * -1 // sum < 0
                        newPayment.paymentMethod = account.name
                        newPayment.withdrawal = account.chargeAccount
                        newPayment.save()
                        // 紛失の登録　price + sum　は、差額。
                        let lostPayment = Payment.make()
                        lostPayment.mainCategoryNumber = 0
                        lostPayment.price = (price + sum) * -1
                        lostPayment.paymentMethod = account.chargeAccount
                        lostPayment.category = "紛失"
                        lostPayment.save()
                        let newCheck = Check()
                        newCheck.balance = sum
                        account.newCheck = newCheck
                        
                        HUD.flash(.labeledSuccess(title: "引き落とし登録完了",
                                                  subtitle: "家計簿を更新しました。"))
                        self.reloadData()
                    }
                    HUD.flash(.label("引き落とし金額と、家計簿の記録が一致しません。")) {_ in
                        self.present(alert.controller,
                                     animated: true, completion: nil)
                    }
                }
            }
        }
        self.present(inputAlert.controller, animated: true, completion: nil)
    }
    
    // MARK: Scan ICCard
    
    private func checkICCard(account: Account) {
        NFCReader(type: FeliCaCardType(account.icType)!) { (balance, error) in
            
            if let error = error {
                HUD.flash(.label("予期せぬエラーです。\n\(error.localizedDescription)"))
                return
            }
            
            if balance < 0 { HUD.flash(.label("読み取れませんでした")); return }
            if balance == account.balance {
                HUD.flash(.label("残高が一致しました！"), delay: 1.0) {_ in
                    HUD.flash(.labeledSuccess(title: "成功", subtitle: "残高を更新します"))
                }
                let newCheck = Check()
                newCheck.balance = account.balance
                account.newCheck = newCheck
                self.reloadData()
                
                if account.isMustCheck(checked: true) {
                    let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
                    tbc.setStartStep()
                }
            } else {
                HUD.flash(.label("残高不一致")) {_ in
                    let adjustBalance = balance - account.balance
                    self.adjustBalance(account: account,
                                       adjustBalance: adjustBalance)
                }
            }
        }.start()
    }
    
    // MARK: Controlle Screen Func
    
    //画面を閉じるときに、通知を表示
    @objc func willResignActive() {
        
        if let alert = self.presentedViewController as? UIAlertController {
            if alert.title == "確認モード" {
                DispatchQueue.main.async { [self] in
                    var account = String()
                    var accountBudged = String()
                    guard let index = self.checkMoneyTableView.indexPathForSelectedRow
                    else { return }
                    let row = index.row - self.userBudget.count
                    account = accountLists[row].name
                    accountBudged = "¥\(accountLists[row].balance)"
                    let content = UNMutableNotificationContent()
                    content.title = "確認モード"
                    content.body = "\(account)の残高は\(accountBudged)でした。\n確認ください"
                    content.sound = UNNotificationSound.default
                    
                    // タイマーの時間（秒）をセット
                    let timer = 1
                    // ローカル通知リクエストを作成
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timer), repeats: false)
                    //カレンダーでのトリガーをできるようにする。
                    let identifier = NSUUID().uuidString
                    uuID = identifier
                    
                    // 直ぐに通知を表示
                    let request = UNNotificationRequest(identifier: identifier,
                                                        content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { (error) in
                        print(error?.localizedDescription)
                    }
                }
                
            }
        }
    }
    
    @objc func becameActive() {
        print("Activeになった、が呼ばれた")
        if let alert = self.presentedViewController as? UIAlertController {
            alert.dismiss(animated: true, completion: nil)
            
            //選択されてた口座の場所を取得
            guard let index = self.checkMoneyTableView.indexPathForSelectedRow
            else { return }
            let row = index.row - self.userBudget.count
            let checkAlert = MyAlert("残高確認","残金は一致しましたか？")
            checkAlert.addActions("いいえ", type: .cancel) { (cAlert) in
                self.checkMoneyTableView.deselectRow(at: index, animated: true)
                //通知がたまらないように削除
                UNUserNotificationCenter.current()
                    .removeDeliveredNotifications(withIdentifiers: [self.uuID])
                //誤差分を記入
                
                let alert = MyAlert("残高調整","現在の残高を入力してください。")
                alert.addTextField("金額を入力")
                alert.addActions("キャンセル", type: .cancel, nil)
                alert.addActions("完了") { (me) in
                    
                    guard let trueBalance = Int(me.tFs.first!.text!) else {
                        HUD.flash(.labeledError(title: "Error", subtitle: "数値を入力してください"), delay: 1.5)
                        return
                    }
                    let adjustBalance = trueBalance - self.accountLists[row].balance
                    self.adjustBalance(account: self.accountLists[row], adjustBalance: adjustBalance)
                }
                self.present(alert.controller, animated: true, completion: nil)
                
                self.checkMoneyTableView.deselectRow(at: index, animated: true)
            }
            checkAlert.addActions("はい") { _ in
                HUD.flash(.labeledSuccess(title: "確認完了!", subtitle: "残高を更新します"))
                
                let nowAccount = self.accountLists[index.row - self.userBudget.count]
                self.checkMoneyTableView.deselectRow(at: index, animated: true)
                //通知がたまらないように削除
                UNUserNotificationCenter.current()
                    .removeDeliveredNotifications(withIdentifiers: [self.uuID])
                
                //最終確認日を更新
                let newCheck = Check()
                newCheck.balance = self.accountLists[row].balance
                nowAccount.newCheck = newCheck
                
                self.reloadData()
                
                //初期ステップ確認
                if self.accountLists[row].isMustCheck(checked: true) {
                    let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
                    tbc.setStartStep()
                }
            }
            self.present(checkAlert.controller, animated: true, completion: nil)
        }
    }
    
    //adjustBalance
    private func adjustBalance(account: Account, adjustBalance: Int) {
        
        let isMinus = adjustBalance < 0
        let string = "差額\(adjustBalance)円を\(isMinus ? "紛失" : "意外収入")として、\n登録しますか？"
        let alert = UIAlertController(title: "残高調整", message: string, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "登録する", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            let lossPayment = Payment.make()
            lossPayment.mainCategoryNumber = isMinus ? 0 : 1
            lossPayment.paymentMethod = account.name
            lossPayment.price = adjustBalance
            lossPayment.category = isMinus ? "紛失" : "意外収入"
            lossPayment.save()
            
            let newCheck = Check()
            newCheck.balance = account.balance
            account.newCheck = newCheck
            
            HUD.flash(.labeledSuccess(title: "登録成功", subtitle: "残高を更新します"), delay: 1.0)
            
            self.reloadData()
        }
        let noAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: First Step Setting

extension CheckMoneyVC: CoachMarksControllerDataSource {
    
    override func viewDidAppear(_ animated: Bool) {
        
        condition.0 = self.ud.stringArray(forKey: .startSteps)!.first == "3"
        condition.1 = self.ud.stringArray(forKey: .startSteps)!.first == "4"
            && accountLists.contains(where: {$0.isMustCheck()})
        if condition.0 || condition.1 {
            if startStepCells.count == 0 { return }
            coachController.dataSource = self
            self.coachController.start(in: .viewController(self))
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.coachController.stop(immediately: true)
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return condition.0 || condition.1 ? 1 : 0
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        return self.coachController.helper.makeCoachMark(for: startStepCells.first!.cell, pointOfInterest: nil, cutoutPathMaker: nil)
        // for: にUIViewを指定すれば、マークがそのViewに対応します
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        var text = ""
        
        if condition.0 { text += "ここをタップして、\nお小遣い設定の方法を\n見てみましょう" }
        else {
            switch startStepCells.first!.Name {
            case "①　携帯残高確認":
                text += "ここをタップして、\n残高の確認を行いましょう\nタップ後、家継簿appを閉じると\n通知により残高をお知らせします"
            case "②　本アプリ対応ICカード":
                text += "ここをタップして、\n残高の確認を行いましょう\n携帯のICカード読み取り部に\nかざして、残高を確認します"
            case "③　その他の口座":
                text += "残高確認が終わり次第、\nここをタップし、\n残高登録を行ってください"
            default: break
            }
            
        }
        
        coachViews.bodyView.hintLabel.text = text
        coachViews.bodyView.nextLabel.text = "了解" // 「次へ」などの文章
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
}

//口座タイプ編集画面のpickerViewについて
extension CheckMoneyVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    var pickerTitle: [String] {
        var titles = [String]()
        if #available(iOS 13.0, *) {
            titles = ["①　携帯残高確認", "②　本アプリ対応ICカード", "③　その他の口座"]
        } else {
            titles = ["①　携帯残高確認", "③　その他の口座"]
        }
        return titles
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0: return pickerTitle.count
        case 1: return icTypeTitles.count
        default: return 0
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 0: return pickerTitle[row]
        case 1: return icTypeTitles[row]
        default: return nil
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let tF = getCurrentTF?.first {
            tF.text = (pickerView.tag == 0 ? pickerTitle[row] : icTypeTitles[row])
        }
    }
}
