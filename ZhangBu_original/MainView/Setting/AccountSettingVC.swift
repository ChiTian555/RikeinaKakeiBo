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


class AccountSettingVC: MainBaceVC {

    var settingNomber: Int!
    
    var settingArray: [(name: String, cellType: Int)]!
    
    var accounts = [Account]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //スワイプで画面を戻る
        self.setSwipe()
        
        tableView.set()
        
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        accounts = Account.readAll() + []; reloadData()
    }
    
    func reloadData() {
        moveButton.tintColor = accounts.count > 1 ?
            UserDefaults.standard.color(forKey: .buttonColor) : .systemGray3
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
            let vc = nc.visibleViewController as! AddAccountVC
            let i = sender as! Int
            vc.selectedAccount = accounts[i]
            vc.selectedNumber = i
            vc.isEditMode = true
        }
    }

}

// MARK: TableView Func

extension AccountSettingVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count == 0 ? 1 : accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!.create()
        let label = cell.viewWithTag(2) as! UILabel
        
        if accounts.count == 0 {
            label.text = "登録済み口座がありません\n右上の'＋'から、\nまず現金口座を追加してみしょう"
            label.textAlignment = .center
            cell.isUserInteractionEnabled = false
        } else {
            label.text = accounts[indexPath.row].name
            label.textAlignment = .left
        }
        return cell.set()
    }
    
}

extension AccountSettingVC: UITableViewDelegate {
    
    //編集モード切り替え
    @IBAction func tappedEditButton() {
        tableView.isEditing = !tableView.isEditing
    }
    //テーブルビューの編集可否を指定
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if accounts.count == 0 { return false }
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
    
    // MARK: Back Swipe Cell Func
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: nil) { (ctxAction, view, completionHandler) in
            
            let alert = MyAlert("削除", "ほんとに削除してもよろしいですか？")
            alert.addActions("キャンセル", type: .cancel)  { _ in completionHandler(false) }
            alert.addActions("削除", type: .destructive) { _ in
                self.accounts[indexPath.row].delete()
                self.accounts.remove(at: indexPath.row)
                if self.accounts.isEmpty { self.reloadData() }
                else { tableView.deleteRows(at: [indexPath], with: .automatic) }
                
                //並び替えボタンの更新
                self.moveButton.tintColor = self.accounts.count > 1 ? .systemBlue : .systemGray3
                self.moveButton.isEnabled = self.accounts.count > 1
                
                completionHandler(true)
            }
            self.present(alert.controller, animated: true, completion: nil)
        }
        action.image = UIImage(systemName: "trash")
        
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
