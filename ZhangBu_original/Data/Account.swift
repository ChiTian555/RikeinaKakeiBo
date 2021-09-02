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

class Check: Object {
    @objc dynamic var checkDate = Date()
    @objc dynamic var balance = Int()
}

class Account: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var type: String = ""
    //もし、ICのとき
    @objc dynamic var icType: Int = 0
    @objc dynamic var balance: Int = 0
    @objc dynamic private var isMustCheckAccont: Bool = false
    @objc dynamic var chargeAccount: String = ""
    private let check = List<Check>()
    
    //newCheckのset,get
    @objc dynamic var newCheck: Check? {
        get {
            return check.last
        }
        set(check) {
            guard let check = check else { return }
            let realm = try! Realm()
            try! realm.write() {
                self.check.append(check)
            }
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
    
    init?( name: String ) {
        let isDuplicated = Self.readAll().contains(where: {$0.name == name })
        if name == "" || isDuplicated { return nil }
        super.init()
        self.name = name
    }
    
    static func moveAccount(_ source: Account,_ destination: Account) -> Bool {
        let realm = try! Realm()
        print(destination.id, source.id)
        if destination.id > source.id  {
            let moveIdAccounts = realm.objects(Account.self)
                                .filter("id > %@ And id <= %@", source.id, destination.id) + []
            try! realm.write() {
                source.id = destination.id
                moveIdAccounts.forEach({ $0.id -= 1 })
            }
        } else if destination.id < source.id {
            //値を書き換えると、中の変数も変わっちゃう！
            let moveIdAccounts = realm.objects(Account.self)
                                .filter("id >= %@ And id < %@", destination.id, source.id) + []
            print(moveIdAccounts.count)
            try! realm.write() {
                source.id = destination.id
                moveIdAccounts.forEach({ $0.id += 1 })
            }
        } else {
            try! realm.write() {
                source.id += 1
            }
        }
        print(Account.readAll())
        return true
    }
    
    public func firstAdjustBalance(add addPrice: Int) {
        
        let realm = try! Realm()
        try! realm.write() {
            self.balance += addPrice
        }
    }
    
    static func updateBalance(newPayment: Payment?, deletePayment: Payment? = nil) {
        
        let realm = try! Realm()
        
        let payments: [Payment?] = [newPayment, deletePayment]
        for i in 0 ..< payments.count {
            guard let payment = payments[i] else { continue }
            if payment.paymentMethod == "" && payment.withdrawal == "" { return }
            if payment.mainCategoryNumber == 2 {
                guard let outAccount = realm.object(ofType: Account.self, forPrimaryKey: payment.withdrawal)
                    else { return }
                guard let inAccount = realm.object(ofType: Account.self, forPrimaryKey: payment.paymentMethod)
                    else { return }
                try! realm.write() {
                    inAccount.balance += payment.price * (i == 0 ? 1 : -1)
                    outAccount.balance -= payment.price * (i == 0 ? 1 : -1)
                }
            } else {
                guard let inAccount = realm.object(ofType: Account.self, forPrimaryKey: payment.paymentMethod)
                else { return }
                try! realm.write() {
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
        let realm = try! Realm()
        let object = realm.object(ofType: Account.self, forPrimaryKey: name)
            return object
    }
    
    static func readAll(isCredit: Bool? = nil) -> [Account] {
        let realm = try! Realm()
        var returnObjects: [Account]!
        let objects = realm.objects(Account.self).sorted(byKeyPath: "id", ascending: false)
        switch isCredit {
        case nil:
            returnObjects = objects + []
        case true:
            returnObjects = objects.filter("chargeAccount != ''") + []
        case false:
            returnObjects = objects.filter("chargeAccount == ''") + []
        case .some(_): break
        }
        return returnObjects
    }
    
    func isCanEdit() -> Bool {
        let realm = try! Realm()
        let objectsCount = realm.objects(Payment.self)
            .filter("paymentMethod = %@ OR withdrawal = %@" ,self.name, self.name) + []
        return objectsCount == [] ? true : false
    }
    
    static func mustCheckCount() -> Int {
        let realm = try! Realm()
        let objectsCount = realm.objects(Account.self).filter("isMustCheckAccont = %@", true).count
        return objectsCount
    }
    
    func isMustCheck(checked: Bool = false) -> Bool {
        if !self.isMustCheckAccont { return false }
        if checked {
            let realm = try! Realm()
            let object = realm.object(ofType: Account.self, forPrimaryKey: self.name)!
            try! realm.write() {
                object.isMustCheckAccont = false
            }
        }
        return true
    }
    
    // データを更新(Update)するためのコード
    func write(setValue: (Account) -> Void) -> Bool {
        guard let realm = Self.getRealm() else { return false }
        do { try realm.write() { setValue(self) } }
        catch { Self.realmError(error); return false }
        return true
    }
    
    func resetValue(newCheckValue: Check) {
        
        let realm = try! Realm()
        let objects = realm.object(ofType: Account.self, forPrimaryKey: self.name)!
        try! realm.write() {
            objects.setValue([newCheckValue], forKey: "check")
        }
        
    }

    // データを保存するためのコード
    override func save() {
        super.save()
        //チェックしたことのない口座タイプを登録した時
        var notChecked = UserDefaults.standard.stringArray1(forKey: .notDidCheckAccountTipe)!
        if notChecked.contains(self.type) {
            self.isMustCheckAccont = true
            notChecked.remove(at: notChecked.firstIndex(of: self.type)!)
            print(notChecked)
            UserDefaults.standard.setArray1(notChecked, forKey: .notDidCheckAccountTipe)
            let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
            tbc.setStartStep()
        }
    }

    
    static func restore(newPayment: [Account]) {
        let realm = try! Realm()
        try! realm.write() {
            realm.add(newPayment, update: .all)
        }
    }
    
}
