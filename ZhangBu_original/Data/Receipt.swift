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

final class Receipt: MyRealm {
    
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
        
        guard let realm = Self.getRealm() else { return [] }
        let object: Results<Receipt> = realm.objects(Receipt.self).sorted(byKeyPath: "date")
        
        return object + []
        
    }
    // データを更新(Update)するためのコード
    func write(_ set: (Receipt) -> Void) -> Bool {
        guard let realm = Self.getRealm() else { return false }
        do { try realm.write() { set(self as! Self) } }
        catch { Self.realmError(error); return false }
        return true
    }

}
