//
//  Payment.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/15.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//
import RealmSwift

class Account: Object {
    
    @objc dynamic private var id: Int = 0
    @objc dynamic var accountName: String = ""
    @objc dynamic var accountTipe: String = ""
    private let checkDates = List<Date>()
    private let balance = List<Int>()
    private let difference = List<Int>()
    @objc dynamic var newCheckDate: Date = Date()
    @objc dynamic var newBalance: Int = Int()
    @objc dynamic var newDifference: Int = Int()
//    @objc dynamic var accountUIColor: UIColor = UIColor()
    
    
    // 初期設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    //保存しないプロパティの定義
    override static func ignoredProperties() -> [String] {
     return ["newCheckDate","newBalance","newDifference","accountUIColor"]
    }
    
    static func lastId() -> Int {
        let realm = try! Realm()
        if let object = realm.objects(Account.self).last {
            return object.id + 1
        } else {
            return 1
        }
    }
    // 作成(Create)のためのコード
    static func create() -> Account {
        let account = Account()
        account.id = lastId()
        return account
    }
    
    func getNewCheck() -> (date:Date?, balance:Int?, diffrence:Int?) {
        return (self.checkDates.last, self.balance.last, self.difference.last)
    }
    
    //readするコード
    static func readValue(id: Int) -> Account {
        let realm = try! Realm()
            let object = realm.object(ofType: Account.self, forPrimaryKey: id)!
//            object.accountUIColor = UIColor(code: object.colorCode)
            return object
    }
    
    static func readAll() -> [Account] {
        let realm = try! Realm()
        let objects = realm.objects(Account.self) + []
        return objects
    }
    
    // データを更新(Update)するためのコード
    func setValue() {
        let realm = try! Realm()
        let objects = realm.object(ofType: Account.self, forPrimaryKey: self.id)!
        try! realm.write() {
            objects.accountName = self.accountName
//            objects.colorCode = self.accountUIColor.hex(withHash: true, uppercase: true)
            objects.checkDates.append(self.newCheckDate)
            objects.balance.append(self.newBalance)
            objects.difference.append(self.newDifference)
        }
    }

    // データを保存するためのコード
    func save() {
        let realm = try! Realm()
//        self.colorCode = self.accountUIColor.hex(withHash: true, uppercase: true)
        self.checkDates.append(self.newCheckDate)
        self.balance.append(self.newBalance)
        try! realm.write() {
            realm.add(self)
        }
    }
    
    // データを削除(Delete)するためのコード
    func delete() {
        let realm = try! Realm()
        let objects = realm.object(ofType: Account.self, forPrimaryKey: self.id)!
        try! realm.write() {
            realm.delete(objects)
        }
    }
}
