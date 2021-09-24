//
//  ViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/08.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import Siren
import CropViewController
import PKHUD
import RealmSwift

final class SplashVC: MainBaceVC {
    
    private let ud = UserDefaults.standard
    
//    /// 処理中を示すインジケーター
//    private lazy var activityIndicator: UIActivityIndicatorView = {
//        let indicator = UIActivityIndicatorView(style: .large)
//        indicator.frame = view.bounds
//        indicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
//        return indicator
//    }()
    
    var t:CGFloat = 0.0
    
    let screenSize: CGSize = CGSize(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height)
    
    var timer: Timer!
    
    let thita: CGFloat = CGFloat.random(in: 0 ... 2 * CGFloat.pi)
    
    var backgroundTaskID: UIBackgroundTaskIdentifier!
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "理系な家継簿"
        titleLabel.font = UIFont(name: "ERIJI", size: 40)
//        let frame = CGRectMake(0, 0, screenSize.width, 50)
//        titleLabel.frame = frame
        titleLabel.sizeToFit()
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        titleLabel.layer.cornerRadius = titleLabel.bounds.height / 4
        titleLabel.clipsToBounds = true
        return titleLabel
   }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(titleLabel)
//        view.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
        titleLabel.isHidden = true
        
        let swipeGuestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        swipeGuestureLeft.direction = .left
        let swipeGuestureUp = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        swipeGuestureUp.direction = .up
        view.addGestureRecognizer(swipeGuestureLeft)
        view.addGestureRecognizer(swipeGuestureUp)
        view.isUserInteractionEnabled = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        //timerをスタートさせる、timeIntervalおきに関数を呼び出せる。
        timer = Timer.scheduledTimer(timeInterval: Double(0.01), target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
    }
    
    //セレクターで呼び出す関数の指定方法
    @objc func update() {
        
        DispatchQueue.main.async { [self] in
            
            //1巡し終わるまでの処理を実行
            if t <= CGFloat.pi {
                
                //青い点(UIImageView)を設定する！
                let addCircle = UIImageView()
                addCircle.tintColor = UIColor.orange.withAlphaComponent(0.6)
                addCircle.image = UIImage(systemName: "circle.fill")
                addCircle.frame.size = CGSize(width: 5, height: 5)
                
                //座標の指定！
                let x = 0.8 * cos( 6.0 * t )
                let y = 0.8 * sin( 4.0 * t + thita)
                addCircle.center = CGPoint(x: (screenSize.width / 2) * ( 1.0 + x ),
                                           y: (screenSize.height / 2) * ( 1.0 + y ))
                //UIViewの貼り付け
                self.view.addSubview(addCircle)
                
                //モーションが半ばに入った時、上から「大学生の家計簿」のラベルを下ろしてくる！
                if t >= 0.5 * CGFloat.pi  {
                    
                    titleLabel.isHidden = false
                    titleLabel.center = CGPoint(x: screenSize.width / 2,
                                           y: screenSize.height * ((t / (CGFloat.pi)) - 0.5))
                }
            }
            
            t += 0.01
            if t <= 4 { return }
            
            timer.invalidate()
            let scene = SceneDelegate.shared
            
            if scene.rootVC.current == self {
    //            //背景画像追加
    //            scene.rootVC.addPicture()
                
                if !ud.bool(forKey: .isWatchedWalkThrough) {
                    let walkThroughVC = WalkThroughVC()
                    scene.rootVC.transition(to: walkThroughVC)
                } else {
                    //パスワード画面を表示
                    scene.displayPasscodeLockScreenIfNeeded()
                    // メイン画面へ移動
                    scene.rootVC.transitionToMain()

                    print("メイン画面へ移動")
                }
                
            }
                
    //        displayPasscodeLockScreenIfNeeded(keyWindow: keyWindow)
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
        
        }
    
    }
    
//    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
//
//        guard motion == .motionShake else { return }
//
//        if let timer = timer {
//            timer.invalidate()
//        }
//
//        let alert = UIAlertController(title: "メニュー", message: "画面を\n→スワイプ：出費手入力画面へ\n←スワイプ：レシートの撮影", preferredStyle: .alert)
//        let swipeGuestureRight = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
//        swipeGuestureRight.direction = .right
//        let swipeGuestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
//        swipeGuestureLeft.direction = .left
//        present(alert, animated: true, completion: {
//
//            alert.view.superview?.addGestureRecognizer(swipeGuestureRight)
//            alert.view.superview?.addGestureRecognizer(swipeGuestureLeft)
//            alert.view.superview?.isUserInteractionEnabled = true
//        })
//    }
    
    @objc private func swiped(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left: goToAddPayment()
        case .up: takePhoto()
        default: break
        }
    }
    
    //右スワイプ
    private func goToAddPayment() {
    
        let scene = SceneDelegate.shared
        
        if scene.rootVC.current != self { return }
        
        if !ud.bool(forKey: .isWatchedWalkThrough) {
            let walkThroughVC = WalkThroughVC()
            scene.rootVC.transition(to: walkThroughVC)
        } else {
            //パスワード画面を表示
            scene.displayPasscodeLockScreenIfNeeded()
            // メイン画面へ移動
            scene.rootVC.transitionToMain()
            if let tbc = scene.rootVC.current as? MainTBC {
                guard let nc = tbc.selectedViewController as? UINavigationController else { return }
                guard let vc = nc.topViewController as? AddPaymentVC else { return }
            }
            print("メイン画面へ移動")
        }
            
        
    }
    
    // 上スワイプ
    private func takePhoto() {
        timer.fire()
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            picker.sourceType = .photoLibrary
        } else {
            HUD.flash(.labeledError(title: "エラー", subtitle: "カメラ,アルバム機能が使えません"), delay: 2)
            return
        }
        
        picker.delegate = self
        // UIImagePickerController カメラを起動する
        present(picker, animated: true, completion: nil)
    }
    //CGRectを簡単に作る
    private func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }

}

extension SplashVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
        
    func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        let receipt = Receipt.make()
        receipt.photo = image
        receipt.save()
        cropViewController.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        var image = info[.originalImage] as! UIImage
        guard let pickerImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        
        let cropController = CropViewController(croppingStyle: .default, image: pickerImage)
        cropController.delegate = self
        //サイズ指定！
        cropController.customAspectRatio = view.bounds.size
        
        //今回は使わないボタン等を非表示にする。
        cropController.aspectRatioPickerButtonHidden = true
        cropController.resetAspectRatioEnabled = false
        cropController.rotateButtonsHidden = true
        
        cropController.cropView.cropViewPadding = 25
        
        //cropBoxのサイズを固定する。
        cropController.cropView.cropBoxResizeEnabled = false
        //pickerを閉じたら、cropControllerを表示する。
        picker.dismiss(animated: true) {
            self.present(cropController, animated: true, completion: nil)
        }
    }
}

