//
//  CustomTextField.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2021/09/04.
//  Copyright © 2021 net.Chee-Saga. All rights reserved.
//

import UIKit
import SwiftDate

enum InputType {
    case textPicker
    case datePicker
    case inputNum
}

class TextFieldSet {
    var type:InputType
    var name:String
    var tF:UITextField
    var choices:[String]?
    init(type: InputType, name:String = "", tF: UITextField, choices: [String]? = nil) {
        self.type = type
        self.name = name
        self.tF = tF
        self.choices = choices
    }
}

class CustomTextFields {
    
    typealias editObjectFunc = (TextFieldSet) -> Void
    private var ud = UserDefaults.standard
    var pickerDelegate: UIPickerViewDelegate?
    var pickerDataSource: UIPickerViewDataSource?
    var tFSets = [TextFieldSet]()
    var tag: Int = 0
    
    var firstResponderIndex: Int? {
        return tFSets.firstIndex { $0.tF.isFirstResponder }
    }

    /// delegate dataSource も、あれば、同時に、セットします。
    init(_ VC: Any) {
        if let delegate = VC as? UIPickerViewDelegate { pickerDelegate = delegate }
        if let dataSource = VC as? UIPickerViewDataSource { pickerDataSource = dataSource }
    }
    
    // MARK: Set Objects
    
    func setToolBars() {
        for i in 0 ..< tFSets.count {
            let toolbar = MyToolBar(self, type: .doneAndNext(done: #selector(done),
                                                             next: #selector(next)))
            let toolbarLast = MyToolBar(self,type: .done(done: #selector(done)))
            tFSets[i].tF.inputAccessoryView = i != tFSets.count - 1 ? toolbar : toolbarLast
        }
    }
    
    /**
     Add New TextFieldSet.
     
     If you set type to datePicer, First Selection is textField Value which fomat is "yyyy-MM-dd"
     
     - Parameters:
        - type: textField inputType
        - tF: TextField you will add
        - name: title text of your textField
        - set: you can edit your TextFieldSet which now added
     */
    func addTextField( tF: UITextField, name: String, type:InputType, set: editObjectFunc? = nil) {
        let new = TextFieldSet(type: type, name: name ,tF: tF)
        if let set = set { set(new) }
        switch type {
        case .inputNum:
            new.tF.keyboardType = .numberPad
            new.tF.keyboardAppearance = .default
        case .datePicker:
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            if #available(iOS 13.4, *) { datePicker.preferredDatePickerStyle = .wheels }
            if new.tF.text == "" { datePicker.date = Date() }
            else {
                datePicker.date = DateInRegion(new.tF.text!, format: "yyyy-MM-dd")!.date
            }
            datePicker.maximumDate = Date()
            new.tF.inputView = datePicker
        case .textPicker:
            let pickerView = UIPickerView()
            pickerView.dataSource = pickerDataSource
            pickerView.delegate = pickerDelegate
            pickerView.tag = tFSets.count
            new.tF.inputView = pickerView
        }
        tFSets.append(new)
    }
    
    @objc func done() {
        guard let i = setText() else { return }
        tFSets[i].tF.resignFirstResponder()
    }
    @objc func next() {
        guard let i = setText() else { return }
        tFSets[i+1].tF.becomeFirstResponder()
    }
    
    // MARK: Set or Get value func
    
    private func setText() -> Int? {
        guard let i = firstResponderIndex else { return nil }
        if (tFSets[i].type == .textPicker && tFSets[i].tF.text == "") {
            if tFSets[i].choices?.isEmpty != false { return i }
            let pickerView = tFSets[i].tF.inputView as! UIPickerView
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            tFSets[i].tF.text = tFSets[i].choices?[selectedRow]
        } else if tFSets[i].type == .datePicker {
            let picker = tFSets[i].tF.inputView as! UIDatePicker
            tFSets[i].tF.text = picker.date.toFormat("yyyy-MM-dd")
        }; return i
    }
    
    /// TextFieldの名前を指定して、TextFieldの値を取得します。
    func getCurrentText(name: String?) -> String {
        guard let name = name else { return "" }
        let currentTFSet = tFSets.first { $0.name == name }
        return currentTFSet?.tF.text ?? ""
    }
    
}
