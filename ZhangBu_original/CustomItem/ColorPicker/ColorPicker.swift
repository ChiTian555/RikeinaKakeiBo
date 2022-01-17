//
//  ColorPicer.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2022/01/16.
//  Copyright © 2022 net.Chee-Saga. All rights reserved.
//

import UIKit

protocol ColorPickerDelegate {
    /// 値が変化したときに呼び出す関数 (category: R,G,B,αの順)
    func didChangedValue(sender: ColorPicker)
}

class ColorPicker: UIView {
    
    var delegate: ColorPickerDelegate?

    @IBOutlet var colorBars: [UISlider]!
    @IBOutlet var valueLabel: [UILabel]!
    @IBOutlet weak var colorView: UIView!
    
    var color: UIColor {
        get {
            let c = colorBars.map { return CGFloat($0.value) }
            return UIColor(red: c[0], green: c[1], blue: c[2], alpha: c[3])
        }
        set(color) {
            let c = color.cgColor.components! + [color.cgColor.alpha]
            let cFloat = c.map { return Float($0) }
            setValues(components: cFloat)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    func loadNib() {
        if let view = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
    }
    
    func setValues(R:Float,G:Float,B:Float,alpha:Float) { setValues(components: [R,G,B,alpha]) }
    
    func setValues(components:[Float]) {
        if components.count != 4 { return }
        for (i, v) in components.enumerated() {
            valueLabel[i].text = i != 3 ?
            String(format: "%.0f", 255.0 * v):
            String(format: "%.2f", 1.0 * v)
            colorBars[i].setValue(v, animated: false)
        }
        colorView.backgroundColor = color
    }
    
    @IBAction func valueCanged(_ sender: UISlider) {
        valueLabel[sender.tag].text = sender.tag != 3 ?
        String(format: "%.0f", 255.0 * sender.value):
        String(format: "%.2f", 1.0 * sender.value)
        colorView.backgroundColor = color
        delegate?.didChangedValue(sender: self)
    }
    
}
