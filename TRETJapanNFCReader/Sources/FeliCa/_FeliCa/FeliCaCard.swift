//
//  FeliCaCard.swift
//  TRETJapanNFCReader
//
//  Created by treastrain on 2019/08/21.
//  Copyright © 2019 treastrain / Tanaka Ryoga. All rights reserved.
//

import Foundation
#if os(iOS)
import CoreNFC
#endif

#if os(iOS)
/// FeliCaカード
@available(iOS 13.0, *)
public protocol FeliCaCard {
    var tag: NFCFeliCaTag { get }
    func getBalance() -> Int?
}
extension FeliCaCard {
    public func getBalance() -> Int? {
        if let c = self as? TransitICCard { return c.data.balance }
        else if let c = self as? RakutenEdyCard { return c.data.balance }
        else if let c = self as? NanacoCard { return c.data.balance }
        else if let c = self as? WaonCard { return c.data.balance }
        else if let c = self as? UnivCoopICPrepaidCard { return c.data.balance }
        return nil
    }
}
#endif

public protocol FeliCaCardItems: Codable {
}

public protocol FeliCaCardItemType {
}
