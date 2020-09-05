//
//  CheckMoneyViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/29.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import PKHUD
import UserNotifications

//public enum NotificationActionID: String {
//    case repry
//    case cancel
//}
//
//    /// 通知開封時のデリゲート
//    ///
//    /// - parameter center:            NotificationCenter
//    /// - parameter response:          Notification
//    /// - parameter completionHandler: Handler
//internal func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: () -> Void) {
//
//        switch response.actionIdentifier {
//        case NotificationActionID.repry.rawValue: ()
//            /* 返信処理 */
//        case NotificationActionID.cancel.rawValue: ()
//            /* キャンセル処理 */
//        default:
//            ()
//        }
//
//        debugPrint("opened")
//        completionHandler()
//    }

class CheckMoneyViewController: UIViewController {

    var accountLists = [[String]]()
    
    var userBudget: [(name: String, budget: Int)] = [
        ("おこづかい",0),
        ("貯金",0)
    ]
    
    let realm = try! Realm()
    
    var balanceList = [Int]()
    
    var uuID = String()
    
    @IBOutlet var checkMoneyTableView: UITableView!
    
    var notificationCenter: NotificationCenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notificationCenter = NotificationCenter.default
        checkMoneyTableView.estimatedRowHeight = 40
        checkMoneyTableView.rowHeight = UITableView.automaticDimension
        checkMoneyTableView.dataSource = self
        checkMoneyTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        accountLists = UserDefaults.standard.stringArray2(forKey: .account)!
        checkMoneyTableView.reloadData()
    }
    
    func calculateBalance(row i: Int) -> String {
            
        let sum: Int = realm.objects(Payment.self)
        .filter("paymentMethod == '\(accountLists[i].first!)'")
        .sum(ofProperty: "price")
//        .filter("date >= %@ AND date < %@", firstDate, endDate)
        let firstBalance = Int(accountLists[i].last!)!
        return String(sum + firstBalance)
        
    }
}

extension CheckMoneyViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if accountLists[0] == [] {
            return 0
        }
        return accountLists.count + userBudget.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var font = UIFont()
        if UserDefaults.standard.bool(forKey: .isCordMode)! {
            font = UIFont(name: "cordFont", size: 25)!
        } else {
            font = UIFont.systemFont(ofSize: 17, weight: .regular)
        }
        if indexPath.row < userBudget.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1")!
            let labelName = cell.viewWithTag(1) as! UILabel
            let labelBudge = cell.viewWithTag(2) as! UILabel
            labelName.text = userBudget[indexPath.row].name
            labelBudge.font = font
            labelBudge.text = "¥ \(userBudget[indexPath.row].budget)"
            
            cell.selectionStyle = .none
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2")!
            let label = cell.viewWithTag(1) as! UILabel
            cell.textLabel?.text = accountLists[indexPath.row - userBudget.count].first!
            label.font = font
            label.text = "¥" + calculateBalance(row: indexPath.row - userBudget.count)
            
            let selectionView = UIView()
            //タップするとオレンジ色になる
            selectionView.backgroundColor = .systemOrange
            cell.selectedBackgroundView = selectionView
            
            return cell
        }
    }
}

extension CheckMoneyViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row < userBudget.count { return }
        UserDefaults.standard.setBool(true, forKey: .isCheckMode)
        
        notificationCenter.addObserver(self, selector: #selector(willResignActive),
                                       name: UIApplication.willResignActiveNotification,
                                       object: nil)
        notificationCenter.addObserver(self, selector: #selector(becameActive),
                                       name: UIApplication.didBecomeActiveNotification,
                                       object: nil)
        
        let alert = UIAlertController(title: "確認モードです", message: "画面を閉じてください", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { (action) in
            UserDefaults.standard.setBool(false, forKey: .isCheckMode)
            self.notificationCenter.removeObserver(self)
            alert.dismiss(animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //画面を閉じるときに、通知を表示
    @objc func willResignActive() {
        if UserDefaults.standard.bool(forKey: .isCheckMode)! {
            var account = String()
            var accountBudged = String()
            if let indexPath = self.checkMoneyTableView.indexPathForSelectedRow {
                account = accountLists[indexPath.row - userBudget.count].first!
                accountBudged = "¥" + calculateBalance(row: indexPath.row - userBudget.count)
            }
            let content = UNMutableNotificationContent()
            content.title = "確認モード"
            content.body = "\(account)の残高は\(accountBudged)でした。\n確認ください"
            content.sound = UNNotificationSound.default
            
//            let repry = UNNotificationAction(identifier: AppDelegate.NotificationActionID.repry.rawValue,
//                                             title: "返信", options: [])
//
//            let cancel = UNNotificationAction(identifier: AppDelegate.NotificationActionID.cancel.rawValue,
//                                              title: "キャンセル", options: [])
//            let notificationCategory = UNNotificationCategory(identifier: "message", actions: [repry, cancel],
//                                                  intentIdentifiers: [], options: [])
            
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
            
            let checkAlert = UIAlertController(title: "残高確認", message: "残金は一致しましたか？", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "はい", style: .default) { (action) in
                checkAlert.dismiss(animated: true, completion: nil)
                HUD.flash(.labeledSuccess(title: "確認完了!", subtitle: nil), delay: 1.0)
                if let index = self.checkMoneyTableView.indexPathForSelectedRow {
                    self.checkMoneyTableView.deselectRow(at: index, animated: true)
                }
                UNUserNotificationCenter.current()
                    .removeDeliveredNotifications(withIdentifiers: [self.uuID])
                
                //最終確認日を更新
                
            }
            let noAction = UIAlertAction(title: "いいえ", style: .cancel) { (action) in
                checkAlert.dismiss(animated: true, completion: nil)
            }
            checkAlert.addAction(noAction)
            checkAlert.addAction(yesAction)
            self.present(checkAlert, animated: true, completion: nil)
        }
        notificationCenter.removeObserver(self)
    }
    
}
