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
        self.tableFooterView = UIView()
    }

}

extension UITableViewCell {
    
    /**
     タップされたときの色を決定する。
     */
    public func set() -> UITableViewCell {
        let ud = UserDefaults.standard
        if self.backgroundColor != UIColor.clear {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.2)
        }
        if self.selectedBackgroundView != nil || self.selectionStyle != .none {
            let view = UIView.getOneColorView(color: ud.color(forKey: .buttonColor, alpha: 0.5))
            self.selectedBackgroundView = view
        }
        return self
    }
    
    /**
     透明なCellを生成する。
     */
    public func create() -> UITableViewCell {
        self.backgroundColor = .clear
        return self
    }
    
}

extension UISegmentedControl {
    
    public var selectedTitle: String {
        get { return self.titleForSegment(at: self.selectedSegmentIndex) ?? "" }
    }
    
}
