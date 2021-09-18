//
//  BrowserVC.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2021/09/18.
//  Copyright © 2021 net.Chee-Saga. All rights reserved.
//

import UIKit
import WebKit

class BrowserVC: UIViewController {
    
    private let ud = UserDefaults.standard
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    var observation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 7 URLオブジェクトを生成
        let myURL = URL(string:"https://qiita.com/IkeMoMo/private/be9f2b67d27e78d01bd9")
        // 8 URLRequestオブジェクトを生成
        let myRequest = URLRequest(url: myURL!)

        // 9 URLを WebView にロード
        webView.load(myRequest)
        
        progressView.progressTintColor = ud.color(forKey: .buttonColor)
        observation = webView.observe(\.estimatedProgress, options: .new){_, change in
            self.progressView.setProgress(Float(change.newValue!), animated: true)
            if change.newValue! >= 1.0 {
                    UIView.animate(withDuration: 1.0,
                                   delay: 0.0,
                                   options: [.curveEaseIn],
                                   animations: { self.progressView.alpha = 0.0 },
                                   completion: { (finished: Bool) in
                        self.progressView.setProgress(0, animated: false)
                    })
            } else { self.progressView.alpha = 1.0 }
        }

    }
    
    @IBAction func endBrowse(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
