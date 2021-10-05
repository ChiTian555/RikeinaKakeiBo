//
//  UserDefault.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/22.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import Foundation
import UIKit

protocol KeyNamespaceable {}
 
extension KeyNamespaceable where Self: RawRepresentable {
    var strKey: String {
        return "\(Self.self).\(self.rawValue)"
    }
}

// 実際に保存するための関数をセット
// ファイヤーベースにバックアップを取るため、2重配列禁止。
// Date型は、FireBaseタイムスタンプになっちゃう。

//enumのセット
extension UserDefaults {
    
    private var ud: UserDefaults { Self.standard }
    
    enum ArrayKey : String, KeyNamespaceable {
        case notDidCheckAccountTipe
        case startSteps
    }
    enum StringKey : String, KeyNamespaceable {
        case pocketMoneyAdded
    }
    enum IntKey : String, KeyNamespaceable {
        case shake
        case alpha
        case pocketMoney
    }
    enum BoolKey : String, KeyNamespaceable {
        case isCordMode
        case isCheckMode
        case isWatchedWalkThrough
        case isNotFirstOpen
        case isFirstAddAccount
        case canUseNotification
        case watchStartView
    }
    enum ImageKey : String, KeyNamespaceable {
        case backGraundPicture
    }
    enum ColorKey : String, KeyNamespaceable {
        case userColor
        case buttonColor
    }
    
    //UserDefaultsに保存する関数
    func setInteger(_ value: Int, forKey key: UserDefaults.IntKey) {
        ud.set(value, forKey: key.strKey)
    }
        
    @discardableResult
    func integer(forKey key: UserDefaults.IntKey) -> Int {
        return ud.integer(forKey: key.strKey)
    }
    
    func setBool(_ value: Bool?, forKey key: UserDefaults.BoolKey) {
        ud.set(value, forKey: key.strKey)
    }
        
    @discardableResult
    func bool(forKey key: UserDefaults.BoolKey) -> Bool {
        return ud.bool(forKey: key.strKey)
    }

    func setStringArray(_ value: [String]?, forKey key: UserDefaults.ArrayKey) {
        ud.set(value, forKey: key.strKey)
    }
        
    @discardableResult
    func stringArray(forKey key: UserDefaults.ArrayKey) -> [String]? {
        return ud.object(forKey: key.strKey) as? [String]
    }
    
    func deleteArrayElement(_ value: String, forKey key: UserDefaults.ArrayKey ) {
        var array = stringArray(forKey: key.strKey)
        array?.removeAll { $0 == value }
        ud.set(array, forKey: key.strKey)
    }
        
    func setImage(_ image: UIImage?, forKey key: UserDefaults.ImageKey) {
        //NSData型にキャスト
        let data = image?.pngData() as NSData?
        ud.set(data, forKey: key.strKey)
    }
    
    @discardableResult
    func image(forKey key: UserDefaults.ImageKey) -> UIImage? {
        guard let imageData = ud.object(forKey: key.strKey) as? Data
        else { return nil }
        return UIImage(data: imageData)
    }
    
    func setString(_ text: String, forKey key : UserDefaults.StringKey) {
        ud.set(text, forKey: key.strKey)
    }
    
    @discardableResult
    func string(forKey key: UserDefaults.StringKey) -> String {
        return ud.object(forKey: key.strKey) as? String ?? ""
    }
    
    func setColor(_ color: UIColor?, forKey key: UserDefaults.ColorKey) {
        var colorData: NSData?
        if let color = color {
            colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) as NSData
        }
        ud.set(colorData, forKey: key.strKey)
    }
        
    @discardableResult
    func color(forKey key: UserDefaults.ColorKey, alpha: CGFloat? = nil) -> UIColor {
        var color: UIColor!
        switch key {
        case .userColor:
            color = UIColor.orange.withAlphaComponent(0.7)
        case .buttonColor:
            color = UIColor.blue
        }
        guard let colorData = ud.data(forKey: key.strKey) else { return color }
        if let udColor = try? (NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor) {
            color = udColor
        }
        return alpha == nil ? color : color.withAlphaComponent(alpha!)
    }
    
}
