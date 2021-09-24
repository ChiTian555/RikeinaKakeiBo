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

class PLViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    private let realm = try! Realm()
    private var payments = [Payment]()
    
    @IBOutlet var paymentListTableView: UITableView!
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    @IBOutlet var titleBar: UINavigationItem!
    
    var selectedMonth: Int = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paymentListTableView.delegate = self
        paymentListTableView.dataSource = self
        paymentListTableView.tableFooterView = UIView()
        
        let months = ["分類1","分類2","分類3","分類4"]
        let unitsSold = [10.0, 4.0, 12.0, 16.0]
        setChart(dataPoints: months, values: unitsSold)
        
        titleBar.title = "\(selectedMonth)月の収支一覧"
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let realm = try! Realm()
        payments = realm.objects(Payment.self).sorted(byKeyPath: "date", ascending: true)
            .map({ $0 })
        paymentListTableView.reloadData()
    }
    
    /**
     円グラフをセットアップする
     */
    func setChart(dataPoints: [String], values: [Double]) {

        pieChartView.centerText = "合計:\(values.reduce(0) { $0 + $1 })"
        pieChartView.holeColor = UIColor.secondarySystemBackground
        pieChartView.highlightPerTapEnabled = false
        pieChartView.rotationEnabled = false
        pieChartView.holeRadiusPercent = 0.58
        pieChartView.transparentCircleRadiusPercent = 0.61
        pieChartView.setExtraOffsets(left: 5, top: 10, right: 5, bottom: 0)
        let l = pieChartView.legend
        l.font = UIFont.systemFont(ofSize: 15)
        l.horizontalAlignment = .left
        l.verticalAlignment = .top
        l.xOffset = 0
        l.orientation = .vertical

        
//        pieChartView.usePercentValuesEnabled = true
        
        var dataEntries: [ChartDataEntry] = []

        for i in 0..<dataPoints.count {
            let dataEntry1 = PieChartDataEntry(value: values[i], label: dataPoints[i])
//            let dataEntry1 = ChartDataEntry(x: Double(i), y: values[i], data: dataPoints[i] as AnyObject)

            dataEntries.append(dataEntry1)
        }
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label:  nil)
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        

        var colors: [UIColor] = []

        for _ in 0..<dataPoints.count {
            
            var red = Double(arc4random_uniform(256))
            var green = Double(arc4random_uniform(256))
            var blue = Double(arc4random_uniform(256))
            
            while red + green + blue >= 510 && red + green + blue <= 255 {
                red = Double(arc4random_uniform(256))
                green = Double(arc4random_uniform(256))
                blue = Double(arc4random_uniform(256))
            }
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }

        pieChartDataSet.colors = colors
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        let categoryLabel = cell.contentView.viewWithTag(1) as! UILabel
        let dateLabel = cell.contentView.viewWithTag(2) as! UILabel
        let priceLabel = cell.contentView.viewWithTag(3) as! UILabel
        cell.tag = indexPath.row
        let price = payments[indexPath.row].price
        if price < 0 {
            priceLabel.textColor = UIColor.red
        }
        priceLabel.text = "\(price)"
        categoryLabel.text = payments[indexPath.row].category
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "MM/dd"
        dateLabel.text = dateFormatter.string(from: payments[indexPath.row].date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDitail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDitail" {
            let cv = segue.destination as! PaymentDetailViewController
            let indexPath = paymentListTableView.indexPathForSelectedRow!
            cv.detailPayment = payments[indexPath.row]
        }
    }
}
