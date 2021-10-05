//
//  MainNC.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2020/09/14.
//  Copyright © 2020 net.Chee-Saga. All rights reserved.
//

import UIKit

class MainNC: UINavigationController {
    
    private let ud = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        loadColor()
    }
    
    func loadColor() {
        let app = UINavigationBarAppearance()
        app.backgroundColor = .user
//        navigationBar.setBackgroundImage(colorImage, for: .default)
        navigationBar.standardAppearance = app
        navigationBar.scrollEdgeAppearance = app
        navigationBar.tintColor = .button
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
