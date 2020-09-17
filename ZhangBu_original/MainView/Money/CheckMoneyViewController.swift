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
import NFCReader
import SwiftDate

class CheckMoneyViewController: MainBaceVC {
    
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
    
    //NFCReaderの定義
    private let configuration: ReaderConfiguration = {
        var configuration = ReaderConfiguration()
        configuration.message.alert = "携帯の読み取り部を、\nICカードにかざしてください。"
        return configuration
    }()
    
    private let reader = Reader<FeliCa>()
    
    
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
    var budgetsValue:[Int] = []
    
    //tableView更新
    func reloadData() {
        accountLists = Account.readAll()
        let predicate: String
            = "(mainCategoryNumber = %@ AND isUsePoketMoney = %@) OR (mainCategoryNumber = %@ AND isUsePoketMoney = %@ )"
        let sum :Int = realm.objects(Payment.self)
                            .filter(predicate,0 , true, 2, true)
                            .sum(ofProperty: "price")
        budgetsValue = [sum, accountLists.reduce(0){$0 + $1.balance} - sum]
        checkMoneyTableView.reloadData()
    }
    
}

extension CheckMoneyViewController: UITableViewDataSource {
    
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
        var cell = UITableViewCell.create()
        if indexPath.row < userBudget.count {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell1")!
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
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell2")!
            let nameLabel = cell.viewWithTag(1) as! UILabel
            let balanceLabel = cell.viewWithTag(2) as! UILabel
            let typeLabel = cell.viewWithTag(3) as! UILabel
            let checkLabel = cell.viewWithTag(4) as! UILabel
            balanceLabel.font = font
            let nowAccount =  accountLists[indexPath.row - userBudget.count]
            nameLabel.text = nowAccount.name
            typeLabel.text = nowAccount.type
            let lastCheck = nowAccount.getNewCheck()
            let checkedMonth: String = lastCheck != nil ? "\(lastCheck!.checkDate.inDefaultRegion().month)" : "--"
            let checkedDay: String = lastCheck != nil ? "\(lastCheck!.checkDate.inDefaultRegion().day)" : "--"
            let checkedBalance: String = lastCheck != nil ? "\(lastCheck!.balance)" : "--"
            checkLabel.text =
                "最終確認日: \(checkedMonth)/\(checkedDay)\n残高: ¥\(checkedBalance)"
            balances.append(nowAccount.balance)
            balanceLabel.textColor = nowAccount.balance < 0 ? .systemRed : .label
            balanceLabel.text = "¥\(nowAccount.balance)"
            balanceLabel.textAlignment = .right
            if nowAccount.isMustCheck() {
                startStepCells.append((cell, nowAccount.type))
            }
            
        } else {
            //まだ口座登録されてない時
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell3")!
            let label = cell.viewWithTag(1) as! UILabel
            label.textAlignment = .center
            label.text = "まだ、口座が登録されていません！\n設定->口座管理から、まず、\n現金を登録してみてください。"
        }
        
        return cell.set()
    }
}

extension CheckMoneyViewController: UITableViewDelegate {
    
    private func checkMoveSetting() {
        
        let alert = UIAlertController(title: "通知許可がなされていません", message: "設定画面に移りますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            // OSの通知設定画面へ遷移
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "いいえ", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
            HUD.flash(.labeledError(title: "Error", subtitle: "確認できませんでした"), delay: 1.5)
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //cellがタップされた
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < userBudget.count {
            
            if indexPath.row == 0 {
                let alert = UIAlertController(title: "設定", message: "今月のお小遣い額を\n決定しますか？", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "はい", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    
                    //今月のお小遣いをもう設定してしまってるかどうか判定
                    let year = DateInRegion().year
                    let month = DateInRegion().month
                    let firstDate = DateInRegion(year: year, month: month, day: 1).date
                    let endDate = DateInRegion(year: year, month: month + 1, day: 1).date
                    print(DateInRegion().year,DateInRegion().month)
                    let thisMonthCount = self.realm.objects(Payment.self)
                        .filter("mainCategoryNumber = %@ AND isUsePoketMoney = %@", 2, true)
                        .filter("date >= %@ AND date < %@", firstDate, endDate).count
                    
                    if thisMonthCount != 0 {
                        HUD.flash(.labeledError(title: "Error", subtitle: "\(month)月分のお小遣いは\n既に設定済みです"), delay: 1.5)
                        return
                    }
                    
                    let textAlert = UIAlertController(title: "お小遣い設定", message: "今月のお小遣いを\n入力してください", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                        HUD.flash(.label("キャンセルしました"), delay: 1.5)
                        textAlert.dismiss(animated: true, completion: nil)
                    }
                    let okAction = UIAlertAction(title: "確定", style: .default) { (action) in
                        guard let price = Int((textAlert.textFields?.first?.text)!) else {
                            HUD.flash(.labeledError(title: "Error", subtitle: "入力にミスがあります"), delay: 1.0){_ in
                                self.present(textAlert, animated: true, completion: nil)
                            }
                            return
                        }
                        textAlert.dismiss(animated: true, completion: nil)
                        let checkAlert = UIAlertController(title: "金額:¥\(price)", message: "変更できませんがいいですか？", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "はい", style: .default) { (action) in
                            checkAlert.dismiss(animated: true, completion: nil)
                            let payment: Payment = Payment.create()
                            payment.mainCategoryNumber = 2
                            payment.isUsePoketMoney = true
                            payment.price = price
                            payment.save()
                            self.reloadData()
                            HUD.flash(.labeledSuccess(title: "設定完了", subtitle: "\(month)月分のお小遣いを\n入力完了しました"), delay: 1.5)
                        }
                        let cancelAction = UIAlertAction(title: "訂正", style: .cancel) { (action) in
                            checkAlert.dismiss(animated: true, completion: nil)
                            self.present(textAlert, animated: true, completion: nil)
                        }
                        checkAlert.addAction(cancelAction)
                        checkAlert.addAction(okAction)
                        self.present(checkAlert, animated: true, completion: nil)
                    }
                    
                    textAlert.addAction(cancelAction)
                    textAlert.addAction(okAction)
                    textAlert.addTextField { (textField) in
                        textField.placeholder = "金額を入力"
                        textField.keyboardType = .numberPad
                    }
                    self.present(textAlert, animated: true, completion: nil)
                    
                }
                let cancelAction = UIAlertAction(title: "いいえ", style: .cancel) { (acrtion) in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
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

        let row = indexPath.row - userBudget.count
        switch accountLists[row].type {
        case "①　携帯残高確認":
            
            if !ud.bool(forKey: .canUseNotification)! {
                checkMoneyTableView.deselectRow(at: indexPath, animated: true)
                checkMoveSetting()
                return
            }
            
            ud.setBool(true, forKey: .isCheckMode)
            let alert = UIAlertController(title: "確認モードです",
                                          message: "画面を閉じてください",
                                          preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { (action) in
                SceneDelegate.shared.isCheckMode = true
    //            self.notificationCenter.removeObserver(self)
                alert.dismiss(animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
            }
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            break
        case "②　本アプリ対応ICカード":
            self.checkSearchIcCard(index: indexPath)
            break
        case "③　その他の口座":
            let checkAlert = UIAlertController(title: "残高確認", message: "残金は一致しましたか？", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "はい", style: .default) { (action) in
                checkAlert.dismiss(animated: true, completion: nil)
                HUD.flash(.labeledSuccess(title: "確認完了!", subtitle: nil), delay: 1.0)
                self.checkMoneyTableView.deselectRow(at: indexPath, animated: true)
                //最終確認日を更新
                
                HUD.flash(.labeledSuccess(title: "成功", subtitle: "残高を更新します"), delay: 1.5)
                let nowAccount = self.accountLists[indexPath.row - self.userBudget.count]
                //最終確認日を更新
                let newCheck = Check()
                newCheck.balance = self.balances[indexPath.row - self.userBudget.count]
                nowAccount.setValue(newCheckValue: newCheck)
                self.reloadData()
                
                if self.accountLists[row].isMustCheck(checked: true) {
                    let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
                    tbc.setStartStep()
                }
            }
            let noAction = UIAlertAction(title: "いいえ", style: .cancel) { (action) in
                checkAlert.dismiss(animated: true, completion: nil)
                self.checkMoneyTableView.deselectRow(at: indexPath, animated: true)
            }
            checkAlert.addAction(noAction)
            checkAlert.addAction(yesAction)
            self.present(checkAlert, animated: true, completion: nil)
            break
        default:
            HUD.flash(.labeledError(title: "予期せぬエラー", subtitle: nil), delay: 1)
        }
    }
    
    
    func checkSearchIcCard(index: IndexPath) {
        let alert = UIAlertController(title: "確認", message: "携帯でICカードを\nスキャンしますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: .default) { (action) in
            SceneDelegate.shared.isCheckMode = true
            self.searchIcCard()
            self.checkMoneyTableView.deselectRow(at: index, animated: true)
            alert.dismiss(animated: true, completion: nil)
        }
        let noAction = UIAlertAction(title: "いいえ", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.checkMoneyTableView.deselectRow(at: index, animated: true)
        }
        alert.addAction(noAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func searchIcCard() {
        
        //選択されてた口座の場所を取得
        guard let index = self.checkMoneyTableView.indexPathForSelectedRow else { return }
        
        reader.configuration = self.configuration
        reader.read(didBecomeActive: { _ in
            print("reader: セット完了")
        }, didDetect: { reader, result in
            print("検出側から反応が返ってきた.")
            print(reader)
            switch result {
            case .success(let tag):
                let balance: UInt
                var cardName = ""
                switch tag {
                case .edy(let edy):
                    cardName = "edy"
                    balance = UInt(edy.histories.first?.balance ?? 0)
                case .nanaco(let nanaco):
                    cardName = "nanaco"
                    balance = UInt(nanaco.histories.first?.balance ?? 0)
                case .waon(let waon):
                    cardName = "waon"
                    balance = UInt(waon.histories.first?.balance ?? 0)
                case .suica(let suica):
                    cardName = "交通系"
                    balance = UInt(suica.boardingHistories.first?.balance ?? 0)
                }
                reader.setMessage("\(cardName): 残高は¥\(balance)でした")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    
                    if self.balances[index.row - self.userBudget.count] == Int(balance) {
                        HUD.flash(.labeledSuccess(title: "成功", subtitle: "残高を更新します"), delay: 1.5)
                        guard let index = self.checkMoneyTableView.indexPathForSelectedRow else { return }
                        let nowAccount = self.accountLists[index.row - self.userBudget.count]
                        //最終確認日を更新
                        let newCheck = Check()
                        newCheck.balance = self.balances[index.row - self.userBudget.count]
                        nowAccount.setValue(newCheckValue: newCheck)
                        self.reloadData()
                    } else {
                        HUD.flash(.labeledError(title: "Error", subtitle: "残高が一致しません。"), delay: 1.5)
                    }
                    //初期ステップ確認
                    if self.accountLists[index.row - self.userBudget.count].isMustCheck(checked: true) {
                        let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
                        tbc.setStartStep()
                    }
                    
                }
                
            case .failure(let error):
                print(error)
                var errorMessage = ""
                switch error {
                case .notSupported:
                    HUD.flash(.labeledError(title: "Error", subtitle: "\(error)"), delay: 1.5) {_ in
                        let alert = UIAlertController(title: "設定", message: "口座タイプを[③その他の口座]に\n変更しますか？", preferredStyle: .alert)
                        let okAlert = UIAlertAction(title: "はい", style: .default) { (action) in
                            alert.dismiss(animated: true , completion: nil)
                            let nowAccount = self.accountLists[index.row - self.userBudget.count]
                            let newAccount = Account()
                            newAccount.type = "③　その他の口座"
                            nowAccount.setValue(newCheckValue: nil, newAccout: newAccount)
                            
                            //初期ステップ確認
                            if self.accountLists[index.row - self.userBudget.count].isMustCheck(checked: true) {
                                let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
                                tbc.setStartStep()
                            }
                            self.reloadData()
                        }
                        let cancelAction = UIAlertAction(title: "いいえ", style: .cancel) { (action) in
                            alert.dismiss(animated: true , completion: nil)
                        }
                        alert.addAction(cancelAction)
                        alert.addAction(okAlert)
                        self.present(alert, animated: true , completion: nil)
                    }
                    break
                case .readTagFailure(let error2):
                    errorMessage = "readTagFailure"
                    print("\(error2)")
                    break
                case .scanFailure(let nfcError):
                    errorMessage = "scanFailure"
                    print(nfcError)
                    break
                case .tagConnectionFailure(let nfcError):
                    errorMessage = "tagConnectionFailure"
                    print(nfcError)
                }
                reader.setMessage("読み込みエラー: \(errorMessage)")
            }
            self.checkMoneyTableView.deselectRow(at: index, animated: true)
        })
    }
    
    //画面を閉じるときに、通知を表示
    @objc func willResignActive() {
        if UserDefaults.standard.bool(forKey: .isCheckMode)! {
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
            let identifier = NSUUID().uuidString
            uuID = identifier
            
            // 直ぐに通知を表示
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//            UNUserNotificationCenter.current().setNotificationCategories([notificationCategory])
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    @objc func becameActive() {
        
        if let alert = self.presentedViewController as? UIAlertController {
            alert.dismiss(animated: true, completion: nil)
            
            //選択されてた口座の場所を取得
            guard let index = self.checkMoneyTableView.indexPathForSelectedRow else { return }
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
                newCheck.balance = self.balances[index.row - self.userBudget.count]
                nowAccount.setValue(newCheckValue: newCheck)
                
                print("Activeになった、が呼ばれた")
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
                
            }
            checkAlert.addAction(noAction)
            checkAlert.addAction(yesAction)
            self.present(checkAlert, animated: true, completion: nil)
        }
//        notificationCenter.removeObserver(self)
    }
    
//    //編集モード切り替え
//    @IBAction func tappedEditButton() {
//        checkMoneyTableView.isEditing = !checkMoneyTableView.isEditing
//    }
//    //テーブルビューの並び替えモード
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if [0,1].contains( indexPath.row ) { return false }
//        return true
//    }
//    
//    //編集モード時の左のマークを選択
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .none
//    }
//    
//    //編集モード時に左を開けない
//    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//    
//    //列の入れ替え
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let sourceRow = sourceIndexPath.row - userBudget.count
//        let destinationRow = destinationIndexPath.row - userBudget.count
//        let source = accountLists.remove(at: sourceRow)
//        accountLists.insert(source, at: destinationRow)
//        if !Account.moveAccount(source, accountLists[destinationRow]) {
//            HUD.flash(.error, delay: 1.5)
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
//        if proposedDestinationIndexPath.row < userBudget.count {
//            return sourceIndexPath
//        }
//        return proposedDestinationIndexPath
//    }
    
    
}

extension CheckMoneyViewController: CoachMarksControllerDataSource {
    
    override func viewDidAppear(_ animated: Bool) {
        condition3 = self.ud.integer(forKey: .startStep) == 3
        condition4 = self.ud.integer(forKey: .startStep) == 4
            && accountLists.contains(where: {$0.isMustCheck()})
        if condition3 || condition4 {
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
