//
//  MainBaceVC.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/14.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit

class MainBaceVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alpha = 1 - CGFloat(UserDefaults.standard.integer(forKey: .alpha)!) / 100
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(alpha)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let alpha = 1 - CGFloat(UserDefaults.standard.integer(forKey: .alpha)!) / 100
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(alpha)
    }

}
