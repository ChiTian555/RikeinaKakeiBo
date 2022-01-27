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
        
        //スワイプで画面を戻る
        self.setSwipe()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.set()
        
    }
    
    //新規口座登録画面から、直接入力
    public func addNewAccount(_ newAccount: String) {
        self.list.append(newAccount)
        self.categoryList.upDateList(newList: self.list, changeName: nil)
        self.setButtonColor()
        self.tableView.reloadData()
        // 初期ステップ
        let nowStep = ud.stringArray(forKey: .startSteps)!.first
        if ["1","2"].contains(nowStep){
            if nowStep == "1" && self.categoryList.name == "決済方法" {
                self.ud.deleteArrayElement("1", forKey: .startSteps)
            } else if nowStep == "2" && self.categoryList.name == "項目" {
                self.ud.deleteArrayElement("2", forKey: .startSteps)
            }
            // 親VCを取り出し
            let tbc = SceneDelegate.shared.rootVC.current as! MainTBC
            tbc.setStartStep()
        }
    }
    
    //シャッフルされたときに呼び出される
    //お手軽新規アカウント追加
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            
        guard motion == .motionShake else { return }
        if categoryList.selectAccount {
            // 名前を指定して Storyboard を取得する(Main.storyboard の場合)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // StorybaordID を指定して ViewController を取得する
            let nc = storyboard.instantiateViewController(withIdentifier: "AddAccountNC") as! MainNC
            self.present(nc, animated: true, completion: nil)
        }
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoryList = CategoryList.readCategory(mainCategoryNumber, tappedCategoriesName)
        
        list = categoryList.list
        
        if categoryList.selectAccount {
            accountList = Account.readAll().map({ $0.name })
            print(accountList)
            accountList.removeAll { (account) -> Bool in
                return list.map({$0}).contains(account)
            }
        }
        self.navigationItem.title = "\\0の内容".l(categoryList.name)
        setButtonColor()
    }
    
    func setButtonColor() {
        
        moveButton.tintColor =
            list.count > 1 ? UserDefaults.standard.color(forKey: .buttonColor) : .systemGray3
        moveButton.isEnabled = list.count > 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if list.count == 0 { return 1 } else { return list.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!.create()
        
        if list.count == 0 {
            cell.textLabel?.text = "右上の'menu'から、\\0を追加しよう!".l(categoryList.name)
            cell.selectionStyle = .none
        } else {
            cell.textLabel?.text = list[indexPath.row].l
        }
        
        return cell.setColor()
    }
    
    @IBAction func tappedAdd() {
        self.addCategory()
    }
    
    @IBOutlet var moveButton: UIBarButtonItem!
    
    @IBAction func moveCategory() {
        tableView.isEditing = !tableView.isEditing
    }
    
    func addCategory() {
        
        if categoryList.selectAccount && accountList.count == 0 {
            HUD.flash(.label("追加できる口座がありません\n携帯をシャッフルして\n新規口座を作成しましょう".l))
            return
        }
        
        if list.count >= 11 {
            HUD.flash(.labeledError(title: "Error", subtitle: "最大10個までです"), delay: 2)
            return
        }
        
        let textAlert = UIAlertController(title: "項目を追加します".l, message: "追加する内容を入力ください".l, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let text = textAlert.textFields!.first!.text!
            if text.count == 0 {
                HUD.flash(.labeledError(title: "入力エラー".l, subtitle: "空欄があります".l))
                return
            }
            if text.count > 5 && !self.categoryList.selectAccount {
                textAlert.dismiss(animated: true, completion: nil)
                HUD.flash(.labeledError(title: "入力エラー".l,
                                        subtitle: "1~5字で入力してください。".l),
                          delay: 2){_ in
                    self.present(textAlert, animated: true, completion: nil)
                    
                }
                return
            }
            if self.list.map({$0}).contains(text) {
                textAlert.dismiss(animated: true, completion: nil)
                HUD.flash(.labeledError(title: "入力エラー".l,
                                        subtitle: "重複しています".l),
                          delay: 2){_ in
                    self.present(textAlert, animated: true, completion: nil)
                }
                return
            }
            self.list.append(text)
            //アカウントを選択肢から削除
            if self.categoryList.selectAccount { self.accountList.removeAll(where: { $0 == text }) }
            self.categoryList.upDateList(newList: self.list, changeName: nil)
            self.setButtonColor()
            self.tableView.reloadData()
            if ["1","2"].contains(self.ud.stringArray(forKey: .startSteps)!.first){
                let nowStep = self.ud.stringArray(forKey: .startSteps)!.first
                if nowStep == "1" && self.categoryList.name == "決済方法" {
                    self.ud.deleteArrayElement("1", forKey: .startSteps)
                } else if nowStep == "2" && self.categoryList.name == "項目" {
                    self.ud.deleteArrayElement("2", forKey: .startSteps)
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
            textField.placeholder = "ここに\\0を入力".l(self.categoryList.name.l)
            if self.categoryList.selectAccount {
                self.settingTextField = textField
                self.addPickerView()
            }
        }
        self.present(textAlert, animated: true, completion: nil)
    }
    
    func addPickerView() {
        let toolbar = MyToolBar(self, type: .done(done: #selector(done)))

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
        categoryList.upDateList(newList: list, changeName: nil)
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
                self.categoryList.upDateList(newList: self.list, changeName: nil)
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
                textField.placeholder = "ここに\(self.categoryList.name)を入力"
                textField.text = self.list[indexPath.row]
            }
            self.present(textAlert, animated: true, completion: nil)
        }
        
        let destructiveAction = UIContextualAction(style: .destructive, title: "削除") {
            (action, view,completionHandler) in
            action.backgroundColor = .systemRed
            self.list.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.categoryList.upDateList(newList: self.list, changeName: nil)
            completionHandler(true)
        }
        let actions = categoryList.selectAccount ? [destructiveAction] : [destructiveAction, normalAction]
        let configuration = UISwipeActionsConfiguration(actions: actions)
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

extension AddCategoryViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if accountList.count == 0 {
            return 1
        }
        return accountList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if accountList.count == 0 {
            return "追加できる講座がありません"
        }
        return accountList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if accountList.count == 0 { return }
        settingTextField.text = accountList[row]
    }
}
