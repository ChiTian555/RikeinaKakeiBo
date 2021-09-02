//
//  MainNC.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/14.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit

class MainNC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadColor()
    }
    
    func loadColor() {
        self.navigationBar.barStyle = .default
        self.navigationBar.tintColor = UserDefaults.standard.color(forKey: .buttonColor)
        let colorImage = UIImage.colorImage(color: UserDefaults.standard.color(forKey: .userColor))
        // ナビゲーションを透明にする処理
        self.navigationBar.setBackgroundImage(colorImage, for: .default)
        
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let colorImage = UIImage.colorImage(color: UserDefaults.standard.color(forKey: .userColor))
        self.navigationBar.setBackgroundImage(colorImage, for: .default)
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        super.view.layer.add(transition, forKey: "transition")
        super.pushViewController(viewController, animated: false)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        super.view.layer.add(transition, forKey: "transition")
        return super.popViewController(animated: false)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        
        if viewControllers.first != topViewController {
            let transition: CATransition = CATransition()
            transition.duration = 0.4
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromLeft
            super.view.layer.add(transition, forKey: "transition")
        }
        return super.popToRootViewController(animated: false)
        
    }
}

//extension UINavigationBar {
//    
//    var addHeight: CGFloat {
//        return 150
//    }
//    
//    open override func sizeThatFits(_ size: CGSize) -> CGSize {
//        //渡されるsizeは widthは決まっているがheightは決まっていない
//        //super.sizeThatFits(size)でheightが決まる
//        var newSize = super.sizeThatFits(size)
//        
//        //iphoneX用
//        var topInset:CGFloat = 0
//        if #available(iOS 11.0, *) {
//            topInset = superview?.safeAreaInsets.top ?? 0
//        }
//
//        newSize.height += addHeight + topInset  //通常よりどれだけ大きくするか
//        
//        return newSize
//    }
//    
//    open override func layoutSubviews() {
//        super.layoutSubviews()
//        if #available(iOS 11.0, *) {
//            for subview in self.subviews {
//                let stringFromClass = NSStringFromClass(subview.classForCoder)
//                if stringFromClass.contains("BarBackground") {
//                    //ステータスバー分あげないと余白ができる。
//                    let statusBarHeight = UIApplication.shared.statusBarFrame.height
//                    let point = CGPoint(x:0,y:-statusBarHeight)
//                    //ここでバーの高さを調節 (sizeThatFitsを呼び出す)
//                    subview.frame = CGRect(origin: point, size: sizeThatFits(self.bounds.size))
//                }else if stringFromClass.contains("BarContentView") {
//                    //ここでサブビューの位置を調整
//                    subview.frame.origin.y = addHeight
//                }
//            }
//        }
//    }
//}
