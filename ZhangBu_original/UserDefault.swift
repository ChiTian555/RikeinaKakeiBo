//
//  UserDefault.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/22.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import Foundation

protocol KeyNamespaceable {
        func namespaced<T: RawRepresentable>(_ key: T) -> String
}

extension KeyNamespaceable {

    func namespaced<T: RawRepresentable>(_ key: T) -> String {
        return "\(Self.self).\(key.rawValue)"
    }
}

protocol DefaultSettable : KeyNamespaceable {
    associatedtype IntKey : RawRepresentable
    associatedtype Array3Key : RawRepresentable
    associatedtype BoolKey : RawRepresentable
    associatedtype Array2Key : RawRepresentable
//    associatedtype StringKey : RawRepresentable
}

extension DefaultSettable {
    
    func setInteger(_ value: Int?, forKey key: IntKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(value, forKey: key)
    }
    
    @discardableResult
    func integer(forKey key: IntKey) -> Int? {
        let key = namespaced(key)
        return UserDefaults.standard.integer(forKey: key)
    }
    
    func  setBool(_ value: Bool?, forKey key: BoolKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(value, forKey: key)
    }
    
    @discardableResult
    func bool(forKey key: BoolKey) -> Bool? {
        let key = namespaced(key)
        return UserDefaults.standard.bool(forKey: key)
    }
    
//    func  setString(_ value: String?, forKey key: StringKey) {
//        let key = namespaced(key)
//        UserDefaults.standard.set(value, forKey: key)
//    }
//
//    @discardableResult
//    func String(forKey key: StringKey) -> String? {
//        let key = namespaced(key)
//        return UserDefaults.standard.string(forKey: key)
//    }
    
    func setArray2(_ value: [[String]]?, forKey key: Array2Key) {
        let key = namespaced(key)
        UserDefaults.standard.set(value, forKey: key)
    }
    
    @discardableResult
    func stringArray2(forKey key: Array2Key) -> [[String]]? {
        let key = namespaced(key)
        return UserDefaults.standard.object(forKey: key) as? [[String]]
    }
    
    func setArray3(_ value: [[[String]]]?, forKey key: Array3Key) {
        let key = namespaced(key)
        UserDefaults.standard.set(value, forKey: key)
    }
    
    @discardableResult
    func stringArray3(forKey key: Array3Key) -> [[[String]]]? {
        let key = namespaced(key)
        return UserDefaults.standard.object(forKey: key) as? [[[String]]]
    }
    
}

extension UserDefaults : DefaultSettable {
    enum Array2Key : String {
        case account
    }
    enum IntKey : String {
        case shake
    }
    enum BoolKey : String {
        case isCordMode
        case isCheckMode
    }
    enum Array3Key : String {
        case list
    }
//    enum StringKey : String {
//        case
//    }
}
