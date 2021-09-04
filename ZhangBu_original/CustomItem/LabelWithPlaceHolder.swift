//
//  LabelWithPlaceHolder.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2021/09/04.
//  Copyright © 2021 net.Chee-Saga. All rights reserved.
//

import UIKit

class LabelWithPlaceHolder: UILabel {
    
    var _text: String?
    var _placeHolder: String?
    
    var placeHolder: String? {
        get{ return _placeHolder }
        set(text){
            if _text == nil || _text == "" { super.text = text }
            _placeHolder = text
        }
    }
    
    override var text: String? {
        get{ return _text }
        set(text){
            _text = text
            if ( text != "" && text != nil ) {
                super.text = text
                font = .systemFont(ofSize: font.pointSize)
                textColor = .label
            } else {
                font = .systemFont(ofSize: font.pointSize)
                textColor = UIColor(displayP3Red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        if text == nil || text == "" {
            font = .systemFont(ofSize: font.pointSize)
            textColor = UIColor(displayP3Red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
