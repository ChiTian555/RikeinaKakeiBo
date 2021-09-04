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

//enumのセット
extension UserDefaults {
    
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
        case pocketMoney
    }
    enum BoolKey : String {
        case isCordMode
        case isCheckMode
        case isWatchedWalkThrough
        case isNotFirstOpen
        case isFirstAddAccount
        case canUseNotification
        case watchStartView
    }
    enum ImageKey : String {
        case backGraundPicture
    }
    enum ColorKey : String {
        case userColor
        case buttonColor
    }
}

//実際に保存するための関数をセット
extension UserDefaults : KeyNamespaceable {
    //UserDefaultsに保存する関数
    func setInteger(_ value: Int?, forKey key: UserDefaults.IntKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(value, forKey: key)
    }
        
    @discardableResult
    func integer(forKey key: UserDefaults.IntKey) -> Int? {
        let key = namespaced(key)
        return UserDefaults.standard.integer(forKey: key)
    }
    
    func setBool(_ value: Bool?, forKey key: UserDefaults.BoolKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(value, forKey: key)
    }
        
    @discardableResult
    func bool(forKey key: UserDefaults.BoolKey) -> Bool {
        let strKey = namespaced(key)
        return UserDefaults.standard.bool(forKey: strKey)
    }

    func setArray1(_ value: [String]?, forKey key: UserDefaults.Array1Key) {
        let key = namespaced(key)
        UserDefaults.standard.set(value, forKey: key)
    }
        
    @discardableResult
    func stringArray1(forKey key: UserDefaults.Array1Key) -> [String]? {
        let key = namespaced(key)
        return UserDefaults.standard.object(forKey: key) as? [String]
    }
        
    func setArray2(_ value: [[String]]?, forKey key: UserDefaults.Array2Key) {
        let key = namespaced(key)
        UserDefaults.standard.set(value, forKey: key)
    }
        
    @discardableResult
    func stringArray2(forKey key: UserDefaults.Array2Key) -> [[String]]? {
        let key = namespaced(key)
        return UserDefaults.standard.object(forKey: key) as? [[String]]
    }
        
    func setImage(_ image: UIImage?, forKey key: UserDefaults.ImageKey) {
        let key = namespaced(key)
        //NSData型にキャスト
        let data = image?.pngData() as NSData?
        UserDefaults.standard.set(data, forKey: key)

    }
    
    @discardableResult
    func image(forKey key: UserDefaults.ImageKey) -> UIImage? {
        let key = namespaced(key)
        guard let imageData = UserDefaults.standard.object(forKey: key) as? Data else { return nil }
        return UIImage(data: imageData)
    }
    
    func setColor(_ color: UIColor?, forKey key: UserDefaults.ColorKey) {
        let key = namespaced(key)
        var colorData: NSData?
        if let color = color {
            colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) as NSData
        }
        UserDefaults.standard.set(colorData, forKey: key)
    }
        
    @discardableResult
    func color(forKey key: UserDefaults.ColorKey, alpha: CGFloat = 1) -> UIColor {
        var color: UIColor!
        switch key {
        case .userColor:
            color = UIColor.orange.withAlphaComponent(alpha)
        case .buttonColor:
            color = UIColor.blue.withAlphaComponent(alpha)
        }
        let key = namespaced(key)
        guard let colorData = UserDefaults.standard.data(forKey: key) else { return color }
        if let udColor = try? (NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor) {
            color = udColor.withAlphaComponent(alpha)
        }
        return color
    }
    
}
