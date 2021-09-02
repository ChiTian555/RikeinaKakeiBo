//
//  MyAlert.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2021/09/01.
//  Copyright © 2021 net.Chee-Saga. All rights reserved.
//

import UIKit

class MyAlert {
    typealias AC = UIAlertController
    typealias AA = UIAlertAction
    var contontroller: AC
    var textField: UITextField?
    init(_ title:String,_ message:String ,style: AC.Style = .alert) {
        contontroller = AC(title: title, message: message, preferredStyle: style)
    }
    func addActions(_ name:String, type: AA.Style = .default,_ action:( (MyAlert) -> Void)? ) {
        contontroller.addAction(AA(title: name, style: type, handler: { _ in
            self.contontroller.dismiss(animated: true, completion: nil)
            action?(self)
        }))
    }
    func addTextField(_ a:String, set: ( (UITextField) -> Void )? = nil ) {
        
        contontroller.addTextField { (tF) in
            tF.placeholder = a
            if let set = set { set(tF) }
            else { tF.keyboardType = .numberPad }
            self.textField = tF
        }
    }
}
