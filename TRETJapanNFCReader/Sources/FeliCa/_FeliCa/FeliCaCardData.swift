//
//  FeliCaCardData.swift
//  TRETJapanNFCReader
//
//  Created by treastrain on 2019/10/10.
//  Copyright © 2019 treastrain / Tanaka Ryoga. All rights reserved.
//

import Foundation

public protocol FeliCaCardData: Codable {
    var version: String { get }
    var type: FeliCaCardType { get }
    var primaryIDm: String { get }
    var primarySystemCode: FeliCaSystemCode { get }
    var contents: [FeliCaSystemCode : FeliCaSystem] { get set }
    
    mutating func convert()
    func toJSONData() -> Data?
//    func getBalance() -> Int?
    
    /// Unavailable
    // var idm: String { get }
    // var systemCode: FeliCaSystemCode { get }
    // var data: [FeliCaServiceCode : [Data]] { get }
}

extension FeliCaCardData {
    public func toJSONData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    public var balance: Int? {
        if let d = self as? TransitICCardData { return d.balance }
        else if let d = self as? RakutenEdyCardData { return d.balance }
        else if let d = self as? NanacoCardData { return d.balance }
        else if let d = self as? WaonCardData { return d.balance }
        else if let d = self as? UnivCoopICPrepaidCardData { return d.balance }
        return nil
    }
}
