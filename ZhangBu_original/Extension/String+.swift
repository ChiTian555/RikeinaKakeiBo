//
//  StringExtension.swift
//  TouchIDExample
//
//  Created by 酒井文也 on 2018/12/23.
//  Copyright © 2018 酒井文也. All rights reserved.
//

import Foundation
import UIKit


public func l(_ key: String,_ args:String...) -> String {
    var localizedStr = NSLocalizedString(key , bundle: Bundle.main, comment: "")
    localizedStr = localizedStr.isEmpty ? key : localizedStr
    args.enumerated().forEach {
        localizedStr = localizedStr.replacingOccurrences(of: "\\\($0)", with: $1) }
    return localizedStr
}


extension String {

    // MARK: - Function
    func hmac(algorithm: CryptoAlgorithm) -> String {
        let key: String = AppConstant.PASSCODE_HASH
        var result: [CUnsignedChar]
        if let ckey = key.cString(using: String.Encoding.utf8), let cdata = self.cString(using: String.Encoding.utf8) {
            result = Array(repeating: 0, count: Int(algorithm.digestLength))
            CCHmac(algorithm.HMACAlgorithm, ckey, ckey.count - 1, cdata, cdata.count - 1, &result)
        } else {
            return ""
        }

        let hash = NSMutableString()
        for val in result {
            hash.appendFormat("%02hhx", val)
        }
        return hash as String
    }
    
    func l(_ args:String...) -> String {
        var localizedStr = NSLocalizedString(self , bundle: Bundle.main, comment: "")
        localizedStr = localizedStr.isEmpty ? self : localizedStr
        args.enumerated().forEach {
            localizedStr = localizedStr.replacingOccurrences(of: "\\\($0)", with: $1) }
        return localizedStr
    }
    
    var l: String {
        let localizedStr = NSLocalizedString(self , bundle: Bundle.main, comment: "")
        return localizedStr.isEmpty ? self : localizedStr
    }
    
}

//MARK: UIFont

extension UIFont {
    private static var ud : UserDefaults { .standard }
    static func getEncryption(_ s:CGFloat) -> UIFont {
        let ud = UserDefaults.standard
        if ud.bool(forKey:.isCordMode) { return UIFont(name: "cordIn",size: 1.15 * s)! }
        return UIFont.systemFont(ofSize: s, weight: .semibold)
    }
    static func codeFont(_ size: CGFloat) -> UIFont {
        return ud.bool(forKey: .isCordMode) ?
        UIFont(name: "codeIn",size: size * 1.15)! :
        UIFont.systemFont(ofSize: size)
    }
}
