//
//  Account.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/15.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//
import RealmSwift
import SwiftDate
import Realm

class Check: Object, Codable {
    @objc dynamic var checkDate = Date()
    @objc dynamic var balance = Int()
}

final class Account: Object, Codable, MyRealmFunction {

    //migration:3
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var type: String = ""
    //もし、ICのとき
    @objc dynamic var icType: Int = 0
    @objc dynamic var balance: Int = 0
    @objc dynamic private var isMustCheckAccont: Bool = false
    @objc dynamic var chargeAccount: String = ""
    private var check = List<Check>()
    
    //migration:4
    @objc dynamic var createDate: Date = Date()
    
    // MARK: Functions
    
    //newCheckのset,get
    @objc dynamic var newCheck: Check? {
        get {
            return check.last
        }
        set(check) {
            guard let check = check else { return }
            try! myRealm.write() {
                self.check.append(check)
            }
            myRealm.beginWrite()
            
        }
    }
    
    // 初期設定
    override static func primaryKey() -> String? {
        return "name"
    }
    
    //保存しないプロパティの定義
    override static func ignoredProperties() -> [String] {
        return ["newCheck"]
    }
    
    class func get(_ name: String) -> Self? {
        return myRealm.object(ofType: Self.self, forPrimaryKey: name)
    }
    
    class func make(name: String) -> Self? {
        if name == "" || Self.get(name) != nil { return nil }
        let me = Self()
        me.id = ( myRealm.objects(Self.self).max(ofProperty: "id") ?? 0 ) + 1
        me.name = name
        return me
    }

    // 講座の並び替え
    static func moveAccount(_ source: Account,_ destination: Account) -> Bool {
        if destination.id > source.id  {
            let moveIdAccounts = myRealm.objects(Account.self)
                                .filter("id > %@ And id <= %@", source.id, destination.id) + []
            try! myRealm.write() {
                source.id = destination.id
                moveIdAccounts.forEach({ $0.id -= 1 })
            }
        } else if destination.id < source.id {
            //値を書き換えると、中の変数も変わっちゃう！
            let moveIdAccounts = myRealm.objects(Account.self)
                                .filter("id >= %@ And id < %@", destination.id, source.id) + []
            print(moveIdAccounts.count)
            try! myRealm.write() {
                source.id = destination.id
                moveIdAccounts.forEach({ $0.id += 1 })
            }
        }; return true
    }
    
    static func updateBalance(newPayment: Payment?, deletePayment: Payment? = nil) {
        
        let payments: [Payment?] = [newPayment, deletePayment]
        for i in 0 ..< payments.count {
            guard let payment = payments[i] else { continue }
            if payment.paymentMethod == "" && payment.withdrawal == "" { return }
            if payment.mainCategoryNumber == 2 {
                guard let outAccount = myRealm.object(ofType: Account.self, forPrimaryKey: payment.withdrawal)
                    else { return }
                guard let inAccount = myRealm.object(ofType: Account.self, forPrimaryKey: payment.paymentMethod)
                    else { return }
                try! myRealm.write() {
                    inAccount.balance += payment.price * (i == 0 ? 1 : -1)
                    outAccount.balance -= payment.price * (i == 0 ? 1 : -1)
                }
            } else {
                guard let inAccount = myRealm.object(ofType: Account.self, forPrimaryKey: payment.paymentMethod)
                else { return }
                try! myRealm.write() {
                    inAccount.balance += payment.price * (i == 0 ? 1 : -1)
                }
            }
        }
        return
    }
    
    func getFirstCheck() -> Check? {
        return (self.check.first)
    }
    
    //readするコード
    static func readValue(name: String) -> Account? {
        let object = myRealm.object(ofType: Account.self, forPrimaryKey: name)
            return object
    }
    
    static func readAll(isCredit: Bool? = nil) -> Results<Account> {
        var returnObjects: Results<Account>!
        let objects = myRealm.objects(Account.self).sorted(byKeyPath: "id", ascending: false)
        switch isCredit {
        case nil:
            returnObjects = objects
        case true:
            returnObjects = objects.filter("chargeAccount != ''")
        case false:
            returnObjects = objects.filter("chargeAccount == ''")
        case .some(_): break
        }
        return returnObjects
    }
    
    func isCanEdit() -> Bool {
        let objectsCount = myRealm.objects(Payment.self)
            .filter("paymentMethod = %@ OR withdrawal = %@" ,self.name, self.name) + []
        return objectsCount == [] ? true : false
    }
    
    static func mustCheckCount() -> Int {
        let objectsCount = myRealm.objects(Account.self).filter("isMustCheckAccont = %@", true).count
        return objectsCount
    }
    
    func isMustCheck(checked: Bool = false) -> Bool {
        if !self.isMustCheckAccont { return false }
        if checked {
            let object = myRealm.object(ofType: Account.self, forPrimaryKey: self.name)!
            try! myRealm.write() {
                object.isMustCheckAccont = false
            }
        }
        return true
    }
    
    func resetValue(newCheckValue: Check) {        
        if !self.write({ $0.setValue([newCheckValue], forKey: "check") }) {
            fatalError("Error: status=setNewCheckFaild")
        }
    }

    /// 新規データを保存。既存データなら->wright
    override func save() {
        super.save()
        //チェックしたことのない口座タイプを登録した時
        let notChecked = ud.stringArray(forKey: .notDidCheckAccountTipe)!
        if notChecked.contains(self.type) {
            _ = self.write { $0.isMustCheckAccont = true }
            ud.deleteArrayElement(self.type, forKey: .notDidCheckAccountTipe)
            let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
            tbc.setStartStep()
        }
    }
    override func delete() {
        CategoryList.deleteAccount(name: self.name)
        super.delete()
    }

    
    static func restore(newPayment: [Account]) {
        try! myRealm.write() {
            myRealm.add(newPayment, update: .all)
        }
    }
}
