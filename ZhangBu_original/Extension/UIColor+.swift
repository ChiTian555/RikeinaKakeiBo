//
//  UIColor+.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/19.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import Foundation
import UIKit

// UIColor, UIImage

//MARK: UIColor

extension UIColor {
    
    func isEqualTo(_ color: UIColor) -> Bool {
        var lhsRed: CGFloat = 0.0
        var lhsGreen: CGFloat = 0.0
        var lhsBlue: CGFloat = 0.0
        self.getRed(&lhsRed, green: &lhsGreen, blue: &lhsBlue, alpha: nil)

        var rhsRed: CGFloat = 0.0
        var rhsGreen: CGFloat = 0.0
        var rhsBlue: CGFloat = 0.0
        color.getRed(&rhsRed, green: &rhsGreen, blue: &rhsBlue, alpha: nil)

        return lhsRed == rhsRed && lhsGreen == rhsGreen && lhsBlue == rhsBlue
    }
    
    private class var ud: UserDefaults { UserDefaults.standard }
    
    class var user: UIColor { ud.color(forKey: .userColor) }
    class var button: UIColor { ud.color(forKey: .buttonColor) }
    
}

//MARK: UIImage

extension UIImage {

    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    class func colorImage(color: UIColor, size: CGSize = CGSize(width: 10, height: 10)) -> UIImage {
        
        UIGraphicsBeginImageContext(size)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
    
        UIGraphicsEndImageContext()
    
        return image
    }
    
}

