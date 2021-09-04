//
//  FeliCaCard.swift
//  TRETJapanNFCReader
//
//  Created by treastrain on 2019/08/21.
//  Copyright © 2019 treastrain / Tanaka Ryoga. All rights reserved.
//

import Foundation
import CoreNFC

/// FeliCaカード
@available(iOS 13.0, *)
public protocol FeliCaCard {
    var tag: NFCFeliCaTag { get }
}

public protocol FeliCaCardItems: Codable {
}

public protocol FeliCaCardItemType {
}
