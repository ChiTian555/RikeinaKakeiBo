//
//  UIColor+.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/19.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import Foundation
import UIKit

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
    
}
