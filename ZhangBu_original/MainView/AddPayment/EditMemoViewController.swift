//
//  EditMemoViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/13.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit

class EditMemoViewController: MainBaceVC, UITextViewDelegate {
    
    @IBOutlet var editTextView: UITextView!

    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    var memo = ""
    
    var width = CGFloat()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //スワイプで画面を戻る
        self.setSwipe()
        
        editTextView.delegate = self
//        TableView.delegate = self
//        TableView.dataSource = self
//        TableView.tableFooterView = UIView()
//        TableView.estimatedRowHeight = 44
//        TableView.rowHeight = UITableView.automaticDimension
        editTextView.text = memo
        editTextView.becomeFirstResponder()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        widthConstraint.constant = width
    }
    
    @IBAction func ok() {
        print(width)
        print(editTextView.frame.width)
        editTextView.resignFirstResponder()
        let count = (self.navigationController?.viewControllers.count)! - 2
        let vc = self.navigationController?.viewControllers[count] as! AddPaymentVC
        vc.memo = editTextView.text
        self.navigationController?.popViewController(animated: true)
    }

}
