//
//  util_+.swift.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2022/01/15.
//  Copyright © 2022 net.Chee-Saga. All rights reserved.
//

import Foundation
import UIKit

extension Array {
    subscript (safe index: Index) -> Element? {
        //indexが配列内なら要素を返し、配列外ならnilを返す（三項演算子）
        return indices.contains(index) ? self[index] : nil
    }
}

// NSObjectProtocolの拡張
extension NSObjectProtocol {
    // クラス名を返す変数"className"を返す
    static var className: String { String(describing: self) }
}

extension StringUtil { var ud: UserDefaults { return UserDefaults.standard } }

struct StringUtil {
    var size: CGFloat
    var mainFont: UIFont?
    enum MyFont { case code(CGFloat?); case normal(CGFloat?) }
    func getText(_ attributes: (text: String, deco: [String.Decolate])...) -> NSAttributedString {
        let text = NSMutableAttributedString()
        attributes.forEach { ( a ) in
            var para = [NSAttributedString.Key:Any]()
            a.deco.forEach { (decoType) in
                switch decoType {
                case .color(let color): para[.foregroundColor] = color
                case .myFont(let f):
                    switch f {
                    case .code: para[.font] = UIFont.codeFont(size)
                    case .name(let name): para[.font] = UIFont(name: name, size: size)
                    case .codeWithSize(let s): para[.font] = UIFont.codeFont(s)
                    case .nameWithSize(let (name, s)): para[.font] = UIFont(name: name, size: s)
                    }
                case .sysFont(let f):
                    switch f {
                    case .size(let s): para[.font] = UIFont.systemFont(ofSize: s)
                    case .sizeAndWeight(let (s, weight)):
                        para[.font] = UIFont.systemFont(ofSize: s, weight: weight)
                    case .weight(let weight):
                        para[.font] = UIFont.systemFont(ofSize: size, weight: weight)
                    }
                case .font(let selectedFont): para[.font] = selectedFont
                }
            }
            if para[.font] == nil { para[.font] = UIFont.systemFont(ofSize: size) }
            text.append(NSAttributedString(string: a.text, attributes: para))
        }; return text
    }
}

extension String {
    private var ud: UserDefaults { .standard }
    enum MyFont {
        case code
        case codeWithSize(CGFloat)
        case name(String)
        case nameWithSize((String,CGFloat))
    }
    enum SysFont {
        case size(CGFloat)
        case sizeAndWeight((CGFloat,UIFont.Weight))
        case weight(UIFont.Weight)
    }
    enum Decolate {
        case font(UIFont)
        case myFont(MyFont)
        case sysFont(SysFont)
        case color(UIColor)
    }
    func deco(_ deco: Decolate...) -> (String,[Decolate]) { return (self,deco) }
    var deco: (String,[Decolate]) { return (self,[]) }
    func code(_ size: CGFloat) -> NSAttributedString {
        return .init(string: self, attributes: [.font: UIFont.codeFont(size)])
    }
}
