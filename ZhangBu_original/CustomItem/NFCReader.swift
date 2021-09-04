//
//  NFCReader.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2021/09/02.
//  Copyright © 2021 net.Chee-Saga. All rights reserved.
//

import Foundation

class NFCReader {
    
    var reader: FeliCaReader!
    var didReadFunc: (Int,Error?) -> Void
    init(type: FeliCaCardType, didRead :@escaping (Int,Error?) -> Void) {
        didReadFunc = didRead
        reader = Self.getReader(type: type, delegate: self)
    }
    func start() {
        if let r = reader as? TransitICReader { r.get(itemTypes: [.balance]) }
        else if let r = reader as? UnivCoopICPrepaidReader { r.get(itemTypes: [.balance]) }
        else if let r = reader as? RakutenEdyReader { r.get(itemTypes: [.balance]) }
        else if let r = reader as? NanacoReader { r.get(itemTypes: [.balance]) }
        else if let r = reader as? WaonReader { r.get(itemTypes: [.balance]) }
    }
    static func getReader(type:FeliCaCardType, delegate: FeliCaReaderSessionDelegate) -> FeliCaReader? {
        switch type {
        case .waon: return WaonReader(delegate: delegate)
        case .transitIC: return TransitICReader(delegate: delegate)
        case .univCoopICPrepaid: return UnivCoopICPrepaidReader(delegate: delegate)
        case .nanaco: return NanacoReader(delegate: delegate)
        case .rakutenEdy: return RakutenEdyReader(delegate: delegate)
        default: return nil
        }
    }
}

extension NFCReader: FeliCaReaderSessionDelegate {
    
    func feliCaReaderSession(didInvalidateWithError pollingErrors: [FeliCaSystemCode : Error?]?, readErrors: [FeliCaSystemCode : [FeliCaServiceCode : Error]]?) {
        print(pollingErrors)
    }
    
    func feliCaReaderSession(didRead feliCaCardData: FeliCaCardData, pollingErrors: [FeliCaSystemCode : Error?]?, readErrors: [FeliCaSystemCode : [FeliCaServiceCode : Error]]?) {
        
        print(feliCaCardData.type.localizedString)
        print(pollingErrors,readErrors)
        print(feliCaCardData.primaryIDm)
        print(feliCaCardData)
        if let balance = feliCaCardData.getBalance() { didReadFunc(balance, nil) }
        else { didReadFunc(-1, nil) }
        
    }
    
    func japanNFCReaderSession(didInvalidateWithError error: Error) {
        didReadFunc(-1,error)
    }
}
