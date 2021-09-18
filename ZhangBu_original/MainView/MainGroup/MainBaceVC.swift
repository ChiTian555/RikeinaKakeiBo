//
//  MainBaceVC.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/14.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit

class MainBaceVC: UIViewController {
    
    private let ud = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nv = self.navigationController as? MainNC {
            nv.loadColor()
        }
        let alpha = 1 - CGFloat(ud.integer(forKey: .alpha)) / 100
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(alpha)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let nv = self.navigationController as? MainNC {
            nv.loadColor()
        }
        let alpha = 1 - CGFloat(ud.integer(forKey: .alpha)) / 100
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(alpha)
    }

}