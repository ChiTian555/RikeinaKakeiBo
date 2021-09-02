//
//  TestAddMobViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/26.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds

class TestAddMobViewController: MainBaceVC, GADFullScreenContentDelegate {
    
    var timer = Timer()
    var timer2 = Timer()
    var count:Int = 3
    
    var interstitial: GADInterstitialAd! // 広告をnullで宣言
    var adunitID = "ca-app-pub-3940256099942544/4411468910"

    override func viewDidLoad() {
        super.viewDidLoad()
        createAndLoadInterstitial() //読み込みに少し時間がかかるよ。
    }
    
    
    
    func createAndLoadInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-8123415297019784/4985798738",
                               request: request, completionHandler: { (ad, error) in
            if let error = error {
                print("Failed to load interstitial ad with error:\(error.localizedDescription)")
                      return
            }
            self.interstitial = ad
            self.interstitial.fullScreenContentDelegate = self
        })
    }
    
    @IBAction func startTest() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target:self, selector: #selector(self.countDown), userInfo:nil, repeats:true)
    }
    
    //タイマーから呼び出されるメソッド
    @objc func countDown(){
        
        //カウントを減してラベル文字を更新
        count -= 1
        print("残り：\(count)")
        
        //1以上
        if(count > 0) {
            
            //カウントが0になったら
        } else if (count == 0) {
            self.alertDisplay()
            timer.invalidate()
            
            //カウントを元の状態に戻す
            count = 3
            print("残り：3")
        }
    }
    
    //アラート（ポップアップ）表示
    func alertDisplay() {
        
        //ポップアップを実装
        let alertController = UIAlertController(title: "広告", message: "広告を表示しますか？", preferredStyle: UIAlertController.Style.alert)
        
        //はいボタンの実装
        let okAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default){ (action: UIAlertAction) in
            //「はい」がクリックされた時の処理
            print("はいをクリック")
            //広告を表示する関数の呼び出し
            self.dispalyAd()
        }
        //いいえボタンの実装
        let cancelButton = UIAlertAction(title: "いいえ", style: UIAlertAction.Style.cancel, handler: nil)
        //はいボタンをポップアップのビューに追加
        alertController.addAction(okAction)
        //いいえボタンをポップアップのビューに追加
        alertController.addAction(cancelButton)
        //アラートの表示
        present(alertController,animated: true,completion: nil)
    }
    
    //広告が表示用の関数。広告の準備があれば表示する処理を入れている。
    @objc func dispalyAd() {
        if let ad = self.interstitial {
            print("広告準備あり")
            ad.present(fromRootViewController: self)
        } else {
            print("広告の準備がない")
        }
    }
    
    //デリゲートメソッド。インタースティシャル広告が閉じられた時にもう一度createAndLoadInterstitialメソッドを呼び出し、
    // 新しい広告をロードしています。これを実装しないと、インタースティシャル広告は一度しか表示されなくなる。
    /// Tells the delegate that the rewarded ad was presented.
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Rewarded ad presented.")
        createAndLoadInterstitial()
    }
    /// Tells the delegate that the rewarded ad was dismissed.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Rewarded ad dismissed.")
    }
    /// Tells the delegate that the rewarded ad failed to present.
    func ad(_ ad: GADFullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        print("Rewarded ad failed to present with error: \(error.localizedDescription).")
    }
    
    @IBAction func upload() {
        
        if let realmFileURL = Realm.Configuration.defaultConfiguration.fileURL {
            print(realmFileURL)
            do {
                let uploaddata = try NSData(contentsOf: realmFileURL, options: [])
                print(uploaddata)
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
}
