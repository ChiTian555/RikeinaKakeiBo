//
//  SceneDelegate.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/08.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        print("SceneDelegateWillConnectTo: アプリ起動時")
        
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = RootVC()
        window?.makeKeyAndVisible()
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        print("sceneDidDisconnect: 非アクティブになった")
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("sceneDidBecomeActive: アクティブになった")
        if UserDefaults.standard.bool(forKey: .isCheckMode)! {
            UserDefaults.standard.setBool(false, forKey: .isCheckMode)
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            let canNotice = settings.authorizationStatus == .authorized
            UserDefaults.standard.setBool(canNotice, forKey: .canUseNotification)
            print("\(settings.authorizationStatus)")
                
        }
        
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("sceneWillResignActive: バックグラウンドへ移行しようとした時")
        if !UserDefaults.standard.bool(forKey: .isCheckMode)! {
        // パスコードロック画面を表示する
        displayPasscodeLockScreenIfNeeded()
        }
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("sceneWillEnterForeground: フォアグラウンドへ移行しようとした時")
        
        let passcodeModel = PasscodeModel()
        // パスコードロックを設定していない場合は何もしない
        if !passcodeModel.existsHashedPasscode() {
            return
        }
        if let isDisplayedPasscodeLock = isDisplayedPasscodeLock() {
            // パスコードロック画面がかぶせてある時に、情報を更新
            if isDisplayedPasscodeLock.0 {
                if let passcodeVC = isDisplayedPasscodeLock.VC as? PasscodeViewController {
                    passcodeVC.setupPasscodeNumberKeyboardView()
                }
            }
        }
        
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("sceneDidEnterBackground: バックグラウンドへ移行完了した時")
        
    }


    // MARK: - Private Function

    func displayPasscodeLockScreenIfNeeded() {
        let passcodeModel = PasscodeModel()

        // パスコードロックを設定していない場合は何もしない
        if !passcodeModel.existsHashedPasscode() {
            return
        }
        
        if let isDisplayedPasscodeLock = isDisplayedPasscodeLock() {
            // パスコードロック画面がかぶせてなければかぶせる
            if !isDisplayedPasscodeLock.0 {
                let nav = UINavigationController(rootViewController: getPasscodeViewController())
                nav.modalPresentationStyle = .overFullScreen
                nav.modalTransitionStyle   = .crossDissolve
                isDisplayedPasscodeLock.VC.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    private func isDisplayedPasscodeLock() -> (Bool, VC:UIViewController)?  {
        if let rootViewController = SceneDelegate.shared.window!.rootViewController {

            // 現在のrootViewControllerにおいて一番上に表示されているViewControllerを取得する
            var topViewController: UIViewController = rootViewController
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }

            // すでにパスコードロック画面がかぶせてあるかを確認する
            let isDisplayedPasscodeLock: Bool = topViewController.children.map{
                return $0 is PasscodeViewController
            }.contains(true)
            
            if let passcodeLockDisplay: UIViewController = topViewController.children
                .first(where: {$0 is PasscodeViewController}) {
                
                return (isDisplayedPasscodeLock, passcodeLockDisplay)
            }
            return (isDisplayedPasscodeLock, topViewController)
        }
        return nil
    }

    private func getPasscodeViewController() -> PasscodeViewController {
        // 遷移先のViewControllerに関する設定をする
        let sb = UIStoryboard(name: "Passcode", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! PasscodeViewController
        vc.setTargetInputPasscodeType(.displayPasscodeLock)
        vc.setTargetPresenter(PasscodePresenter(previousPasscode: nil))
        return vc
    }
}

extension SceneDelegate {

    /// AppDelegateのシングルトン
    static var shared: SceneDelegate {
        return UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
    }
    /// rootViewControllerは常にRootVC
    var rootVC: RootVC {
        return window!.rootViewController as! RootVC
    }
}
