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

class PLViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
    
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
    
    var year: Int = 0
    var month: Int = 0
    
    var selectYear = 0
    var selectMonth = 0
    
    let years = (2018...2021).map { $0 }
    let months = (1...12).map { $0 }
    
    let pickerView = UIPickerView()
    
    var showedPicker = false
    
    var vi: UIView! //pikerViewを格納するView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if year == 0 || month == 0 {
            year = Date().year
            month = Date().month
        }
        
        //右へ
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        rightSwipeGesture.direction = .right
        //左へ
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        leftSwipeGesture.direction = .left
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.numberOfTouchesRequired = 1
        
        pickerView.backgroundColor = UIColor.secondarySystemBackground
        pickerView.delegate = self
        
        paymentListTableView.delegate = self
        paymentListTableView.dataSource = self
        paymentListTableView.tableFooterView = UIView()
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.tableFooterView = UIView()
        categoryTableView.estimatedRowHeight = 32
        categoryTableView.rowHeight = UITableView.automaticDimension
        pieChartView.delegate = self
        
        let titleView =  UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        titleView.backgroundColor = .clear
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor.label
        titleView.addSubview(titleLabel)
        titleBar.titleView = titleView
        
        paymentListTableView.addGestureRecognizer(rightSwipeGesture)
        paymentListTableView.addGestureRecognizer(leftSwipeGesture)
        
        titleBar.titleView?.addGestureRecognizer(tapGesture)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if year == 0 || month == 0 {
            year = Date().year
            month = Date().month
        }
        titleLabel.text = "\(year)年 \(month)月の\( changeMainCategoryTab.titleForSegment(at: changeMainCategoryTab.selectedSegmentIndex) ?? "")"
        reLoadDataAndChart()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBAction func selectMainMenu(_ sender: UISegmentedControl) {
        titleLabel.text = "\(year)年 \(month)月の\( changeMainCategoryTab.titleForSegment(at: changeMainCategoryTab.selectedSegmentIndex) ?? "")"
        reLoadDataAndChart()
    }
    
    @objc func swiped(_ sender: UISwipeGestureRecognizer) {

        switch sender.direction {
        case .left:
            if month == 12 {
                month = 1
                year += 1
            } else {
                month += 1
            }
        case .right:
            if month == 1 {
                month = 12
                year -= 1
            } else {
                month -= 1
            }
        default:
            break
        }
        titleLabel.text = "\(year)年 \(month)月の\( changeMainCategoryTab.titleForSegment(at: changeMainCategoryTab.selectedSegmentIndex) ?? "")"
        reLoadDataAndChart()
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        
        if !showedPicker {
            pickerPush()
        }
    }
    
    func reLoadDataAndChart() {
        let firstDate = DateInRegion(year: year, month: month, day: 1).date
        let endDate = DateInRegion(year: year, month: month + 1, day: 1).date
        var data : [(category: String, value: Int)] = []
        let monthRealmPayments = realm.objects(Payment.self)
            .filter("mainCategoryNumber == \(changeMainCategoryTab.selectedSegmentIndex)")
            .filter("date >= %@ AND date < %@", firstDate, endDate)
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
    
    //tabBarから、pickerViewを呼び出す
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return years.count
        } else if component == 1 {
            return months.count
        } else {
            return 0
        }
    }

    // MARK: - UIPickerView delegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(years[row])年"
        } else if component == 1 {
            return "\(months[row])月"
        } else {
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectYear = years[pickerView.selectedRow(inComponent: 0)]
        selectMonth = months[pickerView.selectedRow(inComponent: 1)]
        titleLabel.text = "\(year)年 \(month)月の\(changeMainCategoryTab.titleForSegment(at: changeMainCategoryTab.selectedSegmentIndex) ?? "")"
    }
    
    
    func pickerPush(){
        pickerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: pickerView.bounds.size.height)
        //viは、pickerViewを格納
        vi = UIView(frame: pickerView.bounds)
        // Connect data:
        vi.backgroundColor = UIColor.secondarySystemBackground
        vi.addSubview(pickerView)
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, view.frame.size.width, 35))
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        toolbar.tintColor = UIColor.systemOrange
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        doneItem.tintColor = UIColor.orange
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        cancelItem.tintColor = UIColor.orange
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelItem, spaceButton, doneItem], animated: true)
        toolbar.isUserInteractionEnabled = true
        vi.addSubview(toolbar)
        // viをviewに追加し、下からアニメーション表示
        self.tabBarController?.tabBar.isHidden = true
        view.addSubview(vi)
        view.bringSubviewToFront(vi)
        let screenSize = UIScreen.main.bounds.size
        vi.frame.origin.y = screenSize.height
        UIView.animate(withDuration: 0.3) {
            self.vi.frame.origin.y = screenSize.height - self.vi.bounds.size.height
        }
        showedPicker = true
        
        pickerView.selectRow(year - 2018 , inComponent: 0, animated: false)
        pickerView.selectRow(month - 1, inComponent: 1, animated: false)
    }
    
    @objc func done() {
        if selectYear != 0 || selectMonth != 0 {
            year = selectYear
            month = selectMonth
        }
        selectMonth = 0
        selectYear = 0
        UIView.animate(withDuration: 0.3, animations:  {
        self.vi.frame.origin.y = UIScreen.main.bounds.size.height
        }) { _ in
            self.showedPicker = false
            self.pickerView.reloadAllComponents()
            self.vi.removeFromSuperview()
            self.tabBarController?.tabBar.isHidden = false
        }
        titleLabel.text = "\(year)年 \(month)月の\( changeMainCategoryTab.titleForSegment(at: changeMainCategoryTab.selectedSegmentIndex) ?? "")"
        reLoadDataAndChart()
    }
    
    @objc func cancel() {
        selectMonth = 0
        selectYear = 0
        UIView.animate(withDuration: 0.3, animations:  {
        self.vi.frame.origin.y = UIScreen.main.bounds.size.height
        }) { _ in
            self.showedPicker = false
            self.pickerView.reloadAllComponents()
            self.vi.removeFromSuperview()
            self.tabBarController?.tabBar.isHidden = false
        }
        titleLabel.text = "\(year)年 \(month)月の\( changeMainCategoryTab.titleForSegment(at: changeMainCategoryTab.selectedSegmentIndex) ?? "")"
    }
    
    /**
     円グラフをセットアップする
     */
    func setChart(dataPoints: [String], values: [Int]) {
        let attrStr = NSMutableAttributedString()
        if UserDefaults.standard.bool(forKey: .isCordMode)! {
            attrStr.append(NSAttributedString(string: "計:", attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .regular),
                NSAttributedString.Key.foregroundColor : UIColor.label
            ]))
            attrStr.append(NSAttributedString(string: "¥\(values.reduce(0) { $0 + $1 })", attributes: [
                            NSAttributedString.Key.font : UIFont(name: "cordFont", size: 20)!,
                            NSAttributedString.Key.foregroundColor : UIColor.label
                            ]))
        } else {
            attrStr.append(NSAttributedString(string: "計:¥\(values.reduce(0) { $0 + $1 })", attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .regular),
                NSAttributedString.Key.foregroundColor : UIColor.label
            ]))
        }
        pieChartView.centerAttributedText = attrStr
        pieChartView.noDataFont =  UIFont(name: "cordFont", size: 15)!
        pieChartView.holeColor = UIColor.secondarySystemBackground
//        pieChartView.highlightPerTapEnabled = false
        pieChartView.rotationEnabled = false
        pieChartView.rotationAngle = 0.0
        pieChartView.holeRadiusPercent = 0.7
        pieChartView.transparentCircleRadiusPercent = 0.75
        pieChartView.setExtraOffsets(left: 5, top: 5, right: 5, bottom: 5)
//        pieChartView.highlightValue(nil, callDelegate: true)
        //完成版で実装予定
        pieChartView.legend.enabled = false
        pieChartView.drawEntryLabelsEnabled = true
        pieChartView.entryLabelColor = .label
        pieChartView.entryLabelFont = UIFont.systemFont(ofSize: 10, weight: .light)
//        let l = pieChartView.legend
//        l.font = UIFont.systemFont(ofSize: 14)
//        l.horizontalAlignment = .right
//        l.verticalAlignment = .top
//        l.xOffset = 2
//        l.orientation = .vertical
        
        pieChartView.usePercentValuesEnabled = true
        pieChartView.accessibilityNavigationStyle = .combined
        
        var dataEntries: [ChartDataEntry] = []

        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: Double(values[i]),
                                              label: "\(dataPoints[i])")
//            let dataEntry = ChartDataEntry(x: Double(i), y: values[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        let set = PieChartDataSet(entries: dataEntries, label: nil)
        
        set.sliceSpace = 2
        
        if dataPoints.count != 0 {
            if changeMainCategoryTab.selectedSegmentIndex == 0 {
                set.colors = ChartColorTemplates.vordiplom()
                set.colors.append(contentsOf: ChartColorTemplates.vordiplom())
                if dataPoints[dataPoints.count - 1] == "その他" {
                    set.colors[dataPoints.count - 1] = UIColor.systemGray
                }
            } else {
                set.colors = ChartColorTemplates.colorful()
                set.colors.append(contentsOf: ChartColorTemplates.colorful())
                if dataPoints[dataPoints.count - 1] == "その他" {
                    set.colors[dataPoints.count - 1] = UIColor.systemGray
                }
            }
            colors = set.colors.prefix(dataPoints.count) + []

        }
//            + ChartColorTemplates.vordiplom()
//            + ChartColorTemplates.colorful()
//            + ChartColorTemplates.joyful()
//            + ChartColorTemplates.liberty()
//            + ChartColorTemplates.pastel()
//            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
//            + ChartColorTemplates.colorFromString(String)
        
        set.valueLinePart1OffsetPercentage = 0.5
        set.valueLineVariableLength = true
        set.valueLinePart1Length = 0.3
        set.valueLinePart2Length = 0.3
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
        if UserDefaults.standard.bool(forKey: .isCordMode)! {
            pieChartData.setValueFont(UIFont(name: "cordFont", size: 20)!)
        } else {
            pieChartData.setValueFont(.systemFont(ofSize: 12, weight: .light))
        }
        pieChartData.setValueTextColor(.label)
        
        pieChartView.data = pieChartData
        

        pieChartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDitail" {
            let cv = segue.destination as! PLDetailViewController
            let indexPath = paymentListTableView.indexPathForSelectedRow!
            cv.detailPayment = payments[indexPath.row]
        }
    }
    
    //CGRectを簡単に作る
    private func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
}

extension PLViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 1:
            return payments.count
        case 2:
            return allCategories.count
        default: return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch tableView.tag {
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            let categoryLabel = cell.contentView.viewWithTag(1) as! UILabel
            let dateLabel = cell.contentView.viewWithTag(2) as! UILabel
            let priceLabel = cell.contentView.viewWithTag(3) as! UILabel
            let colorView = cell.contentView.viewWithTag(4)
            if UserDefaults.standard.bool(forKey: .isCordMode)! {
                priceLabel.font = UIFont(name: "cordFont", size: 25)
            } else {
                priceLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            }
            cell.tag = indexPath.row
            let price = payments[indexPath.row].price

            if price < 0 {
                priceLabel.text = "-¥\(price * -1)"
                priceLabel.textColor = UIColor.red
            } else {
                priceLabel.text = "¥\(price)"
                priceLabel.textColor = UIColor.label
            }
            let category = payments[indexPath.row].category
            categoryLabel.text = category
            if payments[indexPath.row].category.count == 5 {
                categoryLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            }
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            dateFormatter.dateFormat = "MM/dd"
            dateLabel.text = dateFormatter.string(from: payments[indexPath.row].date)
            let categoryIndex = allCategories.firstIndex(of: category)!
            if categoryIndex < colors.count {
                colorView?.backgroundColor = colors[categoryIndex]
            } else {
                colorView?.backgroundColor = .systemGray
            }
            return cell
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            let colorView = cell.contentView.viewWithTag(1)!
            let categoryLabel = cell.contentView.viewWithTag(2) as! UILabel
            if indexPath.row < colors.count {
                colorView.backgroundColor = colors[indexPath.row]
            } else {
                colorView.backgroundColor = .systemGray
            }
            categoryLabel.text = allCategories[indexPath.row]
            return cell
        default:
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case 1:
            if showedPicker {
                tableView.cellForRow(at: indexPath)?.isSelected = false
                return
            }
            performSegue(withIdentifier: "toDitail", sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        case 2: break
        default: break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
}

extension PLViewController : ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        performSegue(withIdentifier: "toMonth", sender: nil)
        let i = Int(highlight.x)
        print(i)
    }
}
