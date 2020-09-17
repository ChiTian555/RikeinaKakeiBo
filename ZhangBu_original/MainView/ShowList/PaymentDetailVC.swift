//
//  PaymentDetailViewController.swift
//  ZhangBu_original
//
//  Created by takumi on 2020/08/16.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import RealmSwift
import PKHUD
import SwiftDate

class PaymentDetailVC: MainBaceVC, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate {

    var detailPayment: Payment!
    
    var changed: Bool = false
    
    var memo = String()
    
    var pickerView = UIPickerView()
    
    var datePicker = UIDatePicker()
    
    var list: [[String]] = [[]]
    
    var textFields = [UITextField]()
    
    var allTextFields = [UITextField]()
    
    var dayTextField = UITextField()
    
    var priceTextField = UITextField()
    
    var commentTextFile = UITextView()
    
    var labelZero = UILabel()
    
    var labelYen = UILabel()
    
    var dayNomber = Int()
    
    @IBOutlet var settingTableView: UITableView!
    
    @IBOutlet var changeMainCategoryTab: UISegmentedControl!
    
    var menu = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //完成版で外す
        settingTableView.isUserInteractionEnabled = false
        changeMainCategoryTab.isUserInteractionEnabled = false
        
        pickerView.delegate = self
        pickerView.dataSource = self
        settingTableView.dataSource = self
        let mainCategory = detailPayment.mainCategoryNumber
        changeMainCategoryTab.selectedSegmentIndex = mainCategory
        settingTableView.separatorInset = .init(top: 0, left: 120, bottom: 0, right: 0)
        settingTableView.estimatedRowHeight = 40
        settingTableView.rowHeight = UITableView.automaticDimension
        memo = detailPayment.memo
        settingTableView.tableFooterView = UIView()
        settingTableView.set()
        UIView.animate(
            withDuration: 0.0,
            animations:{
                // リロード
                self.settingTableView.reloadData()
            }, completion:{ finished in
                if (finished) { // 一応finished確認はしておく
                    self.firstLoad()
                }
        });
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ChangeMenu(menu: detailPayment.mainCategoryNumber)
        settingTableView.reloadData()
//        navigationController?.navigationItem.backBarButtonItem = nil
    }
    
    func firstLoad() {
        commentTextFile.text = detailPayment.memo
        dayTextField.text = detailPayment.date.toFormat("yyyy-MM-dd")
        switch detailPayment.mainCategoryNumber {
        case 0:
            if detailPayment.price < 0 {
                priceTextField.text = String(detailPayment.price * -1)
                labelZero.text = "-"
            } else {
                priceTextField.text = String(detailPayment.price)
                labelZero.text = ""
                labelZero.textColor = .label
                labelYen.textColor = .label
                priceTextField.textColor = .label
            }
            textFields[1].text = detailPayment.paymentMethod
            textFields[0].text = detailPayment.category
        case 1:
            textFields[1].text = detailPayment.paymentMethod
            textFields[0].text = detailPayment.category
            priceTextField.text = String(detailPayment.price)
        case 2:
            textFields[1].text = detailPayment.paymentMethod
            textFields[0].text = detailPayment.withdrawal
            priceTextField.text = String(detailPayment.price)
        default:
            print("Error")
        }
    }
    
    @IBAction func selectedMenu(_ sender: UISegmentedControl) {
        
        if changed == true {
            textFields = [UITextField]()
            ChangeMenu(menu: sender.selectedSegmentIndex)
            UIView.animate(
                withDuration: 0.0,
                animations:{
                    // リロード
                    self.settingTableView.reloadData()
                }, completion:{ finished in
                    if (finished) { // 一応finished確認はしておく
                        for textField in self.textFields {
                            textField.text = ""
                        }
                    }
            });
            return
        }
        let alert = UIAlertController(title: "ほんとに変更しますか?", message: "一部入力内容が消えてしまいます。\nよろしいですか?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "OK", style: .destructive) { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.changed = true
            self.textFields = [UITextField]()
            self.ChangeMenu(menu: sender.selectedSegmentIndex)
            UIView.animate(
                withDuration: 0.0,
                animations:{
                    // リロード
                    self.settingTableView.reloadData()
                }, completion:{ finished in
                    if (finished) { // 一応finished確認はしておく
                        for textField in self.textFields {
                            textField.text = ""
                        }
                    }
            });
        }
        
        let canselAction = UIAlertAction(title: "戻る", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.changeMainCategoryTab.selectedSegmentIndex = self.detailPayment.mainCategoryNumber
        }
        alert.addAction(canselAction)
        alert.addAction(deleteAction)
        self.present(alert, animated: true, completion: nil)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count + 3
    }
    
    var pickerTab = 0 //pickerにタブをつけるため。
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mode = changeMainCategoryTab.selectedSegmentIndex
        var cell = UITableViewCell.create()
        if indexPath.row == 0 {
            pickerTab = 0
            textFields = []
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell1")!
            cell.tag = 1
            priceTextField = cell.contentView.viewWithTag(3) as! UITextField
            allTextFields.append(priceTextField)
            priceTextField.keyboardType = UIKeyboardType.numberPad
            let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
            let doneItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(done2))
            doneItem.tintColor = UIColor.orange
            
            let cancelItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(cancel2))
            cancelItem.tintColor = UIColor.orange
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            toolbar.setItems([cancelItem, spaceButton, doneItem], animated: true)
            priceTextField.inputAccessoryView = toolbar
            labelZero = cell.contentView.viewWithTag(1) as! UILabel
            labelYen = cell.contentView.viewWithTag(2) as! UILabel
            switch mode {
            case 0:
                labelZero.textColor = UIColor.red
                labelYen.textColor = UIColor.red
                labelZero.text = "-"
                priceTextField.textColor = UIColor.red
            case 1:
                labelZero.textColor = UIColor.green
                labelYen.textColor = UIColor.green
                labelZero.text = ""
                priceTextField.textColor = UIColor.green
            case 2:
                labelZero.textColor = UIColor.systemBlue
                labelYen.textColor = UIColor.systemBlue
                labelZero.text = ""
                priceTextField.textColor = UIColor.systemBlue
            default:
                print("error")
            }
            let ud = UserDefaults.standard
            if ud.bool(forKey: .isCordMode)! {
                let cordFont = UIFont(name: "cordFont", size: 35)
                priceTextField.font = cordFont
                labelYen.font = cordFont
                labelZero.font = cordFont
            } else {
                let systemFont = UIFont.systemFont(ofSize: 35, weight: .thin)
                priceTextField.font = systemFont
                labelYen.font = systemFont
                labelZero.font = systemFont
            }
            priceTextField.attributedPlaceholder = NSAttributedString(string: "ここに金額を入力", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35, weight: .thin)])
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
        } else if indexPath.row - 1 <= menu.count {
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell2")!
            cell.tag = indexPath.row
            let row = indexPath.row - 1
            let label = cell.contentView.viewWithTag(1) as! UILabel
            let textField = cell.contentView.viewWithTag(2) as! UITextField
            textField.placeholder = "タップして選択"
            if row == menu.count {
                label.text = "日付"
                dayTextField = textField
                addDatePicer(textField: textField)
            } else {
                label.text = menu[row]
                textFields.append(textField)
                addPickerView(textField: textField)
            }
            allTextFields.append(textField)
            textField.tintColor = .clear
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell3")!
            commentTextFile = cell.contentView.viewWithTag(2) as! UITextView
            commentTextFile.text = memo
            let selectionView = UIView()
            //タップするとオレンジ色になる
            selectionView.backgroundColor = UIColor.orange
            cell.selectedBackgroundView = selectionView
        }
        
        return cell.set()
        
    }
    
    func ChangeMenu(menu mode: Int) {
        settingTableView.delegate = self
        let categoryList = CategoryList.readAllCategory(mode)
        menu = categoryList.map({ $0.categoryName })
        list = categoryList.map({ $0.list + [] })
    }
    
    //CGRectを簡単に作る
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func addDatePicer(textField: UITextField) {
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, view.frame.size.width, 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done1))
        doneItem.tintColor = UIColor.orange
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        datePicker.datePickerMode = .date
        datePicker.date = detailPayment.date
        datePicker.maximumDate = Date()
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar
    }
        
    func addPickerView(textField: UITextField) {
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(done))
        doneItem.tintColor = UIColor.orange
        let cancelItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(cancel))
        cancelItem.tintColor = UIColor.orange
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelItem, spaceButton, doneItem], animated: true)

        let newPickerView = UIPickerView()
        
        newPickerView.delegate = self
        newPickerView.dataSource = self
        
        newPickerView.tag = pickerTab
        pickerTab += 1
        textField.inputView = newPickerView
        textField.inputAccessoryView = toolbar
    }
        
    @objc func cancel() {
        guard let i = reloadEditing() else { return }
        let textField = textFields[i]
        if textFields[i].text == "" {
            textFields[i].text = menu[i]
        }
        textField.resignFirstResponder()
    }
    
    @objc func cancel2() {
        priceTextField.resignFirstResponder()
    }
    
    @objc func done() {
        guard let i = reloadEditing() else { return }
        if textFields[i].text == "" {
            textFields[i].text = menu[i]
        }
        if textFields.count - 1 > i {
            textFields[i + 1].becomeFirstResponder()
        } else {
            dayTextField.becomeFirstResponder()
        }
    }
    // 決定ボタン押下
    @objc func done1() {
        dayTextField.resignFirstResponder()
        
        // 日付のフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dayTextField.text = "\(formatter.string(from: datePicker.date))"
    }
    
    @objc func done2() {
        textFields[0].becomeFirstResponder()
//        pickerView.reloadAllComponents()
    }
        
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return list[changeMainCategoryTab.selectedSegmentIndex][pickerView.tag].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let titleOfRow = list[pickerView.tag][row]
        if textFields[pickerView.tag].text == titleOfRow {
            pickerView.selectRow(row, inComponent: component, animated: false)
        }
        return titleOfRow
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let textField = textFields[pickerView.tag]
        textField.text = list[pickerView.tag][row]
//        textFields[editingNumber].resignFirstResponder()
    }
    
        
        
    func reloadEditing() -> Int! {
        if let editingNumber = textFields.firstIndex(where: { (textField) -> Bool in
            return textField.isFirstResponder
            }) {
            return editingNumber
        } else {
            HUD.flash(.labeledError(title: "Error", subtitle: "予期せぬエラー"), delay: 2)
            return nil
        }
    }
    
        //テーブルビューがタップされたときの動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == menu.count + 2  {
            self.performSegue(withIdentifier: "toPLDMemoEdit", sender: nil)
        } else if indexPath.row == 0 && changeMainCategoryTab.selectedSegmentIndex == 0 {
            
            let becomePuls = labelZero.text == "-"
            labelZero.text = (becomePuls ? "" : "-")
            labelYen.textColor = (becomePuls ? .label : .systemRed)
            labelYen.textColor = (becomePuls ? .label : .systemRed)
            
        }
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
        
        
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPLDMemoEdit" {
            let vc = segue.destination as! EditMemoOfPLDViewController
            vc.memo = commentTextFile.text
            vc.width = commentTextFile.frame.width
        }
    }
    
    @IBAction func openMenu(){
        
        allTextFields.forEach { (textField) in
            textField.resignFirstResponder()
        }
        let alert = UIAlertController(title: "メニュー", message: "メニューからお選びください", preferredStyle: .actionSheet)
        
        let overwriteAction = UIAlertAction(title: "上書き保存", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.overwrite()
        }
        
        let deleteAction = UIAlertAction(title: "削除", style: .destructive) { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.deletePayment()
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(overwriteAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func deletePayment() {
        
        let alertController = UIAlertController(title: "削除", message: "ほんとに削除しても?\nよろしいですか?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: .destructive) { (action) in
            alertController.dismiss(animated: true, completion: nil)
            
            self.detailPayment.delete()
            
            let alert = UIAlertController(title: "削除成功！", message: "新家計簿の記入を続けますか?\n閲覧ページに戻ります", preferredStyle: .alert)
            let moveAction = UIAlertAction(title: "OK", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
            
            alert.addAction(moveAction)
            self.present(alert, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "戻る", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func overwrite() {

//        var fields = [UITextField]()
//        fields.append(priceTextField)
//        fields.append(contentsOf: textFields)
//        fields.append(dayTextField)
        
        let checkFields = allTextFields.contains(where: { (textField) -> Bool in
            return textField.text == ""
        })
        
        if checkFields {
            HUD.flash(.labeledError(title: "Error", subtitle: "空欄があります！"), delay: 2)
            return
        }
        
        let alertController = UIAlertController(title: "上書き保存", message: "ほんとに上書きしても?\nよろしいですか?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: .destructive) { (action) in
            alertController.dismiss(animated: true, completion: nil)
            let mainCategoryNomber = self.changeMainCategoryTab.selectedSegmentIndex
            let newPayment = Payment()
            
            newPayment.mainCategoryNumber = Int(mainCategoryNomber)
            newPayment.memo = self.commentTextFile.text
            newPayment.date = self.dayTextField.text!.toDate("yyyy-MM-dd")!.date
            switch mainCategoryNomber {
            case 0:
                if self.labelZero.text == "-" {
                    newPayment.paymentMethod = self.textFields[1].text!
                    newPayment.price = Int(self.priceTextField.text!)! * -1
                    newPayment.category = self.textFields[0].text!
                } else {
                    newPayment.paymentMethod = self.textFields[1].text!
                    newPayment.price = Int(self.priceTextField.text!)!
                    newPayment.category = self.textFields[0].text!
                }
            case 1:
                newPayment.paymentMethod = self.textFields[0].text!
                newPayment.price = Int(self.priceTextField.text!)!
            case 2:
                newPayment.paymentMethod = self.textFields[1].text!
                newPayment.withdrawal = self.textFields[0].text!
                newPayment.price = Int(self.priceTextField.text!)!
            default:
                print("Error")
            }
            self.detailPayment.setValue(newValue: newPayment)
                
            let alert = UIAlertController(title: "保存成功！", message: "新家計簿の記入を続けますか?\n閲覧ページに戻ります", preferredStyle: .alert)
            let moveAction = UIAlertAction(title: "OK", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(moveAction)
            self.present(alert, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "戻る", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
