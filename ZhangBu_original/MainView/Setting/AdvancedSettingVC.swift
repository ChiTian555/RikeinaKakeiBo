//
//  ViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/16.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import PKHUD
import CropViewController

class AdvancedSettingVC: MainBaceVC {
    
    var cells = [UITableViewCell]()
    let ud = UserDefaults.standard
    //cellTipe: 1 -> normalCell, 2 -> ButtonCell, 3 -> SliderCell, 4 -> selectColor
    private var settingTitle = [(name:String, cellTipe: Int)]()
    
    var titleText: String!
    var alphaLabel: UILabel!
    
    @IBOutlet var settingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //スワイプで画面を戻る
        self.setSwipe()
        
        self.navigationItem.title = titleText
        
        switch titleText {
        case "背景画像とテーマ色":
            
            settingTitle = [
                ("テーマ色の変更",4),
                ("ボタンの色変更",4),
                ("背景画像を選択",1),
                ("背景画像を削除",1),
                ("背景の透明度",3)
            ]
            
        default:
            self.navigationController?.popViewController(animated: true)
            break
        }
        settingTableView.dataSource = self
        settingTableView.delegate = self
        settingTableView.tableFooterView = UIView()
        settingTableView.estimatedRowHeight = 45
        settingTableView.rowHeight = UITableView.automaticDimension
        settingTableView.set()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCell()
    }
}

extension AdvancedSettingVC: UITableViewDataSource, UITableViewDelegate {
    
    func loadCell() {
        cells = []
        for row in 0 ..< settingTitle.count {
            var cell: UITableViewCell!
            
            switch settingTitle[row].cellTipe {
            case 1:
                cell = settingTableView.dequeueReusableCell(withIdentifier: "CellNoneItem")!.create()
                cell.textLabel?.text = settingTitle[row].name
            case 2:
                cell = settingTableView.dequeueReusableCell(withIdentifier: "CellSwitch")!.create()
                _ = cell.contentView.viewWithTag(1) as! UISwitch
            case 3:
                cell = settingTableView.dequeueReusableCell(withIdentifier: "CellSlider")!.create()
                let titleLabel = cell.contentView.viewWithTag(1) as! UILabel
                alphaLabel = cell.contentView.viewWithTag(2) as? UILabel
                alphaLabel.layer.cornerRadius = alphaLabel.bounds.height / 4
                alphaLabel.layer.borderWidth = 1
                alphaLabel.layer.borderColor = ud.color(forKey: .userColor).cgColor
                alphaLabel.clipsToBounds = true
                alphaLabel.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
                let slider = cell.contentView.viewWithTag(3) as! CustomSlider
                slider.value = Float(ud.integer(forKey: .alpha)
                ) / 100
                alphaLabel.text = String(format: "%.2f", slider.value)
                slider.title = settingTitle[row].name
                slider.label = alphaLabel
                slider.addTarget(self, action: #selector(touchUp(_:)), for: UIControl.Event.touchUpInside)
                slider.addTarget(self, action: #selector(changeValue(_:)), for: UIControl.Event.valueChanged)
                titleLabel.text = settingTitle[row].name
                cell.selectionStyle = .none
            case 4:
                cell = settingTableView.dequeueReusableCell(withIdentifier: "CellSelectColor")!
                cell.textLabel?.text = settingTitle[row].name
                let colorView = cell.contentView.viewWithTag(1)!
                colorView.layer.cornerRadius = colorView.bounds.height / 2
                colorView.clipsToBounds = true
                let pickerView = UIPickerView()
                var index: Int!
                if settingTitle[row].name == "テーマ色の変更" {
                    let color = ud.color(forKey: .userColor)
                    colorView.backgroundColor = color
                    index = colors.firstIndex(where: {$0.isEqualTo(color)})!
                } else if settingTitle[row].name == "ボタンの色変更" {
                    let color = ud.color(forKey: .buttonColor).withAlphaComponent(1)
                    colorView.backgroundColor = color
                    index = colors.firstIndex(where: {$0.isEqualTo(color)})!
                }
                let pickerLabel = CustomKeyboard(frame: cell.bounds)
                pickerLabel.tag = row
                pickerView.delegate = self
                pickerView.dataSource = self
                pickerView.backgroundColor = .clear
                pickerView.tag = row
                pickerView.selectRow(index, inComponent: 0, animated: false)
                pickerLabel.inputView = pickerView
                pickerLabel.delegate = self
                pickerLabel.backgroundColor = .clear
                cell.contentView.addSubview(pickerLabel)
            default:
                break
            }
            cells.append(cell.set())
        }
        settingTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(cells.count)
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
    
    @objc func touchUp(_ sender: CustomSlider) {
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(1 - CGFloat(sender.value))
        self.ud.setInteger(Int(sender.value * 100), forKey: .alpha)
    }
    
    @objc func changeValue(_ sender: CustomSlider) {
        sender.label!.text = String(format: "%.2f", sender.value)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if titleText == "背景画像とテーマ色" {
            
            switch settingTitle[indexPath.row].name {
            case "テーマ色の変更":
                break
            case "背景画像を選択":
                self.pickUpPicture()
            case "背景画像を削除":
                let alert = UIAlertController(title: "確認", message: "ほんとに削除してもよろしいですか？", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "削除", style: .destructive) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    SceneDelegate.shared.rootVC.picture = nil
                    self.ud.setImage(nil, forKey: .backGraundPicture)
                }
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            default:
                break
            }
            
        }
    }
    
}

extension AdvancedSettingVC: UIPickerViewDataSource, UIPickerViewDelegate, CustomKeyboardDelegate {
    
    
    var colors: [UIColor] {
        let colorArray: [UIColor] = [
            
            .purple,
            .magenta,
            .red,
            .orange,
            .yellow,
            .green,
            .cyan,
            .blue,
            .brown,
            .darkGray,
            .lightGray
            
        ]
        return colorArray
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colors.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 24)))
        view.backgroundColor = colors[row]
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let colorView = cells[pickerView.tag].contentView.viewWithTag(1)!
        colorView.backgroundColor = colors[row]
        switch settingTitle[pickerView.tag].name {
        case "テーマ色の変更":
            let colorImage = UIImage.colorImage(color: colors[row].withAlphaComponent(0.7))
            self.tabBarController?.tabBar.backgroundImage = colorImage
            self.navigationController?.navigationBar.setBackgroundImage(colorImage, for: .default)
        case "ボタンの色変更":
            self.navigationController?.navigationBar.tintColor = colors[row]
            self.tabBarController?.tabBar.tintColor = colors[row]
        default: break
        }
        
    }
    
    func startEdit(sender: CustomKeyboard) {
        settingTableView.isUserInteractionEnabled = false
    }
    
    func didCancel(sender: CustomKeyboard) {
        let colorImage = UIImage.colorImage(color: ud.color(forKey: .userColor))
        self.tabBarController?.tabBar.backgroundImage = colorImage
        self.navigationController?.navigationBar.setBackgroundImage(colorImage, for: .default)
        
        sender.resignFirstResponder()
        settingTableView.isUserInteractionEnabled = true
    }
    
    func didDone(sender: CustomKeyboard) {
        switch settingTitle[sender.tag].name {
        case "テーマ色の変更":
            ud.setColor(colors[sender.pickerView!.selectedRow(inComponent: 0)].withAlphaComponent(0.7),
                        forKey: .userColor)
            alphaLabel.layer.borderColor = ud.color(forKey: .userColor).cgColor
        case "ボタンの色変更":
            ud.setColor(colors[sender.pickerView!.selectedRow(inComponent: 0)], forKey: .buttonColor)
        default: break
        }
        sender.resignFirstResponder()
        settingTableView.isUserInteractionEnabled = true
        
    }
    
}


extension AdvancedSettingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate  {

    func pickUpPicture(){
        let picker = UIImagePickerController() //アルバムを開く処理を呼び出す
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
        
    func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        SceneDelegate.shared.rootVC.picture = image
        UserDefaults.standard.setImage(image, forKey: .backGraundPicture)
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
