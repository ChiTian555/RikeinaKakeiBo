//
//  Payment.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/15.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//
import RealmSwift

class Payment: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var date: Date = Date()
    @objc dynamic var category = String()
    @objc dynamic var memo = String()
    @objc dynamic var paymentMethod = String()
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
        let objects = realm.object(ofType: Payment.self, forPrimaryKey: self.id)!
        try! realm.write() {
            objects.date = newPayment.date
            objects.category = newPayment.category
            objects.memo = newPayment.memo
            objects.paymentMethod = newPayment.paymentMethod
            objects.withdrawal = newPayment.withdrawal
            objects.price = newPayment.price
            objects.mainCategoryNumber = newPayment.mainCategoryNumber
        }
    }

    // データを保存するためのコード
    func save() {
        let realm = try! Realm()
        try! realm.write() {
            realm.add(self)
        }
    }
    
    // データを削除(Delete)するためのコード
    func delete() {
        let realm = try! Realm()
        let objects = realm.object(ofType: Payment.self, forPrimaryKey: self.id)!
        try! realm.write() {
            realm.delete(objects)
        }
    }
}
