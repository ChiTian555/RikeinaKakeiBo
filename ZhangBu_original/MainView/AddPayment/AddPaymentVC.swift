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
import CropViewController


class AddPaymentVC: MainBaceVC, UITableViewDataSource, UITableViewDelegate {
    
    private let ud = UserDefaults.standard
    
    /// is coler for price textField
    let colors: [UIColor] = [.systemRed,.systemGreen,.systemBlue]
    
    /// if edditingmode, use this variable
    /// edited is mark had changed mainCategory
    var current: (payment:Payment,edited:Bool)?
    var isNavigationMove: Bool!
    
    var memo: String?
    var memoLabel: LabelWithPlaceHolder!
    
    var menu = [CategoryList]()
    var menus: [String] { ["金額"] + menu.map({$0.name}) + ["日付","メモ"] }
    
    var tFManager = CustomTextFields(self)
    
    var labelZero = UILabel()
    var labelYen = UILabel()
    
    @IBOutlet var changeMainCategoryTab: UISegmentedControl!
    var mainCategory: Int {
        get{ changeMainCategoryTab.selectedSegmentIndex }
        set(i) { changeMainCategoryTab.selectedSegmentIndex = i }
    }
    @IBOutlet var usePocketMoneyLabel: UILabel!
    
    var menuButton : UIBarButtonItem!
    
    /// if now is startStep use this variable
    var startStepLabel = [UILabel]()
    
    var coachController = CoachMarksController()
    
    //表示させるレシート画像の番号
    var pictureNumber = Int()
    var receipts = [Receipt]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var settingTableView: UITableView!
    var cells = [UITableViewCell]()
    
    // レシート用ImageView
    var imageView: UIImageView!
    @IBOutlet var pictureModeView: UIView!
    
    // お小遣いの使用について
    @IBOutlet var useSavedMoneyCheckLabel: UILabel!
    var isUsePoketMoney: Bool {
        set(use) { useSavedMoneyCheckLabel.text = use ? "貯金利用 ×" : "貯金利用 ○" }
        get { return useSavedMoneyCheckLabel.text == "貯金利用 ×" }
    }
    
    // MARK: First Step Loding View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //写真関連
        imageView = UIImageView()
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        pictureModeView.isHidden = true
        
        //キーボード出現を感知
        self.configureObserver()
        if current != nil { self.setSwipe() }
        
        isNavigationMove = false
        settingTableView.dataSource = self
        settingTableView.delegate = self
        settingTableView.separatorInset = .init(top: 0, left: 120, bottom: 0, right: 0)
        settingTableView.estimatedRowHeight = 40
        settingTableView.rowHeight = UITableView.automaticDimension
        settingTableView.set()
        
        // 貯金を崩すか、崩さないかのボタン
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
        
        // iOS14以降で、対応した、Memo機能の実装。
        if #available(iOS 14.0, *) {
            menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"),
                                         menu: UIMenu())
        } else {
            menuButton = UIBarButtonItem(barButtonSystemItem: .action, target: self,
                                         action: #selector(addUserCategory(_:)))
        }
        
        navigationItem.leftBarButtonItem = menuButton
        
    }
    
    private func setMenu() -> UIMenu {
        let addUserCategory = UIAction(title: "ユーザー項目の追加", image: UIImage(systemName: "plus")) { _ in
            self.editUserCategory(create: true)
        }
        let editUserCategory = UIAction(title: "ユーザー項目の編集",
                                        image: UIImage(systemName: "square.and.pencil")) { _ in
            self.editUserCategory(create: false)
        }
        let deleteUserCategory = UIAction(title: "ユーザー項目の削除", image: UIImage(systemName: "trash")) { _ in
            self.deleteUserCategory()
        }
        let showReceipt = UIAction(title: "レシート表示切替", image: UIImage(systemName: "paperplane")) { _ in
            self.turnOnPictureMode()
        }
        let takePicture = UIAction(title: "レシートの撮影", image: UIImage(systemName: "camera")) { _ in
            self.takePicture()
        }
        
        let menu: UIMenu!
        switch self.menu.count {
        case 2: menu = UIMenu(title: "", children: [addUserCategory, showReceipt,takePicture])
        case 3: menu = UIMenu(title: "", children: [editUserCategory, deleteUserCategory,
                                                    showReceipt, takePicture])
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
        alert.addActions("レシートの表示切替") { _ in self.turnOnPictureMode() }
        alert.addActions("レシートの撮影") { _ in self.takePicture() }
        present(alert.controller, animated: true, completion: nil)
    }
    
    private func editUserCategory(create: Bool) {
        let alert = MyAlert("ユーザー項目の" + (create ? "追加" : "編集"), "分類名を記入してください。")
        alert.addTextField("ここに入力") { (tF) in tF.text = create ? "" : self.menu[2].name }
        alert.addActions("キャンセル", type: .cancel, nil)
        alert.addActions("OK") { (myAlert) in
            guard let userCategoryName = myAlert.tFs.first?.text else { return }
            if ["金額","日付","メモ"].contains(userCategoryName) {
                HUD.flash(.labeledError(title: "Error",subtitle: "このｷｰﾜｰﾄﾞは、利用できません")); return
            }
            if userCategoryName.count >= 7 {
                HUD.flash(.labeledError(title: "Error",subtitle: "6字以内で入力して下さい。")); return
            }
            if create {
                let newCategoryList = CategoryList.make()
                newCategoryList.name = userCategoryName
                newCategoryList.mainCategory = self.mainCategory
                newCategoryList.selectAccount = false
                newCategoryList.save()
                self.menu.append(newCategoryList)
            } else { self.menu.last?.upDateList(changeName: userCategoryName) }
            self.reloadData(allReset: false)
            // メニューは、中身を変えてあげる必要がある。
            if #available(iOS 14.0, *) { self.menuButton.menu = self.setMenu() }
        }
        present(alert.controller, animated: true, completion: nil)
    }
        
    func deleteUserCategory() {
        menu.last?.delete()
        menu.remove(at: menu.count - 1)
        reloadData(allReset: false)
        if #available(iOS 14.0, *) { menuButton.menu = setMenu() }
    }
    
    @objc func changeUseSaveMoney(_ sender: UITapGestureRecognizer) {
        isUsePoketMoney = !isUsePoketMoney
    }
    
    // MARK: Move Display Setting
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        receipts = Receipt.readAll()
        
        if let c = current, !c.edited { mainCategory = c.payment.mainCategoryNumber }
        useSavedMoneyCheckLabel.isHidden = (mainCategory != 0)
        menu = CategoryList.readAllCategory(mainCategory)
        if #available(iOS 14.0, *) { menuButton.menu = setMenu() }
        
        navigationItem.title = ( current == nil ) ? "料金入力欄" : "修正欄"
        
        // リロード
        if isNavigationMove {
            isNavigationMove = false
            if memo != nil {
                memoLabel.text = self.memo
                let memoIndex = IndexPath(row: menus.count - 1, section:0 )
                settingTableView.reloadRows(at: [memoIndex], with: .none)
            } else {
                // ここで、アイテムリストの更新が必要。
                tFManager.tFSets.forEach { (set) in
                    if set.type == .textPicker {
                        set.choices = CategoryList.readCategory(mainCategory, set.name)!.list
                    }
                }
            }
        } else {
            // 初期ロード
            reloadData(allReset: true)
            if let c = current?.payment {
                isUsePoketMoney = c.isUsePoketMoney
                tFManager.tFSets.forEach {
                    if $0.name == "金額" && c.mainCategoryNumber == 0 {
                        var value = c.getValue(title: $0.name)
                        if value.first == "-" {
                            value.removeFirst()
                            labelZero.text = "-"
                        } else {
                            labelZero.text = ""
                            labelYen.textColor = .label
                            tFManager.tFSets[0].tF.textColor = .label
                        }; $0.tF.text = value
                    } else { $0.tF.text = c.getValue(title: $0.name) }
                }
                memoLabel.text = c.memo
            }
        }
        memo = nil
    }
    
    @IBAction func selectMenu(_ sender: UISegmentedControl) {
        if let c = current, !c.edited {
            let alert = MyAlert("注意", "情報が一部、削除されます。\nほんとに、変更しますか")
            alert.addActions("キャンセル", type: .cancel) { _ in
                sender.selectedSegmentIndex = c.payment.mainCategoryNumber
            }
            alert.addActions("はい") { _ in
                self.current?.edited = true
                self.selectMenu(sender)
            }
            present(alert.controller, animated: true, completion: nil); return
        }
        useSavedMoneyCheckLabel.text = "貯金利用 ×"
        menu = CategoryList.readAllCategory(sender.selectedSegmentIndex)
        if #available(iOS 14.0, *) { menuButton.menu = setMenu() }
        useSavedMoneyCheckLabel.isHidden = (sender.selectedSegmentIndex != 0)
        reloadData(allReset: false)
    }

    /// If allReset true delete all text in textField, if not keep Money, Date, and Memo value
    func reloadData(allReset: Bool) {
        /*
         呼ぶタイミング：
            • viewWillApear when is not NavigationMove : allReset = true
            • delete payment function                  : allReset = true
            • UserCategory added or deleted            : allReset = false
            • MainCategory is changed                  : allReset = false
         */
        if allReset { isUsePoketMoney = true }
        makeTextFieldSet(allReset)
        self.settingTableView.reloadData()
    }
    
    // MARK: About TableView Data

    func makeTextFieldSet(_ allReset: Bool) {
        
        // 過去の情報を残し、一旦新規で作成。
        let textFieldSet = CustomTextFields(self)
        cells = []
        for menu in menus {
            var cell: UITableViewCell!
                
            let mode = mainCategory
            if menu == "金額" {
                let colors: [UIColor] = [.systemRed,.systemGreen,.systemBlue]
                let currrentFont = ( ud.bool(forKey: .isCordMode) ?
                                        UIFont(name: "cordFont", size: 35) :
                                        UIFont.systemFont(ofSize: 35, weight: .light) )
                
                cell = settingTableView.dequeueReusableCell(withIdentifier: "Cell1")!.create()
                let newTF = cell.contentView.viewWithTag(3) as! UITextField
                textFieldSet.addTextField(tF: newTF, name: menu, type: .inputNum) { (me) in
                    me.tF.text = allReset ? "" : self.tFManager.getCurrentText(name: menu)
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
                // これは、カーソルの色かな。
                textField.tintColor = .clear
                textField.placeholder = "タップして選択"
                if menu == "日付" {
                    textFieldSet.addTextField(tF: textField, name: menu, type: .datePicker)
                        { (me) in
                        me.tF.text = allReset ? "" : self.tFManager.getCurrentText(name: menu)
                    }
                } else {
                    textFieldSet.addTextField(tF: textField, name: menu, type: .textPicker) { (me) in
                        me.tF.text = (allReset || self.mainCategory != self.tFManager.tag)
                            ? "" : self.tFManager.getCurrentText(name: menu)
                        me.choices = CategoryList.readCategory(mode, menu)!.list + []
                    }
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
                    tapGesture.numberOfTouchesRequired = 1
                    label.addGestureRecognizer(tapGesture)
                    //最初のチュートリアル用
                    if ["1","2"].contains(ud.stringArray(forKey: .startSteps)!.first) {
                        if ["決済方法","項目"].contains(menu) { startStepLabel.append(label) }
                    }
                }
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            } else {
                cell = settingTableView.dequeueReusableCell(withIdentifier: "Cell3")!.create()
                let newLabel = cell.contentView.viewWithTag(2) as! LabelWithPlaceHolder
                newLabel.placeHolder = "タップして入力"
                newLabel.text = (allReset ? "" : memoLabel.text)
                memoLabel = newLabel
            }
            cells.append(cell.set())
        }
        textFieldSet.setToolBars()
        textFieldSet.tag = mainCategory
        tFManager = textFieldSet
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
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
    
    // テーブルビューがタップされたときの動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 価格、メニュー、日付、メモ
        print(indexPath.row, tFManager.tFSets.count)
        if indexPath.row == tFManager.tFSets.count {
            self.isNavigationMove = true
            self.performSegue(withIdentifier: "toEdit", sender: nil)
        } else if indexPath.row == 0 && mainCategory == 0 {
            if labelZero.text == ""{
                labelZero.text = "-"
                labelYen.textColor = .red
                tFManager.tFSets[0].tF.textColor = .red
            } else {
                labelZero.text = ""
                labelYen.textColor = UIColor.label
                tFManager.tFSets[0].tF.textColor = .label
            }
        }
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditMemoViewController {
            vc.memo = memoLabel.text ?? ""
            vc.width = memoLabel.frame.width
        } else if let vc = segue.destination as? AddCategoryViewController {
            vc.mainCategoryNumber = mainCategory
            vc.tappedCategoriesName = (sender as! String)
        }
    }
    
    // MARK: Save Data
    
    @IBAction func add() {
        
        // .isEnpty != false : enpty
        if tFManager.tFSets.contains(where: { $0.tF.text?.isEmpty != false }) {
            HUD.flash(.labeledError(title: "Error", subtitle: "空欄があります！")); return
        }
        
        let edit = current != nil
        
        let alert = MyAlert("保存", "ほんとに\(edit ? "上書き":"")保存しても?\nよろしいですか?")
        alert.addActions("戻る", type: .cancel, nil)
        alert.addActions("はい") { _ in
            let payment = edit ? Payment(value: self.current!.payment): Payment.make()
            if self.mainCategory == 0 { payment.isUsePoketMoney = self.isUsePoketMoney }
            payment.mainCategoryNumber = self.mainCategory
            payment.memo = self.memoLabel.text ?? ""
            for tFSet in self.tFManager.tFSets {
                payment.setValue(title: tFSet.name, value: tFSet.tF.text!)
                if tFSet.name == "金額" && self.mainCategory == 0 {
                    payment.price *= self.labelZero.text == "-" ? -1 : 1
                }
            }
            guard let account = Account.get(payment.paymentMethod) else {
                HUD.flash(.label("一致する口座がありません。")); return
            }
            
            // ↓最終保存のためのクロージャーを定義。
            let finalSave: () -> Void = {
                if edit { self.current!.payment.delete() }
                payment.save()
                if let picture = self.receipts[safe: self.pictureNumber] {
                    picture.delete()
                    self.receipts.remove(at: self.pictureNumber)
                    if self.receipts.count - 1 == self.pictureNumber && self.receipts.count != 1 {
                        self.pictureNumber -= 1
                    }
                }
                if edit {
                    HUD.flash(.success, delay: 1.0) { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    HUD.flash(.success, delay: 1.0) { _ in
                        self.tFManager.tFSets.forEach { $0.tF.text = "" }
                        self.memoLabel.text = ""
                    }
                }
            }
            //　↑ここまで
            
            if !edit && payment.date < account.createDate {
                let checkAlert = MyAlert("口座追加以前の出費",
                                         "口座の残高からこの出費分を\n差し引きますか？")
                checkAlert.addActions("はい") { _ in finalSave() }
                checkAlert.addActions("いいえ",type: .destructive) { _ in
                    payment.avoidSpending = true; finalSave()
                }
                self.present(checkAlert.controller, animated: true, completion: nil); return
            }
            finalSave()
        }
        self.present(alert.controller, animated: true, completion: nil)
    }
    
    @IBAction func trush(_ sender: UIBarButtonItem) {
        if let c = current?.payment {
            // ほんとに削除しますか？
            let alert = MyAlert("確認", "ほんとに削除しますか？")
            alert.addActions("キャンセル", type: .cancel, nil)
            alert.addActions("削除", type: .destructive) { _ in
                c.delete()
                HUD.flash(.labeledSuccess(title: "成功", subtitle: "一覧画面に\n戻ります"))
                { _ in
                    self.navigationController?.popViewController(animated: true)
                }
            }
            present(alert.controller, animated: true, completion: nil)
        } else {
            // 入力をリセットしますか？
            let alert = MyAlert("確認", "入力をリセットしますか？")
            alert.addActions("キャンセル", type: .cancel, nil)
            alert.addActions("リセット", type: .destructive) { _ in
                self.reloadData(allReset: true)
            }
            present(alert.controller, animated: true, completion: nil)
        }
    }
    

    
    //tableViewのインセットを調整
    override func keyboardWillShow(_ notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        print(keyboardSize)
        
        settingTableView.contentInset.bottom = keyboardSize -
            ( tabBarController?.tabBar.bounds.height ?? 0 )
    }
    override func keyboardWillHide(_ notification: NSNotification) {
        settingTableView.contentInset = .zero
    }
    
}

// MARK: About PickerView

extension AddPaymentVC: UIPickerViewDelegate, UIPickerViewDataSource {

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        let count = tFManager.tFSets[pickerView.tag].choices!.count
        return ( count == 0 ) ? 1 : count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let choices = tFManager.tFSets[pickerView.tag].choices!
        return ( choices.count == 0 ) ? "項目がありません!" : choices[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if tFManager.tFSets[pickerView.tag].choices!.count == 0 { return }
        tFManager.tFSets[pickerView.tag].tF.text = tFManager.tFSets[pickerView.tag].choices![row]
    }
    
}

//MARK: About Fiest Step Recture

extension AddPaymentVC: CoachMarksControllerDataSource {
    
    override func viewDidAppear(_ animated: Bool) {
        if ["1","2"].contains(self.ud.stringArray(forKey: .startSteps)!.first) {
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
    
    override func viewDidDisappear(_ animated: Bool) {
        if !isNavigationMove && current != nil {
            current = nil
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        
        var label = UILabel()
        
        switch self.ud.stringArray(forKey: .startSteps)!.first {
        case "1":
            label = startStepLabel[1]
        case "2":
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
        let nowStep = Int( ud.stringArray(forKey: .startSteps)!.first! )!
        coachViews.bodyView.hintLabel.text = texts[nowStep - 1]
        coachViews.bodyView.nextLabel.text = "了解" // 「次へ」などの文章

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
}

// MARK: ImagePicker

extension AddPaymentVC: UIImagePickerControllerDelegate,
                        UINavigationControllerDelegate,
                        CropViewControllerDelegate {
    private func takePicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            picker.sourceType = .photoLibrary
        } else {
            HUD.flash(.labeledError(title: "エラー", subtitle: "カメラ,アルバム機能が使えません"), delay: 2)
            return
        }
        
        picker.delegate = self
        // UIImagePickerController カメラを起動する
        present(picker, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
        
    func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        let receipt = Receipt.make()
        receipt.photo = image
        receipt.save()
        receipts.append(receipt)
        if !pictureModeView.isHidden { setImage() }
        cropViewController.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        var image = info[.originalImage] as! UIImage
        guard let pickerImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        
        let cropController = CropViewController(croppingStyle: .default, image: pickerImage)
        cropController.delegate = self
        //サイズ指定！
        cropController.customAspectRatio = view.bounds.size
        
        //今回は使わないボタン等を非表示にする。
        cropController.aspectRatioPickerButtonHidden = true
        cropController.resetAspectRatioEnabled = false
        cropController.rotateButtonsHidden = true
        
        cropController.cropView.cropViewPadding = 25
        
        //cropBoxのサイズを固定する。
        cropController.cropView.cropBoxResizeEnabled = false
        //pickerを閉じたら、cropControllerを表示する。
        picker.dismiss(animated: true) {
            self.present(cropController, animated: true, completion: nil)
        }
    }
}

// MARK: ScrollView

extension AddPaymentVC: UIScrollViewDelegate {
    
    // レシート表示モードに
    private func turnOnPictureMode() {
        pictureModeView.isHidden = !pictureModeView.isHidden
        
        setImage()
        // 初期表示のためcontentInsetを更新
        updateScrollInset()
    }

    @IBAction func toUpp() { setImage(isUp: true) }
    
    @IBAction func toDown() { setImage(isUp: false) }
    
    @IBAction func deletePicture() {
        if receipts[safe: pictureNumber] == nil { return }
        let alert = MyAlert("確認", "写真を削除しますか？")
        alert.addActions("キャンセル", type: .cancel, nil)
        alert.addActions("削除", type: .destructive) { [self] _ in
            receipts[pictureNumber].delete()
            receipts.remove(at: pictureNumber)
            HUD.flash(.labeledSuccess(title: "成功", subtitle: nil)) { _ in setImage() }
        }
        present(alert.controller, animated: true, completion: nil)
    }
    
//    @objc func deletePicture() {
//        let alert = MyAlert("確認", "写真を削除しますか？")
//        alert.addActions("キャンセル", type: .cancel, nil)
//        alert.addActions("削除", type: .destructive) { [self] _ in
//            receipts[pictureNumber].delete()
//            HUD.flash(.labeledSuccess(title: "成功", subtitle: nil)) { _ in setImage() }
//        }
//    }
        
    private func setImage( isUp: Bool? = nil ) {
        
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
