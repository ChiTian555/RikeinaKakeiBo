//
//  AddAccountViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/25.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import PKHUD
import NFCReader
import Instructions

class AddAccountViewController: UIViewController {

    @IBOutlet var accountNameTextField: UITextField!
    @IBOutlet var accountMoneyTextField: UITextField!
    @IBOutlet var accountTipeTextField: UITextField!
    
    var coachController = CoachMarksController()
    
    var pickerTitle = [String]()
    
    var selectedAccount: Account!
    var selectedNumber: Int!
    var isEditMode: Bool = false
    
    var isCanEdit: Bool = false
    
    var textFields = [UITextField]()
    
    let pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            pickerTitle = ["①　携帯残高確認", "②　本アプリ対応ICカード", "③　その他の口座"]
        } else {
            pickerTitle = ["①　携帯残高確認", "③　その他の口座"]
        }
        
        textFields = [accountNameTextField, accountTipeTextField, accountMoneyTextField]
        
        accountMoneyTextField.delegate = self
        accountNameTextField.delegate = self
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
        
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let toolbarLast = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
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
        
    }
    
    @objc func done() {
        let edittingTextField = textFields.first{($0.isFirstResponder)}!
        if edittingTextField == accountTipeTextField {
            if accountTipeTextField.text == "②　本アプリ対応ICカード" {
                checkSearchIcCard()
                return
            }
            if accountTipeTextField.text == "" {
            accountTipeTextField.text = pickerTitle.first
            }
        }
        edittingTextField.resignFirstResponder()
    }

    @objc func goNext() {
        let firstResponderIndex = textFields.firstIndex{($0.isFirstResponder)}!
        
        if textFields[firstResponderIndex] == accountTipeTextField {
            if accountTipeTextField.text == "②　本アプリ対応ICカード" {
                checkSearchIcCard()
                return
            }
            if accountTipeTextField.text == "" {
                accountTipeTextField.text = pickerTitle.first
            }
        }
        textFields[firstResponderIndex + 1].becomeFirstResponder()
//        pickerView.reloadAllComponents()
    }
    
    func checkSearchIcCard() {
        let alert = UIAlertController(title: "確認", message: "携帯でICカードを\nスキャンしますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: .default) { (action) in
            self.searchIcCard()
            alert.dismiss(animated: true, completion: nil)
        }
        let noAction = UIAlertAction(title: "いいえ", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.accountMoneyTextField.becomeFirstResponder()
        }
        alert.addAction(noAction)
        alert.addAction(okAction)
        self .present(alert, animated: true, completion: nil)
    }
    
    func searchIcCard() {
        
        var configuration = ReaderConfiguration()
        configuration.message.alert = "ICカードに近づけてください。."
        configuration.message.foundMultipleTags = "複数のカードが感知されました."
        let reader = Reader<FeliCa>(configuration: configuration)

        reader.read(didBecomeActive: { _ in
            print("reader: セット完了")
        }, didDetect: { reader, result in
            print("検出側から反応が返ってきた.")
            switch result {
            case .success(let tag):
                var balance = UInt32()
                var cardName = ""
                switch tag {
                case .edy(let edy):
                    cardName = "edy"
                    balance = edy.histories.first?.balance ?? 0
                case .nanaco(let nanaco):
                    cardName = "nanaco"
                    balance = nanaco.histories.first?.balance ?? 0
                case .waon(let waon):
                    cardName = "waon"
                    balance = waon.histories.first?.balance ?? 0
                case .suica(let suica):
                    cardName = "交通系"
                    balance = UInt32(suica.boardingHistories.first?.balance ?? 0)
                }
                reader.setMessage("\(cardName): 残高は¥\(balance)でした")
                self.accountMoneyTextField.text = "\(balance)"
                
            case .failure(let error):
                print(error)
                switch error {
                case .notSupported:
                    HUD.flash(.labeledError(title: "Error", subtitle: "\(error)"), delay: 1.5)
                    break
                case .readTagFailure(let error2):
                    print("\(error2)")
                    break
                case .scanFailure(let nsError):
                    print("\(nsError)")
                    break
                case .tagConnectionFailure(let nsError):
                    print("\(nsError)")
                }
                reader.setMessage("読み込みに失敗しました")
            }
        })
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
        
        if isEditMode {
//            let newCheck = Check()
//            let newAccount = Account()
//            newAccount.accountName = accountNameTextField.text!
//            newAccount.accountTipe = accountTipeTextField.text!
//            newCheck.balance = Int(accountMoneyTextField.text!)!
//            selectedAccount.setValue(newCheckValue: newCheck, newAccout: newAccount)
        } else {
            guard let accountName = accountNameTextField.text else { return }
            guard let newAccount = Account.create(name: accountName) else {
                HUD.flash(.labeledError(title: "Error", subtitle: "口座名が重複します"))
                return
            }
            newAccount.type = accountTipeTextField.text!
            newAccount.balance = Int(accountMoneyTextField.text!)!
            newAccount.save()
        }
        // 親VCを取り出し
        let parentTBC = SceneDelegate.shared.rootVC.current as! MainTBC
        
        let step = UserDefaults.standard.integer(forKey: .startStep)!
        if step == 0 {
            UserDefaults.standard.setInteger(1, forKey: .startStep)
        }
        parentTBC.setStartStep()
        
        let parentNC = parentTBC.selectedViewController as! UINavigationController
        let parentVC = parentNC.topViewController as! IndividualSettingViewController
        // ユーザデフォルトでラベル更新
        parentVC.load()
        // 画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    //CGRectを簡単に作る
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
}

extension AddAccountViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        accountNameTextField.resignFirstResponder()
    }
    
}

extension AddAccountViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerTitle[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        accountTipeTextField.text = pickerTitle[row]
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

