//
//  IndividualSettingViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/20.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import PKHUD
import Realm
import RealmSwift

class IndividualSettingViewController: UIViewController {

    var settingNomber: Int!
    
    var settingArray: [(name: String, cellTipe: Int)]!
    
    var accounts = [Account]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        load()
        print(accounts)
    }
    
    func load() {
//        accounts = UserDefaults.standard.stringArray2(forKey: .account)!
        accounts = Account.readAll() + []
        tableView.reloadData()
    }
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func addAccount() {
        self.performSegue(withIdentifier: "toAddAccount", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender != nil {
            let nc = segue.destination as! UINavigationController
            let vc = nc.visibleViewController as! AddAccountViewController
            let i = sender as! Int
            let account = UserDefaults.standard.stringArray2(forKey: .account)![i]
            vc.selectedMoney = account[1]
            vc.selectedName = account[0]
            vc.selectedNumber = i
            vc.isEditMode = true
        }
    }

}

extension IndividualSettingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let label = cell.viewWithTag(2) as! UILabel
//        let colorView = cell.viewWithTag(1)!
        label.text = accounts[indexPath.row].accountName
//        colorView.backgroundColor = accounts[indexPath.row].accountUIColor
        
        return cell
    }
    
}

extension IndividualSettingViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
////        let sourceCellItem = list[mainCategoryNumber][tappedNumber][sourceIndexPath.row]
////        guard let indexPath = list[mainCategoryNumber][tappedNumber].firstIndex(of: sourceCellItem) else { return }
////        list[mainCategoryNumber][tappedNumber].remove(at: indexPath)
////        list[mainCategoryNumber][tappedNumber].insert(sourceCellItem, at: destinationIndexPath.row)
////        ud.setArray3(list, forKey: .list)
//    }
//
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        let ud = UserDefaults.standard
//        let normalAction = UIContextualAction(style: .normal, title: "編集") {
//            (action, view, completionHandler) in
//
//            self.performSegue(withIdentifier: "toAddAccount", sender:
//                indexPath.row)
//            completionHandler(true)
//        }
//
//        let destructiveAction = UIContextualAction(style: .destructive, title: "削除") {
//            (action, view,completionHandler) in
//            action.backgroundColor = .systemRed
//            self.accounts.remove(at: indexPath.row)
//            if self.accounts.count == 0 {
//                self.accounts.append([])
//            }
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            ud.setArray2(self.accounts, forKey: .account)
//            completionHandler(true)
//        }
//
//        let configuration = UISwipeActionsConfiguration(actions: [destructiveAction, normalAction])
//        configuration.performsFirstActionWithFullSwipe = false
//
//        return configuration
//    }
//
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .none
//    }
    
}
