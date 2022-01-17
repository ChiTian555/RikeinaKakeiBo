//
//  util_+.swift.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2022/01/15.
//  Copyright © 2022 net.Chee-Saga. All rights reserved.
//

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
