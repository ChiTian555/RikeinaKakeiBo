//
//  BackUpVC.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/10/03.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import PKHUD
import SwiftDate
import GoogleMobileAds

class BackUpVC: MainBaceVC {

    private let ud = UserDefaults.standard
    var user: User! {
        didSet {
            nameLabel.text = user.displayName
            mailLabel.text = user.email
        }
    }
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var mailLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    var interstitial: GADRewardedAd! // 広告をnullで宣言
    var rewarded = false
    /// true: save, false: restore
    var willSave: Bool? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setSwipe()
        tableView.dataSource = self
        tableView.set()
        
        if let user = Auth.auth().currentUser {
            Auth.auth().currentUser?.reload(completion: { (error) in
                SignInVC.showErrorIfNeeded(error, target: self)
                if !user.isEmailVerified { HUD.flash(.label("本登録が\nなされていません。")) }
                self.user = user
            })
        } else {
            if let nc = UIStoryboard(name: "SignIn", bundle: nil).instantiateInitialViewController() as? MainNC {
//                nc.modalPresentationStyle = .fullScreen
                present(nc, animated: true, completion: nil)
            }
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if user == nil { if let user = Auth.auth().currentUser { self.user = user } }
        
        if rewarded && willSave != nil { saveAndLoad(); rewarded = false }
    }
    
    public func setMainCurrent() {
        if user == nil || !user.isEmailVerified {
            if let user = Auth.auth().currentUser { self.user = user } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func singout() {
        let alert = MyAlert("メニュー", nil, style: .actionSheet)
        alert.addActions("ログアウト") { _ in
            do {
                try Auth.auth().signOut()
                self.flashHud(.success) { _ in 
                    self.navigationController?.popViewController(animated: true)
                }
            }
            catch { HUD.flash(.label("予期せぬエラー\n\(error.localizedDescription)")) }
        }
        alert.addActions("ユーザー切替") { _ in
            if let nc = UIStoryboard(name: "SignIn", bundle: nil).instantiateInitialViewController() {
                self.present(nc, animated: true, completion: nil)
            }
        }
        alert.addActions("キャンセル", type: .cancel, nil)
        present(alert.controller, animated: true, completion: nil)
    }
    
    
    
    @IBAction func watchCM(_ button: UIButton) {
        
        if !user.isEmailVerified {
            HUD.flash(.label("本登録を完了させてください")); return
        }
        
        willSave = button.tag == 1
        let alert = MyAlert("注意", "数十秒の広告をみますか？")
        alert.addActions("いいえ", type: .cancel) { _ in HUD.flash(.label("\(button.currentTitle!)できません")) }
        alert.addActions("はい") { _ in
            HUD.show(.progress)
//            self.createAndLoadInterstitial()
            // 0.01秒周期で待機条件をクリアするまで待ちます。
            let semaphore = DispatchSemaphore(value: 0)
            DispatchQueue.global().async {
                self.createAndLoadInterstitial()
                while self.interstitial == nil {
                    DispatchQueue.main.async {
                        semaphore.signal()
                    }
                    semaphore.wait()
                    Thread.sleep(forTimeInterval: 0.5)
                }
                // 待機条件をクリアしたので通過後の処理を行います。
                DispatchQueue.main.async {
                    HUD.hide()
                    self.dispalyAd()
                    self.interstitial = nil
                }
            }
        }
        present(alert.controller, animated: true, completion: nil)
    }
    
    private func saveAndLoad() {
        let save = willSave!; willSave = nil
        if !save { restore(); return }
        let db = Firestore.firestore()
        let documents = db.collection("users").document(user.uid)
        documents.getDocument { (document, error) in
            if let error = error {
                HUD.flash(.labeledError(title: "Error", subtitle: error.localizedDescription)) }
            if let date = document?["uploadDate"] {
                let alert = MyAlert("既存のデータが見つかりました","\(date)に保存したデータに\n上書き保存しますか？")
                alert.addActions("キャンセル", type: .cancel, nil)
                alert.addActions("アップロード") { _ in self.saveToFireBase(db) }
                self.present(alert.controller, animated: true, completion: nil)
                return
            } else { self.saveToFireBase(db) }
        }
    }
    
    private func saveToFireBase(_ db: Firestore) {
        let accounts = Account.readAll()
        let accountData = try! JSONEncoder().encode(accounts)
        let categorys = CategoryList.readAllCategory(nil)
        let categoryData = try! JSONEncoder().encode(categorys)
        let payments = Payment.readAllPayment()
        let paymentData = try! JSONEncoder().encode(payments)
        
        let saccounts = try! JSONDecoder().decode(Array<Account>.self, from: accountData)
        let spayments = try! JSONDecoder().decode(Array<Payment>.self, from: paymentData)
        let scategorys = try! JSONDecoder().decode(Array<CategoryList>.self, from: categoryData)
        let appDomain = Bundle.main.bundleIdentifier!
        var dic = ud.persistentDomain(forName: appDomain)!
        dic.removeValue(forKey: UserDefaults.BoolKey.canUseNotification.strKey)
        let dataSet: [String:Any] = ["accountData": accountData,
                                     "categoryData": categoryData,
                                     "paymentData": paymentData,
                                     "uploadDate": DateInRegion().toFormat("yyyy/MM/dd"),
                                     "userDefault" : dic]
        print(saccounts,scategorys,spayments)

        HUD.show(.progress)
        db.collection("users").document(user.uid).setData(dataSet) { error in
            if let error = error {
                // エラー処理
                HUD.flash(.label(error.localizedDescription))
                print(error.localizedDescription)
                return
            }
            // 成功したときの処理
            HUD.flash(.labeledSuccess(title: "成功", subtitle: "バックアップを保存しました"))
        }
    }
    
    private func restore() {
        let db = Firestore.firestore()
        let documents = db.collection("users").document(user.uid)

        documents.getDocument { (document, error) in
            guard let date = ( document?["uploadDate"] as? String ) else {
                HUD.flash(.labeledError(title: "Error", subtitle: "ファイルが\n見つかりませんでした。")); return
            }
            let alert = MyAlert("\(date)に保存した、\nファイルが見つかりました","読み込みますか？")
            alert.addActions("キャンセル", type: .cancel, nil)
            alert.addActions("読み込む") { _ in
                let accounts = try! JSONDecoder().decode(Array<Account>.self, from: document?["accountData"] as! Data)
                let payments = try! JSONDecoder().decode(Array<Payment>.self, from: document?["paymentData"] as! Data)
                let categorys = try! JSONDecoder().decode(Array<CategoryList>.self,
                                                          from: document?["categoryData"] as! Data)
                let udDatas = document?["userDefault"] as! [String:Any]
                let appDomain = Bundle.main.bundleIdentifier!
                self.ud.removePersistentDomain(forName: appDomain)
                self.ud.setValuesForKeys(udDatas)
                // 成功したときの処理
                HUD.flash(.labeledSuccess(title: "成功", subtitle: "バックアップを読み込みました!"))
                Account.restore(newObjects: accounts)
                Payment.restore(newObjects: payments)
                CategoryList.restore(newPayment: categorys)
                
                if let tbc = SceneDelegate.shared.rootVC.current as? MainTBC {
                    tbc.setStartStep()
                }
                
                print(accounts, payments, categorys)
                print("読み込み完了！")
                
                // ここで、ビューの調整がしたい
            }
            self.present(alert.controller, animated: true, completion: nil)
        }
        
    }

    func createAndLoadInterstitial() {
        GADRewardedAd.load(withAdUnitID: adUnitID(.reward), request: GADRequest()) {
            (ad, error) in
            self.interstitial = ad
            if let error = error {
                print("Failed to load interstitial ad with error:\(error.localizedDescription)")
                HUD.hide()
                self.flashHud(.label("広告を読み込めませんでした")) { [self] _ in
                    if error.localizedDescription.contains("Publisher data not found.") {
                        if willSave != nil { saveAndLoad(); rewarded = false }
                    }
                }
                return
            }
            print("Loading Succeeded")
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
        }
      
    }
    
    //広告が表示用の関数。広告の準備があれば表示する処理を入れている。
    private func dispalyAd() {
        if let ad = self.interstitial {
            ad.present(fromRootViewController: self) {
                let reward = ad.adReward
                print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
                self.rewarded = true
            }
        } else { HUD.flash(.label("広告がありません。")) }
    }
    
    enum AdKeys: String { case reward }
    func adUnitID(_ key: AdKeys) -> String {
        let adUnitIDs = Bundle.main.object(forInfoDictionaryKey: "AdUnitIDs") as! [String: String]
        return adUnitIDs[key.rawValue]!
    }
    
}

extension BackUpVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}

extension BackUpVC: GADFullScreenContentDelegate {
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Rewarded ad presented.")
    }
    func ad( _ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error ) {
        HUD.flash(.label("予期せぬエラーです/n\(error.localizedDescription)"))
    }
}
