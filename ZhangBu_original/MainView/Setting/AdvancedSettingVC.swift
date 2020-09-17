//
//  ViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/16.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit

class AdvancedSettingVC: MainBaceVC {

    //cellTipe: 1 -> Cell, 2 -> ButtonCell, 3 -> SliderCell
    private var settingTitle = [(name:String, cellTipe: Int, item: Any?)]()
    
    func setTitle(title: String) {
        
        switch title {
        case "背景画像とテーマ色":
            
            settingTitle = [
                ("テーマ色の変更",1,nil),
                ("背景画像を選択",1,nil),
                ("背景の透明度",3,nil)
            ]
            
        default:
            self.navigationController?.popViewController(animated: true)
            break
        }
        
    }
    
    @IBOutlet var settingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    

}

extension AdvancedSettingVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell.create()
        
        switch settingTitle[indexPath.row].cellTipe {
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "CellNoneItem")!
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "CellSwitch")!
            let onOffSwitch = cell.contentView.viewWithTag(1)
            settingTitle[indexPath.row].item = onOffSwitch
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "CellSlider")!
            let titleLabel = cell.contentView.viewWithTag(1)
            let sliderLabel = cell.contentView.viewWithTag(2)
            let slider = cell.contentView.viewWithTag(3)
            settingTitle[indexPath.row].item = slider
            slider?.target(forAction: #selector(sliderDidChangValue(_:)), withSender: settingTitle[indexPath.row])
            
        default:
            <#code#>
        }
        
        return cell.set()
    }
    
    @objc func sliderDidChangValue(sender: UISlider) {
        
    }
    
}
