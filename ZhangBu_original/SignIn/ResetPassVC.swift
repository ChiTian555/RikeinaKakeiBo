//
//  ResetPassVC.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/10/02.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import Firebase

class ResetPassVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboard()
    }
    
    @IBOutlet var eMailTextField: UITextField!
    

    @IBAction private func didTapSendButton() {
        let email = eMailTextField.text ?? ""
        
        if email == "" { return }
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            if error != nil {
                // 送信完了画面へ
                self.navigationController?.popViewController(animated: true)
            }
            SignInVC.showErrorIfNeeded(error, target: self)
        }
    }

}
