//
//  AddCategoryViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/19.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import PKHUD
import RealmSwift

class AddCategoryViewController: MainBaceVC, UITableViewDataSource {

    //遷移前画面からをくられる変数
    var categoryList: CategoryList!
    var list = [String]()
    var accountList = [String]()
    
    var menu = String()
    
    var mainCategoryNumber: Int!
    var tappedCategoriesName: String!
    
    let ud = UserDefaults.standard
    
    var settingTextField: UITextField!
    
//    var selectAccountMode: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.set()
        
        navigationController?.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoryList = CategoryList.readCategory(mainCategoryNumber, tappedCategoriesName)
        
        list = categoryList.list + []
        
        if categoryList.selectAccount {
            accountList = Account.readAll().map({ $0.name })
            print(accountList)
            accountList.removeAll { (account) -> Bool in
                return list.map({$0}).contains(account)
            }
        }
        
        self.navigationItem.title = "\(categoryList.categoryName)の内容"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if list.count == 0 { return 1 } else { return list.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        if list.count == 0 {
            cell.textLabel?.text = "右上の'menu'から、\(categoryList.categoryName)を追加しよう!"
            cell.selectionStyle = .none
        } else {
            cell.textLabel?.text = list[indexPath.row]
        }
        
        return cell.set()
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
        
        if list.count <= 1 {
            alert.addAction(addAction)
        } else if tableView.isEditing {
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
            if text.count == 0 {
                HUD.flash(.labeledError(title: "入力エラー", subtitle: "空欄があります") , delay: 1.5)
                return
            }
            if text.count > 5 && !self.categoryList.selectAccount {
                textAlert.dismiss(animated: true, completion: nil)
                HUD.flash(.labeledError(title: "入力エラー",
                                        subtitle: "1~5字で入力してください。"),
                          delay: 2){_ in
                    self.present(textAlert, animated: true, completion: nil)
                    
                }
                return
            }
            if self.list.map({$0}).contains(text) {
                textAlert.dismiss(animated: true, completion: nil)
                HUD.flash(.labeledError(title: "入力エラー",
                                        subtitle: "重複しています"),
                          delay: 2){_ in
                    self.present(textAlert, animated: true, completion: nil)
                }
                return
            }
            self.list.append(text)
            self.categoryList.upDate(newList: self.list, name: nil)
            self.tableView.reloadData()
            if [1,2].contains(self.ud.integer(forKey: .startStep)){
                if self.ud.integer(forKey: .startStep) == 1 && self.categoryList.categoryName == "決済方法" {
                    self.ud.setInteger(2, forKey: .startStep)
                } else if self.ud.integer(forKey: .startStep) == 2 && self.categoryList.categoryName == "項目" {
                    self.ud.setInteger(3, forKey: .startStep)
                }
                    // 親VCを取り出し
                    let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
                    tbc.setStartStep()
            }
            textAlert.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            textAlert.dismiss(animated: true, completion: nil)
        }
        textAlert.addAction(okAction)
        textAlert.addAction(cancelAction)
        textAlert.addTextField { (textField) in
            textField.placeholder = "ここにコメントを入力"
            if self.categoryList.selectAccount {
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
        let sourceItem = list.remove(at: sourceIndexPath.row)
        list.insert(sourceItem, at: destinationIndexPath.row)
        categoryList.upDate(newList: list, name: nil)
        
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
                if text.count == 0 {
                    HUD.flash(.labeledError(title: "入力エラー", subtitle: "空欄があります"), delay: 1.5)
                    return
                }
                if text.count > 5 && !self.categoryList.selectAccount {
                    textAlert.dismiss(animated: true, completion: nil)
                    HUD.flash(.labeledError(title: "入力エラー",
                                            subtitle: "1~5字で入力してください。"),
                              delay: 1.5){_ in
                        self.present(textAlert, animated: true, completion: nil)
//                        completionHandler(false)
                    }
                    return
                }
                
                self.list[indexPath.row] = text
                self.categoryList.upDate(newList: self.list, name: nil)
                self.tableView.reloadData()
                textAlert.dismiss(animated: true, completion: nil)
                completionHandler(true)
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
            self.categoryList.upDate(newList: self.list, name: nil)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        if accountList == [""] {
            return 1
        }
        return accountList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if accountList == [""] {
            return "追加できる講座がありません"
        }
        return accountList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if accountList == [] {return}
        settingTextField.text = accountList[row]
    }
}
