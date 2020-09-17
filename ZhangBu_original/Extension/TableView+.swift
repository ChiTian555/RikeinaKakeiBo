//
//  TableView+.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/14.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    public func set() {
        self.backgroundColor = .clear
    }
    
}

extension UITableViewCell {
    
    public func set() -> UITableViewCell {
        if self.backgroundColor != UIColor.clear {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.2)
        }
        if self.selectedBackgroundView != nil || self.selectionStyle != .none {
            let colorView = UIView()
            colorView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.5)
            self.selectedBackgroundView = colorView
        }
        return self
    }
    
    static func create() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        return cell
    }
    
}
