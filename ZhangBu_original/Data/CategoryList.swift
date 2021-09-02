//
//  Payment.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/15.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import RealmSwift
import Realm
import Foundation

class CategoryList: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var mainCategory: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var selectAccount: Bool = false
    let list = List<String>()
    
    // 初期設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override init() {
        super.init()
        if let last_id = lastObject()?.id { id = last_id }
    }
    
    //readするコード
    static func readCategory(_ mainCategory:Int,_ name: String ) -> CategoryList? {
        guard let realm = super.getRealm() else { return nil }
        let object: CategoryList? = realm.objects(CategoryList.self)
            .filter("mainCategory == %@", mainCategory)
            .filter("name == %@", name).first
        return object
    }
    
    //readするコード
    static func readAllCategory(_ mainCategory:Int?) -> [CategoryList] {
        guard let realm = super.getRealm() else { return [] }
        var categoryList = [CategoryList]()
        let objects = realm.objects(CategoryList.self)
        if let main = mainCategory {
            categoryList = objects.filter("mainCategory == %@", main) + []
        } else {
            categoryList = objects + []
        }
        return categoryList
    }
    
    // データを更新(Update)するためのコード
    func upDate(newList to: [String]? = nil, name: String?) {
        guard let realm = Self.getRealm() else { return }
        try! realm.write() {
            if name != nil { self.name = name! }
            if to != nil { self.setValue(to, forKey: "list") }
//            objects.colorCode = self.categoryColor.hex(withHash: true, uppercase: true)
        }
    }
    
    static func restore(newPayment: [CategoryList]) {
        guard let realm = Self.getRealm() else { return }
        try! realm.write() { realm.add(newPayment, update: .all) }
    }
    
}
