//
//  CustomToolBar.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/23.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit

enum ToolBarType {
    case done(done:Selector)
    case cancelAndDone(cancel:Selector,done:Selector)
    case doneAndNext(done:Selector,next:Selector)
}

class MyToolBar: UIToolbar {
    private let ud = UserDefaults.standard
    init(_ target: Any?,type:ToolBarType) {
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
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                          target: nil, action: nil)
        let t = target
        switch type {
        case .done(done: let done):
            let done = UIBarButtonItem(title: "Done", style: .done, target: t, action: done)
            done.tintColor = self.ud.color(forKey: .userColor, alpha: 0.7)
            self.setItems([spaceButton, done], animated: true)
        case .doneAndNext(done: let d, next: let n):
            let next = UIBarButtonItem(title: "Next", style: .done, target: t, action: n)
            let done = UIBarButtonItem(title: "Done", style: .plain, target: t, action: d)
            next.tintColor = ud.color(forKey: .userColor, alpha: 0.7)
            done.tintColor = ud.color(forKey: .userColor, alpha: 0.7)
            self.setItems([done, spaceButton, next], animated: true)
        case .cancelAndDone(cancel: let c, done: let d):
            let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: t, action: c)
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: t, action: d)
            cancel.tintColor = ud.color(forKey: .userColor, alpha: 0.7)
            done.tintColor = ud.color(forKey: .userColor, alpha: 0.7)
            self.setItems([cancel, spaceButton, done], animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
