//
//  AddAccountViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/25.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import PKHUD
import Instructions

class AddAccountViewController: UIViewController {

    @IBOutlet var accountNameTextField: UITextField!
    @IBOutlet var accountMoneyTextField: UITextField!
    @IBOutlet var accountTipeTextField: UITextField!
    
    @IBOutlet var chargeAccountNameTextField: UITextField!
    
    
    var coachController = CoachMarksController()
    
    var pickerTitle: [String] {
        if #available(iOS 13.0, *) {
            return ["①　携帯残高確認", "②　本アプリ対応ICカード", "③　その他の口座", "④　クレカ型(負債型)口座"]
        } else {
            return ["①　携帯残高確認", "③　その他の口座", "④　クレカ型(負債型)口座"]
        }
    }
    
    var selectedAccount: Account!
    var selectedNumber: Int!
    var isEditMode: Bool = false
    
    var isCanEdit: Bool = false
    
    var textFields = [UITextField]()
    
    let pickerView = UIPickerView()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var creditSetting: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureObserver()
        creditSetting.isHidden = true
        accountMoneyTextField.isEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width,
                                        height: scrollView.viewWithTag(1)!.frame.height)
        scrollView.flashScrollIndicators()
        
        textFields = [accountNameTextField, accountTipeTextField, accountMoneyTextField]
        
        setHideKeyboardTapped()
        accountMoneyTextField.delegate = self
        accountNameTextField.delegate = self
        accountTipeTextField.delegate = self
        chargeAccountNameTextField.delegate = self
        pickerView.dataSource = self
        pickerView.delegate = self
        
        if selectedAccount != nil {
            if selectedAccount.isCanEdit() {
                accountMoneyTextField.isUserInteractionEnabled = true
                accountMoneyTextField.textColor = .label
            } else {
                textFields.removeLast()
                accountMoneyTextField.isUserInteractionEnabled = false
                accountMoneyTextField.textColor = .systemGray
            }
            accountMoneyTextField.text = String(selectedAccount.getFirstCheck()!.balance)
            accountNameTextField.text = selectedAccount.name
            accountTipeTextField.text = selectedAccount.type
            
        }
        
        accountMoneyTextField.keyboardType = .numberPad
        accountTipeTextField.inputView = pickerView
        let accountPicker = UIPickerView()
        accountPicker.dataSource  = self
        accountPicker.delegate = self
        accountPicker.tag = 1
        chargeAccountNameTextField.inputView = accountPicker
        
        //機種によって、自動で、toolBarの高さ変更
        let toolbar = CustomToolBar()
        let toolbarLast = CustomToolBar()
        let goNextItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(goNext))
        goNextItem.tintColor = UIColor.orange
        let doneItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
        doneItem.tintColor = UIColor.orange
        let doneLastItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        doneLastItem.tintColor = UIColor.orange
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([doneItem, spaceButton, goNextItem], animated: true)
        toolbarLast.setItems([spaceButton, doneLastItem], animated: true)
        textFields.forEach { (textField) in
            if textField != textFields.last {
                textField.inputAccessoryView = toolbar
            } else {
                textField.inputAccessoryView = toolbarLast
            }
        }
        chargeAccountNameTextField.inputAccessoryView = toolbarLast
    }
    
    //キーボードの出現でスクロールビューを変更するのを監視用オブザーバー
    @objc override func configureObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        //ここでUIKeyboardWillShowという名前の通知のイベントをオブザーバー登録をしている
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        //ここでUIKeyboardWillHideという名前の通知のイベントをオブザーバー登録をしている
    }
    
     //UIKeyboardWillShow通知を受けて、実行される関数
    @objc override func keyboardWillShow(_ notification: NSNotification){
        
        print("キーボードが立ち上がった")
        guard let userInfo = notification.userInfo else { return }
        print("userInfo GET")
        let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        print(keyboardSize)
            
        scrollView.contentInset.bottom = keyboardSize
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize, right: 0)
    }
       
       
       //UIKeyboardWillShow通知を受けて、実行される関数
    override func keyboardWillHide(_ notification: NSNotification){
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
       }
    
    @objc func done() {
        guard let edittingTextField = textFields.first(where: {($0.isFirstResponder)}) else { return }
        if edittingTextField == accountTipeTextField {
            //②...ICカード
            if accountTipeTextField.text!.first == "④" {
                accountMoneyTextField.text = "0"
                accountMoneyTextField.isEnabled = false
                creditSetting.isHidden = false
            } else {
                accountMoneyTextField.isEnabled = true
                creditSetting.isHidden = true
            }
            if accountTipeTextField.text!.first == "②" {
                checkSearchIcCard(isNextAfterFinished: false)
                return
            }
            if accountTipeTextField.text == "" {
                accountTipeTextField.text = pickerTitle.first
            }
        } else if edittingTextField == chargeAccountNameTextField {
            if chargeAccountNameTextField.text == "" {
                chargeAccountNameTextField.text = allAccount.first?.name
            }
        }
        edittingTextField.resignFirstResponder()
    }

    @objc func goNext() {
        let firstResponderIndex = textFields.firstIndex{($0.isFirstResponder)}!
        
        if accountTipeTextField.text!.first == "④" {
            textFields.append(chargeAccountNameTextField)
            creditSetting.isHidden = false
            accountMoneyTextField.text = "0"
            accountMoneyTextField.isEnabled = false
            chargeAccountNameTextField.becomeFirstResponder()
            
        } else {
            creditSetting.isHidden = true
            accountMoneyTextField.isEnabled = true
            textFields.removeAll(where: {$0 == chargeAccountNameTextField})

            if textFields[firstResponderIndex] == accountTipeTextField {
                if accountTipeTextField.text!.first == "②" {
                    checkSearchIcCard(isNextAfterFinished: true)
                    return
                }
                if accountTipeTextField.text == "" {
                    accountTipeTextField.text = pickerTitle.first
                }
            }
            textFields[firstResponderIndex + 1].becomeFirstResponder()
    //        pickerView.reloadAllComponents()
        }
    }
    
    //actionAfterFinished 0 -> Done , 1 -> Next
    func checkSearchIcCard(isNextAfterFinished: Bool) {
        self.accountTipeTextField.resignFirstResponder()
        let alert = MyAlert("確認", "携帯でICカードを\nスキャンしますか？")
        alert.addActions("いいえ", type: .cancel) { _ in
            if isNextAfterFinished { self.accountMoneyTextField.becomeFirstResponder() }
        }
        alert.addActions("はい") { _ in
            self.accountMoneyTextField.resignFirstResponder()
            //パスワード画面の表示をさせない。
            SceneDelegate.shared.isCheckMode = true
            self.searchIcCard()
        }
        self .present(alert.contontroller, animated: true, completion: nil)
    }
    
    func searchIcCard() {
        
        NFCReader(type: FeliCaCardType(rawValue: 1) ?? .unknown) { (balance, error) in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.accountNameTextField.becomeFirstResponder()
                }; return
            }
            print("検出側から反応が返ってきた.")
            self.accountMoneyTextField.text = "\(balance)"
        }.start()
        
    }

    
    @IBAction func save() {
        let text = accountNameTextField.text
        if textFields.contains(where: { $0.text?.count == 0 }) {
            HUD.flash(.labeledError(title: "入力エラー", subtitle: "空欄があります。"), delay: 2)
            return
        }
        if text!.count == 0 || text!.count > 8  {
            HUD.flash(.labeledError(title: "入力エラー", subtitle: "口座名を8字以内で\n入力してください。"), delay: 2)
            return
        }
        
        guard let price = Int(accountMoneyTextField.text!) else {
            HUD.flash(.labeledError(title: "入力エラー", subtitle: "残高の欄には数値を\n入力してください。"), delay: 1.2)
            return
        }
        
        if isEditMode {
//            let newCheck = Check()
//            let newAccount = Account()
//            newAccount.accountName = accountNameTextField.text!
//            newAccount.accountTipe = accountTipeTextField.text!
//            newCheck.balance = Int(accountMoneyTextField.text!)!
//            selectedAccount.setValue(newCheckValue: newCheck, newAccout: newAccount)
        } else {
            guard let accountName = accountNameTextField.text else { return }
            guard let newAccount = Account(name: accountName) else {
                HUD.flash(.labeledError(title: "Error", subtitle: "口座名が重複します"))
                return
            }
            newAccount.type = accountTipeTextField.text!
            newAccount.balance = price
            if newAccount.type.first == "④" {
                newAccount.chargeAccount = chargeAccountNameTextField.text!
            }
            newAccount.save()
        }
        // 親VCを取り出し
        let parentTBC = SceneDelegate.shared.rootVC.current as! MainTBC
        
        if UserDefaults.standard.integer(forKey: .startStep)! == 0 {
            UserDefaults.standard.setInteger(1, forKey: .startStep)
            parentTBC.setStartStep()
        }
        
        let parentNC = parentTBC.selectedViewController as! UINavigationController
        if let parentVC = parentNC.topViewController as? AccountSettingVC {
            // ユーザデフォルトでラベル更新
            parentVC.load()
        } else if let parentVC = parentNC.topViewController as? AddCategoryViewController {
            parentVC.addNewAccount(text!)
        }
        // 画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    //CGRectを簡単に作る
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
}

extension AddAccountViewController: UITextFieldDelegate {
    
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        
//        if textField == accountTipeTextField {
//            if textField.text?.first == "④" && creditSetting.isHidden {
//                creditSetting.isHidden = false
//                accountMoneyTextField.isEnabled = false
//                accountMoneyTextField.text = "0"
//            } else if textField.text?.first != "④" && !creditSetting.isHidden {
//                creditSetting.isHidden = true
//                accountMoneyTextField.isEnabled = true
//            }
//        }
//        return true
//    }

//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        return textField.isEnabled
//    }
//
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if !textField.isEnabled {
//            textField.resignFirstResponder()
//        }
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == chargeAccountNameTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
}

extension AddAccountViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    var allAccount: [Account] {
        return Account.readAll(isCredit: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            if allAccount.count == 0 {
                return 1
            }
            return allAccount.count
        }
        return pickerTitle.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            if allAccount.count == 0 {
                return "追加できるアカウントがありません"
            }
            return allAccount[row].name
        }
        return pickerTitle[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            if allAccount.count == 0 { return }
            chargeAccountNameTextField.text = allAccount[row].name
            return
        }
        accountTipeTextField.text = pickerTitle[row]
        
        if accountTipeTextField.text?.first == "④" && creditSetting.isHidden {
            creditSetting.isHidden = false
            accountMoneyTextField.isEnabled = false
            accountMoneyTextField.text = "0"
        } else if accountTipeTextField.text?.first != "④" && !creditSetting.isHidden {
            creditSetting.isHidden = true
            accountMoneyTextField.isEnabled = true
        }
        
    }
    
}

extension AddAccountViewController: CoachMarksControllerDataSource {
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.integer(forKey: .startStep) == 0 {
            accountNameTextField.text = "現金"
            accountTipeTextField.text = "③　その他の口座"
            coachController.dataSource = self
            self.coachController.start(in: .viewController(self))
        }
        if accountTipeTextField.text != "" {
            pickerView.selectRow(pickerTitle.firstIndex(of: accountTipeTextField.text!)!,
                                 inComponent: 0,
                                 animated: false)
        }
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        self.coachController.stop(immediately: true)
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return UserDefaults.standard.integer(forKey: .startStep) == 0 ? 1 : 0
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        return self.coachController.helper.makeCoachMark(for: accountMoneyTextField, pointOfInterest: nil, cutoutPathMaker: nil)
        // for: にUIViewを指定すれば、マークがそのViewに対応します
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        let text = "ここをタップして\n手持ちの残高を入力してください"
        
        coachViews.bodyView.hintLabel.text = text
        coachViews.bodyView.nextLabel.text = "了解" // 「次へ」などの文章

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
}

