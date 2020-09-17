//
//  PickerViewKeyboard.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/18.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit

protocol CustomKeyboardDelegate {
//    func titlesOfPickerViewKeyboard(sender: CustomKeyboard) -> Array<Array<String>>
//    func initSelectedRowValues(sender: CustomKeyboard) -> Array<String>?
//    func didChangeValue(sender: CustomKeyboard, component: Int, rowValue: String)
    func startEdit(sender: CustomKeyboard)
    func didCancel(sender: CustomKeyboard)
    func didDone(sender: CustomKeyboard)
}



class CustomKeyboard: UIControl {
    
    private var keyboard: UIView!
    
    var canOpenKeyboard: Bool = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchDown)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.keyboard = UIView()
        self.addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchDown)
    }

    var delegate: CustomKeyboardDelegate!

    override var canBecomeFirstResponder: Bool {
        return true
    }

    @objc func didTouchUpInside(_ sender: CustomKeyboard) {
        self.delegate.startEdit(sender: sender)
        self.becomeFirstResponder()
    }
    
    override var inputView: UIView? {
        get {
            return keyboard
        }
        set(newKeyboard) {
            keyboard = newKeyboard
        }
    }
//    override var inputView: UIView? {
//        pickerView = UIPickerView()
//        pickerView.delegate = self
//        let rowValues = delegate.initSelectedRowValues(sender: self)
//        for i in 0 ..< data.count {
//            guard let rowValues = rowValues else { break }
//            if let selectedRow = data[i].firstIndex(of: rowValues[i]) {
//                pickerView.selectRow(selectedRow, inComponent: i, animated: false)
//            }
//        }
//        return pickerView
//    }

    override var inputAccessoryView: UIView? {
        let toolbar = UIToolbar()
        toolbar.isTranslucent = true
        toolbar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 35)

        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        space.width = 12
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPicker))
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
        cancelItem.tintColor = .systemOrange
        doneButtonItem.tintColor = .systemOrange

        let toolbarItems = [space, cancelItem, flexSpaceItem, doneButtonItem, space]

        toolbar.setItems(toolbarItems, animated: true)

        return toolbar
    }
    
    @objc func cancelPicker() {
        delegate.didCancel(sender: self)
    }

    @objc func donePicker() {
//        var selectedValues = [String]()
//        for i in 0 ..< data.count {
//            selectedValues.append(data[i][pickerView.selectedRow(inComponent: i)])
//        }
        delegate.didDone(sender: self)
    }

}

//extension CustomKeyboard: UIPickerViewDelegate, UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return data.count
//    }
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return data[component].count
//    }
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return data[component][row]
//    }
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//
//        self.delegate.didChangeValue(sender: self, component: component, rowValue: data[component][row])
//    }
//}
