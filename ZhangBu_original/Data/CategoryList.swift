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

final class CategoryList: Object, Codable, MyRealmFunction {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var mainCategory: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var selectAccount: Bool = false
    private var _list = List<String>()
    
    @objc var list: [String] { get { return _list + [] } }
    
    // 初期設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    //保存しないプロパティの定義
    override static func ignoredProperties() -> [String] {
        return ["list"]
    }
    
    class func make() -> Self {
        let me = Self()
        me.id = ( myRealm.objects(Self.self).max(ofProperty: "id") ?? 0 ) + 1
        return me
    }
    
    
    //readするコード
    static func readCategory(_ mainCategory:Int,_ name: String ) -> CategoryList? {
        let object: CategoryList? = myRealm.objects(CategoryList.self)
            .filter("mainCategory == %@", mainCategory)
            .filter("name == %@", name).first
        return object
    }
    
    //readするコード
    static func readAllCategory(_ mainCategory:Int?) -> [CategoryList] {
        var categoryList = [CategoryList]()
        let objects = myRealm.objects(CategoryList.self)
        if let main = mainCategory {
            categoryList = objects.filter("mainCategory == %@", main) + []
        } else {
            categoryList = objects + []
        }
        return categoryList
    }
    
    // データを更新(Update)するためのコード
    func upDateList(newList list: [String]? = nil, changeName name: String?) {
        try! myRealm.write({
            if list != nil { self.setValue(list, forKey: "_list") }
            if let name = name { self.name = name }
        })
    }
    
    class func deleteAccount(name: String) {
        let objects = myRealm.objects(Self.self).filter("selectAccount == %@", true)
        try! myRealm.write() {
            objects.forEach {
                guard let index = $0._list.firstIndex(of: name) else { return }
                $0._list.remove(at: index)
            }
        }
    }
    
    static func restore(newPayment: [CategoryList]) {
        try! myRealm.write() { myRealm.add(newPayment, update: .all) }
    }

}
