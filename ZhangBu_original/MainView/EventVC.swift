//
//  EventVC.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2021/10/05.
//  Copyright © 2021 net.Chee-Saga. All rights reserved.
//

import UIKit
import FSCalendar

class EventVC: UIViewController {
    
    @IBOutlet var calender: FSCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func addEvent(_ sender: UIButton) {
        let eventEditor = MyAlert("新規イベント追加", "イベント名を\n入力してください".l)
        eventEditor.addTextField("イベント名".l)
        eventEditor.addActions("イベント名".l, type: .cancel, nil)
        eventEditor.addActions("追加".l) { alert in
            //
        }
    }
}
