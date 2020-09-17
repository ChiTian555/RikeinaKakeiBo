//
//  SettingViewController.swift
//  TouchIDExample
//
//  Created by 酒井文也 on 2018/12/16.
//  Copyright © 2018 酒井文也. All rights reserved.
//

import UIKit
import LocalAuthentication
import PKHUD

class SettingViewController: MainBaceVC {
    
    private let passcodeModel = PasscodeModel()

    @IBOutlet weak private var passcodeSwitch: UISwitch!
    @IBOutlet weak private var openSettingButton: UIButton!
    @IBOutlet weak private var editPasscodeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserInterface()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showTabBarItems()
        setCurrentPasscodeStatus()
    }

    // MARK: - Private Function

    @objc private func passcodeSwitchChanged() {
        if passcodeModel.existsHashedPasscode() {
            showAlertWith(title: "パスコードを無効にします", message: "以前に設定したパスコードは削除されますがよろしいですか?",
                okActionHandler: {
                    PasscodeModel().deleteHashedPasscode()
                    self.setCurrentPasscodeStatus()
                },
                cancelActionHandler: {
                    self.setCurrentPasscodeStatus()
                }
            )
        } else {
            let vc = getPasscodeViewController(targetInputPasscodeType: .inputForCreate)
            self.navigationController?.pushViewController(vc, animated: true)
//            self.navigationController?.navigationBar.backgroundColor = .systemBackground
//            self.navigationController?.navigationBar.barTintColor = .label
        }
    }

    @objc private func openSettingButtonAction() {
        let context = LAContext()
        let reason = "This app uses Touch ID / Facd ID to secure your data."
        var authError: NSError?
        
        // MEMO: 利用している端末のFaceIDやTouchIDの状況やどの画面で利用しているか見てボタン状態を判断する
        var isEnabledLocalAuthenticationButton: Bool = false
        isEnabledLocalAuthenticationButton
            = LocalAuthenticationManager.getDeviceOwnerLocalAuthenticationType() != .authWithManual
        
        if isEnabledLocalAuthenticationButton {
            HUD.flash(.label("already can use"), delay: 1)
            return
        }
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
          context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
            if success {
              self.setMessage("Authenticated")
            } else {
              let message = error?.localizedDescription ?? "Failed to authenticate"
              self.setMessage(message)
            }
          }
        } else {
          let message = authError?.localizedDescription ?? "canEvaluatePolicy returned false"
            
            let alert = UIAlertController(title: "生体認証設定", message: "携帯の設定画面に移りますか？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "はい", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.setMessage(message)
            }
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func setMessage(_ message: String) {
        DispatchQueue.main.async {
            HUD.flash(.label(message), delay: 1.5)
        }
    }

    @objc private func editPasscodeButtonAction() {
        let vc = getPasscodeViewController(targetInputPasscodeType: .inputForUpdate)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func setCurrentPasscodeStatus() {
        let isPasscodeExist = PasscodeModel().existsHashedPasscode()
        passcodeSwitch.isOn = isPasscodeExist
        editPasscodeButton.superview?.isHidden = !isPasscodeExist
        openSettingButton.setTitleColor(isPasscodeExist ? .systemBlue : .systemGray3 , for: .normal)
        openSettingButton.isUserInteractionEnabled = isPasscodeExist
    }

    private func getPasscodeViewController(targetInputPasscodeType: InputPasscodeType) -> PasscodeViewController {
        // 遷移先のViewControllerに関する設定をする
        let sb = UIStoryboard(name: "Passcode", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! PasscodeViewController
        vc.setTargetInputPasscodeType(targetInputPasscodeType)
        vc.setTargetPresenter(PasscodePresenter(previousPasscode: nil))
        return vc
    }

    private func setupUserInterface() {
        setupNavigationItems()
        setupPasscodeSwitch()
        setupOpenSettingButton()
        setupEditPasscodeButton()
    }

    private func setupNavigationItems() {
//        setupNavigationBarTitle("サンプルでの設定")
        removeBackButtonText()
    }

    private func setupPasscodeSwitch() {
        passcodeSwitch.addTarget(self, action: #selector(self.passcodeSwitchChanged), for: .touchUpInside)
    }

    private func setupOpenSettingButton() {
        openSettingButton.addTarget(self, action: #selector(self.openSettingButtonAction), for: .touchUpInside)
    }

    private func setupEditPasscodeButton() {
        editPasscodeButton.addTarget(self, action: #selector(self.editPasscodeButtonAction), for: .touchUpInside)
    }

    private func showTabBarItems() {
        if let tabBarVC = self.tabBarController {
            tabBarVC.tabBar.isHidden = false
        }
    }

    private func showAlertWith(title: String? = nil, message: String,
                                                 okActionHandler: @escaping () -> Void = {}, cancelActionHandler: @escaping () -> Void = {}) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: .default) { _ in
            okActionHandler()
        }
        let cancelAction = UIAlertAction(title: "いいえ", style: .cancel) { _ in
            cancelActionHandler()
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
