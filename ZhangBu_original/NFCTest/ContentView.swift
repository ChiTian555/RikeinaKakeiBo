//
//  ContentView.swift
//  SuicaExample
//
//  Created by Tatsuya Tanaka on 2019/08/11.
//  Copyright © 2019 Tatsuya Tanaka. All rights reserved.
//

import SwiftUI
import NFCReader

struct ContentView: View {
    typealias FelicaReader = Reader<FeliCa>
    private let configuration: ReaderConfiguration = {
        var configuration = ReaderConfiguration()
        configuration.message.alert = "Hold your iPhone near a FeliCa tag."
        return configuration
    }()
    
    
    private let reader = FelicaReader()
    var body: some View {
        VStack {
            Button("Scan IC") {
                self.reader.configuration = self.configuration
                self.reader.read(didBecomeActive: { _ in
                    print("didBecomeActive")
                }, didDetect: { reader, result in
                    switch result {
                    case .success(let tag):
                        let balance: UInt
                        switch tag {
                        case .edy(let edy):
                            balance = UInt(edy.histories.first?.balance ?? 0)
                        case .nanaco(let nanaco):
                            balance = UInt(nanaco.histories.first?.balance ?? 0)
                        case .waon(let waon):
                            balance = UInt(waon.histories.first?.balance ?? 0)
                        case .suica(let suica):
                            balance = UInt(suica.boardingHistories.first?.balance ?? 0)
                            
                        }
                        print(tag)
                        reader.setMessage("Your balance is ¥\(balance) .")

                    case .failure(let error):
                        reader.setMessage(String(describing: error))
                        print(error)
                    }
                })
            }
            
            Button(action: {
                SceneDelegate.shared.rootVC.transitionToNFCTest()
            }) {
                Text("BackScreen")
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
