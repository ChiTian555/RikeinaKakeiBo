//
//  CategoryStatisticsViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/03.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import Charts
import SwiftDate

class CategoryStatisticsVC: MainBaceVC {
    
    @IBOutlet var spanTab: UISegmentedControl!
    
    @IBOutlet var barChartView: BarChartView!
    var year: Int!
    
    var tableViewDatas = [(price: Int, month: Int)]()
    @IBOutlet var sumInCategoryTableView: UITableView!
    
    var pickerView: UIPickerView!
    var pickerLabel: UILabel!
    
    @IBOutlet var spanLabel: UILabel!
    
    var category: String?
    var color: UIColor!
    
    var mainCategory: Int!
    
    @IBAction func changedSpan(_ sender: Any) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setChart(year, mainCategory: mainCategory, category: category)
        spanLabel.text = "\(year!)年分 ▼"
        pickerView.selectRow(years.count - 1, inComponent: 0, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        year = DateInRegion().year
        
        self.setSwipe()
        
        sumInCategoryTableView.set()
        
        sumInCategoryTableView.dataSource = self
        sumInCategoryTableView.estimatedRowHeight = 30
        sumInCategoryTableView.rowHeight = UITableView.automaticDimension
        sumInCategoryTableView.allowsSelection = false

        navigationItem.title = "\(category ?? "合計")の月別統計"
        let keyView = CustomKeyboard(frame: spanLabel.layer.bounds)
        pickerView = UIPickerView()
        keyView.inputView = pickerView
        pickerView.dataSource = self
        pickerView.delegate = self
        keyView.delegate = self
        spanLabel.addSubview(keyView)
        spanLabel.isUserInteractionEnabled = true
        pickerLabel = spanLabel
    }

    func setChart(_ year: Int, mainCategory: Int, category: String?) {
        barChartView.chartDescription?.enabled = false
        barChartView.dragEnabled = false
        barChartView.setScaleEnabled(false)
        barChartView.pinchZoomEnabled = false
        barChartView.autoScaleMinMaxEnabled = true
        barChartView.setExtraOffsets(left: 3, top: 20, right: 20, bottom: 5)
        
        let l = barChartView.legend

        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.form = .none
        l.xEntrySpace = 4
        l.drawInside = false
        
        // x-axis limit line
        let llxAxis = barChartView.xAxis
        
        let ud = UserDefaults.standard
        ud.array(forKey: "")
        
        llxAxis.labelCount = 12
        llxAxis.gridLineDashLengths = [10, 10]
        llxAxis.labelPosition = .bottom
        llxAxis.gridLineDashPhase = 0
        llxAxis.drawLimitLinesBehindDataEnabled = true
        llxAxis.decimals = 0
        llxAxis.valueFormatter = lineChartFormatter()
        
        barChartView.xAxis.enabled = true
        
        let leftAxis = barChartView.leftAxis
        leftAxis.removeAllLimitLines()
        
        leftAxis.axisMinimum = 0
        leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.drawLimitLinesBehindDataEnabled = true

        leftAxis.decimals = 0
        if UserDefaults.standard.bool(forKey: .isCordMode) {
            leftAxis.labelFont = UIFont(name: "cordFont", size: 15)!
        } else {
            leftAxis.labelFont = UIFont.systemFont(ofSize: 10, weight: .regular)
        }
        
        barChartView.rightAxis.enabled = false
        
        tableViewDatas = []
        let values = (1...12).map { (i) -> BarChartDataEntry in
            let val: Int = Payment.getMonthPayment(mainCategory,
                                                   year: year,
                                                   month: i,
                                                   category: category)
            .sum(ofProperty: "price") * ( mainCategory == 0  ? -1 : 1 )
            
            if val != 0 {
                tableViewDatas.append((val,i))
            }
            
            return BarChartDataEntry(x: Double(i), y: Double(val))
        }
        sumInCategoryTableView.reloadData()
        
        let set1 = BarChartDataSet(entries: values, label: nil)
        set1.drawIconsEnabled = false
        
        set1.drawValuesEnabled = true
        set1.setColor(color.withAlphaComponent(0.8))
        set1.barBorderWidth = 1
        set1.barBorderColor = .label
        set1.drawValuesEnabled = false
        if UserDefaults.standard.bool(forKey: .isCordMode) {
            set1.valueFont = UIFont(name: "cordFont", size: 17)!
        } else {
            set1.valueFont = UIFont.systemFont(ofSize: 10, weight: .regular)
        }
//        set1.formLineWidth = 0
//        set1.formSize = 15
        
        let data = BarChartData(dataSet: set1)
        
        barChartView.data = data
        barChartView.animate(xAxisDuration: 1.0)
    }
}

extension CategoryStatisticsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count",tableViewDatas.count)
        return tableViewDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let monthLabel = cell.contentView.viewWithTag(1) as! UILabel
        let priceLabel = cell.contentView.viewWithTag(2) as! UILabel
        
        var font = UIFont()
        if UserDefaults.standard.bool(forKey: .isCordMode) {
            font = UIFont(name: "cordFont", size: 25)!
        } else {
            font = UIFont.systemFont(ofSize: 17, weight: .regular)
        }
        monthLabel.text = "\(tableViewDatas[indexPath.row].month)月"
        priceLabel.text = "¥ \(tableViewDatas[indexPath.row].price)"
        priceLabel.font = font
        return cell.setColor()
    }
    
}

extension CategoryStatisticsVC: UIPickerViewDataSource, UIPickerViewDelegate, CustomKeyboardDelegate {
    
    
    var years: [Int] {
        let nowYear = DateInRegion().year
        return (nowYear - 3 ... nowYear).map({$0})
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(years[row]) + "年"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerLabel.text = String(years[row]) + "年分 ▼"
    }
    
    func startEdit(sender: CustomKeyboard) {
        sumInCategoryTableView.isUserInteractionEnabled = false
    }
    
    func didCancel(sender: CustomKeyboard) {
        sumInCategoryTableView.isUserInteractionEnabled = true
        
        pickerLabel.text = String(year) + "年分 ▼"
        sender.resignFirstResponder()
        if let yearOfBeforeEdit = years.firstIndex(of: year) {
            pickerView.selectRow(yearOfBeforeEdit, inComponent: 0, animated: true)
        }
    }
    
    func didDone(sender: CustomKeyboard) {
        sumInCategoryTableView.isUserInteractionEnabled = true
        
        year = years[(sender.pickerView?.selectedRow(inComponent: 0))!]
        setChart(year, mainCategory: mainCategory, category: category)
        
        sender.resignFirstResponder()
    }
    
}

//x軸のラベルを設定する
public class lineChartFormatter: NSObject, IAxisValueFormatter{

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String(Int(value)) + "月"
    }
}
