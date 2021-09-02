//
//  RealmMain.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2021/09/02.
//  Copyright © 2021 net.Chee-Saga. All rights reserved.
//

import RealmSwift
import Foundation
import PKHUD

extension Object {
    
    class func getRealm() -> Realm? {
        do { return try Realm()
        } catch { Self.realmError(error); return nil }
    }
    class func realmError(_ err:Error) {
        HUD.flash(.labeledError(title: "データベースエラー",
                                subtitle: "app作成者に、ご連絡ください。\n" + err.localizedDescription),
                  delay: 2.0)
    }
    @objc func lastObject() -> Self? {
        let realm = try! Realm()
        if let object = realm.objects(Self.self).last {
            return object
        } else {
            return nil
        }
    }
    @objc func save() { 
        do {
            let realm = try Realm()
            try realm.write() {
                realm.add(self)
            }
        } catch { Self.realmError(error) }
    }
    @objc func delete() {
        do {
            let realm = try Realm()
            try realm.write() {
                realm.delete(self)
            }
        } catch { Self.realmError(error) }
    }
}
