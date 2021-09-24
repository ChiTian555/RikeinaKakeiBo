//
//  ConectPaymentVC.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/10/05.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit

class ConectPaymentVC: UIViewController {

    var parentVC: UIViewController!
    
    @IBOutlet var selectPaymentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectPaymentTableView.sectionHeaderHeight = 10
        
        selectPaymentTableView.set()

        // Do any additional setup after loading the view.
    }

}

extension ConectPaymentVC: UITableViewDataSource, UITableViewDelegate {
    
    var payments: [Payment] {
        
        return Payment.readSortedByAddDate(0)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 5
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "新着5件の支払い"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let categoryLabel = cell.contentView.viewWithTag(1) as! UILabel
        let dateLabel = cell.contentView.viewWithTag(2) as! UILabel
        let priceLabel = cell.contentView.viewWithTag(3) as! UILabel
        let memoLabel = cell.contentView.viewWithTag(4) as! UILabel
        if UserDefaults.standard.bool(forKey: .isCordMode) {
            priceLabel.font = UIFont(name: "cordFont", size: 20)
        } else {
            priceLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        }
        let price = payments[indexPath.row].price

        if price < 0 {
            priceLabel.text = "-¥\(price * -1)"
            priceLabel.textColor = UIColor.red
        } else {
            priceLabel.text = "¥\(price)"
            priceLabel.textColor = UIColor.label
        }
        let nowPayment = payments[indexPath.row]
        let isUseSavedMoney = payments[indexPath.row].isUsePoketMoney == false
                            && nowPayment.mainCategoryNumber == 0
        let markUseSavedMoney = isUseSavedMoney ? " (貯)" : ""
        categoryLabel.text = nowPayment.category + markUseSavedMoney
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "MM/dd"
        dateLabel.text = dateFormatter.string(from: payments[indexPath.row].date)
        memoLabel.text = payments[indexPath.row].memo
    
        return cell.set()
    }
    
    
}
