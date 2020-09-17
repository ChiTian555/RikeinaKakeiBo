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
        
        self.navigationBar.barStyle = .default
        let colorImage = UIImage.colorImage(color: UIColor.systemOrange.withAlphaComponent(0.7))
        // ナビゲーションを透明にする処理
        self.navigationBar.setBackgroundImage(colorImage, for: .default)

        
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
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
}
