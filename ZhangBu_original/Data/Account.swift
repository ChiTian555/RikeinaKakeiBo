//
//  Account.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/15.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//
import RealmSwift
import SwiftDate

class Check: Object {
    @objc dynamic var checkDate = Date()
    @objc dynamic var balance = Int()
}

class Account: Object {
    
    @objc dynamic private var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var balance: Int = 0
    @objc dynamic private var isMustCheckAccont: Bool = false
    private let check = List<Check>()
    @objc dynamic var newCheck = Check()
//    @objc dynamic var accountUIColor: UIColor = UIColor()
    
    // 初期設定
    override static func primaryKey() -> String? {
        return "name"
    }
    
    //保存しないプロパティの定義
    override static func ignoredProperties() -> [String] {
        return ["newCheck"]
    }
    
    static func lastId() -> Int {
        let realm = try! Realm()
        if let object = realm.objects(Account.self).sorted(byKeyPath: "id").last {
            return object.id + 1
        } else {
            return 0
        }
    }
    
    // 作成(Create)のためのコード
    static func create(name: String) -> Account? {
        
        let isDuplicated = readAll().contains(where: {$0.name == name })
        if name == "" || isDuplicated {
            return nil
        }
        let account = Account()
        account.id = lastId()
        account.name = name
        return account
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
    
    func getNewCheck() -> Check? {
        return (self.check.last)
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
    
    static func readAll() -> [Account] {
        let realm = try! Realm()
        let objects = realm.objects(Account.self).sorted(byKeyPath: "id", ascending: false) + []
        return objects
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
    func setValue(newCheckValue: Check? , newAccout: Account? = nil) {
        let realm = try! Realm()
        let objects = realm.object(ofType: Account.self, forPrimaryKey: self.name)!
        try! realm.write() {
            if newAccout != nil {
                if newAccout?.name != "" {
                    objects.name = newAccout!.name
                }
                if newAccout?.type != "" {
                    objects.type = newAccout!.type
                }
            }
            if newCheckValue != nil {
                objects.check.append(newCheckValue!)
            }
        }
    }
    
    func resetValue(newCheckValue: Check) {
        
        let realm = try! Realm()
        let objects = realm.object(ofType: Account.self, forPrimaryKey: self.name)!
        try! realm.write() {
            objects.setValue([newCheckValue], forKey: "check")
        }
        
    }

    // データを保存するためのコード
    func save() {
        let realm = try! Realm()
        
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
        
        try! realm.write() {
            realm.add(self)
        }
    }
    
    // データを削除(Delete)するためのコード
    func delete() {
        let realm = try! Realm()
        let objects = realm.object(ofType: Account.self, forPrimaryKey: self.name)!
        try! realm.write() {
            realm.delete(objects)
        }
    }
}
