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

final class Payment: MyRealm {
    
    @objc dynamic var isUsePoketMoney: Bool = true
    
    @objc dynamic var mainCategoryNumber: Int = 0
    @objc dynamic var price: Int = 0
    @objc dynamic var date: Date = Date()
   
    @objc dynamic var addDate: Date = Date()
    @objc dynamic var category = String()
    
    //(2.0)に実装
    @objc dynamic var userCategory = String()
    
    @objc dynamic var memo = String()
    // 出金、入金の支払い方法
    @objc dynamic var paymentMethod = String()
    // 金銭移動の出金講座
    @objc dynamic var withdrawal = String()

    // 初期設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func write(_ set: (Payment) -> Void) -> Bool {
        let oldPayment = self.copy() as! Payment
        guard let realm = Self.getRealm() else { return false }
        do { try realm.write() { set(self) } }
        catch { Self.realmError(error); return false }
        Account.updateBalance(newPayment: self, deletePayment: oldPayment)
        return true
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
        super.delete()
    }
    
    static func restore(newPayment: [Payment]) {
        let realm = try! Realm()
        try! realm.write() {
            realm.add(newPayment, update: .all)
        }
    }
    
    func set(title: String, value: String?) -> Bool {
        guard let value = value else { return false }
        if mainCategoryNumber == 0 {
            if title == "項目" { self.category = title }
            else if title == "決済方法" { self.paymentMethod = value }
            else { self.userCategory = value }
        } else if mainCategoryNumber == 1 {
            if title == "項目" { self.category = title }
            else if title == "入金講座" { self.paymentMethod = value }
            else { self.userCategory = value }
        } else if mainCategoryNumber == 2 {
            if title == "出金講座" { self.withdrawal = title }
            else if title == "入金講座" { self.paymentMethod = value }
            else { self.userCategory = value }
        }
        return true
    }
}
