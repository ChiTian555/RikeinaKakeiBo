//
//  BackUpVC.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/10/03.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import Firebase
import PKHUD

class BackUpVC: MainBaceVC {

    var user: User!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var mailLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.set()
        
        if let user = Auth.auth().currentUser { self.user = user } else {
            if let nc = UIStoryboard(name: "SignIn", bundle: nil).instantiateInitialViewController() as? MainNC {
//                nc.modalPresentationStyle = .fullScreen
                present(nc, animated: true, completion: nil)
            }
            return
        }
        
        nameLabel.text = user.displayName
        mailLabel.text = user.email
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if user == nil {
            if let user = Auth.auth().currentUser { self.user = user }
        }
        
    }
    
    public func setMainCurrent() {
        if user == nil {
            if let user = Auth.auth().currentUser { self.user = user } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func singout() {
        if let nc = UIStoryboard(name: "SignIn", bundle: nil).instantiateInitialViewController() {
            self.present(nc, animated: true, completion: nil)
        }
    }
    
    @IBAction func save() {
        let db = Firestore.firestore()
        
//        let accounts = Account.readAll()
//        let accountData = try! JSONEncoder().encode(accounts)
//        let categorys = CategoryList.readAllCategory(nil)
//        let categoryData = try! JSONEncoder().encode(categorys)
//        let payments = Payment.readAllPayment()
//        let paymentData = try! JSONEncoder().encode(payments)
//
//        HUD.show(.progress)
//        db.collection("users").document(user.uid).setData([
//            "accountData": accountData,
//            "categoryData": categoryData,
//            "paymentData": paymentData
//        ]) { error in
//            if let error = error {
//                // エラー処理
//                HUD.flash(.label(error.localizedDescription), delay: 2.0)
//                return
//            }
//            // 成功したときの処理
//            HUD.flash(.labeledSuccess(title: "成功", subtitle: "バックアップを保存しました"), delay: 1.0)
//        }
    }
    
    @IBAction func restore() {
//        let db = Firestore.firestore()
//        let documents = db.collection("users").document(user.uid)
//
//        documents.getDocument { (document, error) in
//            let accounts = try! JSONDecoder().decode(Array<Account>.self, from: document?["accountData"] as! Data)
//            let payments = try! JSONDecoder().decode(Array<Payment>.self, from: document?["paymentData"] as! Data)
//            let categorys = try! JSONDecoder().decode(Array<CategoryList>.self,
//                                                      from: document?["categoryData"] as! Data)
//            Account.restore(newPayment: accounts)
//            Payment.restore(newPayment: payments)
//            CategoryList.restore(newPayment: categorys)
//            print(accounts, payments, categorys)
//        }
        
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
