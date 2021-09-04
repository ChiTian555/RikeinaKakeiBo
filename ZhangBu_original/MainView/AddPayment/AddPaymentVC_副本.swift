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

class AddPaymentVC: MainBaceVC, UITableViewDataSource & UITableViewDelegate, UITextFieldDelegate {
    
    var memo = String()
    var memoIndexPath = IndexPath()
    var memoTextView = UITextView()
    
    var datePicker = UIDatePicker()
    
    var editingTextFieldNomber: Int!
    
    var list = [[String]]()
    var menu = [CategoryList]()
    var menus: [String] { ["金額"] + menu.map({$0.name}) + ["日付","メモ"] }
    
    var tFManager = CustomTextFields(self)
    
    var textFields = [UITextField]()
    var allTextFields = [UITextField]()
    
    var dayTextField = UITextField()
    var priceTextField = UITextField()
    var labelZero = UILabel()
    var labelYen = UILabel()
    
    var isNavigationMove: Bool!
    
    var startStepLabel = [UILabel]()
    
    var selectAccountNomber = Int()
    
    var coachController = CoachMarksController()
    
    //表示させるレシート画像の番号
    var pictureNumber = Int()
    var receipts = [Receipt]()
    
    // お小遣いの使用について
    @IBOutlet var useSavedMoneyCheckLabel: UILabel!
    var isUsePoketMoney: Bool {
        set(use) { useSavedMoneyCheckLabel.text = use ? "貯金利用 ○" : "貯金利用 ×" }
        get { return useSavedMoneyCheckLabel.text == "貯金利用 ○" }
    }
    
    var mainCategory: Int { changeMainCategoryTab.selectedSegmentIndex }
    
    @IBAction func selectMenu(_ sender: UISegmentedControl) {
        useSavedMoneyCheckLabel.text = "貯金利用 ×"
        textFields = [UITextField]()
        ChangeMenu(menu: sender.selectedSegmentIndex)
        if #available(iOS 14.0, *) {
            menuButton.menu = setMenu()
        }
        useSavedMoneyCheckLabel.isHidden = (sender.selectedSegmentIndex != 0)
        reloadData(allReset: false)
    }
    
    @IBOutlet var usePocketMoneyLabel: UILabel!
    
    @IBOutlet var pictureModeView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    // レシート用ImageView
    var imageView: UIImageView!
    
    let ud = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        receipts = Receipt.readAll()
        
        let menuNomber = changeMainCategoryTab.selectedSegmentIndex
        useSavedMoneyCheckLabel.isHidden = (menuNomber != 0)
        ChangeMenu(menu: menuNomber)
        // リロード
        if isNavigationMove {
            isNavigationMove = false
            if memo != "" {
                memoTextView.text = self.memo
                settingTableView.reloadRows(at: [self.memoIndexPath], with: .none)
            }
        } else {
            reloadData(allReset: true)
        }
        memo = ""
        
    }
    
    @IBOutlet var settingTableView: UITableView!
    
    @IBOutlet var changeMainCategoryTab: UISegmentedControl!
    
    
    func ChangeMenu(menu mode: Int) {
        settingTableView.delegate = self
        let categoryList = CategoryList.readAllCategory(mode)
        menu = categoryList + []
        list = categoryList.map({ $0.list + [] })
    }
    
    var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //写真関連
        imageView = UIImageView()
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        pictureModeView.isHidden = true
        
        //キーボード出現を感知
        self.configureObserver()
        
        isNavigationMove = false
        settingTableView.dataSource = self
        ChangeMenu(menu: changeMainCategoryTab.selectedSegmentIndex)
        settingTableView.separatorInset = .init(top: 0, left: 120, bottom: 0, right: 0)
        settingTableView.estimatedRowHeight = 40
        settingTableView.rowHeight = UITableView.automaticDimension
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
        
        if #available(iOS 14.0, *) {
            menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: setMenu())
        } else {
            menuButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(addUserCategory(_:)))
        }
        navigationItem.leftBarButtonItem = menuButton
    }
    
    private func setMenu() -> UIMenu {
        let addUserCategory = UIAction(title: "ユーザー項目の追加", image: UIImage(systemName: "plus")) { (action) in
            self.editUserCategory(create: true)
        }
        let editUserCategory = UIAction(title: "ユーザー項目の編集", image: UIImage(systemName: "square.and.pencil")) { (action) in
            self.editUserCategory(create: false)
        }
        let deleteUserCategory = UIAction(title: "ユーザー項目の削除", image: UIImage(systemName: "trash")) { (action) in
            self.deleteUserCategory()
        }
        let showReceipt = UIAction(title: "レシート表示", image: UIImage(systemName: "paperplane")) { (action) in
            self.turnOnPictureMode()
        }
        let menu: UIMenu!
        switch self.menu.count {
        case 2: menu = UIMenu(title: "", children: [addUserCategory, showReceipt])
        case 3: menu = UIMenu(title: "", children: [editUserCategory, deleteUserCategory, showReceipt])
        default: menu = UIMenu()
        }
        return menu
    }
    
    @objc private func addUserCategory(_ sender: Any) {
        let alert = MyAlert("", "メニューからお選びください。", style: .actionSheet)
        if menu.count == 2 {
            alert.addActions("ユーザー項目の追加") { _ in self.editUserCategory(create: true) }
        } else {
            alert.addActions("ユーザー項目の変更") { _ in self.editUserCategory(create: false) }
            alert.addActions("ユーザー項目の削除") { _ in self.deleteUserCategory() }
        }
        alert.addActions("レシートの表示") { _ in self.turnOnPictureMode() }
        present(alert.controller, animated: true, completion: nil)
    }
    
    private func editUserCategory(create: Bool) {
        let alert = MyAlert("ユーザー項目の" + (create ? "追加" : "編集"), "分類名を記入してください。")
        alert.addTextField("ここに入力") { (tF) in tF.text = create ? "" : self.menu[2].name }
        alert.addActions("キャンセル", type: .cancel, nil)
        alert.addActions("OK") { (myAlert) in
            guard let userCategoryName = myAlert.textField?.text else { return }
            if ["金額","日付","メモ"].contains(userCategoryName) {
                HUD.flash(.labeledError(title: "Error",subtitle: "このｷｰﾜｰﾄﾞは、利用できません")); return
            }
            if userCategoryName.count >= 7 {
                HUD.flash(.labeledError(title: "Error",subtitle: "6字以内で入力して下さい。")); return
            }
            if create {
                let newCategoryList = CategoryList.make()
                newCategoryList.name = userCategoryName
                newCategoryList.mainCategory = self.changeMainCategoryTab.selectedSegmentIndex
                newCategoryList.selectAccount = false
                newCategoryList.save()
                self.menu.append(newCategoryList)
            } else { self.menu[2].upDate(name: userCategoryName) }
            self.reloadData(allReset: false)
            // メニューは、中身を変えてあげる必要がある。
            if #available(iOS 14.0, *) { self.menuButton.menu = self.setMenu() }
        }
        present(alert.controller, animated: true, completion: nil)
    }
        
    func deleteUserCategory() {
        menu[2].delete()
        menu.remove(at: 2)
        reloadData(allReset: false)
        if #available(iOS 14.0, *) {
            menuButton.menu = setMenu()
        }
    }
    
    @objc func changeUseSaveMoney(_ sender: UITapGestureRecognizer) {
        isUsePoketMoney = !isUsePoketMoney
    }
    
    //tableViewの設定
    var cells = [UITableViewCell]()
    
    func reloadData(allReset: Bool) {
        loadCells(allReset)
        self.settingTableView.reloadData()
    }
    
    var cellCount: Int = 0
    var pickerTab: Int = 0 //pickerにタブをつけるため。
    
    func makeTextFieldSet(_ allReset: Bool) {
        let textFieldSet = CustomTextFields(self)
        for menu in menus {
            
            var cell: UITableViewCell!
                
            let mode = changeMainCategoryTab.selectedSegmentIndex
            if menu == "金額" {
                let colors: [UIColor] = [.systemRed,.systemGreen,.systemBlue]
                let currrentFont = ( ud.bool(forKey: .isCordMode) ?
                                        UIFont(name: "cordFont", size: 35) :
                                        UIFont.systemFont(ofSize: 35, weight: .light) )
                
                cell = settingTableView.dequeueReusableCell(withIdentifier: "Cell1")!.create()
                let newTF = cell.contentView.viewWithTag(3) as! UITextField
                textFieldSet.addTextField(tF: newTF, name: menu, type: .inputNum) { (me) in
                    me.tF.text = ""
                    me.tF.attributedPlaceholder = NSAttributedString(string: "ここに金額を入力", attributes: [.font: UIFont.systemFont(ofSize: 35, weight: .thin)])
                    me.tF.font = currrentFont
                    me.tF.textColor = colors[mode]
                }
                labelZero = cell.contentView.viewWithTag(1) as! UILabel
                labelYen = cell.contentView.viewWithTag(2) as! UILabel
                
                labelZero.textColor = colors[mode]
                labelYen.textColor = colors[mode]
                labelZero.text = (mode == 0 ? "-" : "")
                labelYen.font = currrentFont
                labelZero.font = currrentFont
            } else if menu != "メモ" {
                cell = settingTableView.dequeueReusableCell(withIdentifier: "Cell2")!.create()

                let label = cell.contentView.viewWithTag(1) as! UILabel
                let textField = cell.contentView.viewWithTag(2) as! UITextField
                label.text = menu
                textField.text = ""
                textField.tintColor = .clear
                textField.placeholder = "タップして選択"
                if menu == "日付" {
                    if !allReset { textField.text = dayTextField.text }
                    textFieldSet.addTextField(tF: textField, name: menu, type: .datePicker)
                } else {
                    textFieldSet.addTextField(tF: textField, name: menu, type: .textPicker) { (me) in
                        me.choices = CategoryList.readCategory(mode, menu)!.list + []
                    }
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
                    tapGesture.numberOfTouchesRequired = 1
                    label.addGestureRecognizer(tapGesture)
                    addPickerView(textField: textField)
                    //最初のチュートリアル用
                    if [1,2].contains(ud.integer(forKey: .startStep)) {
                        if ["決済方法","項目"].contains(menu) { startStepLabel.append(label) }
                    }
                }
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
            } else {
                cell = settingTableView.dequeueReusableCell(withIdentifier: "Cell3")!.create()
                let newTextView = cell.contentView.viewWithTag(2) as! UITextView
                newTextView.text = (allReset ? "" : memoTextView.text)
                memoTextView = newTextView
            }
            cells.append(cell.set())
        }
    }
    
    //true->
    //false->
    func loadCells(_ allReset:Bool) {
        cellCount = menu.count + 3
        //全部のセルを配列に格納
        cells = []
        for row in 0 ..< cellCount {
            
            var cell: UITableViewCell!
                
            let mode = changeMainCategoryTab.selectedSegmentIndex
            if row == 0 {
                pickerTab = 0
                textFields = []
                cell = settingTableView.dequeueReusableCell(withIdentifier: "Cell1")!.create()
                let newPriceTextField = cell.contentView.viewWithTag(3) as! UITextField
                newPriceTextField.text = (allReset ? "" : priceTextField.text)
                priceTextField = newPriceTextField
                allTextFields.append(priceTextField)
                priceTextField.keyboardType = .numberPad
                priceTextField.keyboardAppearance = .default
                let toolbar = CustomToolBar()
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
                
                let currrentFont = ( ud.bool(forKey: .isCordMode) ?
                                        UIFont(name: "cordFont", size: 35) :
                                        UIFont.systemFont(ofSize: 35, weight: .light) )
                priceTextField.font = currrentFont
                labelYen.font = currrentFont
                labelZero.font = currrentFont

                priceTextField.attributedPlaceholder = NSAttributedString(string: "ここに金額を入力", attributes: [.font: UIFont.systemFont(ofSize: 35, weight: .thin)])
                cell.selectionStyle = .none
                
            } else if row - 1 <= menu.count {
                cell = settingTableView.dequeueReusableCell(withIdentifier: "Cell2")!.create()
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
                    label.text = menu[newRow].name
                    //最初のチュートリアル用
                    if [1,2].contains(ud.integer(forKey: .startStep)) {
                        if ["決済方法","項目"].contains(menu[newRow].name) {
                            startStepLabel.append(label)
                        }
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
                cell = settingTableView.dequeueReusableCell(withIdentifier: "Cell3")!.create()
                memoIndexPath = IndexPath(row: row, section: 0)
                let newTextView = cell.contentView.viewWithTag(2) as! UITextView
                newTextView.text = (allReset ? "" : memoTextView.text)
                memoTextView = newTextView
                cell.selectedBackgroundView = .getOneColorView(color: ud.color(forKey: .buttonColor))
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
            isNavigationMove = true
            self.performSegue(withIdentifier: "toAdd", sender: irLabel.text)
        }
    }
    
    //CGRectを簡単に作る
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func addDatePicer(textField: UITextField) {
        let toolbar = CustomToolBar()
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done1))
        doneItem.tintColor = UIColor.orange
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) { datePicker.preferredDatePickerStyle = .wheels }
        if dayTextField.text == "" { datePicker.date = Date() }
        else { datePicker.date = DateInRegion(dayTextField.text!, format: "yyyy-MM-dd")!.date }
        datePicker.maximumDate = Date()
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar
    }
    
    func addPickerView(textField: UITextField) {
        
        let toolbar = CustomToolBar()
        let doneItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(goNext))
        doneItem.tintColor = ud.color(forKey: .buttonColor)
        let cancelItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
        cancelItem.tintColor = ud.color(forKey: .buttonColor)
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
    
    // テーブルビューがタップされたときの動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 価格、メニュー、日付、メモ
        if tFManager.tFSets[indexPath.row].name == "メモ" {
            self.isNavigationMove = true
            self.performSegue(withIdentifier: "toEdit", sender: nil)
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
        if let vc = segue.destination as? EditMemoViewController {
            vc.memo = memoTextView.text
            vc.width = memoTextView.frame.width
        } else if let vc = segue.destination as? AddCategoryViewController {
            vc.mainCategoryNumber = changeMainCategoryTab.selectedSegmentIndex
            vc.tappedCategoriesName = (sender as! String)
        }
    }
    
    @IBAction func add() {
        
        if tFManager.tFSets.contains(where: { $0.tF.text == "" }) {
            HUD.flash(.labeledError(title: "Error", subtitle: "空欄があります！")); return
        }
        
        let alert = MyAlert("保存", "ほんとに保存しても?\nよろしいですか?")
        alert.addActions("戻る", type: .cancel, nil)
        alert.addActions("はい") { _ in
            let payment = Payment.make()
            if self.mainCategory == 0 { payment.isUsePoketMoney = self.isUsePoketMoney }
            payment.mainCategoryNumber = Int(self.mainCategory)
            for tFSet in self.tFManager.tFSets {
                if tFSet.name == "金額" {
                    payment.price = Int(self.priceTextField.text!)!
                    if self.mainCategory == 0 { payment.price *= self.labelZero.text == "-" ? -1 : 1 }
                } else if tFSet.name == "日付" {
                    payment.date = self.dayTextField.text!.toDate("yyyy-MM-dd")!.date
                } else {
                    if !payment.set(title: tFSet.name, value: tFSet.tF.text) {
                        HUD.flash(.labeledError(title: "Error", subtitle: "エラーコード : C01_add")); return
                    }
                }
            }
            
            if let picture = self.receipts[safe: self.pictureNumber] {
                picture.delete()
                self.receipts.remove(at: self.pictureNumber)
                if self.receipts.count - 1 == self.pictureNumber && self.receipts.count != 1 {
                    self.pictureNumber -= 1
                }
            }
            
            let resultAlert = MyAlert("保存成功！","新家計簿の記入を続けますか?")
            resultAlert.addActions("一覧に戻る") { _ in
                for textField in self.allTextFields {
                    textField.text = ""
                }
                self.memoTextView.text = ""
                self.tabBarController?.selectedIndex = 1
            }
            resultAlert.addActions("続ける") { _ in
                self.reloadData(allReset: true)
                //pickerViewを1に選択してあげる必要がある
                self.setImage()
            }
            self.present(resultAlert.controller, animated: true, completion: nil)
        }
        self.present(alert.controller, animated: true, completion: nil)
    }

    
    //tableViewのインセットを調整
    override func keyboardWillShow(_ notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        print(keyboardSize)
        
        settingTableView.contentInset.bottom = keyboardSize - tabBarController!.tabBar.bounds.height
    }
    override func keyboardWillHide(_ notification: NSNotification) {
        settingTableView.contentInset = .zero
    }
    
}

extension AddPaymentVC: UIPickerViewDelegate, UIPickerViewDataSource {

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if list[pickerView.tag].count == 0 { return 1 }
        return list[pickerView.tag].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if tFManager.tFSets[pickerView.tag].choices!.count == 0 {
            return "項目がありません!"
        }
        return tFManager.tFSets[pickerView.tag].choices![row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if tFManager.tFSets[pickerView.tag].choices!.count == 0 { return }
        tFManager.tFSets[pickerView.tag].tF.text = tFManager.tFSets[pickerView.tag].choices![row]
    }
    
}

extension AddPaymentVC: CoachMarksControllerDataSource {
    
    override func viewDidAppear(_ animated: Bool) {
        if [1,2].contains(self.ud.integer(forKey: .startStep)) {
            coachController.dataSource = self
            self.coachController.start(in: .viewController(self))
            changeMainCategoryTab.isHidden = true
        } else {
            changeMainCategoryTab.isHidden = false
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.coachController.stop(immediately: true)
        print("isNavigationMove:",isNavigationMove!)
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        
        var label = UILabel()
        
        switch self.ud.integer(forKey: .startStep) {
        case 1:
            label = startStepLabel[1]
        case 2:
            label = startStepLabel[0]
        default: break
        }
        
        return self.coachController.helper.makeCoachMark(for: label, pointOfInterest: nil, cutoutPathMaker: nil)
        // for: にUIViewを指定すれば、マークがそのViewに対応します
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        let texts = [
            "ここをタップして\n登録済みの\n口座を登録してください",
            "ここをタップして\n新しい項目を登録しましょう\n例えば、食費、交通費、\n交際費などなど！"
        ]
        
        coachViews.bodyView.hintLabel.text = texts[ud.integer(forKey: .startStep)! - 1]
        coachViews.bodyView.nextLabel.text = "了解" // 「次へ」などの文章

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
}

extension AddPaymentVC: UIScrollViewDelegate {
    
    // レシート表示モードに
    private func turnOnPictureMode() {
        pictureModeView.isHidden = !pictureModeView.isHidden
        
        setImage()
        // 初期表示のためcontentInsetを更新
        updateScrollInset()

    }
    
    @IBAction func selectPicture() {
        
    }
    
    @IBAction func toUpp() { setImage(isUp: true) }
    
    @IBAction func toDown() { setImage(isUp: false) }
        
    private func setImage( isUp: Bool? = nil ){
        
        if isUp != nil { pictureNumber += ( isUp! ? 1 : -1 ) }
        //extensionで作った自作out of range回避方法
        guard let image = receipts[safe: pictureNumber] else {
            // 元に、戻す。
            if let status = isUp { pictureNumber -= ( status ? 1 : -1 ) }
            else { imageView.image = nil }; return
        }
        imageView.image = image.photo
        if let size = imageView.image?.size {
            // imageViewのサイズがscrollView内に収まるように調整
            let wRate = scrollView.frame.width / size.width
            let rate = wRate
            imageView.frame.size = CGSize(width: size.width * rate, height: size.height * rate)

            // contentSizeを画像サイズに設定
            scrollView.contentSize = imageView.frame.size
        }
        return
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        // ズームのために要指定
        return imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        return
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        return
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
            // ズームのタイミングでcontentInsetを更新
            updateScrollInset()
    }
    
    private func updateScrollInset() {
            // imageViewの大きさからcontentInsetを再計算
            // なお、0を下回らないようにする
        scrollView.contentInset = UIEdgeInsets(
            top: max((scrollView.frame.height - imageView.frame.height)/2, 0),
            left: max((scrollView.frame.width - imageView.frame.width)/2, 0),
            bottom: 0,
            right: 0
        )
    }
    
}
