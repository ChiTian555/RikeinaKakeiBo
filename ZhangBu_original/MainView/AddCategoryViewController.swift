//
//  AddCategoryViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/19.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import PKHUD

class AddCategoryViewController: UIViewController, UITableViewDataSource {

    var lists = [[[String]]]()
    var list = [String]()
    var accountList = [String]()
    
    var menu = String()
    
    var mainCategoryNumber: Int!
    var tappedNumber: Int!
    
    let ud = UserDefaults.standard
    
    var settingTextField: UITextField!
    
    var selectAccountMode: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        
        navigationController?.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        lists = ud.stringArray3(forKey: .list)!
        list = lists[mainCategoryNumber][tappedNumber].dropFirst() + []
        menu = lists[mainCategoryNumber][tappedNumber].first!
        
        let selectAccount:[[Int]] = [[0,1],[1,1],[2,0],[2,1]]
        if selectAccount.contains([self.mainCategoryNumber,self.tappedNumber]) {
            selectAccountMode = true
            accountList = ud.stringArray2(forKey: .account)!.map({ $0.first ?? "" })
            accountList.removeAll { (account) -> Bool in
                return list.contains(account)
            }
        } else {
            selectAccountMode = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        cell.textLabel?.text = list[indexPath.row]
        
        return cell
    }
    
    @IBAction func tappedAdd() {
        
        let alert = UIAlertController(title: "メニュー", message: "メニューからお選びください", preferredStyle: .actionSheet)
        
        let addAction = UIAlertAction(title: "項目を追加", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.addCategory()
        }
        
        let editAction = UIAlertAction(title: "並び替え", style: .destructive) { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.tableView.isEditing = true
        }
        
        let endEditAction = UIAlertAction(title: "編集モード解除", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.tableView.isEditing = false
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        if tableView.isEditing {
            alert.addAction(endEditAction)
        } else {
            alert.addAction(addAction)
            alert.addAction(editAction)
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    
    func addCategory() {
        if list.count >= 11 {
            HUD.flash(.labeledError(title: "Error", subtitle: "最大10個までです"), delay: 2)
            return
        }
        let textAlert = UIAlertController(title: "項目を追加します", message: "追加する内容を入力ください", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let text = textAlert.textFields!.first!.text!
            if text.count == 0 || text.count > 8 {
                textAlert.dismiss(animated: true, completion: nil)
                HUD.flash(.labeledError(title: "入力エラー",
                                        subtitle: "1~8字で入力してください。"),
                          delay: 2){_ in
                    self.present(textAlert, animated: true, completion: nil)
                    
                }
                return
            }
            if self.list.contains(text) {
                textAlert.dismiss(animated: true, completion: nil)
                HUD.flash(.labeledError(title: "入力エラー",
                                        subtitle: "重複しています"),
                          delay: 2){_ in
                    self.present(textAlert, animated: true, completion: nil)
                }
                return
            }
            self.list.append(text)
            self.lists[self.mainCategoryNumber][self.tappedNumber] = [self.menu] + self.list
            self.ud.setArray3(self.lists, forKey: .list)
            self.tableView.reloadData()
            textAlert.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            textAlert.dismiss(animated: true, completion: nil)
        }
        textAlert.addAction(okAction)
        textAlert.addAction(cancelAction)
        textAlert.addTextField { (textField) in
            textField.placeholder = "ここにコメントを入力"
            let selectAccount:[[Int]] = [[0,1],[1,1],[2,0],[2,1]]
            if selectAccount.contains([self.mainCategoryNumber,self.tappedNumber]) {
                self.settingTextField = textField
                self.addPickerView()
            }
        }
        self.present(textAlert, animated: true, completion: nil)
    }
    
    func addPickerView() {
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let cancelItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
        cancelItem.tintColor = UIColor.orange
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton, cancelItem], animated: true)

        let newPickerView = UIPickerView()
        
        newPickerView.delegate = self
        newPickerView.dataSource = self
        
        settingTextField.inputView = newPickerView
        settingTextField.inputAccessoryView = toolbar
    }
    
    //pickerViewのボタン
    @objc func done() {
        if settingTextField.text == "" && accountList.count != 0 {
            settingTextField.text = accountList[0]
        }
        settingTextField.resignFirstResponder()
    }
    
    //CGRectを簡単に作る
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
}

extension AddCategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceCellItem = list.remove(at: sourceIndexPath.row)
        list.insert(sourceCellItem, at: destinationIndexPath.row)
        lists[mainCategoryNumber][tappedNumber] = [menu] + list
        ud.setArray3(lists, forKey: .list)
    }
    
//    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
//        return "Delete"
//    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let normalAction = UIContextualAction(style: .normal, title: "編集") {
            (action, view, completionHandler) in
                
            let textAlert = UIAlertController(title: "項目を編集する", message: "編集する内容を入力ください", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                let text = textAlert.textFields!.first!.text!
                if text.count == 0 || text.count > 8 {
                    textAlert.dismiss(animated: true, completion: nil)
                    HUD.flash(.labeledError(title: "入力エラー",
                                            subtitle: "1~8字で入力してください。"),
                              delay: 2){_ in
                        self.present(textAlert, animated: true, completion: nil)
//                        completionHandler(false)
                    }
                } else {
                    self.list[indexPath.row] = text
                    self.lists[self.mainCategoryNumber][self.tappedNumber]
                        = [self.menu] + self.list
                    self.ud.setArray3(self.lists, forKey: .list)
                    self.tableView.reloadData()
                    textAlert.dismiss(animated: true, completion: nil)
                    completionHandler(true)
                }
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                textAlert.dismiss(animated: true, completion: nil)
                completionHandler(false)
            }
            textAlert.addAction(okAction)
            textAlert.addAction(cancelAction)
            textAlert.addTextField { (textField) in
                textField.placeholder = "ここにコメントを入力"
                textField.text = self.list[indexPath.row]
            }
            self.present(textAlert, animated: true, completion: nil)
        }
        
        let destructiveAction = UIContextualAction(style: .destructive, title: "削除") {
            (action, view,completionHandler) in
            action.backgroundColor = .systemRed
            self.list.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.lists[self.mainCategoryNumber][self.tappedNumber] = [self.menu] + self.list
            self.ud.setArray3(self.lists, forKey: .list)
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [destructiveAction, normalAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if tableView.isEditing {
            return true
//        }
//        return false
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        list[mainCategoryNumber][tappedNumber].remove(at: indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: .fade)
//        ud.set(list, forKey: "list")
//    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        
    }
    
}

extension AddCategoryViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if let nv = viewController as? AddPaymentViewController {
            
            nv.isNavigationMove = true
            
        }
        
    }
    
}

extension AddCategoryViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if accountList == [] {
            return 1
        }
        return accountList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if accountList == [] {
            return "追加できる講座がありません"
        }
        return accountList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if accountList == [] {return}
        settingTextField.text = accountList[row]
    }
}
