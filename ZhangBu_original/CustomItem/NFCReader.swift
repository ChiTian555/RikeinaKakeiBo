//
//  NFCReader.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2021/09/02.
//  Copyright © 2021 net.Chee-Saga. All rights reserved.
//

import Foundation

class NFCReader {
    typealias CardType = FeliCaCardType
    var reader: FeliCaReader!
    var didReadFunc: (Int, Error?) -> Void
    var finished: Bool = false
    init(type: CardType, didRead :@escaping (Int, Error?) -> Void) {
        didReadFunc = didRead
        reader = Self.getReader(type: type, delegate: self)
    }
    func start() {
        SceneDelegate.shared.isCheckMode = true
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
    
    func japanNFCReaderSession(didInvalidateWithError error: Error) {
        print("japanNFCReaderSession")
        DispatchQueue.main.async {
            
            if error.localizedDescription == "Session invalidated by user" { return }
            print("\(error.localizedDescription)")
            if self.finished { return }
            self.finished = true
            self.didReadFunc(-1, error)
        }
    }
    
    func feliCaReaderSession(didInvalidateWithError pollingErrors: [FeliCaSystemCode : Error?]?, readErrors: [FeliCaSystemCode : [FeliCaServiceCode : Error]]?) {
        print("feliCaReaderSessionInvalidateWithError")
        print(pollingErrors,readErrors)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            DispatchQueue.main.async {
                if self.finished { return }
                self.finished = true
                self.didReadFunc(-1, nil)
            }
        }
    }
    
    func feliCaReaderSession(didRead feliCaCardData: FeliCaCardData, pollingErrors: [FeliCaSystemCode : Error?]?, readErrors: [FeliCaSystemCode : [FeliCaServiceCode : Error]]?) {
        print("feliCaReaderSessionDidRead")
        print(pollingErrors,readErrors)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            DispatchQueue.main.async{
                self.finished = true
                if let balance = feliCaCardData.balance { self.didReadFunc(balance, nil) }
                else { self.didReadFunc(-1, nil) }
            }
        }
    }
}
