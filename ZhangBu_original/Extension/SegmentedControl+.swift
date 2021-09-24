//
//  SegmentedController+.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/14.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import Foundation
import UIKit

extension UISegmentedControl {
    
    public var selectedTitle: String {
        get {
            return self.titleForSegment(at: self.selectedSegmentIndex) ?? ""
        }
    }
    
}
