//
//  UIView+.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/13.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    private var ud: UserDefaults { return UserDefaults.standard }
    
    public func setBackGroundPicture(alpha: CGFloat? = nil) {
        self.backgroundColor = .systemBackground
        let finalAlpha: CGFloat
        //背景画像を入れる器
        let currentBackGround = UIImageView(frame: self.bounds)
        if alpha == nil {
            finalAlpha = CGFloat(ud.integer(forKey: .alpha)) / 100
        } else {
            finalAlpha = alpha!
        }
        currentBackGround.image = ud.image(forKey: .backGraundPicture)?.alpha(finalAlpha)
        self.addSubview(currentBackGround)
        self.sendSubviewToBack(currentBackGround)
    }
    
    static func getOneColorView(color:UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        return view
    }
    
}