//
//  pickerTextField.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/14.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import PKHUD

final class PickerTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tintColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        tintColor = .clear
    }
    
    // 入力カーソル非表示
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
    
    // 範囲選択カーソル非表示
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }

    // ペーストの禁止
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) { return false }
        return true
    }
    
}

class NumberTextField: UITextField, UITextFieldDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !string.isNumber && !string.isEmpty {
            HUD.flash(.label("無効な入力"), delay: 0.8)
            return false
        }
        return true
    }

}

extension String {
    var isNumber: Bool {
        return NSPredicate(format: "SELF MATCHES %@", "^[0-9]+$").evaluate(with: self)
    }
}
