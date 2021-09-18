//
//  RealmMain.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2021/09/02.
//  Copyright © 2021 net.Chee-Saga. All rights reserved.
//

import RealmSwift
import PKHUD

extension Object {
    
    var myRealm: Realm { try! Realm() }
    var ud: UserDefaults { UserDefaults.standard }
    
    @objc func save() {
        do {
            try myRealm.write() {
                myRealm.add(self)
            }
        } catch { Self.realmError(error) }
    }
    @objc func delete() {
        do {
            try myRealm.write() {
                myRealm.delete(self)
            }
        } catch { Self.realmError(error) }
    }
    @objc class func realmError(_ err:Error) {
        HUD.flash(.labeledError(title: "データベースエラー",
                                subtitle: "app作成者に、ご連絡ください。\n" + err.localizedDescription))
    }
}

protocol MyRealmFunction {}
extension MyRealmFunction where Self: Object, Self: Codable {
    
    static var myRealm: Realm { try! Realm() }
    static var ud: UserDefaults { UserDefaults.standard }
    
    func write(_ set:(Self)->Void) -> Bool {
        do { try realm!.write() { set(self) } }
        catch { Self.realmError(error); return false }
        return true
    }
    
    static func restore(newObjects: [Self]) {
        try! myRealm.write() { myRealm.add(newObjects, update: .all) }
    }
}
