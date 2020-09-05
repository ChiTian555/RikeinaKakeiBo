//
//  pickerTextField.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/14.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit

class pickerTextField: UITextField {

    // 入力カーソル非表示
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
    
    // 範囲選択カーソル非表示
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }

    // コピー・ペースト・選択等のメニュー非表示
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    

}
