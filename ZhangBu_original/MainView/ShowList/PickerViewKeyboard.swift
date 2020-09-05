//
//  PickerViewKeyboard.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/18.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit

protocol PickerViewKeyboardDelegate {
    func titlesOfPickerViewKeyboard(sender: PickerViewKeyboard) -> Array<Array<String>>
    func initSelectedRow(sender: PickerViewKeyboard) -> Int
    func didCancel(sender: PickerViewKeyboard)
    func didDone(sender: PickerViewKeyboard, selectedData: Array<String>)
}

class PickerViewKeyboard: UIButton {
    
    var delegate: PickerViewKeyboardDelegate!
    var pickerView: UIPickerView!

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // ピッカーに表示させるデータ
    var data: Array<Array<String>> {
        return delegate.titlesOfPickerViewKeyboard(sender: self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
    }

    @objc func didTouchUpInside(_ sender: UIButton) {
        becomeFirstResponder()
    }

    override var inputView: UIView? {
        pickerView = UIPickerView()
        pickerView.delegate = self
        let row = delegate.initSelectedRow(sender: self)
        pickerView.selectRow(row, inComponent: 0, animated: true)

        return pickerView
    }

    override var inputAccessoryView: UIView? {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 44)

        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        space.width = 12
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PickerViewKeyboard.cancelPicker))
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PickerViewKeyboard.donePicker))

        let toolbarItems = [space, cancelItem, flexSpaceItem, doneButtonItem, space]

        toolbar.setItems(toolbarItems, animated: true)

        return toolbar
    }

    @objc func cancelPicker() {
        delegate.didCancel(sender: self)
    }

    @objc func donePicker() {
        
        var selectedValue: Array<String> = []
        for i in 0 ..< data.count{
            selectedValue.append(data[i][pickerView.selectedRow(inComponent: i)])
        }
        delegate.didDone(sender: self, selectedData: selectedValue)
    }

}

extension PickerViewKeyboard: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data[component].count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return data.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[component][row]
    }
}
