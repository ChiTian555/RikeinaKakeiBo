//
//  CustomToolBar.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/23.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit

class CustomToolBar: UIToolbar {
    private let ud = UserDefaults.standard
    init() {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        var barFrame: CGRect!
        //iPhone X 以降で、以下のコードが実行されます
        if height > 800.0 && height < 1000.0 {
            barFrame = CGRect(x: 0, y: height * 0.92, width: width, height: 42)
        } else {
            barFrame = CGRect(x: 0, y: height * 0.92, width: width, height: 37)
        }
        super.init(frame: barFrame)
        self.isTranslucent = true
        self.tintColor = ud.color(forKey: .userColor, alpha: 70)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
