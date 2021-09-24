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

final class Payment: Object, Codable, MyRealmFunction {
    
    // migration:3
    @objc dynamic var id: Int = 0
    @objc dynamic var isUsePoketMoney: Bool = true
    /// 0 -> pay, 1 -> get, 2 -> trade
    @objc dynamic var mainCategoryNumber: Int = 0 {
        didSet { if mainCategoryNumber == 1 { isUsePoketMoney = false } }
    }
    @objc dynamic var price: Int = 0
    @objc dynamic var date: Date = Date()
    @objc dynamic var category = String()
    @objc dynamic var userCategory = String() //(1.0)に実装
    @objc dynamic var memo = String()
    @objc dynamic var paymentMethod = String() // 出金、入金の支払い方法
    @objc dynamic var withdrawal = String() // 金銭移動の出金講座
    
    // migration:4
    @objc dynamic var avoidSpending = false

    // 初期設定
    override static func primaryKey() -> String? { return "id" }
    
    class func make() -> Self {
        let me = Self()
        me.id = ( myRealm.objects(Self.self).max(ofProperty: "id") ?? 0 ) + 1
        return me
    }
    
    static func readAllPayment() -> [Payment] {
        return myRealm.objects(Payment.self) + []
    }
    
    //追加日時から割り勘を設定
    static func readSortedByAddDate(_ mainCategory: Int?) -> [Payment] {
        var payments = myRealm.objects(Payment.self).sorted(byKeyPath: "addDate")
        if let main = mainCategory {
            payments = payments.filter("category == %@", main)
        }; return payments.prefix(5) + []
    }
    
    static func getMonthPayment(_ mainCategory: Int, year: Int, month: Int, category: String? = nil) -> Results<Payment> {
        
        let firstDate = DateInRegion(year: year, month: month, day: 1).date
        let endDate = DateInRegion(year: year, month: month + 1, day: 1).date
        var monthRealmPayments = myRealm.objects(Payment.self)
            .filter("mainCategoryNumber == \(mainCategory)")
            .filter("date >= %@ AND date < %@", firstDate, endDate)
        if let category = category {
            monthRealmPayments = monthRealmPayments.filter("category == %@", category)
        }
        return monthRealmPayments
    }
    
    //日にちの前後
    static func getCreditPaymentSum(_ account: Account, endDate: Date) -> Int {
        let creditPayments = myRealm.objects(Payment.self)
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
    
    // データを保存するためのコード
    override func save() {
        super.save()
        updatePocketMoney(added: true)
        if !avoidSpending { Account.updateBalance(newPayment: self) }
    }
    
    // データを削除(Delete)するためのコード
    override func delete() {
        self.updatePocketMoney(added: false)
        if !avoidSpending { Account.updateBalance(newPayment: nil, deletePayment: self) }
        super.delete()
    }
    
    func updatePocketMoney(added: Bool) {
        if self.isUsePoketMoney {
            var nowPoketMoney = ud.integer(forKey: .pocketMoney) 
            nowPoketMoney += self.price * ((added) ? 1 : -1)
            ud.setInteger(nowPoketMoney, forKey: .pocketMoney)
        }
    }
    
    func setValue(title: String, value: String)  {
        
        if title == "金額" { self.price = Int(value)! }
        else if title == "日付" { self.date = value.toDate("yyyy-MM-dd")!.date }
        else if mainCategoryNumber == 0 {
            if title == "項目" { self.category = value }
            else if title == "決済方法" { self.paymentMethod = value }
            else { self.userCategory = value }
        } else if mainCategoryNumber == 1 {
            if title == "項目" { self.category = value }
            else if title == "入金口座" { self.paymentMethod = value }
            else { self.userCategory = value }
        } else if mainCategoryNumber == 2 {
            if title == "出金口座" { self.withdrawal = value }
            else if title == "入金口座" { self.paymentMethod = value }
            else { self.userCategory = value }
        }
    }
    
    func getValue(title: String) -> String {
        if title == "金額" { return "\(self.price)" }
        if title == "日付" { return self.date.toFormat("yyyy-MM-dd") }
        if mainCategoryNumber == 0 {
            if title == "項目" { return self.category }
            else if title == "決済方法" { return self.paymentMethod }
            else { return self.userCategory }
        } else if mainCategoryNumber == 1 {
            if title == "項目" { return self.category }
            else if title == "入金口座" { return self.paymentMethod }
            else { return self.userCategory }
        } else if mainCategoryNumber == 2 {
            if title == "出金口座" { return self.withdrawal }
            else if title == "入金口座" { return self.paymentMethod }
            else { return self.userCategory }
        }; return ""
    }
}
