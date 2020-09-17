//
//  UserDefault.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/22.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import Foundation
import UIKit

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
    associatedtype Array1Key : RawRepresentable
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
    
    func  setFloat(_ value: Float, forKey key: BoolKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(value, forKey: key)
    }
    
    @discardableResult
    func float(forKey key: String = "alpha") -> Float {
//        let key = namespaced(key)
        let float: Float = UserDefaults.standard.float(forKey: key)
        return float
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
    
    func setArray1(_ value: [String]?, forKey key: Array1Key) {
        let key = namespaced(key)
        UserDefaults.standard.set(value, forKey: key)
    }
    
    @discardableResult
    func stringArray1(forKey key: Array1Key) -> [String]? {
        let key = namespaced(key)
        return UserDefaults.standard.object(forKey: key) as? [String]
    }
    
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
    
    func setImage(_ image: UIImage?, forKey key: String = "backGraundPicture") {
        //NSData型にキャスト
        let data = image?.pngData() as NSData?
        UserDefaults.standard.set(data, forKey: key)

    }
    
    @discardableResult
    func image(forKey key: String = "backGraundPicture") -> UIImage? {
        guard let imageData = UserDefaults.standard.object(forKey: key) as? Data else { return nil }
        return UIImage(data: imageData)
    }
    
}

extension UserDefaults : DefaultSettable {
    enum Array2Key : String {
        case account
    }
    enum Array1Key : String {
        case notDidCheckAccountTipe
    }
    enum IntKey : String {
        case shake
        case startStep
        case alpha
    }
    enum BoolKey : String {
        case isCordMode
        case isCheckMode
        case isWatchedWalkThrough
        case isNotFirstOpen
        case isFirstAddAccount
        case canUseNotification
    }
    enum Array3Key : String {
        case list
    }
//    enum StringKey : String {
//        case
//    }
}
