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
import CropViewController
import Instructions

class MainSettingVC: MainBaceVC, UIViewControllerTransitioningDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.set()
        tableView.reloadData()
        if let tabBarVC = self.tabBarController {
            tabBarVC.tabBar.isHidden = false
        }
    }
    
    let ud = UserDefaults.standard
    
    let checkTextField = UITextField()
    
    var cellSwitchs = [UISwitch]()
    
    var sliderV = UIView()
    let slider = UISlider()
    let sliderLabel = UILabel()
    
    //type: 0 -> 未対応, 1 -> Action, 2 -> Switch, 3 -> toAdvance
    let titleArray: [(name:String ,cellType: Int)] = [
        
        ("口座管理", 1),
        ("暗号モード", 2),
        ("パスワードの設定", 1),
        ("背景画像とテーマ色", 3),
        ("作成者に意見を送信", 1),
        ("家計簿のヒント", 1),
        ("バックアップ", 1),
//        ("定期的な出費の登録(β版未対応)", 0)
        
    ]

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let selectedRow = sender as? Int else { return }
        switch segue.identifier {
        case "toIndividual":
            let vc = segue.destination as! AccountSettingVC
            vc.settingArray = titleArray
            vc.settingNomber = selectedRow
        case "toAdvance":
            let vc = segue.destination as! AdvancedSettingVC
            vc.titleText = titleArray[selectedRow].name
            print(titleArray[selectedRow].name)
        default: break
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
    
    private func sendEmail() {
        //メールを送信できるかチェック
        if MFMailComposeViewController.canSendMail() == false {
            HUD.flash(.labeledError(title: "Error", subtitle: "メールが送信できません"), delay: 1)
            return
        }
        let mailViewController = MFMailComposeViewController()
        let toRecipients = ["rikei.no.kakeibo.developper@gmail.com"] //Toのアドレス指定

        mailViewController.mailComposeDelegate = self
        mailViewController.setSubject("意見,アドバイスを送信")
        mailViewController.setToRecipients(toRecipients) //Toアドレスの表示
        
        mailViewController.setMessageBody("↓↓意見を下に入力ください↓↓\n", isHTML: false)
        self.present(mailViewController, animated: true, completion: nil)
    }
}

extension MainSettingVC: MFMailComposeViewControllerDelegate {
    
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

extension MainSettingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate  {

    func pickUpPicture(){
        let picker = UIImagePickerController() //アルバムを開く処理を呼び出す
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
        
    func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        SceneDelegate.shared.rootVC.picture = image
        UserDefaults.standard.setImage(image, forKey: .backGraundPicture)
        cropViewController.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        var image = info[.originalImage] as! UIImage
        guard let pickerImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        
        let cropController = CropViewController(croppingStyle: .default, image: pickerImage)
        cropController.delegate = self
        //サイズ指定！
        cropController.customAspectRatio = view.bounds.size
        
        //今回は使わないボタン等を非表示にする。
        cropController.aspectRatioPickerButtonHidden = true
        cropController.resetAspectRatioEnabled = false
        cropController.rotateButtonsHidden = true
        
        //cropBoxのサイズを固定する。
        cropController.cropView.cropBoxResizeEnabled = false
        //pickerを閉じたら、cropControllerを表示する。
        picker.dismiss(animated: true) {
            self.present(cropController, animated: true, completion: nil)
        }
    }
    
}

extension MainSettingVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titleTaple = titleArray[indexPath.row]
        var cell: UITableViewCell!
        switch titleTaple.cellType {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell1")!.create()
            cell.backgroundColor = .systemGray
            cell.selectionStyle = .none
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell1")!.create()
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell2")!.create()
            cell.selectionStyle = .none
            let cellSwitch = cell.viewWithTag(1) as! UISwitch
            if ud.bool(forKey: .isCordMode) {
                cellSwitch.setOn(true, animated: false)
            } else {
                cellSwitch.setOn(false, animated: false)
            }
            cellSwitch.addTarget(self, action: #selector(self.switchTapped(_:)), for: UIControl.Event.valueChanged)
            cellSwitchs.append(cellSwitch)

            
        default:
            cell = UITableViewCell().create()
        }
        cell.textLabel?.text = titleTaple.name
        //初回起動時にラベルを表示
        if indexPath.row == 0 {
            let startStepLabel = cell.viewWithTag(2) as! UILabel
            if ud.stringArray(forKey: .startSteps)!.first == "0" {
                startStepLabel.textAlignment = .center
                startStepLabel.text = "New"
                startStepLabel.backgroundColor = .systemRed
                startStepLabel.textColor = .white
                startStepLabel.layer.cornerRadius = startStepLabel.layer.bounds.height / 2
                startStepLabel.clipsToBounds = true
            } else {
                let startStepLabel = cell.viewWithTag(2) as! UILabel
                startStepLabel.text = ""
                startStepLabel.backgroundColor = .clear
            }
        }
        return cell.set()
    }
    
    //CGRectを簡単に作る
    private func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
}

extension MainSettingVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = titleArray[indexPath.row]
        if title.cellType == 1 {
            
            switch title.name {
            case "口座管理":
                self.performSegue(withIdentifier: "toIndividual", sender: indexPath.row)
            case "パスワードの設定":
                self.performSegue(withIdentifier: "toEditPasscode", sender: indexPath.row)
            case "作成者に意見を送信":
                sendEmail()
            case "バックアップ":
                self.performSegue(withIdentifier: "toBackUp", sender: indexPath.row)
            case "家計簿のヒント":
                self.performSegue(withIdentifier: "toBrowser", sender: indexPath.row)
            default:
                HUD.flash(.labeledError(title: "Error", subtitle: "不明なエラー"), delay: 1.5)
            }
        } else if title.cellType == 3 {
            switch title.name {
            case "背景画像とテーマ色":
                
                self.performSegue(withIdentifier: "toAdvance", sender: indexPath.row)
                
            default:
                HUD.flash(.labeledError(title: "Error", subtitle: "不明なエラー"), delay: 1.5)
            }
        }
    }
}
