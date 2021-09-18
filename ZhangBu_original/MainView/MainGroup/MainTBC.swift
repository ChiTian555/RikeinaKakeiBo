//
//  MainTBC.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/07.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit
import FontAwesome_swift

class MainTBC: UITabBarController, UITabBarControllerDelegate {
    
    private let ud = UserDefaults.standard
    let size = CGSize(width: 27, height: 27)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        let colorImage = UIImage.colorImage(color: UserDefaults.standard.color(forKey: .userColor))
        self.tabBar.backgroundImage = colorImage
        
        let Images: [(image: UIImage,title: String)] =
            [(UIImage.fontAwesomeIcon(name: .yenSign, style: .solid, textColor: .white, size: size),"残高"),
             (UIImage.fontAwesomeIcon(name: .chartPie, style: .solid, textColor: .white, size: size),"一覧"),
             (UIImage.fontAwesomeIcon(name: .edit, style: .solid, textColor: .white, size: size),"記入"),
             (UIImage.fontAwesomeIcon(name: .cogs, style: .solid, textColor: .white, size: size),"設定")]
        
        if let count = self.tabBar.items?.count {
            for i in 0 ..< count {
                self.tabBar.items![i].image = Images[i].image
                self.tabBar.items![i].title = Images[i].title
                self.tabBar.items![i].badgeColor = .systemRed
            }
        }
        self.tabBar.tintColor = UserDefaults.standard.color(forKey: .buttonColor)
        self.tabBar.unselectedItemTintColor = UIColor.label.withAlphaComponent(0.7)
        setStartStep()
    }
    
    func setColor(color: UIColor? = nil) {
        if let color = color {
            self.tabBar.tintColor = color
        }
        self.tabBar.tintColor = UserDefaults.standard.color(forKey: .buttonColor)
    }
    
    func setStartStep() {
        switch ud.stringArray(forKey: .startSteps)!.first {
        case "0":
            self.viewControllers![3].tabBarItem.badgeValue = "new"
            break
        case "1":
            self.viewControllers![3].tabBarItem.badgeValue = nil
            self.viewControllers![2].tabBarItem.badgeValue = "new"
            break
        case "2":
            self.viewControllers![2].tabBarItem.badgeValue = "new"
            break
        case "3":
            self.viewControllers![2].tabBarItem.badgeValue = nil
            self.viewControllers![0].tabBarItem.badgeValue = "new"
            break
        case "4":
            print(Account.mustCheckCount())
                self.viewControllers![2].tabBarItem.badgeValue = nil
                self.viewControllers![0].tabBarItem.badgeValue =
                    Account.mustCheckCount() == 0 ? nil : "\(Account.mustCheckCount())"
            break
        default:
            break
        }
    }
    
}
