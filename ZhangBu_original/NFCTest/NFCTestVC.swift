//
//  NFCTestVC.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/10.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import SwiftUI
import NFCReader
import CoreNFC
import PKHUD

class NFCTestVC: UIViewController, NFCTagReaderSessionDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    var session: NFCTagReaderSession?
    
    @IBAction func notUseLibrelyTest() {
        guard NFCTagReaderSession.readingAvailable else {
            let alertController = UIAlertController(
                title: "Scanning Not Supported",
                message: "This device doesn't support tag scanning.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }

        self.session = NFCTagReaderSession(pollingOption: .iso18092, delegate: self)
        self.session?.alertMessage = "Hold your iPhone near the item to learn more about it."
        self.session?.begin()
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("tagReaderSessionDidBecomeActive(_:)")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        if let readerError = error as? NFCReaderError {
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                let alertController = UIAlertController(
                    title: "Session Invalidated",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        self.session = nil
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        print("tagReaderSession(_:didDetect:)")

        if tags.count > 1 {
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected, please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }

        let tag = tags.first!

        session.connect(to: tag) { (error) in
            if nil != error {
                session.invalidate(errorMessage: "Connection error. Please try again.")
                return
            }

            guard case .feliCa(let feliCaTag) = tag else {
                let retryInterval = DispatchTimeInterval.milliseconds(500)
                session.alertMessage = "A tag that is not FeliCa is detected, please try again with tag FeliCa."
                DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                    session.restartPolling()
                })
                return
            }

            print(feliCaTag)

            let idm = feliCaTag.currentIDm.map { String(format: "%.2hhx", $0) }.joined()
            let systemCode = feliCaTag.currentSystemCode.map { String(format: "%.2hhx", $0) }.joined()

            print("IDm: \(idm)")
            print("System Code: \(systemCode)")

            session.alertMessage = "Read success!\nIDm: \(idm)\nSystem Code: \(systemCode)"
            session.invalidate()
        }
    }
    
    
    
   @IBAction func librelyExampleTest() {
    
        SceneDelegate.shared.rootVC.transition(to: UIHostingController(rootView: ContentView()))
    
    }
    
    @IBAction func useLibrelyMyProjectTest() {
        var configuration = ReaderConfiguration()
        
        configuration.message.alert = "ICカードに近づけて、\nしばらくお待ちください."
        configuration.message.foundMultipleTags = "複数のカードが感知されました。"
        let reader = Reader<FeliCa>(configuration: configuration)
        
        reader.read(didBecomeActive: { _ in
            print("reader: セット完了")
        }, didDetect: { reader, result in
            print("検出側から反応が返ってきた.")
            print(reader)
            switch result {
            case .success(let tag):
                let balance: UInt
                var cardName = ""
                switch tag {
                case .edy(let edy):
                    cardName = "edy"
                    balance = UInt(edy.histories.first?.balance ?? 0)
                case .nanaco(let nanaco):
                    cardName = "nanaco"
                    balance = UInt(nanaco.histories.first?.balance ?? 0)
                case .waon(let waon):
                    cardName = "waon"
                    balance = UInt(waon.histories.first?.balance ?? 0)
                case .suica(let suica):
                    cardName = "交通系"
                    balance = UInt(suica.boardingHistories.first?.balance ?? 0)
                }
                print(tag)
                reader.setMessage("\(cardName): 残高は¥\(balance)でした")
                
            case .failure(let error):
                print(error)
                var errorMessage = ""
                switch error {
                case .notSupported:
                    HUD.flash(.labeledError(title: "Error", subtitle: "\(error)"), delay: 1.5)
                    break
                case .readTagFailure(let error2):
                    errorMessage = "エラー: readTagFailure"
                    print("\(error2)")
                    break
                case .scanFailure(let nfcError):
                    errorMessage = "エラー: scanFailure"
                    print(nfcError)
                    break
                case .tagConnectionFailure(let nfcError):
                    errorMessage = "エラー: tagConnectionFailure"
                    print(nfcError)
                }
                reader.setMessage("読み込みエラー:\(errorMessage)")
            }
        })
    }
    

    

}



struct NFCTestVC_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
