//
//  Receipt.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/10/12.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import RealmSwift
import Realm
import SwiftDate

final class Receipt: Object, Codable, MyRealmFunction {
    
    @objc dynamic var id: Int = 0
    @objc dynamic private var _photo = Data()
    //マイグレーション番号1
    @objc dynamic private var date = Date()
    
    // 初期設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    //保存しないプロパティの定義
    override static func ignoredProperties() -> [String] {
        return ["photo"]
    }
    
    class func make() -> Self {
        let me = Self()
        me.id = ( myRealm.objects(Receipt.self).max(ofProperty: "id") ?? 0 ) + 1
        return me
    }
    

    
    @objc dynamic var photo: UIImage {
        set(photo) {
            guard let data = photo.pngData() else { return }
            self._photo = data
        }
        get {
            guard let image = UIImage(data: _photo) else { return UIImage() }
            return image
        }
    }
    
    class func readAll() -> [Receipt] {
        let object: Results<Receipt> = myRealm.objects(Receipt.self).sorted(byKeyPath: "date")
        return object + []
    }


}
