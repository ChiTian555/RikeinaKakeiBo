//
//  EditMemoViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/13.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit

class EditMemoViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var editTextView: UITextView!

    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    var memo = ""
    
    var width = CGFloat()
    
    
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
//        editTextView = cell.viewWithTag(1) as! UITextView
//        editTextView.becomeFirstResponder()
//        editTextView.text = memo
//        return cell
//    }

//    @IBOutlet var TableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self
        
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
        widthConstraint.constant = width
    }
    
    @IBAction func ok() {
        print(width)
        print(editTextView.frame.width)
        editTextView.resignFirstResponder()
        let count = (self.navigationController?.viewControllers.count)! - 2
        let vc = self.navigationController?.viewControllers[count] as! AddPaymentViewController
        vc.memo = editTextView.text
        vc.isNavigationMove = true
        self.navigationController?.popViewController(animated: true)
    }
    
    

}

extension EditMemoViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if let nv = viewController as? AddPaymentViewController {
            
            nv.isNavigationMove = true
            
        }
        
    }
    
}
