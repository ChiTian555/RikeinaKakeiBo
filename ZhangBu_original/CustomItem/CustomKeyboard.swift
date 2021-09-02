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
   
    var pickerView: UIPickerView?

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
            if newKeyboard is UIPickerView {
                pickerView = newKeyboard as? UIPickerView
            }
            keyboard = newKeyboard
        }
    }

    override var inputAccessoryView: UIView? {
        let toolbar = CustomToolBar()

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
        delegate.didDone(sender: self)
    }

}
