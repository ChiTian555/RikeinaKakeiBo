//
//  UIViewControllerExtension.swift
//  TouchIDExample
//
//  Created by 酒井文也 on 2018/08/29.
//  Copyright © 2018年 酒井文也. All rights reserved.
//

import Foundation
import UIKit
import PKHUD

//MARK: UIView

extension UIView {
    
    private var ud: UserDefaults { return UserDefaults.standard }
    
    public func setBackGroundPicture(alpha: CGFloat? = nil) {
        self.backgroundColor = .systemBackground
        let finalAlpha: CGFloat
        //背景画像を入れる器
        let currentBackGround = UIImageView(frame: self.bounds)
        if alpha == nil {
            finalAlpha = CGFloat(ud.integer(forKey: .alpha)) / 100
        } else {
            finalAlpha = alpha!
        }
        currentBackGround.image = ud.image(forKey: .backGraundPicture)?.alpha(finalAlpha)
        self.addSubview(currentBackGround)
        self.sendSubviewToBack(currentBackGround)
    }
    
    static func getOneColorView(color:UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        return view
    }
    
}

//MARK: UIViewCOntroller

// UIViewControllerの拡張
extension UIViewController {
    
    var nBar: UINavigationBar? { navigationController?.navigationBar }
    var tBar: UITabBar? { tabBarController?.tabBar }
    
    func setBarColor(color: UIColor) {
        tBar?.standardAppearance.backgroundColor = color
        if #available(iOS 15.0, *) {
            tBar?.scrollEdgeAppearance?.backgroundColor = color
        }
        nBar?.standardAppearance.backgroundColor = color
        nBar?.scrollEdgeAppearance?.backgroundColor = color
    }
    // この画面のナビゲーションバーを設定するメソッド
    public func setupNavigationBarTitle(_ title: String) {

        // NavigationControllerのデザイン調整を行う
        var attributes = [NSAttributedString.Key : Any]()
        attributes[NSAttributedString.Key.font] = UIFont(name: "HiraKakuProN-W6", size: 14.0)
        attributes[NSAttributedString.Key.foregroundColor]  = UIColor.label

        nBar?.isTranslucent = false
        nBar?.titleTextAttributes = attributes

        // タイトルを入れる
        self.navigationItem.title = title
    }

    // 戻るボタンの「戻る」テキストを削除した状態にするメソッド
    public func removeBackButtonText() {
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        self.navigationController!.navigationBar.tintColor = UIColor.label
        self.navigationItem.backBarButtonItem = backButtonItem
    }
    
    //キーボード外部タップによるキーボードを閉じる動作
    func setHideKeyboardTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    //キーボードの出現でスクロールビューを変更するのを監視用オブザーバー
    @objc func configureObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        //ここでUIKeyboardWillShowという名前の通知のイベントをオブザーバー登録をしている
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        //ここでUIKeyboardWillHideという名前の通知のイベントをオブザーバー登録をしている
    }
    
     //UIKeyboardWillShow通知を受けて、実行される関数
    @objc func keyboardWillShow(_ notification: NSNotification){
    }
       
       //UIKeyboardWillShow通知を受けて、実行される関数
    @objc func keyboardWillHide(_ notification: NSNotification){
    }
    
    func setSwipe() {
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(UIViewController.turnBuck))
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
    }
    
    @objc func turnBuck() {
        navigationController?.popViewController(animated: true)
    }
    
    func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
    
    
    /// カスタマイズされた、PKHudのつーる。
    /// - Parameters:
    ///   - content: type of hud
    ///   - delay: delay time
    ///   - completion: function after flash
    func flashHud(_ content: HUDContentType,
                  _ delay:Double = 2.0,
                  completion: ((Bool)->Void)? = nil) {
        HUD.flash(content, onView: view, delay: delay, completion: completion)
    }
    
}
