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
    var controller: AC
    var tFs = [UITextField]()
    init(_ title:String?,_ message:String? ,style: AC.Style = .alert) {
        controller = AC(title: title, message: message, preferredStyle: style)
    }
    func addActions(_ name:String, type: AA.Style = .default,_ action:( (MyAlert) -> Void)? ) {
        controller.addAction(AA(title: name, style: type, handler: { _ in
            self.tFs.forEach { $0.resignFirstResponder() }
            self.controller.dismiss(animated: true, completion: nil)
            action?(self)
        }))
    }
    func addTextField(_ placeHolder:String, set: ( (UITextField) -> Void )? = nil ) {
        controller.addTextField { (tF) in
            tF.placeholder = placeHolder
            if let set = set { set(tF) }
            else { tF.keyboardType = .numberPad }
            self.tFs.append(tF)
        }
    }
}

