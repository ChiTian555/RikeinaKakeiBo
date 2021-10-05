//
//  Memory.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2021/10/05.
//  Copyright © 2021 net.Chee-Saga. All rights reserved.
//

import RealmSwift

final class Memory: Object, Codable, MyRealmFunction {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var date: Date = Date()
    // 初期設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
