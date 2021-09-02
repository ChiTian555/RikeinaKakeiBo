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
    
    //口座タイプ変更時に表示するTextField
    var editTextField: UITextField!
    var pickerView: UIPickerView!
    
    //クレカ引き落とし登録時の締め日選択用
    var dayTextField: UITextField!
    var datePicker: UIDatePicker!
    var priceTextField: UITextField!
    
    let ud = UserDefaults.standard
    
    var budgetsLavel = [UILabel]()
    
    var sumMoney = Int()
    
    var userBudget: [String] = ["おこづかい","貯金"]
    
    var balances: [Int] = []
    
    let realm = try! Realm()
    
    var balanceList = [Int]()
    
    var uuID = String()
    
    var startStepCells = [(cell: UITableViewCell,Name: String)]()
    
    @IBOutlet var checkMoneyTableView: UITableView!
    
    var notificationCenter = NotificationCenter.default
    
    var coachController = CoachMarksController()
    //初期ステップのうむを格納
    var condition3 = false
    var condition4 = false
    
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
    
    //Cellデータ格納変数
    var accountLists: [Account] = []
    var budgetsValue: [Int] = []
    
    //tableView更新
    func reloadData() {
        accountLists = Account.readAll()
        //sum:お小遣い お小遣いの導出
        let predicate: String
            = "(mainCategoryNumber=%@ AND isUsePoketMoney=%@) OR (mainCategoryNumber=%@ AND isUsePoketMoney=%@ )"
        let sum :Int = realm.objects(Payment.self)
                            .filter(predicate,0 , true, 2, true)
                            .sum(ofProperty: "price")
        budgetsValue = [sum, accountLists.reduce(0){$0 + $1.balance} - sum]
        checkMoneyTableView.reloadData()
    }
    
}

extension CheckMoneyVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if accountLists.count < 1 {
            return userBudget.count + 1
        }
        
        //balance配列のリセット
        balances = []
        //UserButget計算に関するリセット
        budgetsLavel = []
        sumMoney = 0
        //スタートステップに関するリセット
        startStepCells = []
        
        return accountLists.count + userBudget.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var font = UIFont()
        if UserDefaults.standard.bool(forKey: .isCordMode)! {
            font = UIFont(name: "cordFont", size: 25)!
        } else {
            font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        }
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
                if ud.integer(forKey: .startStep) == 3 {
                    startStepCells.append((cell,"condition3"))
                }
            } else {
                cell.selectionStyle = .none
            }
            
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
//            if nowAccount.type.first == "④" {
//                typeLabel.text! += "\n支払: \(nowAccount.chargeAccount)"
//            }
            
            let lastCheck = nowAccount.newCheck
            let checkedMonth: String = lastCheck != nil ? "\(lastCheck!.checkDate.inDefaultRegion().month)" : "--"
            let checkedDay: String = lastCheck != nil ? "\(lastCheck!.checkDate.inDefaultRegion().day)" : "--"
            let checkedBalance: String = lastCheck != nil ? "\(lastCheck!.balance)" : "--"
            let attriStr = NSMutableAttributedString()
            let isCredit = nowAccount.type.first == "④"
            let title = isCredit ? ("最終引き落とし日","金額") : ("最終確認日","残高")
            
            if ud.bool(forKey: .isCordMode)! {
                attriStr.append(
                    NSAttributedString(string: "\(title.0): \(checkedMonth)/\(checkedDay)\n\(title.1): ")
                )
                attriStr.append(
                    NSAttributedString(string: "¥\(checkedBalance)",
                        attributes: [NSAttributedString.Key.font : UIFont(name: "cordFont", size: 20)!])
                )
            } else {
                attriStr.append(
                    NSAttributedString(string: "\(title.0): \(checkedMonth)/\(checkedDay)\n\(title.1): ¥\(checkedBalance)")
                )
            }
            checkLabel.attributedText = attriStr
//                "最終確認日: \(checkedMonth)/\(checkedDay)\n残高: ¥\(checkedBalance)"
            balances.append(nowAccount.balance)
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

extension CheckMoneyVC: UITableViewDelegate {
    
    private func moveSetting() {
        
        let alert = MyAlert("通知許可がなされていません","設定画面に移りますか？")
        alert.addActions("いいえ", type: .cancel) { _ in
            HUD.flash(.labeledError(title: "Error", subtitle: "確認できませんでした"), delay: 1.5)
        }
        alert.addActions("はい") { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        self.present(alert.contontroller, animated: true, completion: nil)
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
            myAlert.addTextField("タップして選択") { (tF) in
                self.editTextField = tF
                self.pickerView = UIPickerView()
                self.pickerView.delegate = self
                tF.inputView = self.pickerView
                let toolBar = CustomToolBar()
                let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
                let doneItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.donePicker(_:)))
                doneItem.tintColor = UIColor.orange
                toolBar.setItems([spacelItem, doneItem], animated: true)
                tF.inputAccessoryView = toolBar
            }
            myAlert.addActions("キャンセル", type: .cancel) { _ in completionHandler(false) }
            myAlert.addActions("変更", type: .destructive) { (alert) in
                if self.editTextField.text! == "" {
                    HUD.flash(.labeledError(title: "Error", subtitle: "空欄があります"), delay: 1.5) {_ in
                        self.present(alert.contontroller, animated: true, completion: nil)
                    }
                    return
                }
                
                let res = self.accountLists[row].write { (me) in me.type = self.editTextField.text! }
                if res { self.reloadData(); completionHandler(true) }
                else { HUD.flash(.error, delay: 2.0) ; completionHandler(false)}
            }
            self.present(myAlert.contontroller, animated: true, completion: nil)
        }

        let easyPay = UIContextualAction(style: .normal, title: "支払登録") { (ctxAction, view, completionHandler) in

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

    
    // cellがタップされた
    // ここが、むちゃくちゃに、長い。笑
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < userBudget.count {
            if indexPath.row == 0 {
                let myAlert = MyAlert("設定", "今月のお小遣い額を\n決定しますか？")
                myAlert.addActions("いいえ", type: .cancel, nil)
                myAlert.addActions("はい") { (alert) in
                    //今月のお小遣いをもう設定してしまってるかどうか判定
                    let d = DateInRegion()
                    let firstDate = DateInRegion(year: d.year, month: d.month, day: 1).date
                    let endDate = DateInRegion(year: d.year, month: d.month + 1, day: 1).date
                    let thisMonthCount = self.realm.objects(Payment.self)
                        .filter("mainCategoryNumber = %@ AND isUsePoketMoney = %@", 2, true)
                        .filter("date >= %@ AND date < %@", firstDate, endDate).count
                    if thisMonthCount != 0 {
                        HUD.flash(.labeledError(title: "Error",
                                                subtitle: "\(d.month)月分のお小遣いは\n既に設定済みです"),
                                  delay: 1.5); return
                    }
                    let textAlert = MyAlert("お小遣い設定", "今月のお小遣いを\n入力してください")
                    textAlert.addTextField("金額を入力")
                    textAlert.addActions("キャンセル",type: .cancel) { (alert) in
                        HUD.flash(.label("キャンセルしました"), delay: 1.5)
                        alert.contontroller.dismiss(animated: true, completion: nil)
                    }
                    textAlert.addActions("確定") { (tAlert) in
                        guard let price = Int(tAlert.textField?.text ?? "") else {
                            HUD.flash(.labeledError(title: "Error", subtitle: "入力にミスがあります"), delay: 1.0){_ in
                                self.present(tAlert.contontroller, animated: true, completion: nil)
                            }; return
                        }
                        let checkAlert = MyAlert("金額:¥\(price)", "変更できませんがいいですか？")
                        checkAlert.addActions("訂正", type: .cancel) { (alert) in
                            self.present(tAlert.contontroller, animated: true, completion: nil)
                        }
                        checkAlert.addActions("はい") { _ in
                            let payment: Payment = Payment()
                            payment.mainCategoryNumber = 2
                            payment.isUsePoketMoney = true
                            payment.price = price
                            payment.save()
                            self.reloadData()
                            HUD.flash(.labeledSuccess(title: "設定完了",
                                                      subtitle: "\(d.month)月分のお小遣いを\n入力完了しました"),
                                      delay: 1.5)
                        }
                        self.present(checkAlert.contontroller, animated: true, completion: nil)
                    }
                    self.present(textAlert.contontroller, animated: true, completion: nil)
                }
                self.present(myAlert.contontroller, animated: true, completion: nil)
            }
            //初期ステップ3->4
            if condition3 {
                self.ud.setInteger(4, forKey: .startStep)
                condition3 = false
                let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
                tbc.setStartStep()
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }

        // 残高チェックのコード
        let row = indexPath.row - userBudget.count
        let account = accountLists[row]
        
        if accountLists.count == 0 {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        
        switch account.type.first {
        case "①":
            
            if !ud.bool(forKey: .canUseNotification)! {
                checkMoneyTableView.deselectRow(at: indexPath, animated: true)
                moveSetting()
                return
            }
            let alert = MyAlert("確認モードです", "画面を閉じてください")
            alert.addActions("キャンセル", type: .cancel) { _ in
                tableView.deselectRow(at: indexPath, animated: true)
                SceneDelegate.shared.isCheckMode = false
            }
            self.present(alert.contontroller, animated: true, completion: nil)
            SceneDelegate.shared.isCheckMode = true
            break
        case "②":
            self.checkSearchIcCard(index: indexPath)
            break
        case "③":
            let checkAlert = MyAlert("残高確認", "残金は一致しましたか？")
            checkAlert.addActions("いいえ", type: .cancel) { _ in
                let alert = MyAlert("残高調整", "現在の残高を入力してください。")
                alert.addTextField("タップして入力")
                alert.addActions("キャンセル", type: .cancel, nil)
                alert.addActions("完了") { (alert) in
                    guard let trueBalance = Int(alert.textField?.text ?? "") else {
                        HUD.flash(.labeledError(title: "Error", subtitle: "数値を入力してください"), delay: 1.5)
                        return
                    }
                    let adjustBalance = trueBalance - self.accountLists[row].balance
                    self.adjustBalance(account: self.accountLists[row], adjustBalance: adjustBalance)
                }
                self.present(alert.contontroller, animated: true, completion: nil)
                self.checkMoneyTableView.deselectRow(at: indexPath, animated: true)
            }
            checkAlert.addActions("はい") { (alert) in
                HUD.flash(.labeledSuccess(title: "確認完了!", subtitle: nil), delay: 1.0)
                self.checkMoneyTableView.deselectRow(at: indexPath, animated: true)
                //最終確認日を更新
                
                HUD.flash(.labeledSuccess(title: "成功", subtitle: "残高を更新します"), delay: 1.5)
                let nowAccount = self.accountLists[indexPath.row - self.userBudget.count]
                //最終確認日を更新
                let newCheck = Check()
                newCheck.balance = self.balances[indexPath.row - self.userBudget.count]
                nowAccount.newCheck = newCheck
                self.reloadData()
                
                if account.isMustCheck(checked: true) {
                    let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
                    tbc.setStartStep()
                }
            }
            self.present(checkAlert.contontroller, animated: true, completion: nil)
            break
        case "④":
            let checkAlert = UIAlertController(title: "支払", message: "\(account.chargeAccount)から\n引き落とし登録行いますか？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "はい", style: .default) { (action) in
                checkAlert.dismiss(animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
                
                let inputAlert = UIAlertController(title: "クレジットカードの締め日", message: "本引き落としの締め日を\n入力してください。", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                    inputAlert.dismiss(animated: true, completion: nil)
                    
                    if dayTextField.text?.count == 0 {
                        HUD.flash(.labeledError(title: "空欄があります", subtitle: "日付を選択してください"), delay: 1.5)
                        return
                    }
                    
                    guard let endDate = DateInRegion(dayTextField.text!, format: "yyyy-MM-dd")?.date else {
                        HUD.flash(.labeledError(title: "エラー", subtitle: "日付入力に\nミスがあります"), delay: 1.5)
                        return
                    }
                    guard let price: Int = Int(priceTextField.text ?? "") else {
                        HUD.flash(.labeledError(title: "エラー",
                                                subtitle: "引き落とし金額に\n入力ミスがあります"),delay: 1.5)
                        return
                    }
                    //<0
                    let sum = Payment.getCreditPaymentSum(account, endDate: endDate)
                    
                    print("price:",price,"\nsum:",sum)
                    
                    if price == sum * -1 {
                        HUD.flash(.label("引き落とし金額と、家計簿の記録が一致しました。"), delay: 1.5) {_ in
                            HUD.flash(.labeledSuccess(title: "引き落とし登録完了",
                                                      subtitle: "家計簿を更新しました。。"),
                                      delay: 1.0)
                            let newPayment = Payment()
                            newPayment.mainCategoryNumber = 2
                            newPayment.price = sum * -1 //>0
                            newPayment.paymentMethod = account.name
                            newPayment.withdrawal = account.chargeAccount
                            newPayment.save()
                            let newCheck = Check()
                            newCheck.balance = sum
                            account.newCheck = newCheck
                            reloadData()
                        }
                    } else {
                        if account.newCheck == nil {
                            let message = "\(account.chargeAccount)残高から\n" +
                                "家計簿開始前の出費分\n¥\((price + sum) * -1)を除きますか?"
                            let alert = UIAlertController(title: "初回引き落とし登録",
                                                          message: message,
                                                          preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                                let newPayment = Payment()
                                newPayment.mainCategoryNumber = 2
                                newPayment.price = sum * -1
                                newPayment.paymentMethod = account.name
                                newPayment.withdrawal = account.chargeAccount
                                newPayment.save()
                                guard let charge = Account.readValue(name: account.chargeAccount) else { return }
                                charge.firstAdjustBalance(add: (price + sum) * -1)
                                let newCheck = Check()
                                newCheck.balance = sum
                                account.newCheck = newCheck
                                alert.dismiss(animated: true, completion: nil)
                                HUD.flash(.labeledSuccess(title: "引き落とし登録完了",
                                                          subtitle: "家計簿を更新しました。。"),
                                          delay: 1.0)
                                reloadData()
                            }
                            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                                alert.dismiss(animated: true, completion: nil)
                            }
                            alert.addAction(cancelAction)
                            alert.addAction(okAction)
                            HUD.flash(.label("引き落とし金額と、家計簿の記録が一致しません。"), delay: 1.5) {_ in
                                present(alert, animated: true, completion: nil)
                            }
                        } else {
                            let message = "\(account.chargeAccount)残高から\n" +
                                "家計簿未記入の出費分¥\((price + sum) * -1)を\n紛失額として登録しますか?"
                            let alert = UIAlertController(title: "初回引き落とし登録",
                                                          message: message,
                                                          preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                                let newPayment = Payment()
                                newPayment.mainCategoryNumber = 2
                                newPayment.price = sum * -1
                                newPayment.paymentMethod = account.name
                                newPayment.withdrawal = account.chargeAccount
                                newPayment.save()
                                let lostPayment = Payment()
                                lostPayment.mainCategoryNumber = 0
                                lostPayment.price = (price + sum) * -1
                                lostPayment.paymentMethod = account.chargeAccount
                                lostPayment.category = "紛失"
                                lostPayment.save()
                                let newCheck = Check()
                                newCheck.balance = sum
                                account.newCheck = newCheck
                                alert.dismiss(animated: true, completion: nil)
                                HUD.flash(.labeledSuccess(title: "引き落とし登録完了",
                                                          subtitle: "家計簿を更新しました。"),
                                          delay: 1.0)
                                reloadData()
                            }
                            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                                alert.dismiss(animated: true, completion: nil)
                            }
                            alert.addAction(cancelAction)
                            alert.addAction(okAction)
                            HUD.flash(.label("引き落とし金額と、家計簿の記録が一致しません。"), delay: 1.5) {_ in
                                present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                    inputAlert.dismiss(animated: true, completion: nil)
                }
                inputAlert.addTextField { [self] (textField) in
                    //締め日入力用のtextFieldの初期設定
                    textField.placeholder = "タップして締め日を入力"
                    self.dayTextField = textField
                    
                    let toolbar = CustomToolBar()
                    let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
                    let doneItem = UIBarButtonItem(title: "Done",
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(done(_:)))
                    let nextItem = UIBarButtonItem(title: "Next",
                                                   style: .done,
                                                   target: self,
                                                   action: #selector(next(_:)))
                    doneItem.tintColor = UIColor.orange
                    toolbar.setItems([doneItem, spacelItem, nextItem], animated: true)
                    
                    datePicker = UIDatePicker()
                    datePicker.datePickerMode = .date
                    if #available(iOS 13.4, *) {
                        datePicker.preferredDatePickerStyle = .wheels
                    }
                    datePicker.maximumDate = Date()
                    textField.inputView = datePicker
                    textField.inputAccessoryView = toolbar
                }
                inputAlert.addTextField { [self] (textField) in
                    priceTextField = textField
                    textField.placeholder = "実際の引き落し金額を入力"
                    textField.keyboardType = .numberPad
                    let toolbar = CustomToolBar()
                    let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
                    let doneItem = UIBarButtonItem(title: "Done",
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(done(_:)))
                    doneItem.tintColor = UIColor.orange
                    toolbar.setItems([spacelItem, doneItem], animated: true)
                    textField.inputAccessoryView = toolbar
                }
                inputAlert.addAction(cancelAction)
                inputAlert.addAction(okAction)
                self.present(inputAlert, animated: true, completion: nil)
                
            }
            let cancelAction = UIAlertAction(title: "いいえ", style: .cancel) { (action) in
                checkAlert.dismiss(animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
            }
            checkAlert.addAction(cancelAction)
            checkAlert.addAction(okAction)
            self.present(checkAlert, animated: true, completion: nil)
            break
        default:
            HUD.flash(.labeledError(title: "予期せぬエラー", subtitle: nil), delay: 1)
        }
    }
    
    // 決定ボタン押下
    @objc func done(_: Any) {
        
        dayTextField.resignFirstResponder()
        // 日付のフォーマット
        dayTextField.text = datePicker.date.toString(.custom("yyyy-MM-dd"))
    }
    
    @objc func next(_: Any) {
        
        priceTextField.becomeFirstResponder()
        // 日付のフォーマット
        dayTextField.text = datePicker.date.toString(.custom("yyyy-MM-dd"))
    }
    
    func checkSearchIcCard(index: IndexPath) {
        let alert = MyAlert("確認", "携帯でICカードを\nスキャンしますか？")
        alert.addActions("いいえ", type: .cancel) { _ in
            self.checkMoneyTableView.deselectRow(at: index, animated: true)
        }
        alert.addActions("はい") { _ in
            SceneDelegate.shared.isCheckMode = true
            self.searchIcCard()
            self.checkMoneyTableView.deselectRow(at: index, animated: true)
        }
        self.present(alert.contontroller, animated: true, completion: nil)
    }
    
    func searchIcCard() {
        
        //選択されてた口座の場所を取得
        guard let index = self.checkMoneyTableView.indexPathForSelectedRow else { return }
        
        let felica = NFCReader(type: .univCoopICPrepaid) { (balance,error)  in
            print("検出側から反応が返ってきた.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                // エラーのとき
                if let error = error {
                    HUD.flash(.labeledError(title: "Error", subtitle: "\(error)"), delay: 1.5) { _ in
                        let alert = MyAlert("設定", "口座タイプを[③その他の口座]に\n変更しますか？")
                        alert.addActions("いいえ", type: .cancel, nil)
                        alert.addActions("はい") { _ in
                            let nowAccount = self.accountLists[index.row - self.userBudget.count]
                            let res = nowAccount.write { (me) in me.type = "③　その他の口座" }
                            print("講座タイプ変更 status=\(res ? "succsess":"failed")")
                            
                            //初期ステップ確認
                            if self.accountLists[index.row - self.userBudget.count].isMustCheck(checked: true) {
                                let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
                                tbc.setStartStep()
                            }
                            self.reloadData()
                        }
                        self.present(alert.contontroller, animated: true , completion: nil)
                    }
                    return
                }
                // 上手く、値段が取得された。
                if balance < 0 {HUD.flash(.error, delay: 1.5); return}
                let row = index.row - self.userBudget.count
                if self.balances[row] == balance {
                    HUD.flash(.labeledSuccess(title: "成功", subtitle: "残高を更新します"))
                    let nowAccount = self.accountLists[row]
                    //最終確認日を更新
                    let newCheck = Check()
                    newCheck.balance = self.accountLists[row].balance
                    nowAccount.newCheck = newCheck
                    self.reloadData()
                } else {
                    HUD.flash(.labeledError(title: "Error", subtitle: "残高が一致しません。"), delay: 1.5) { _ in
                        let adjustBalance: Int = Int(balance) - self.accountLists[row].balance
                        self.adjustBalance(account: self.accountLists[row], adjustBalance: adjustBalance)
                    }
                }
                //初期ステップ確認
                if self.accountLists[index.row - self.userBudget.count].isMustCheck(checked: true) {
                    let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
                    tbc.setStartStep()
                }
            }
        }
        felica.start()
    }
    
    //画面を閉じるときに、通知を表示
    @objc func willResignActive() {
        if let alert = self.presentedViewController as? UIAlertController {
            if alert.title == "確認モードです" {
                print("alertを表示させたい")
                var account = String()
                var accountBudged = String()
                if let indexPath = self.checkMoneyTableView.indexPathForSelectedRow {
                    account = accountLists[indexPath.row - userBudget.count].name
                    accountBudged = "¥\(balances[indexPath.row - userBudget.count])"
                }
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
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    //            UNUserNotificationCenter.current().setNotificationCategories([notificationCategory])
                UNUserNotificationCenter.current().add(request) { (error) in
                    print(error?.localizedDescription)
                }
                
            }
        }
    }
    
    @objc func becameActive() {
        print("Activeになった、が呼ばれた")
        if let alert = self.presentedViewController as? UIAlertController {
            alert.dismiss(animated: true, completion: nil)
            
            //選択されてた口座の場所を取得
            guard let index = self.checkMoneyTableView.indexPathForSelectedRow else { return }
            let row = index.row - self.userBudget.count
            let checkAlert = UIAlertController(title: "残高確認", message: "残金は一致しましたか？", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "はい", style: .default) { (action) in
                checkAlert.dismiss(animated: true, completion: nil)
                HUD.flash(.labeledSuccess(title: "確認完了!", subtitle: "残高を更新します"), delay: 1.0)
                
                let nowAccount = self.accountLists[index.row - self.userBudget.count]
                self.checkMoneyTableView.deselectRow(at: index, animated: true)
                //通知がたまらないように削除
                UNUserNotificationCenter.current()
                    .removeDeliveredNotifications(withIdentifiers: [self.uuID])
                
                //最終確認日を更新
                let newCheck = Check()
                newCheck.balance = self.balances[row]
                nowAccount.newCheck = newCheck
                
                self.reloadData()
                
                //初期ステップ確認
                if self.accountLists[index.row - self.userBudget.count].isMustCheck(checked: true) {
                    let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
                    tbc.setStartStep()
                }
            }
            let noAction = UIAlertAction(title: "いいえ", style: .cancel) { (action) in
                checkAlert.dismiss(animated: true, completion: nil)
                self.checkMoneyTableView.deselectRow(at: index, animated: true)
                //通知がたまらないように削除
                UNUserNotificationCenter.current()
                .removeDeliveredNotifications(withIdentifiers: [self.uuID])
                //誤差分を記入
                
                let alert = UIAlertController(title: "残高調整", message: "現在の残高を入力してください。", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "完了", style: .default) { (action) in
                    
                    alert.dismiss(animated: true, completion: nil)
                    guard let trueBalance = Int(alert.textFields!.first!.text!) else {
                        HUD.flash(.labeledError(title: "Error", subtitle: "数値を入力してください"), delay: 1.5)
                        return
                    }
                    let adjustBalance = trueBalance - self.accountLists[row].balance
                    self.adjustBalance(account: self.accountLists[row], adjustBalance: adjustBalance)
                }
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }
                
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                alert.addTextField { (textField) in
                    textField.keyboardType = .numberPad
                }
                self.present(alert, animated: true, completion: nil)
                
                self.checkMoneyTableView.deselectRow(at: index, animated: true)
                
            }
            checkAlert.addAction(noAction)
            checkAlert.addAction(yesAction)
            self.present(checkAlert, animated: true, completion: nil)
        }
    }
    
    //adjustBalance
    private func adjustBalance(account: Account, adjustBalance: Int) {
        
        let isMinus = adjustBalance < 0
        let string = "差額\(adjustBalance)円を\(isMinus ? "紛失" : "意外収入")として、\n登録しますか？"
        let alert = UIAlertController(title: "残高調整", message: string, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "登録する", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            let lossPayment = Payment()
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

extension CheckMoneyVC: CoachMarksControllerDataSource {
    
    override func viewDidAppear(_ animated: Bool) {
        
        condition3 = self.ud.integer(forKey: .startStep) == 3
        condition4 = self.ud.integer(forKey: .startStep) == 4
            && accountLists.contains(where: {$0.isMustCheck()})
        if condition3 || condition4 {
            if startStepCells.count == 0 { return }
            coachController.dataSource = self
            self.coachController.start(in: .viewController(self))
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.coachController.stop(immediately: true)
    }

    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return condition3 || condition4 ? 1 : 0
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        return self.coachController.helper.makeCoachMark(for: startStepCells.first!.cell, pointOfInterest: nil, cutoutPathMaker: nil)
        // for: にUIViewを指定すれば、マークがそのViewに対応します
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        var text = ""
        
        if condition3 {
            text += "ここをタップして、\nお小遣い設定の方法を\n見てみましょう"
        } else {
            switch startStepCells.first!.Name {
            case "①　携帯残高確認":
                text += "ここをタップして、\n残高の確認を行いましょう\nタップ後、家継簿appを閉じると\n通知により残高をお知らせします"
            case "②　本アプリ対応ICカード":
                text += "ここをタップして、\n残高の確認を行いましょう\n携帯のICカード読み取り部に\nかざして、残高を確認します"
            case "③　その他の口座":
                text += "残高確認が終わり次第、\nここをタップし、\n残高登録を行ってください"
            default:
                break
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
        return pickerTitle.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerTitle[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        editTextField.text = pickerTitle[row]
    }
    
//    @objc func cancelPicker() {
//
//    }
    
    @objc func donePicker(_ sender: UIBarButtonItem) {
        editTextField.text = pickerTitle[pickerView.selectedRow(inComponent: 0)]
        editTextField.resignFirstResponder()
    }
    
    
}
