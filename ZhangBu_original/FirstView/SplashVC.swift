//
//  ViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/08.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit

final class SplashVC: UIViewController {
    
    /// 処理中を示すインジケーター
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.frame = view.bounds
        indicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
        return indicator
    }()
    
    var t:CGFloat = 0.0
    
    let screenSize: CGSize = CGSize(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height)
    
    var timer: Timer!
    
    let thita: CGFloat = CGFloat.random(in: 0 ... 2 * CGFloat.pi)
    
    var backgroundTaskID: UIBackgroundTaskIdentifier!
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "理系の家継簿"
        titleLabel.font = UIFont.systemFont(ofSize: 30)
        let frame = CGRectMake(screenSize.width, screenSize.height, 200, 50)
        titleLabel.frame = frame
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        return titleLabel
   }()
    
    override func viewDidLoad() {
        
        
        view.addSubview(titleLabel)
//        view.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
        titleLabel.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        //timerをスタートさせる、timeIntervalおきに関数を呼び出せる。
        timer = Timer.scheduledTimer(timeInterval: Double(0.01), target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
    }
    
    //セレクターで呼び出す関数の指定方法
    @objc func update() {
        
        //1巡し終わるまでの処理を実行
        if t <= CGFloat.pi {
            
            //青い点(UIImageView)を設定する！
            let addCircle = UIImageView()
            addCircle.tintColor = UIColor.orange
            addCircle.image = UIImage(systemName: "circle.fill")
            addCircle.frame.size = CGSize(width: 5, height: 5)
            
            //座標の指定！
            let x = 0.8 * cos( 6.0 * t )
            let y = 0.8 * sin( 4.0 * t + thita)
            addCircle.center = CGPoint(x: (screenSize.width / 2) * ( 1.0 + x),
                                       y: (screenSize.height / 2) * ( 1.0 + y))
            //UIViewの貼り付け
            self.view.addSubview(addCircle)
            
            //モーションが半ばに入った時、上から「大学生の家計簿」のラベルを下ろしてくる！
            if t >= 0.5 * CGFloat.pi  {
                
                titleLabel.isHidden = false
                titleLabel.center = CGPoint(x: screenSize.width / 2,
                                       y: screenSize.height * ((t / (CGFloat.pi)) - 0.5))
            }
            t += 0.01
            return
        }
        
        timer.invalidate()
        
        if SceneDelegate.shared.rootVC.current == self {
            // メイン画面へ移動
            SceneDelegate.shared.rootVC.transitionToMain()
            print("メイン画面へ移動")
        }
            
//        displayPasscodeLockScreenIfNeeded(keyWindow: keyWindow)
        UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
        
    }
    

    // MARK: - Private Function

    private func displayPasscodeLockScreenIfNeeded(keyWindow: UIWindow?) {
        let passcodeModel = PasscodeModel()

        // パスコードロックを設定していない場合は何もしない
        if !passcodeModel.existsHashedPasscode() {
            return
        }
        
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
    
    //CGRectを簡単に作る
    private func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }

}

