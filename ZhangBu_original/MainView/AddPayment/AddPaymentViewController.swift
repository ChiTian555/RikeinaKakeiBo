//
//  AddPaymentViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/11.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import RealmSwift
import PKHUD
import SwiftDate
import Instructions

class AddPaymentViewController: MainBaceVC, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{
    
    var memo = String()
    var memoIndexPath = IndexPath()
    var memoTextView = UITextView()
    
    var datePicker = UIDatePicker()
    
    var editingTextFieldNomber: Int!
    
    var list = [[String]]()
    
    var textFields = [UITextField]()
    
    var allTextFields = [UITextField]()
    
    var dayTextField = UITextField()
    
    var priceTextField = UITextField()
    
    var labelZero = UILabel()
    
    var labelYen = UILabel()
    
    var isNavigationMove: Bool!
    
    var startStepLabel: UILabel!
    
    var selectAccountNomber = Int()
    
    var coachController = CoachMarksController()
    
    @IBOutlet var useSavedMoneyCheckLabel: UILabel!
    
    @IBAction func selectMenu(_ sender: UISegmentedControl) {
        useSavedMoneyCheckLabel.text = "貯金利用 ×"
        textFields = [UITextField]()
        ChangeMenu(menu: sender.selectedSegmentIndex)
        useSavedMoneyCheckLabel.isHidden = (sender.selectedSegmentIndex != 0)
        self.reloadData(allReset: false)
//        UIView.animate(
//            withDuration: 0.0,
//            animations:{
//                // リロード
//                self.reloadData(allReset: false)
//            }, completion:{ finished in
//                if (finished) { // 一応finished確認はしておく
//                    for textField in self.textFields {
//                        textField.text = ""
//                    }
//                }
//        });
    }
    
    @IBOutlet var label: UILabel!
    
    let ud = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewWillApare")
        let menuNomber = changeMainCategoryTab.selectedSegmentIndex
        useSavedMoneyCheckLabel.isHidden = (menuNomber != 0)
        ChangeMenu(menu: menuNomber)
        UIView.animate(
            withDuration: 0.0,
            animations:{
                // リロード
                if self.isNavigationMove {
                    if self.memo != "" {
                        self.memoTextView.text = self.memo
                        self.settingTableView.reloadRows(at: [self.memoIndexPath], with: .none)
                    }
                } else {
                    self.reloadData(allReset: true)
                }
            }, completion:{ finished in
                if (finished) && !self.isNavigationMove { // 一応finished確認はしておく
                    for textField in self.allTextFields {
                        textField.text = ""
                    }
                    self.memoTextView.text = ""
                    self.useSavedMoneyCheckLabel.text = "貯金利用 ×"
                }
                self.memo = ""
                self.isNavigationMove = false
        });
    }
    
    @IBOutlet var settingTableView: UITableView!
    
    @IBOutlet var changeMainCategoryTab: UISegmentedControl!
    
    var menu = [String]()
    
    func ChangeMenu(menu mode: Int) {
        settingTableView.delegate = self
        let categoryList = CategoryList.readAllCategory(mode)
        menu = categoryList.map({ $0.categoryName })
        list = categoryList.map({ $0.list + [] })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        isNavigationMove = false
        settingTableView.dataSource = self
        ChangeMenu(menu: changeMainCategoryTab.selectedSegmentIndex)
        settingTableView.separatorInset = .init(top: 0, left: 120, bottom: 0, right: 0)
        settingTableView.estimatedRowHeight = 40
        settingTableView.rowHeight = UITableView.automaticDimension
        settingTableView.tableFooterView = UIView()
        settingTableView.set()

        textFields = [UITextField]()
        
        let taped = UITapGestureRecognizer(target: self, action: #selector(changeUseSaveMoney(_:)))
        taped.numberOfTouchesRequired = 1
        useSavedMoneyCheckLabel.addGestureRecognizer(taped)
        useSavedMoneyCheckLabel.isUserInteractionEnabled = true
        useSavedMoneyCheckLabel.textAlignment = .center
//        useSavedMoneyCheckLabel.backgroundColor = .secondarySystemBackground
        useSavedMoneyCheckLabel.layer.borderWidth = 0.5
        useSavedMoneyCheckLabel.layer.borderColor = UIColor.systemGray.cgColor
        useSavedMoneyCheckLabel.layer.cornerRadius = useSavedMoneyCheckLabel.layer.bounds.height / 5
        useSavedMoneyCheckLabel.clipsToBounds = true
    }
    
    @objc func changeUseSaveMoney(_ sender: UITapGestureRecognizer) {
        if useSavedMoneyCheckLabel.text == "貯金利用 ×" {
            useSavedMoneyCheckLabel.text = "貯金利用 ○"
        } else {
            useSavedMoneyCheckLabel.text = "貯金利用 ×"
        }
    }
    
    //tableViewの設定
    var cells = [UITableViewCell]()
    
    func reloadData(allReset: Bool) {
        loadCells(allReset)
        // リロード
        self.settingTableView.reloadData()
    }
    
    var cellCount: Int = 0
    var pickerTab: Int = 0 //pickerにタブをつけるため。
    func loadCells(_ allReset:Bool) {
        cellCount = menu.count + 3
        //全部のセルを配列に格納
        cells = []
        for row in 0 ..< cellCount {
            
            var cell = UITableViewCell.create()
                
            let mode = changeMainCategoryTab.selectedSegmentIndex
            if row == 0 {
                pickerTab = 0
                textFields = []
                cell = settingTableView.dequeueReusableCell(withIdentifier: "Cell1")!
                let newPriceTextField = cell.contentView.viewWithTag(3) as! UITextField
                newPriceTextField.text = (allReset ? "" : priceTextField.text)
                priceTextField = newPriceTextField
                allTextFields.append(priceTextField)
                priceTextField.keyboardType = UIKeyboardType.numberPad
                priceTextField.keyboardAppearance = UIKeyboardAppearance.default
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
                
                let colors: [UIColor] = [.systemRed,.systemGreen,.systemBlue]
                labelZero.textColor = colors[mode]
                labelYen.textColor = colors[mode]
                labelZero.text = (mode == 0 ? "-" : "")
                priceTextField.textColor = colors[mode]
                
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
                
            } else if row - 1 <= menu.count {
                cell = settingTableView.dequeueReusableCell(withIdentifier: "Cell2")!
                let newRow = row - 1
                let label = cell.contentView.viewWithTag(1) as! UILabel
                let textField = cell.contentView.viewWithTag(2) as! UITextField
                textField.text = ""
                textField.placeholder = "タップして選択"
                if newRow == menu.count {
                    label.text = "日付"
                    if !allReset { textField.text = dayTextField.text }
                    dayTextField = textField
                    addDatePicer(textField: textField)
                } else {
                    label.text = menu[newRow]
                    //最初のチュートリアル用
                    if menu[newRow] == "決済方法" && UserDefaults.standard.integer(forKey: .startStep) == 1 {
                        startStepLabel = label
                    } else if menu[newRow] == "項目" && UserDefaults.standard.integer(forKey: .startStep) == 2 {
                        startStepLabel = label
                    }
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
                    tapGesture.numberOfTouchesRequired = 1
                    label.addGestureRecognizer(tapGesture)
                    textFields.append(textField)
                    addPickerView(textField: textField)
                }
                allTextFields.append(textField)
                textField.tintColor = .clear
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
            } else {
                cell = settingTableView.dequeueReusableCell(withIdentifier: "Cell3")!
                memoIndexPath = IndexPath(row: row, section: 0)
                let newTextView = cell.contentView.viewWithTag(2) as! UITextView
                newTextView.text = (allReset ? "" : memoTextView.text)
                memoTextView = newTextView
                let selectionView = UIView()
                //タップするとオレンジ色になる
                selectionView.backgroundColor = .systemOrange
                cell.selectedBackgroundView = selectionView
            }
            
            cells.append(cell.set())
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return cells[indexPath.row]
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        if let irLabel = sender.view as? UILabel {
            self.performSegue(withIdentifier: "toAdd", sender: irLabel.text)
        }
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
        if dayTextField.text == "" {
            datePicker.date = Date()
        } else {
            print(dayTextField.text!)
            datePicker.date = DateInRegion(dayTextField.text!, format: "yyyy-MM-dd")!.date
        }
        datePicker.maximumDate = Date()
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar
    }
    
    func addPickerView(textField: UITextField) {
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(goNext))
        doneItem.tintColor = UIColor.orange
        let cancelItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
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
    //pickerViewのボタン
    @objc func done() {
        guard let i = reloadEditing() else { return }
        if textFields[i].text == "" && list[i].count != 0 {
            textFields[i].text = list[i][0]
        }
        textFields[i].resignFirstResponder()
    }
    //pickerViewのボタン
    @objc func goNext() {
        guard let i = reloadEditing() else { return }
        if textFields[i].text == "" && list[i].count != 0 {
            textFields[i].text = list[i][0]
        }
        if textFields.count - 1 > i {
            textFields[i + 1].becomeFirstResponder()
        } else {
            dayTextField.becomeFirstResponder()
        }
    }
    
    @objc func cancel2() {
        priceTextField.resignFirstResponder()
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
        // 価格、メニュー、日付、メモ
        if indexPath.row == menu.count + 2  {
            self.performSegue(withIdentifier: "toEdit", sender: nil)
            self.isNavigationMove = true
        } else if indexPath.row == 0 && changeMainCategoryTab.selectedSegmentIndex == 0 {
            if labelZero.text == ""{
                labelZero.text = "-"
                
                labelYen.textColor = .red
                priceTextField.textColor = .red
            } else {
                labelZero.text = ""
                labelYen.textColor = UIColor.label
                priceTextField.textColor = .label
            }
        }
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEdit" {
            let vc = segue.destination as! EditMemoViewController
            vc.memo = memoTextView.text
            vc.width = memoTextView.frame.width
        } else if segue.identifier == "toAdd" {
            let vc = segue.destination as! AddCategoryViewController
            vc.mainCategoryNumber = changeMainCategoryTab.selectedSegmentIndex
            vc.tappedCategoriesName = (sender as! String)
        }
    }
    
    @IBAction func add() {

        var fields = [UITextField]()
        fields.append(priceTextField)
        fields.append(contentsOf: textFields)
        fields.append(dayTextField)
        
        let checkFields = fields.contains(where: { (textField) -> Bool in
            return textField.text == ""
        })
        
        if checkFields {
            HUD.flash(.labeledError(title: "Error", subtitle: "空欄があります！"), delay: 2)
            return
        }
        
        let alertController = UIAlertController(title: "保存", message: "ほんとに保存しても?\nよろしいですか?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
            
            let mainCategoryNomber = self.changeMainCategoryTab.selectedSegmentIndex
            
            let payment = Payment.create()
            payment.mainCategoryNumber = Int(mainCategoryNomber)
            payment.memo = self.memoTextView.text
            payment.date = self.dayTextField.text!.toDate("yyyy-MM-dd")!.date
            print(payment.date)
            switch mainCategoryNomber {
            case 0:
                payment.paymentMethod = self.textFields[1].text!
                payment.category = self.textFields[0].text!
                if self.labelZero.text == "-" {
                    payment.price = Int(self.priceTextField.text!)! * -1
                } else {
                    payment.price = Int(self.priceTextField.text!)!
                }
                if self.useSavedMoneyCheckLabel.text == "貯金利用 ○" {
                    payment.isUsePoketMoney = false
                }
            case 1:
                payment.paymentMethod = self.textFields[1].text!
                payment.category = self.textFields[0].text!
                payment.price = Int(self.priceTextField.text!)!
            case 2:
                payment.paymentMethod = self.textFields[1].text!
                payment.withdrawal = self.textFields[0].text!
                payment.price = Int(self.priceTextField.text!)!
                payment.isUsePoketMoney = false
            default:
                print("Error")
            }

            payment.save()
                
            let alert = UIAlertController(title: "保存成功！", message: "新家計簿の記入を続けますか?", preferredStyle: .alert)
            let moveAction = UIAlertAction(title: "戻る", style: .cancel) { (action) in
                alert.dismiss(animated: true, completion: nil)
                for textField in self.allTextFields {
                    textField.text = ""
                }
                self.memoTextView.text = ""
                self.tabBarController?.selectedIndex = 1
            }
            let stayAction = UIAlertAction(title: "はい", style: .default) { (action) in
                self.priceTextField.text = ""
                for textField in self.allTextFields {
                    textField.text = ""
                }
                self.memoTextView.text = ""
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(moveAction)
            alert.addAction(stayAction)
            self.present(alert, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "戻る", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    
}

extension AddPaymentViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if list[pickerView.tag].count == 0 {
            return 1
        }
        return list[pickerView.tag].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if list[pickerView.tag].count == 0 {
            return "項目がありません!"
        }
        return list[pickerView.tag][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let textField = textFields[pickerView.tag]
        if list[pickerView.tag].count == 0 {
            return
        }
        textField.text = list[pickerView.tag][row]
    }
    
}

extension AddPaymentViewController: CoachMarksControllerDataSource {
    
    override func viewDidAppear(_ animated: Bool) {
        if [1,2].contains(self.ud.integer(forKey: .startStep)) {
            coachController.dataSource = self
            self.coachController.start(in: .viewController(self))
            changeMainCategoryTab.isUserInteractionEnabled = false
        } else {
            changeMainCategoryTab.isUserInteractionEnabled = true
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.coachController.stop(immediately: true)
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        return self.coachController.helper.makeCoachMark(for: startStepLabel, pointOfInterest: nil, cutoutPathMaker: nil)
        // for: にUIViewを指定すれば、マークがそのViewに対応します
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        let texts = ["ここをタップして\n登録済みの\n口座を登録してください",
                     "ここをタップして\n新しい項目を登録しましょう\n例えば、食費、交通費、\n交際費などなど！"]
        
        coachViews.bodyView.hintLabel.text = texts[ud.integer(forKey: .startStep)! - 1]
        coachViews.bodyView.nextLabel.text = "了解" // 「次へ」などの文章

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
}
