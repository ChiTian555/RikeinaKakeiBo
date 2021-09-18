//
//  LabelWithPlaceHolder.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2021/09/04.
//  Copyright © 2021 net.Chee-Saga. All rights reserved.
//

import UIKit

class LabelWithPlaceHolder: UILabel {
    
    private var _text = ""
    
    var placeHolder: String? {
        didSet {
            if text?.isEmpty != false { super.text = placeHolder }
        }
    }
    
    override var text: String? {
        get { return _text }
        set ( text ) {
            if text?.isEmpty != false {
                super.text = placeHolder
                font = .systemFont(ofSize: font.pointSize)
                textColor = UIColor.placeholderText
            } else {
                super.text = text
                _text = text ?? ""
                font = .systemFont(ofSize: font.pointSize)
                textColor = .label
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        if text?.isEmpty != false {
            font = .systemFont(ofSize: font.pointSize)
            textColor = UIColor.placeholderText
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
