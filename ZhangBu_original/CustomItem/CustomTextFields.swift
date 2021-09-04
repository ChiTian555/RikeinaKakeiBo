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
    var inputObject: Any?
    init(type: InputType, name:String = "", tF: UITextField, choices: [String]? = nil) {
        self.type = type
        self.name = name
        self.tF = tF
        self.choices = choices
    }
}

class CustomTextFields {
    
    private var ud = UserDefaults.standard
    var pickerDelegate: UIPickerViewDelegate?
    var pickerDataSource: UIPickerViewDataSource?
    var tFSets = [TextFieldSet]()
    
    var firstResponderIndex: Int? {
        return tFSets.firstIndex { $0.tF.isFirstResponder }
    }
    /**
     delegate dataSource も、あれば、同時に、セットします。
     */
    init(_ VC: Any) {
        if let delegate = VC as? UIPickerViewDelegate { pickerDelegate = delegate }
        if let dataSource = VC as? UIPickerViewDataSource { pickerDataSource = dataSource }
    }
    
    func setToolBars() {

        for i in 0 ..< tFSets.count {
            let toolbar = CustomToolBar()
            let nextItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(next))
//            nextItem.tintColor = ud.color(forKey: .buttonColor)
            let doneItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
//            doneItem.tintColor = ud.color(forKey: .buttonColor)
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            if i != tFSets.count - 1 {
                toolbar.setItems([doneItem, spaceButton, nextItem], animated: true)
            } else {
                toolbar.setItems([spaceButton, doneItem], animated: true)
            }
            tFSets[i].tF.inputAccessoryView = toolbar
        }
    }
    
    func addTextField( tF: UITextField, name: String, type:InputType, set:((TextFieldSet) -> Void)? = nil) {
        let new = TextFieldSet(type: type, name: name ,tF: tF)
        if let set = set { set(new) }
        if type == .inputNum {
            new.tF.keyboardType = .numberPad
            new.tF.keyboardAppearance = .default
        } else if type == .textPicker {
            let pickerView = UIPickerView()
            pickerView.dataSource = pickerDataSource
            pickerView.delegate = pickerDelegate
            pickerView.tag = tFSets.count
            new.tF.inputView = pickerView
            new.inputObject = pickerView
        } else if type == .datePicker {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            if #available(iOS 13.4, *) { datePicker.preferredDatePickerStyle = .wheels }
            if new.tF.text == "" { datePicker.date = Date() }
            else { datePicker.date = DateInRegion(new.tF.text!, format: "yyyy-MM-dd")!.date }
            datePicker.maximumDate = Date()
            new.tF.inputView = datePicker
            new.inputObject = datePicker
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
    private func setText() -> Int? {
        guard let i = firstResponderIndex else { return nil }
        if (tFSets[i].type == .textPicker && tFSets[i].tF.text == "") {
            let pickerView = tFSets[i].inputObject as! UIPickerView
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            tFSets[i].tF.text = tFSets[i].choices?[selectedRow]
        } else if tFSets[i].type == .datePicker {
            let picker = tFSets[i].inputObject as! UIDatePicker
            tFSets[i].tF.text = picker.date.toFormat("yyyy-MM-dd")
        }
        return i
    }
}
