//
//  Array+.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/10/21.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

extension Array {
    subscript (safe index: Index) -> Element? {
        //indexが配列内なら要素を返し、配列外ならnilを返す（三項演算子）
        return indices.contains(index) ? self[index] : nil
    }
}
