//
//  WalkThroughViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/06.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import EAIntroView
import UIKit

final class WalkThroughVC: UIViewController, EAIntroDelegate, UNUserNotificationCenterDelegate {

    var pages = [EAIntroPage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let page1 = EAIntroPage()
        page1.title = "はじめまして！"
        page1.desc = "アプリをインストールいただき\nありがとうございます！"
        
        pages.append(page1)
        
        let page2 = EAIntroPage()
        page2.title = "こちは、iPhoneアプリ\n「理系な家継簿」です!"
        page2.desc = "これからも、アプリ開発を続けますので\nご支援よろしくお願いします！"
        pages.append(page2)

        let page3 = EAIntroPage()
        page3.title = "家計簿を作り上げる\nのは、そう\nあなた自身です!"
        page3.desc = "理想の家計簿に仕上げていきましょう!"
        page3.descFont = UIFont.systemFont(ofSize: 15, weight: .light)
        page3.titleFont = UIFont(name: "Helvetica-Bold", size: 32)
        page3.titleColor = UIColor.orange
        page3.descPositionY = self.view.bounds.size.height/2
        pages.append(page3)
        
        let page4 = EAIntroPage()
        page4.title = "設定ページに意見箱を\n設けてます"
        page4.desc = "皆さんの貴重なご意見、感想を\nお待ちしております!"
        pages.append(page4)
        
        pages.forEach { (page) in
//            page.bgColor = .systemBackground
            if page != page3 {
                page.titleFont = UIFont.systemFont(ofSize: 24, weight: .heavy)
                page.descFont = UIFont.systemFont(ofSize: 15, weight: .light)
            }
            page.titleColor = .label
            page.descColor = .label
            page.bgImage = UIImage(named: "BackGround.jpeg")?.alpha(0.4)
        }

        
        let introView = EAIntroView(frame: self.view.bounds, andPages: pages)
        introView?.tintColor = .label
        introView?.backgroundColor = .systemBackground
        introView?.easeOutCrossDisolves = true
        introView?.skipButton.setTitle("完了", for: .normal)
        introView?.skipButton.setTitleColor(.systemOrange, for: .normal)
        introView?.delegate = self
        introView?.showSkipButtonOnlyOnLastPage = true
        introView?.show(in: self.view, animateDuration: 1.0)
    }
    
    func introWillFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        
//        //テスト画面に移動
//        SceneDelegate.shared.rootVC.transitionToNFCTest()
        
        UserDefaults.standard.setBool(true, forKey: .isWatchedWalkThrough)

        // 通知許可の取得
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, _) in
            if granted {
                UNUserNotificationCenter.current().delegate = AppDelegate.shared
            }
        }

        // メイン画面へ移動
        SceneDelegate.shared.rootVC.transitionToMain()
    }

}
