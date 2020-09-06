//
//  Payment.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/15.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//
import RealmSwift

class CategoryList: Object {
    
    @objc dynamic private var id: Int = 0
    @objc dynamic var mainCategory: Int = 0
    @objc dynamic var categoryName: String = ""
    @objc dynamic var selectAccount: Bool = false
    let list = List<String>()
    
    
    
    // 初期設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func lastId() -> Int {
        let realm = try! Realm()
        if let object = realm.objects(CategoryList.self).last {
            return object.id + 1
        } else {
            return 1
        }
    }
    // 作成(Create)のためのコード
    static func create() -> CategoryList {
        let account = CategoryList()
        account.id = lastId()
        return account
    }
    
    //readするコード
    static func readCategory(_ mainCategory:Int,_ categoryName: String ) -> CategoryList {
        let realm = try! Realm()
        let object: CategoryList = realm.objects(CategoryList.self)
            .filter("mainCategory == %@", mainCategory)
            .filter("categoryName == %@", categoryName).first!
        return object
    }
    
    //readするコード
    static func readAllCategory(_ mainCategory:Int) -> [CategoryList] {
        let realm = try! Realm()
        let objects: [CategoryList] = realm.objects(CategoryList.self)
            .filter("mainCategory == %@", mainCategory).map({$0})
        return objects
    }
    
    // データを更新(Update)するためのコード
    func upDate(newList to: [String]?,name: String?) {
        let realm = try! Realm()
        let object = realm.object(ofType: CategoryList.self, forPrimaryKey: self.id)!
        try! realm.write() {
            if name != nil { object.categoryName = name! }
            if to != nil { object.setValue(to, forKey: "list") }
//            objects.colorCode = self.categoryColor.hex(withHash: true, uppercase: true)
        }
    }

    // データを保存するためのコード
    func save() {
        let realm = try! Realm()
//        self.colorCode = self.categoryColor.hex(withHash: true, uppercase: true)
        try! realm.write() {
            realm.add(self)
        }
    }
    
    // データを削除(Delete)するためのコード
    func delete() {
        let realm = try! Realm()
        let objects = realm.object(ofType: CategoryList.self, forPrimaryKey: self.id)!
        try! realm.write() {
            realm.delete(objects)
        }
    }
}
