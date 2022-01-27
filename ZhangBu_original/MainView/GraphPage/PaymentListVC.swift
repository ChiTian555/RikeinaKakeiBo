//
//  PaymentListViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/11.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import RealmSwift
import Charts
import SwiftDate
import PKHUD

class PaymentListVC: MainBaceVC, UITextFieldDelegate, CustomKeyboardDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private let realm = try! Realm()
    private var payments = [Payment]()
    
    @IBOutlet var changeMainCategoryTab: UISegmentedControl!
    
    @IBOutlet var paymentListTableView: UITableView!
    
    @IBOutlet var categoryTableView: UITableView!
    
    var colors = [UIColor]()
    var allCategories = [String]()
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    @IBOutlet var titleBar: UINavigationItem!
    
    var titleLabel = UILabel(frame: CGRect(x: 0, y: 13, width: 200, height: 18))
    
    //表示する年月を格納、0項：年、1項：月
    var editMonth: [Int] = [0,0]
    var month: [Int] = [0,0]
    let dates: [[String]] = [(2018...2030).map{ (String($0)) }, (1...12).map{ (String($0)) }]

    let pickerView = UIPickerView()
    
    var showedPicker = false
    
    var keyboard: UIView! //pikerViewを格納するView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if month.contains(0) {
            month = [DateInRegion().year, DateInRegion().month]
        }
        
        //右へ
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        rightSwipeGesture.direction = .right
        //左へ
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        leftSwipeGesture.direction = .left
        
        paymentListTableView.delegate = self
        paymentListTableView.dataSource = self
        paymentListTableView.tableFooterView = UIView()
        paymentListTableView.set()
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        categoryTableView.tableFooterView = UIView()
        let tableHeight = categoryTableView.layer.frame.height
        let height = (tableHeight / 10 <= 30) ? 30 : tableHeight / 10
        categoryTableView.estimatedRowHeight = height
        categoryTableView.rowHeight = height
        print(categoryTableView.layer.frame.height / 10)
//        categoryTableView.rowHeight = UITableView.automaticDimension
        categoryTableView.allowsSelection = true
        categoryTableView.set()
        pieChartView.delegate = self
        
        setKeyboard()
        let titleView = CustomKeyboard(frame: CGRectMake(0, 0, 200, 44))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .clear
        titleView.inputView = pickerView
        titleView.delegate = self
        titleView.backgroundColor = .clear
        
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor.label
        titleView.addSubview(titleLabel)
        titleBar.titleView = titleView
        
        paymentListTableView.addGestureRecognizer(rightSwipeGesture)
        paymentListTableView.addGestureRecognizer(leftSwipeGesture)
        
    }
    
    //カスタムキーボード(PickerView)の中身を生成
    func setKeyboard() {
        pickerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: pickerView.bounds.size.height)
        //viは、pickerViewを格納
        keyboard = UIView(frame: pickerView.bounds)
        // Connect data:
        keyboard.backgroundColor = UIColor.secondarySystemBackground
        keyboard.addSubview(pickerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if month.contains(0) {
            month = [DateInRegion().year, DateInRegion().month]
        }
        titleLabel.text = "\(month[0])年 \(month[1])月の\(changeMainCategoryTab.selectedTitle) ▼"
        print("viewWillApare")
        reLoadDataAndChart()
    }
    
    
    @IBAction func selectMainMenu(_ sender: UISegmentedControl) {
        titleLabel.text = "\(month[0])年 \(month[1])月の\(changeMainCategoryTab.selectedTitle) ▼"
        reLoadDataAndChart()
    }
    
    @objc func swiped(_ sender: UISwipeGestureRecognizer) {

        if sender.direction == .left {
            if month[1] == 12 {
                month[1] = 1
                month[0] += 1
            } else { month[1] += 1 }
        } else if sender.direction == .right {
            if month[1] == 1 {
                month[1] = 12
                month[0] -= 1
            } else { month[1] -= 1 }
        }
        titleLabel.text = "\(month[0])年 \(month[1])月の\(changeMainCategoryTab.selectedTitle) ▼"
        reLoadDataAndChart()
    }
    
    func reLoadDataAndChart() {
        var data : [(category: String, value: Int)] = []
        let mainCategory = changeMainCategoryTab.selectedSegmentIndex
        let monthRealmPayments = Payment.getMonthPayment(mainCategory, year: month[0], month: month[1])
        var allSum: Int = monthRealmPayments.sum(ofProperty: "price")
        var categories: [String] = monthRealmPayments.map({ $0.category })
        categories = NSOrderedSet(array: categories).array as! [String]
        
        if changeMainCategoryTab.selectedSegmentIndex == 0 {
            allSum *= -1
        }
        
        for category in categories {
            let realmPayments = monthRealmPayments.filter("category == %@", category)
            var sum: Int = realmPayments.sum(ofProperty: "price")
            if changeMainCategoryTab.selectedSegmentIndex == 0 {
                sum *= -1
            }
            data.append((category, sum))
            data = data.sorted { (first, second) -> Bool in
                return first.value > second.value
            }
        }
        allCategories = data.map({ $0.category })
        
        //小さいデータから、合計全体の10%に満たないデータをその他表示
        var nowSum = Int()
        var otherSum = Int()
        let dataCount = data.count
        if dataCount != 0 {
            for i in 1 ... dataCount {
                nowSum += data[dataCount - i].value
                let value: Double = Double(nowSum) / Double(allSum)
                print(value)
                if 10 * nowSum > allSum  {
                    if i >= 3 {
                        otherSum += data.removeLast().value
                        data.append(("その他", otherSum))
                    }
                    break
                }
                if i >= 2 {
                    otherSum += data.removeLast().value
                }
            }
        }
        
        setChart(dataPoints: data.map({ $0.category }), values: data.map({ $0.value }))
        
        payments = monthRealmPayments.sorted(byKeyPath: "date", ascending: true).map({ $0 })
        paymentListTableView.reloadData()
        categoryTableView.reloadData()
    }
    

    // MARK: - delegate, DataSource
    
    func startEdit(sender: CustomKeyboard) {
        for i in 0 ..< self.dates.count {
        self.pickerView.selectRow(self.dates[i].firstIndex(of: String(self.month[i]))!,
                                  inComponent: i,
                                  animated: false)
        }
        showedPicker = true
        editMonth = month
    }
    
    func didCancel(sender: CustomKeyboard) {
        sender.resignFirstResponder()
        showedPicker = false
        editMonth = [0,0]
        titleLabel.text = "\(month[0])年 \(month[1])月の\(changeMainCategoryTab.selectedTitle) ▼"
    }
    
    func didDone(sender: CustomKeyboard) {
        sender.resignFirstResponder()
        showedPicker = false
        month = editMonth
        editMonth = [0,0]
        reLoadDataAndChart()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dates[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dates[component][row] + (component == 0 ? "年":"月")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        editMonth[component] = Int(dates[component][row])!
        titleLabel.text = "\(editMonth[0])年 \(editMonth[1])月の\(changeMainCategoryTab.selectedTitle) ▼"
    }
    
    /**
     円グラフをセットアップする
     */
    func setChart(dataPoints: [String], values: [Int]) {
        pieChartView.centerAttributedText = StringUtil(size: 14).getText(
            "計:".deco, "¥\(values.reduce(0) { $0 + $1 })".deco(.myFont(.codeWithSize(20)))
        )
        pieChartView.noDataFont =  UIFont.systemFont(ofSize: 14, weight: .regular)
        pieChartView.holeColor = UIColor.secondarySystemBackground
//        pieChartView.highlightPerTapEnabled = false
        pieChartView.rotationEnabled = false
        pieChartView.rotationAngle = 0.0
        pieChartView.holeRadiusPercent = 0.7
        pieChartView.transparentCircleRadiusPercent = 0.75
        pieChartView.setExtraOffsets(left: 5, top: 5, right: 5, bottom: 5)
        //完成版で実装予定
//        pieChartView.highlightValue(nil, callDelegate: true)
        pieChartView.isUserInteractionEnabled = false
        pieChartView.legend.enabled = false
        pieChartView.drawEntryLabelsEnabled = true
        pieChartView.entryLabelColor = .label
        pieChartView.entryLabelFont = UIFont.systemFont(ofSize: 12, weight: .light)
        
        pieChartView.usePercentValuesEnabled = true
        pieChartView.accessibilityNavigationStyle = .combined
        
        var dataEntries: [ChartDataEntry] = []

        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: Double(values[i]),
                                              label: "\(dataPoints[i])")
            dataEntries.append(dataEntry)
        }
        let set = PieChartDataSet(entries: dataEntries, label: nil)
        set.sliceSpace = 2
        
        if dataPoints.count != 0 {
            if changeMainCategoryTab.selectedSegmentIndex == 0 {
                set.colors = ChartColorTemplates.vordiplom()
                set.colors.append(contentsOf: ChartColorTemplates.colorful())
                if dataPoints[dataPoints.count - 1] == "その他" {
                    set.colors[dataPoints.count - 1] = UIColor.systemGray
                }
            } else {
                set.colors = ChartColorTemplates.colorful()
                set.colors.append(contentsOf: ChartColorTemplates.vordiplom())
                if dataPoints[dataPoints.count - 1] == "その他" {
                    set.colors[dataPoints.count - 1] = UIColor.systemGray
                }
            }
            colors = set.colors.prefix(dataPoints.count) + []

        }
        
        set.valueLinePart1OffsetPercentage = 0.5
        set.valueLineVariableLength = true
        //放射線状に伸びる部分
        set.valueLinePart1Length = 0.3
        set.valueLinePart2Length = 0.1
        set.valueLineColor = .label
        set.xValuePosition = .outsideSlice
        set.yValuePosition = .outsideSlice
        set.sliceSpace = 2.0
        
        let pieChartData = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = "%"
        pieChartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        pieChartData.setValueFont(.codeFont(14))
        pieChartData.setValueTextColor(.label)
        
        pieChartView.data = pieChartData
        

        pieChartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
    }
    
    //CGRectを簡単に作る
    private func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
}

// MARK: TableView Seting

extension PaymentListVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 1:
            return payments.count
        case 2:
            return allCategories.isEmpty ? 0 : allCategories.count + 1
        default: return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch tableView.tag {
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!.create()
            let categoryLabel = cell.contentView.viewWithTag(1) as! UILabel
            let dateLabel = cell.contentView.viewWithTag(2) as! UILabel
            let priceLabel = cell.contentView.viewWithTag(3) as! UILabel
            let colorView = cell.contentView.viewWithTag(4)
            priceLabel.font = .codeFont(17)
            cell.tag = indexPath.row
            let price = payments[indexPath.row].price

            priceLabel.text = ( price < 0 ) ? "-¥\(price * -1)" : "¥\(price)"
            priceLabel.textColor = ( price < 0 ) ? .red : .label

            let nowPayment = payments[indexPath.row]
            let isUseSavedMoney = payments[indexPath.row].isUsePoketMoney == false
                                && nowPayment.mainCategoryNumber == 0
            let markUseSavedMoney = isUseSavedMoney ? " (貯)" : ""
            categoryLabel.text = nowPayment.category + markUseSavedMoney
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            dateFormatter.dateFormat = "MM/dd"
            dateLabel.text = dateFormatter.string(from: payments[indexPath.row].date)
            let categoryIndex = allCategories.firstIndex(of: nowPayment.category)!
            if categoryIndex < colors.count {
                colorView?.backgroundColor = colors[categoryIndex]
            } else {
                colorView?.backgroundColor = .systemGray
            }
        case 2:
            let row = indexPath.row - 1
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!.create()
            let colorView = cell.contentView.viewWithTag(1)!
            let categoryLabel = cell.contentView.viewWithTag(2) as! UILabel
            
            if row < 0 { colorView.backgroundColor = .label }
            else if row < colors.count { colorView.backgroundColor = colors[row] }
            else { colorView.backgroundColor = .systemGray }
            
            categoryLabel.text = ( row ) < 0 ? "合計" : allCategories[row]
        default:
            cell = UITableViewCell()
        }
        
        return cell.setColor()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case 1:
            if showedPicker {
                tableView.cellForRow(at: indexPath)?.isSelected = false
                return
            }
            performSegue(withIdentifier: "toDitail", sender: indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
        case 2:
            performSegue(withIdentifier: "toMonth", sender: indexPath)
            break
        default:
            paymentListTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let editVC = segue.destination as? AddPaymentVC {
            let tappedIndex = sender as! IndexPath
            paymentListTableView.deselectRow(at: tappedIndex, animated: true)
            editVC.current = (payments[tappedIndex.row], false)
        } else if let barChartVC = segue.destination as? CategoryStatisticsVC {
            let tappedIndex = sender as! IndexPath
            let row = tappedIndex.row - 1
            categoryTableView.deselectRow(at: tappedIndex, animated: true)
            barChartVC.category = (row < 0) ? nil : allCategories[row]
            if row < 0 { barChartVC.color = .label }
            else if row < colors.count { barChartVC.color = colors[row] }
            else { barChartVC.color = .systemGray }

            barChartVC.mainCategory = changeMainCategoryTab.selectedSegmentIndex
        }
        
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//    }
    
}

extension PaymentListVC: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        performSegue(withIdentifier: "toMonth", sender: nil)
        let i = Int(highlight.x)
        print(i)
    }
}
