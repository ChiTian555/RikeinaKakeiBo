//
//  SignInViewController.swift
//  77.Ins
//
//  Created by Kiichi Ikeda on 2020/07/31.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import Firebase
import PKHUD

class SignInVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var eMailTextField: UITextField!
    @IBOutlet var passwardTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboard()
        eMailTextField.delegate = self
        passwardTextField.delegate = self
        
        // UIAdaptivePresentationControllerDelegateを渡す
        self.navigationController?.presentationController?.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signIn() {
        if eMailTextField.text?.count == 0 || passwardTextField.text?.count == 0 {return}
        
        let email = eMailTextField.text ?? ""
        let password = passwardTextField.text ?? ""
        
        HUD.show(.progress)
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            guard let user = result?.user else {
                HUD.hide()
                SignInVC.showErrorIfNeeded(error, target: self)
                return
            }
            if !user.isEmailVerified {
                HUD.hide()
                HUD.flash(.label("本登録が\nなされていません。"))
                return
            }
            // サインイン後の画面へ
            HUD.flash(.labeledSuccess(title: "ログイン完了", subtitle: "メイン画面に移ります"), delay: 1) { _ in
                SignInVC.backToMain(target: self)
            }
        }
        
    }
    
    @IBAction func cancel() {
        SignInVC.backToMain(target: self)
    }
    
    func isValidEmail(_ string: String) -> Bool {
           let emailRegEx = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,4}"
           let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
           let result = emailTest.evaluate(with: string)
           return result
    }
    
    
    static func backToMain(target: UIViewController? = nil) {
        
        let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
        let nc = tbc.selectedViewController as! MainNC
        let vc = nc.topViewController as! BackUpVC
        
        if let user = Auth.auth().currentUser {
            vc.user = user
        }
        vc.setMainCurrent()
        if let vc = target {
            vc.dismiss(animated: true, completion: nil)
        }
    }
    
    //SignIn.StoryBoardで用いられる関数をここに記述した
    
    static func showErrorIfNeeded(_ errorOrNil: Error?,target vc: UIViewController) {
        // エラーがなければ何もしません
        guard let error = errorOrNil else { return }
        
        let message = SignInVC.errorMessage(of: error)
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    static private func errorMessage(of error: Error) -> String {
        var message = "エラーが発生しました\n"
        guard let errcd = AuthErrorCode(rawValue: (error as NSError).code) else {
            return message
        }
        
        switch errcd {
        case .networkError: message += "ネットワークに接続できません"
        case .userNotFound: message += "ユーザが見つかりません"
        case .invalidEmail: message += "不正なメールアドレスです"
        case .emailAlreadyInUse: message += "このメールアドレスは既に使われています"
        case .wrongPassword: message += "入力した認証情報でサインインできません"
        case .userDisabled: message += "このアカウントは無効です"
        case .weakPassword: message += "パスワードが脆弱すぎます"
        // これは一例です。必要に応じて増減させてください
        default: break
        }
        return message
    }
    
}

extension SignInVC: UIAdaptivePresentationControllerDelegate {
    
    // true: スワイプで閉じる false: スワイプで閉じない
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
    // スワイプで閉じない場合に実行したい処理
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {

        let alert = UIAlertController(title: "登録画面を閉じますか？", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "閉じる", style: .default) { _ in
            SignInVC.backToMain(target: self)
        })
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}
