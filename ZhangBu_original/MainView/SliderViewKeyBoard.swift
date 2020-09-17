////
////  SliderViewKeyBoard.swift
////  ZhangBu_original
////
////  Created by Kiichi Ikeda on 2020/09/14.
////  Copyright © 2020 net.Chee-Saga. All rights reserved.
////
//
//import UIKit
//
//protocol SliderViewKeyboardDelegate {
//    func titlesOfPickerViewKeyboard(sender: PickerViewKeyboard) -> Array<Array<String>>
//    func initSelectedRowValues(sender: PickerViewKeyboard) -> Array<String>?
//    func didChangeValue(sender: PickerViewKeyboard, component: Int, rowValue: String)
//    func didCancel(sender: PickerViewKeyboard)
//    func didDone(sender: PickerViewKeyboard, selectedData: Array<String>)
//}
//
//
//
//class SliderViewKeyboard: UIControl {
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchDown)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    var delegate: PickerViewKeyboardDelegate!
//    var pickerView: UIPickerView!
//
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
//
//    // ピッカーに表示させるデータ
//    var data: Array<Array<String>> {
//        return self.delegate.titlesOfPickerViewKeyboard(sender: self)
//    }
//
//    @objc func didTouchUpInside(_ sender: PickerViewKeyboard) {
//        self.becomeFirstResponder()
//    }
//
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
//
//    override var inputAccessoryView: UIView? {
//        let toolbar = UIToolbar()
//        toolbar.isTranslucent = true
//        toolbar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 35)
//
//        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
//        space.width = 12
//        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPicker))
//        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
//        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
//        cancelItem.tintColor = .systemOrange
//        doneButtonItem.tintColor = .systemOrange
//
//        let toolbarItems = [space, cancelItem, flexSpaceItem, doneButtonItem, space]
//
//        toolbar.setItems(toolbarItems, animated: true)
//
//        return toolbar
//    }
//
//    @objc func cancelPicker() {
//        delegate.didCancel(sender: self)
//    }
//
//    @objc func donePicker() {
//
//        var selectedValues = [String]()
//        for i in 0 ..< data.count {
//            selectedValues.append(data[i][pickerView.selectedRow(inComponent: i)])
//        }
//        delegate.didDone(sender: self, selectedData: selectedValues)
//    }
//
//}
//
//extension SliderViewKeyboard: UIPickerViewDelegate, UIPickerViewDataSource {
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
//
