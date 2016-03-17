//
//  OAuthViewController.swift
//  上海微博
//
//  Created by teacher on 16/2/24.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import SVProgressHUD

/// 身份验证控制器
class OAuthViewController: UIViewController {

    private lazy var webView = UIWebView()
    
    // MARK: - 视图生命周期
    override func loadView() {
        view = webView
        
        // 设置导航栏
        title = "登录新浪微博"
        //navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(16)]
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "取消",
            style: .Plain,
            target: self,
            action: "clickCloseButton")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "自动填充",
            style: .Plain,
            target: self,
            action: "clickAutoFillButton")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 在纯代码开发中，所有的 view 都要指定背景颜色
        view.backgroundColor = UIColor.whiteColor()
        
        // 加载授权 URL
        webView.loadRequest(NSURLRequest(URL: NetworkTools.sharedTools.oauthURL))
        
        // 设置代理
        webView.delegate = self
    }
    
    // MARK: - 监听方法
    @objc private func clickCloseButton() {
        SVProgressHUD.dismiss()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// 自动填充用户信息
    @objc private func clickAutoFillButton() {
        
        let js = "document.getElementById('userId').value='daoge10000@sina.cn';" +
        "document.getElementById('passwd').value='qqq123';"
        
        // 执行 js
        webView.stringByEvaluatingJavaScriptFromString(js)
    }
}

// MARK: - UIWebViewDelegate
extension OAuthViewController: UIWebViewDelegate {
 
    /// 将要开始加载请求，每次加载新的页面时，都会被调用，执行当前页面的js不会被调用
    ///
    /// - parameter webView:        webView
    /// - parameter request:        request
    /// - parameter navigationType: 导航类型
    ///
    /// - returns: 是否加载，通常在 iOS 的 代理方法中，如果返回 BOOL，通常返回 YES，一切 OK，返回 NO，不正常执行
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // 1. 如果 URL 不是 回调地址，就继续加载页面
        // absoluteString 是 URL 的完整字符串
        // hasPrefix 前面的对象必须保证不为 nil
//        if let urlString = request.URL?.absoluteString {
//            if !urlString.hasPrefix(NetworkTools.sharedTools.redirectUri) {
//                return true
//            }
//        }
        // 提示: where 字句没有智能提示，需要先写好再复制
        if let urlString = request.URL?.absoluteString
            where !urlString.hasPrefix(NetworkTools.sharedTools.redirectUri) {
                
                return true
        }
        
        // 2. 否则判断回调参数，如果授权成功 URL 的`查询字符串`中包含 code 参数
        // query 是 URL `?` 后面所有的内容
        // 1> 判断 query 中是否有 code=
        guard let query = request.URL?.query where query.hasPrefix("code=") else {
            print("取消授权")
            dismissViewControllerAnimated(true, completion: nil)
            
            return false
        }
        
        print("请求字符串 " + query)
        
        // 2> 获得请求码
        let code = query.substringFromIndex("code=".endIndex)
        print("请求码 = \(code)")
        
        // 3> 发起网络请求，做后续操作
        NetworkTools.sharedTools.loadAccessToken(code) { (result) -> () in
            
            guard let result = result else {
                print("您的网络不给力")
                return
            }
            
            // 设置用户账户单例的数据
            UserAccount.sharedUserAccount.updateUserAccount(result)
            
            // 登录成功
            // 1> 通知代理工作
            NSNotificationCenter.defaultCenter().postNotificationName(CZWeiBoLoginSuccessedNotification, object: nil)
            
            SVProgressHUD.showInfoWithStatus("登录成功")
            
            delay() {
                // 2> 关闭视图控制器
                self.clickCloseButton()
            }
        }
        
        return false
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
}
