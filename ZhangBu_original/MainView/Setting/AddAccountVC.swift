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

class AddAccountVC: UIViewController {

    private let ud = UserDefaults.standard
    
    @IBOutlet var accountNameTextField: UITextField!
    @IBOutlet var accountMoneyTextField: UITextField!
    @IBOutlet var accountTipeTextField: UITextField!
    @IBOutlet var chargeAccountNameTextField: UITextField!
    @IBOutlet weak var instructButton: UIButton!
    
    
    var coachController = CoachMarksController()
    
    var accountTypeTitle: [String] {
        if #available(iOS 13.0, *) {
            return ["①　携帯残高確認", "②　本アプリ対応ICカード", "③　その他の口座", "④　クレカ型(負債型)口座"]
        } else {
            return ["①　携帯残高確認", "③　その他の口座", "④　クレカ型(負債型)口座"]
        }
    }
    
    var icTypeTitles : [String] =
        ["交通系IC", "楽天Edy", "nanaco","WAON","大学生協プリペードカード"]
    
    var icType: Int?
    
    var selectedAccount: Account!
    var selectedNumber: Int!
    var isEditMode: Bool = false
    
    var isCanEdit: Bool = false
    
    /// tag,0 -> nomal, tag,1 -> picker, tag,2 -> number
    var textFields = [UITextField]()
    
    // viewDidApearで、利用。
    var typePicker = UIPickerView()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var creditSetting: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instructButton.tintColor = ud.color(forKey: .userColor)
        
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
        textFields.forEach { $0.delegate = self }
        chargeAccountNameTextField.delegate = self
        
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
        typePicker.dataSource  = self
        typePicker.delegate = self
        typePicker.tag = 0
        accountTipeTextField.inputView = typePicker
        let chargePicker = UIPickerView()
        chargePicker.dataSource  = self
        chargePicker.delegate = self
        chargePicker.tag = 1
        chargeAccountNameTextField.inputView = chargePicker
        
        //機種によって、自動で、toolBarの高さ変更
        let toolbar = MyToolBar(self, type: .doneAndNext(done: #selector(done),
                                                         next: #selector(goNext)))
        let toolbarLast = MyToolBar(self, type: .done(done: #selector(done)))
        textFields.forEach { (tF) in
            tF.inputAccessoryView = (tF != textFields.last) ? toolbar : toolbarLast
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
            
        scrollView.contentInset.bottom = keyboardSize + 20
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0,
                                                        bottom: keyboardSize + 20 , right: 0)
    }
       
       
       //UIKeyboardWillShow通知を受けて、実行される関数
    override func keyboardWillHide(_ notification: NSNotification){
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentInset = .zero
            self.scrollView.scrollIndicatorInsets = .zero
        }
    }
    
    // MARK: ToolBar function
    
    @objc func done() {
        guard let edittingTextField = textFields.first(where: {($0.isFirstResponder)}) else {
            let alert = self.presentedViewController as? UIAlertController
            let picker = alert?.textFields?.first?.inputView as? UIPickerView
            guard let selectedRow = picker?.selectedRow(inComponent: 0) else { return }
            alert?.textFields?.first?.text = icTypeTitles[selectedRow]
            alert?.textFields?.first?.resignFirstResponder() ;return
        }
        // 自ら、消すとき、Tagを設定。
        edittingTextField.resignFirstResponder()
        if edittingTextField == chargeAccountNameTextField {
            if chargeAccountNameTextField.text == "" {
                chargeAccountNameTextField.text = allAccount.first?.name
            }
        }
    }

    @objc func goNext() {
        let firstResponderIndex = textFields.firstIndex{($0.isFirstResponder)}!
        textFields[firstResponderIndex + 1].becomeFirstResponder()
    }
    
    func searchICCard() {
        let alert = MyAlert("ICカードを確認します","カードの種類を\nお選びください")
        alert.addTextField("タップして入力") { (tF) in
            tF.text = self.icTypeTitles.first
            let icTypepicker = UIPickerView()
            icTypepicker.dataSource = self
            icTypepicker.delegate = self
            icTypepicker.tag = 2
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
                    HUD.flash(.label("残高は\n\(balance)円でした"))
                    self.icType = icTypeNom + 1
                    self.accountMoneyTextField.text = String(balance)
                }
            }.start()
        }
        present(alert.controller, animated: true, completion: nil)
    }
    
    private func checkTypeTextField() {
        if accountTipeTextField.text?.isEmpty != false {
            accountTipeTextField.text = accountTypeTitle.first
        }
        if accountTipeTextField.text?.first == "④" && creditSetting.isHidden {
            textFields.removeLast()
            textFields.append(chargeAccountNameTextField)
            creditSetting.isHidden = false
        } else if accountTipeTextField.text?.first != "④" && !creditSetting.isHidden {
            textFields.removeLast()
            textFields.append(accountMoneyTextField)
            creditSetting.isHidden = true
        }
    }
    
    // MARK: Save function
    
    @IBAction func checkAllValue() {
        let text = accountNameTextField.text ?? ""
        if textFields.contains(where: { $0.text?.count == 0 }) {
            HUD.flash(.label("空欄があります"))
            return
        }
        if text.count == 0 || text.count > 8  {
            HUD.flash(.label("口座名を8字以内で\n入力してください"))
            return
        }
        
        guard let price = Int(accountMoneyTextField.text!) else {
            HUD.flash(.label("残高の欄には数値を\n入力してください"))
            return
        }
        
        guard let accountName = accountNameTextField.text else { return }
        guard let newAccount = Account.make(name: accountName) else {
            HUD.flash(.label("口座名が重複します"))
            return
        }
        newAccount.type = accountTipeTextField.text!
        newAccount.balance = price
        if newAccount.type.first == "④" {
            newAccount.chargeAccount = chargeAccountNameTextField.text!
        } else if newAccount.type.first == "②" {
            if let type = icType { newAccount.icType = type }
            else {
                HUD.flash(.label("ICカードを\nテストスキャンします。"), delay: 1.0) {_ in
                    self.searchICCard()
                }; return
            }
        }
        save(newAccount: newAccount)
    }
    
    func save(newAccount: Account) {
        
        newAccount.save()
        // 親VCを取り出し
        let parentTBC = SceneDelegate.shared.rootVC.current as! MainTBC
        
        // 初期ステップの表示
        if ud.stringArray(forKey: .startSteps)!.first! == "0" {
            ud.deleteArrayElement("0", forKey: .startSteps)
            parentTBC.setStartStep()
        }
        
        let parentNC = parentTBC.selectedViewController as! UINavigationController
        if let parentVC = parentNC.topViewController as? AccountSettingVC {
            // ユーザデフォルトでラベル更新
            parentVC.load()
        } else if let parentVC = parentNC.topViewController as? AddCategoryViewController {
            //　銀行口座追加の画面から来た場合
            parentVC.addNewAccount(newAccount.name)
        }
        // 画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    //CGRectを簡単に作る
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
}

// MARK: TextField Delegate

extension AddAccountVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if accountTipeTextField.isFirstResponder {
            if accountTipeTextField.text?.first == "②" {
                accountTipeTextField.resignFirstResponder()
                return false
            }
        }
        if textField == accountMoneyTextField {
            if accountTipeTextField.text?.first == "④" {
                HUD.flash(.label("負債型は残高0で\n登録ください"))
                return false
            }
            else if accountTipeTextField.text?.first == "②" {
                if icType == nil { searchICCard() }
                return false
            }
        }; return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == accountTipeTextField {
            if textField.text?.first == "②" { searchICCard(); return }
            icType = nil
            if textField.text?.first == "④" { accountMoneyTextField.text = "0" }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if [accountNameTextField,chargeAccountNameTextField].contains(textField) {
            textField.resignFirstResponder()
        }; return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 2 && !string.isNumber && !string.isEmpty {
            HUD.flash(.label("無効な入力"),delay: 0.8)
            return false
        }
        return true
    }
    
}

// MARK: PickerView

extension AddAccountVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    var allAccount: [Account] {
        return Account.readAll(isCredit: false) + []
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0: return accountTypeTitle.count
        case 1: return (allAccount.isEmpty) ? 1 : allAccount.count
        case 2: return icTypeTitles.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 0: return accountTypeTitle[row]
        case 1: return allAccount.isEmpty ?
            "追加できるアカウントがありません" : allAccount[row].name
        case 2: return icTypeTitles[row]
        default: return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("didSelectRow: \(pickerView.tag)")
        switch pickerView.tag {
        case 0:
            accountTipeTextField.text = accountTypeTitle[row]
            checkTypeTextField()
        case 1:
            if allAccount.isEmpty { return }
            chargeAccountNameTextField.text = allAccount[row].name
        case 2:
            let alert = self.presentedViewController as? UIAlertController
            guard let tF = alert?.textFields?.first else { return }
            tF.text = icTypeTitles[row]
        default: break
        }
    }
    
}

extension AddAccountVC: CoachMarksControllerDataSource {
    
    override func viewDidAppear(_ animated: Bool) {
        if ud.stringArray(forKey: .startSteps)!.first == "0" {
            accountNameTextField.text = "現金"
            accountTipeTextField.text = "③　その他の口座"
            coachController.dataSource = self
            self.coachController.start(in: .viewController(self))
        }
        if accountTipeTextField.text == "" { return }
        typePicker.selectRow(accountTypeTitle.firstIndex(of: accountTipeTextField.text!)!,
                             inComponent: 0,animated: false)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        self.coachController.stop(immediately: true)
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return ud.stringArray(forKey: .startSteps)!.first == "0" ? 1 : 0
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

