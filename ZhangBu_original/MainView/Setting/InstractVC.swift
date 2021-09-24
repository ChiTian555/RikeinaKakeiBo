//
//  InstractVC.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2021/09/09.
//  Copyright © 2021 net.Chee-Saga. All rights reserved.
//

import UIKit

class InstractVC: UIViewController {
    
    @IBOutlet weak var instrusctTextView: UITextView!
    
    var text = """
    -  ①　携帯内残高確認
    +
            携帯内の口座アプリで残高を確認するアプリ
            ApplePay, PayPay, 等を含む
    +
    -  ②　本アプリ対応カード式ICカード
    + 
            (iOS13未満には、未対応です)
    +
        ●交通系ICカード
    +
          - Suica, Kitaca，ICOCA, TOICA, はやかけん
          - manaca, PiTaPa, nimoca, SUGOCA, Pasmo
    +
        ●買い物型ICカード
    +
          - Edy
          - nanaco
          - WAON
          - 大学生協ﾌﾟﾘﾍﾟｰﾄﾞｶｰﾄﾞ
    +
    -  ③　その他の口座
    +
    -  ④  クレカ型(負債型)口座
    """
    
    var aText = NSMutableAttributedString()
    
    private func getStyle(_ size: CGFloat) -> [NSAttributedString.Key : Any] {
        return [
            .foregroundColor : UIColor.label,
            .font : UIFont.systemFont(ofSize: size),
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var t_s:CGFloat = 20
        var s_s:CGFloat = 15
        
        let height = UIScreen.main.bounds.size.height
        if height > 800.0 && height < 1000.0 {
            t_s = 23
            s_s = 18
        }
        let array = text.split(separator: "\n")
        print(text.split(separator: "\n"))
        for t in array {
            if t.first == "-" {
                aText.append(NSAttributedString(string: t.dropFirst() + "\n",
                                                attributes: getStyle(t_s)))
            } else if t.first == "+" {
                aText.append(NSAttributedString(string: "\n", attributes: getStyle(s_s)))
            } else {
                aText.append(NSAttributedString(string: t + "\n", attributes: getStyle(s_s)))
            }
        }
        instrusctTextView.attributedText = aText
    }
}
