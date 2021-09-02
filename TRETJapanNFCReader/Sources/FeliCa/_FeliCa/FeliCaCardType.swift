//
//  FeliCaCardType.swift
//  TRETJapanNFCReader
//
//  Created by treastrain on 2019/10/10.
//  Copyright © 2019 treastrain / Tanaka Ryoga. All rights reserved.
//

import Foundation
#if canImport(TRETJapanNFCReader_Core)
import TRETJapanNFCReader_Core
#endif

public enum FeliCaCardType: Int, Codable, CaseIterable {
    /// 交通系ICカード
    case transitIC = 1
    /// 楽天Edyカード
    case rakutenEdy = 2
    /// nanaco
    case nanaco = 3
    /// WAON
    case waon = 4
    /// 大学生協ICプリペイドカード
    case univCoopICPrepaid = 5
    
    /// OKICA
    case okica = 6
    /// エヌタス
    case ntasu = 7
    /// りゅーと
    case ryuto = 8
    
    /// FCF Campus Card
    case fcfcampus = 9
    
    /// Octopus Card (八達通)
    case octopus = 10
    
    /// iD （PKPaymentNetwork に準拠し、`idCredit` とした）
    case idCredit = 11
    /// QUICPay
    case quicPay = 12
    
    case unknown = 13
    
    public init?(_ num: Int) {
        self.init(rawValue: num)
    }
    
    public var localizedString: String {
        switch self {
        case .transitIC:
            return Localized.transitIC.string()
        case .rakutenEdy:
            return Localized.rakutenEdy.string()
        case .nanaco:
            return "nanaco"
        case .waon:
            return "WAON"
        case .univCoopICPrepaid:
            return Localized.univCoopICPrepaid.string()
        case .okica:
            return "OKICA"
        case .ntasu:
            return "NTasu"
        case .ryuto:
            return Localized.ryuto.string()
        case .fcfcampus:
            return "FCF Campus"
        case .octopus:
            return Localized.octopus.string()
        case .idCredit:
            return "iD"
        case .quicPay:
            return "QUICPay"
        case .unknown:
            return "Unknown"
        }
    }
}
