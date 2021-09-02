//
//  SignUpViewController.swift
//  77.Ins
//
//  Created by Kiichi Ikeda on 2020/07/31.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import PKHUD
import Firebase

class SignUpVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var eMailTextField: UITextField!
    @IBOutlet var passwardTextField: UITextField!
    @IBOutlet var confirmTextField: UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboard()
        userNameTextField.delegate = self
        eMailTextField.delegate = self
        passwardTextField.delegate = self
        confirmTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func signUp(){
        
        let email = eMailTextField.text ?? ""
        let password = passwardTextField.text ?? ""
        let checkPassword = confirmTextField.text ?? ""
        let name = userNameTextField.text ?? ""
        
        if password != checkPassword {
            HUD.flash(.error, delay: 1)
            return
        }
        if name.count <= 3 {
            HUD.flash(.labeledError(title: "Error", subtitle: "ユーザー名の文字数が\n足りません。"), delay: 1)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            guard let user = result?.user else {
                SignInVC.showErrorIfNeeded(error, target: self)
                return
            }
            let req = user.createProfileChangeRequest()
            req.displayName = name
            req.commitChanges() { [weak self] error in
                guard let self = self else { return }
                if error != nil {
                    SignInVC.showErrorIfNeeded(error, target: self)
                    return
                }
                user.sendEmailVerification() { [weak self] error in
                    guard let self = self else { return }
                    if error != nil {
                        SignInVC.showErrorIfNeeded(error, target: self)
                        return
                    }
                    // 仮登録完了画面へ遷移する処理
                    self.performSegue(withIdentifier: "toCheck", sender: user)
                }
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCheck" {
            guard let vc = segue.destination as? CheckEMailVC else { return }
            vc.user = sender as? User ?? nil
            vc.pass = passwardTextField.text ?? ""
        }
    }

}
