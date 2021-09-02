//
//  Payment.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/15.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//
import RealmSwift
import SwiftDate
import Realm

class Payment: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var isUsePoketMoney: Bool = true
    @objc dynamic var date: Date = Date()
    @objc dynamic var addDate: Date = Date()
    @objc dynamic var category = String()
    
    //(2.0)に実装
    @objc dynamic var userCategory = String()
    
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
    
    // データを更新(Update)するためのコード
     func setValue(newValue newPayment: Payment) {
        let realm = try! Realm()

        Account.updateBalance(newPayment: newPayment, deletePayment: self)
        try! realm.write() {
            self.date = newPayment.date
            self.userCategory = newPayment.userCategory
            self.category = newPayment.category
            self.memo = newPayment.memo
            self.paymentMethod = newPayment.paymentMethod
            self.withdrawal = newPayment.withdrawal
            self.price = newPayment.price
            self.mainCategoryNumber = newPayment.mainCategoryNumber
        }
    }

    // データを保存するためのコード
    override func save() {
        super.save()
        if self.mainCategoryNumber == 1 {
            self.isUsePoketMoney = false
        }; Account.updateBalance(newPayment: self)
    }
    
    static func readAllPayment() -> [Payment] {
        let realm = try! Realm()
        return realm.objects(Payment.self) + []
    }
    
    //追加日時から割り勘を設定
    static func readSortedByAddDate(_ mainCategory: Int?) -> [Payment] {
        let realm = try! Realm()
        var payments = realm.objects(Payment.self).sorted(byKeyPath: "addDate")
        if let main = mainCategory {
            payments = payments.filter("category == %@", main)
        }; return payments.prefix(5) + []
    }
    
    static func getMonthPayment(_ mainCategory: Int, year: Int, month: Int, category: String? = nil) -> Results<Payment> {
        
        let realm = try! Realm()
        let firstDate = DateInRegion(year: year, month: month, day: 1).date
        let endDate = DateInRegion(year: year, month: month + 1, day: 1).date
        var monthRealmPayments = realm.objects(Payment.self)
            .filter("mainCategoryNumber == \(mainCategory)")
            .filter("date >= %@ AND date < %@", firstDate, endDate)
        if let category = category {
            monthRealmPayments = monthRealmPayments.filter("category == %@", category)
        }
        return monthRealmPayments
    }
    
    //日にちの前後
    static func getCreditPaymentSum(_ account: Account, endDate: Date) -> Int {
        let realm = try! Realm()
        let creditPayments = realm.objects(Payment.self)
            .filter("mainCategoryNumber != %@ AND paymentMethod == %@", 2, account.name)
        var sum: Int!
        if let startDate = account.newCheck?.checkDate {
            sum = creditPayments.filter("date >= %@ AND date < %@", startDate, endDate)
                .sum(ofProperty: "price")
        } else {
            sum = creditPayments.filter("date < %@", endDate)
                .sum(ofProperty: "price")
        }
        return sum
    }
    
    // データを削除(Delete)するためのコード
    override func delete() {
        Account.updateBalance(newPayment: nil, deletePayment: self)
        delete()
    }
    
    static func restore(newPayment: [Payment]) {
        let realm = try! Realm()
        try! realm.write() {
            realm.add(newPayment, update: .all)
        }
    }
}
