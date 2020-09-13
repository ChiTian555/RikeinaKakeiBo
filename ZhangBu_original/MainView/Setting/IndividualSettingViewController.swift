//
//  IndividualSettingViewController.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/08/20.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import PKHUD
import RealmSwift
import FontAwesome_swift


class IndividualSettingViewController: UIViewController {

    var settingNomber: Int!
    
    var settingArray: [(name: String, cellTipe: Int)]!
    
    var accounts = [Account]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
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
        
        if accounts.count != 0 {
            tableView.rowHeight = 50
            tableView.estimatedRowHeight = 50
        }
        moveButton.tintColor = accounts.count > 1 ? .systemBlue : .systemGray3
        moveButton.isEnabled = accounts.count > 1
        
        tableView.reloadData()
    }
    
    @IBOutlet var moveButton: UIBarButtonItem!
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func addAccount() {
        self.performSegue(withIdentifier: "toAddAccount", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender != nil {
            let nc = segue.destination as! UINavigationController
            let vc = nc.visibleViewController as! AddAccountViewController
            let i = sender as! Int
            vc.selectedAccount = accounts[i]
            vc.selectedNumber = i
            vc.isEditMode = true
        }
    }

}

extension IndividualSettingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count == 0 ? 1 : accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let label = cell.viewWithTag(2) as! UILabel
        
        if accounts.count == 0 {
            label.text = "登録済み口座がありません\n右上の'＋'から、\nまず現金口座を追加してみしょう"
            label.textAlignment = .center
            cell.isUserInteractionEnabled = false
        } else {
            label.text = accounts[indexPath.row].name
            label.textAlignment = .left
        }
        
        return cell
    }
    
}

extension IndividualSettingViewController: UITableViewDelegate {
    
    //編集モード切り替え
    @IBAction func tappedEditButton() {
        tableView.isEditing = !tableView.isEditing
    }
    //テーブルビューの並び替えモード
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    //編集モード時の左のマークを選択
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    //編集モード時に左を開ける
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    //列の入れ替え
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceRow: Int = sourceIndexPath.row
        let destinationRow: Int = destinationIndexPath.row
        if !Account.moveAccount(accounts[sourceRow], accounts[destinationRow]) {
            HUD.flash(.error, delay: 1.5)
        }
        let source = accounts.remove(at: sourceRow)
        accounts.insert(source, at: destinationRow)
    }
    
    //後方スワイプ
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: nil) { (ctxAction, view, completionHandler) in
            
            let alert = UIAlertController(title: "削除", message: "ほんとに削除してもよろしいですか？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "削除", style: .destructive) { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.accounts[indexPath.row].delete()
                self.accounts.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                //並び替えボタンの更新
                self.moveButton.tintColor = self.accounts.count > 1 ? .systemBlue : .systemGray3
                self.moveButton.isEnabled = self.accounts.count > 1
                
                completionHandler(true)
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                alert.dismiss(animated: true, completion: nil)
                completionHandler(false)
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        action.image = UIImage.fontAwesomeIcon(name: .trashAlt, style: .regular, textColor: .label, size: CGSize(width: 50, height: 50))
        let swipeAction = UISwipeActionsConfiguration(actions: [action])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

//    //上の2この位置を変えないようにする。
//    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
//        if proposedDestinationIndexPath.row < userBudget.count {
//            return sourceIndexPath
//        }
//        return proposedDestinationIndexPath
//    }
    
}
