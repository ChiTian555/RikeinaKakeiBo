//
//  AppDelegate.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/08.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import RealmSwift
import Siren
import SwiftDate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        SwiftDate.defaultRegion = Region(calendar: Calendars.gregorian, zone: Zones.asiaTokyo, locale: Locales.japanese)
        
        print("didFinishLaunchingWithOptions: アプリ起動時")
        forceUpdate()
        
        let ud = UserDefaults.standard
//        if ud.stringArray3(forKey: .list) == nil {
//            ud.setArray3([[["項目"],["決済方法"]],[["項目"],["入金口座"]],[["出金"],["入金"]]], forKey: .list)
//        }
        //レルム初期データほぞん
        let realm = try! Realm()
        if realm.objects(CategoryList.self).count == 0 {
            let categoryArray = [[("項目", false),("決済方法", true)],
                                 [("項目", false),("入金口座", true)],
                                 [("出金", true),("入金", true)]]
            for i in 0 ..< 3 {
                categoryArray[i].forEach { (menuName) in
                    let menu = CategoryList.create()
                    menu.mainCategory = i
                    menu.categoryName = menuName.0
                    menu.selectAccount = menuName.1
                    menu.save()
                }
            }
        }
        if ud.integer(forKey: .alpha) == 0 {
            ud.setInteger(50, forKey: .alpha)
        }
        
        if ud.stringArray2(forKey: .account) == nil {
            ud.setArray2([[]], forKey: .account)
        }
        
        if ud.stringArray1(forKey: .notDidCheckAccountTipe) == nil {
            if #available(iOS 13.0, *) {
                ud.setArray1(["①　携帯残高確認", "②　本アプリ対応ICカード", "③　その他の口座"],
                forKey: .notDidCheckAccountTipe)
            } else {
                ud.setArray1(["①　携帯残高確認", "③　その他の口座"],
                forKey: .notDidCheckAccountTipe)
            }
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive: フォアグラウンドからバックグラウンドへ移行しようとした時")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground: バックグラウンドへ移行完了した時")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground: バックグラウンドからフォアグラウンドへ移行しようとした時")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive: アプリの状態がアクティブになった時")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate: アプリ終了時")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Private Function

    private func displayPasscodeLockScreenIfNeeded() {
        let passcodeModel = PasscodeModel()

        // パスコードロックを設定していない場合は何もしない
        if !passcodeModel.existsHashedPasscode() {
            return
        }

        let keyWindow = UIApplication.shared.connectedScenes
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
        
        if let rootViewController = keyWindow?.rootViewController {

            // 現在のrootViewControllerにおいて一番上に表示されているViewControllerを取得する
            var topViewController: UIViewController = rootViewController
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }

            // すでにパスコードロック画面がかぶせてあるかを確認する
            let isDisplayedPasscodeLock: Bool = topViewController.children.map{
                return $0 is PasscodeViewController
            }.contains(true)

            // パスコードロック画面がかぶせてなければかぶせる
            if !isDisplayedPasscodeLock {
                let nav = UINavigationController(rootViewController: getPasscodeViewController())
                nav.modalPresentationStyle = .overFullScreen
                nav.modalTransitionStyle   = .crossDissolve
                topViewController.present(nav, animated: true, completion: nil)
            }
        }
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        // アプリ起動時も通知を行う
        completionHandler([ .badge, .sound, .alert ])
    }
    
}

private extension AppDelegate {
    
    private func forceUpdate() {
        let siren = Siren.shared
        // 言語を日本語に設定
        siren.presentationManager = PresentationManager(forceLanguageLocalization: .japanese)

        // ruleを設定
        siren.rulesManager = RulesManager(globalRules: .annoying)

        // sirenの実行関数
        siren.wail { results in
            switch results {
            case .success(let updateResults):
                print("AlertAction ", updateResults.alertAction)
                print("Localization ", updateResults.localization)
                print("Model ", updateResults.model)
                print("UpdateType ", updateResults.updateType)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension AppDelegate {
    /// AppDelegateのシングルトン
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}

