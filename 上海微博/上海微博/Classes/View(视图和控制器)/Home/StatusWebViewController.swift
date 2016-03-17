//
//  StatusWebViewController.swift
//  上海微博
//
//  Created by teacher on 16/3/15.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import WebKit

class StatusWebViewController: UIViewController {

    private lazy var webView = WKWebView()
    var url: NSURL?
    
    override func loadView() {
        view = webView
        
        title = "网页"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = url else {
            return
        }
        
        webView.loadRequest(NSURLRequest(URL: url))
    }
}
