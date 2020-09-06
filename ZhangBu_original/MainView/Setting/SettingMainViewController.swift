//
//  SettingMainViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/20.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import PKHUD
import MessageUI

class SettingMainViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        if let tabBarVC = self.tabBarController {
            tabBarVC.tabBar.isHidden = false
        }
    }
    
    let ud = UserDefaults.standard
    
    let checkTextField = UITextField()
    
    var cellSwitchs = [UISwitch]()
    
    let titleArray: [(name:String ,cellTipe: Int)] = [
        
        ("支払い方法の追加", 1),
        ("暗号モード", 2),
        ("パスワードの設定", 1),
        ("作成者に意見を送信", 1),
        ("定期的な出費の登録(β版未対応)", 0),
        ("チュートリアル(β版未対応)", 0),
        ("背景画像とテーマ色の変更(β版未対応)", 0)
    
    ]

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toIndividual" {
            let vc = segue.destination as! IndividualSettingViewController
            let selectedRow = sender as? Int
            vc.settingArray = titleArray
            vc.settingNomber = selectedRow
        }
    }
    
    @objc func switchTapped(_ sender: UISwitch){
        
        if sender.isOn {
            let alert = UIAlertController(title: "暗号の確認", message: nil, preferredStyle: .alert)
            
            let cordFont = UIFont(name: "cordFont", size: 27)!
            let systemFont = UIFont.systemFont(ofSize: 13, weight: .light)

            let numbers: [Int] = Array(0...9).shuffled()[0..<5] + []
            var checkNumber = ""
            
            numbers.forEach({ checkNumber += String($0) })
            
            let attrStrings = NSMutableAttributedString()
            attrStrings.append(NSAttributedString(string: "\n" + checkNumber, attributes: [NSAttributedString.Key.font : cordFont]))
            attrStrings.append(NSAttributedString(string: "\n\nを数字に直してください", attributes: [NSAttributedString.Key.font : systemFont]))
            alert.setValue(attrStrings, forKey: "attributedMessage")
            
            alert.addTextField { (textField) in
                textField.placeholder = "ここに入力してください"
                textField.keyboardType = .numberPad
            }
            
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
                if alert.textFields?.first?.text == checkNumber {
                    HUD.flash(.labeledSuccess(title: "成功",
                                              subtitle: "暗号モードに変更しました。")
                        ,delay: 1.0)
                    self.ud.setBool(true, forKey: .isCordMode)
                } else {
                    HUD.flash(.labeledError(title: "一致しません",
                                            subtitle: "通常モードに戻します")
                        ,delay: 1.0)
                    sender.setOn(false, animated: true)
                }
            }
            
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            ud.setBool(false, forKey: .isCordMode)
        }
        
    }
    
}

extension SettingMainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if titleArray[indexPath.row].cellTipe == 1 {
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "toIndividual", sender: indexPath.row)
            } else if titleArray[indexPath.row].name == "パスワードの設定" {
                self.performSegue(withIdentifier: "toEditPasscode", sender: indexPath.row)
            } else if titleArray[indexPath.row].name == "作成者に意見を送信" {
                sendEmail()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func sendEmail() {
        //メールを送信できるかチェック
        if MFMailComposeViewController.canSendMail() == false {
            HUD.flash(.labeledError(title: "Error", subtitle: "メールが送信できません"), delay: 1)
            return
        }
        let mailViewController = MFMailComposeViewController()
        let toRecipients = ["rikei.no.kakeibo.developper@gmail.com"] //Toのアドレス指定
//        var CcRecipients = ["cc@1gmail.com","Cc2@1gmail.com"] //Ccのアドレス指定
//        var BccRecipients = ["Bcc@1gmail.com","Bcc2@1gmail.com"] //Bccのアドレス指定

        mailViewController.mailComposeDelegate = self
        mailViewController.setSubject("意見,アドバイスを送信")
        mailViewController.setToRecipients(toRecipients) //Toアドレスの表示
//        mailViewController.setCcRecipients(CcRecipients) //Ccアドレスの表示
//        mailViewController.setBccRecipients(BccRecipients) //Bccアドレスの表示
        mailViewController.setMessageBody("↓↓意見を下に入力ください↓↓", isHTML: false)
        self.present(mailViewController, animated: true, completion: nil)
    }
    
}

extension SettingMainViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            HUD.flash(.label("キャンセルします"), delay: 1)
            break
        case .saved:
            HUD.flash(.label("下書きに保存しました"), delay: 1)
            break
        case .sent:
            HUD.flash(.labeledSuccess(title: "送信成功しました", subtitle: "貴重な意見を\nありがとうございます！"), delay: 1)
            break
        case .failed:
            HUD.flash(.labeledError(title: "Error", subtitle: "送信失敗しました"), delay: 1)
            break
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
}

extension SettingMainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titleTaple = titleArray[indexPath.row]
        var cell = UITableViewCell()
        switch titleTaple.cellTipe {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell1")!
            cell.backgroundColor = .systemGray
            cell.selectionStyle = .none
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell1")!
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell2")!
            cell.selectionStyle = .none
            let cellSwitch = cell.viewWithTag(1) as! UISwitch
            if ud.bool(forKey: .isCordMode)! {
                cellSwitch.setOn(true, animated: false)
            } else {
                cellSwitch.setOn(false, animated: false)
            }
            cellSwitch.addTarget(self, action: #selector(self.switchTapped(_:)), for: UIControl.Event.valueChanged)
            cellSwitchs.append(cellSwitch)
        default: break
        }
        cell.textLabel?.text = titleTaple.name
        return cell
    }
    
}

//extension SettingMainViewController: CoachMarksControllerDataSource {
//
//    let coachMarksController = CoachMarksController()
//
//    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
//        return 1
//    }
//
//}


