//
//  CheckEMailVC.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/10/02.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import Firebase
import PKHUD

class CheckEMailVC: UIViewController {

    var user: User?
    var pass: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboard()
        navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func resendEMail() {
        
        guard let user = user else {
            HUD.flash(.labeledError(title: "エラー", subtitle: "予期せぬエラーが発生しました。"), delay: 1)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        user.sendEmailVerification() { [weak self] error in
            guard let self = self else { return }
            if error != nil {
                SignInVC.showErrorIfNeeded(error, target: self)
                return
            }
        }
    }
    
    @IBAction func checkEndSetting(){
        
        guard let user = user else {
            HUD.flash(.labeledError(title: "エラー", subtitle: "予期せぬエラーが発生しました。"), delay: 1)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        Auth.auth().signIn(withEmail: user.email!, password: pass, completion: { (res, error) in
            if !(res?.user.isEmailVerified ?? false) {
                HUD.flash(.labeledError(title: "エラー", subtitle: "本登録が行われておりません！"), delay: 1.0)
                return
            }
            if error != nil {
                SignInVC.showErrorIfNeeded(error, target: self)
                return
            }
            HUD.flash(.labeledSuccess(title: "登録完了", subtitle: "元の画面に戻ります！"), delay: 1.0) {_ in
                SignInVC.backToMain(target: self)
            }
        })
    }
    
}
