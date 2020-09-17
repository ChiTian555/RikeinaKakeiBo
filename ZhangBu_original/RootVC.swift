//
//  RootVCViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/04.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit

final class RootVC: UIViewController {
    // 現在表示しているViewControllerを示します
    var current: UIViewController
    var currentBackGround: UIImageView!

    init() {
        // 起動時最初の画面はSplashViewControllerを設定します
        current = SplashVC()
        
        super.init(nibName: nil, bundle: nil)
        //背景画像を入れる器
        currentBackGround = UIImageView(frame: view.bounds)
        self.view.addSubview(currentBackGround)
        self.view.sendSubviewToBack(currentBackGround)

        self.view.backgroundColor = .systemBackground
        self.picture = UserDefaults.standard.image()
    }
    // init()を実装したことによる必須実装
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // ViewControllerをRootVCの子VCとして追加
        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)
    }

    var picture: UIImage? {
        
        set(setImage) {
            currentBackGround.image = setImage
        }
        get {
            return currentBackGround.image
        }
    }
    
    /// RootVCの子VCを入れ替える＝ルートの画面を切り替える
    func transition(to vc: UIViewController) {
        // 新しい子VCを追加
        addChild(vc)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        print(current)
        // 現在のVCを削除する準備
        current.willMove(toParent: nil)
        // Superviewから現在のViewを削除
        current.view.removeFromSuperview()
        // RootVCから現在のVCを削除
        current.removeFromParent()
        // 現在のVCを更新
        current = vc
        
    }
    // 移動したいViewControllerごとに用意しておくと簡単に使用できる
    func transitionToMain() {
        // 切り替えたい先のViewControllerを用意
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        transition(to: vc)
    }
    
    func transitionToNFCTest() {
        // 切り替えたい先のViewControllerを用意
        let vc = UIStoryboard(name: "NFCReaderTest", bundle: nil).instantiateInitialViewController()!
        transition(to: vc)
    }
}
