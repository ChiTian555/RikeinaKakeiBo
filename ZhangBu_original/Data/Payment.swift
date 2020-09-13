//
//  Payment.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/15.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//
import RealmSwift
import SwiftDate

class Payment: Object {
    
    @objc dynamic private var id: Int = 0
    @objc dynamic var isUsePoketMoney: Bool = true
    @objc dynamic var date: Date = Date()
    @objc dynamic var category = String()
    @objc dynamic var memo = String()
    //出金、入金の支払い方法
    @objc dynamic var paymentMethod = String()
    //金銭移動の出金
    @objc dynamic var withdrawal = String()
    @objc dynamic var price: Int = 0
    @objc dynamic var mainCategoryNumber: Int = 0
//    @objc dynamic var userCategory = [String]()
    
    // 初期設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func lastId() -> Int {
        let realm = try! Realm()
        if let object = realm.objects(Payment.self).last {
            return object.id + 1
        } else {
            return 1
        }
    }
    
    // 作成(Create)のためのコード
    static func create() -> Payment {
        let payment = Payment()
        payment.id = lastId()
        return payment
    }
    
    // データを更新(Update)するためのコード
     func setValue(newValue newPayment: Payment) {
        let realm = try! Realm()

        Account.updateBalance(newPayment: newPayment, deletePayment: self)
        try! realm.write() {
            self.date = newPayment.date
            self.category = newPayment.category
            self.memo = newPayment.memo
            self.paymentMethod = newPayment.paymentMethod
            self.withdrawal = newPayment.withdrawal
            self.price = newPayment.price
            self.mainCategoryNumber = newPayment.mainCategoryNumber
        }
    }

    // データを保存するためのコード
    func save() {
        let realm = try! Realm()
        if self.mainCategoryNumber == 1 {
            self.isUsePoketMoney = false
        }
        Account.updateBalance(newPayment: self)
        
        try! realm.write() {
            realm.add(self)
        }
    }
    
    // データを削除(Delete)するためのコード
    func delete() {
        let realm = try! Realm()
        Account.updateBalance(newPayment: nil, deletePayment: self)
        try! realm.write() {
            realm.delete(self)
        }
    }
}
