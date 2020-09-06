//
//  AddAccountViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/25.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import PKHUD

class AddAccountViewController: UIViewController {

    @IBOutlet var accountNameTextField: UITextField!
    @IBOutlet var accountMoney: UITextField!
    
    var selectedMoney: String!
    var selectedName: String!
    var selectedNumber: Int!
    var isEditMode: Bool = false
    
    var textFields = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFields = [accountNameTextField, accountMoney]
        
        accountMoney.delegate = self
        accountNameTextField.delegate = self
        
        if selectedName != nil || selectedMoney != nil {
            accountMoney.text = selectedMoney
            accountNameTextField.text = selectedName
        }
        
        accountMoney.keyboardType = .numberPad
        
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
        textFields.first{($0.isFirstResponder)}!.resignFirstResponder()
    }

    @objc func goNext() {
        let firstResponderIndex = textFields.firstIndex{($0.isFirstResponder)}!
        textFields[firstResponderIndex + 1].becomeFirstResponder()
        
//        pickerView.reloadAllComponents()
    }
    
    @IBAction func save() {
        let text = accountNameTextField.text
        if text!.count == 0 || text!.count > 8 {
            HUD.flash(.labeledError(title: "入力エラー", subtitle: "1~8字で入力してください。"),
                      delay: 2){_ in
            }
            return
        }
        
        if isEditMode {
            let account = Account.readValue(id: selectedNumber)
            account.accountName = accountNameTextField.text!
            account.newBalance = Int(accountMoney.text!)!
            account.setValue()
        } else {
            let newAccount = Account.create()
            newAccount.accountName = accountNameTextField.text!
            newAccount.newBalance = Int(accountMoney.text!)!
//            newAccount.accountUIColor = UIColor.randomColor
            newAccount.save()
        }
        // 親VCを取り出し
        let parentTBC = SceneDelegate.shared.rootVC.current as! UITabBarController
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

