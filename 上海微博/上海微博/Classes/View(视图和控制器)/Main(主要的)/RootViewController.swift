//
//  RootViewController.swift
//  上海微博
//
//  Created by teacher on 16/2/22.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import HMRefresh

/// 根视图控制器-其他主控制器的基类
class RootViewController: UIViewController {

    // MARK: - 公共属性
    /// 表格视图
    var tableView: UITableView?
    /// 刷新控件
    var refreshControl: HMRefreshControl?
    /// 访客视图 - 如果用户登录成功，就不需要创建访客视图
    var visitorView: VisitorView?
    
    // MARK: - 视图生命周期
    override func loadView() {
        
        // 1. 创建根视图
        view = UIView()
        
        // 2. 用户登录显示 tableView ／ 否则显示访客视图
        UserAccount.sharedUserAccount.isLogin ? setupTableView() : setupVisitorView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 如果没有登录注册通知
        if UserAccount.sharedUserAccount.isLogin {
            loadData()
        } else {
            NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: "loginSuccessed",
                name: CZWeiBoLoginSuccessedNotification,
                object: nil)
        }
        // 监听 token 是否失效
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "tokenInvalid",
            name: CZWeiBoAccessTokenInvalidNotification,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /// 加载数据 - 真正的数据加载，应该放在子类中实现
    func loadData() {
        
    }
    
    /// Token 失效监听方法
    @objc private func tokenInvalid() {
        delay() {
            self.visitorViewDidLogin()
        }
    }
    
    /// 登录成功监听方法
    @objc private func loginSuccessed() {
        view = nil
        
        // 注销通知
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CZWeiBoLoginSuccessedNotification, object: nil)
    }
}

// MARK: - VisitorViewDelegate
extension RootViewController: VisitorViewDelegate {
    
    func visitorViewDidRegister() {
        print("注册")
    }
    
    func visitorViewDidLogin() {
        let oauthVC = OAuthViewController()
        let nav = UINavigationController(rootViewController: oauthVC)
        
        presentViewController(nav, animated: true, completion: nil)
    }
}

// MARK: - 设置界面
extension RootViewController {
    
    /// 设置访客视图
    private func setupVisitorView() {
        visitorView = VisitorView()
        
        view.addSubview(visitorView!)
        
        // 自动布局
        visitorView?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(view)
        })
        
        // 设置代理
        visitorView?.delegate = self
        
        // 设置状态栏按钮 - 如果换行参数，一定保证一个参数一行
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "注册",
            style: .Plain,
            target: self,
            action: "visitorViewDidRegister")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "登录",
            style: .Plain,
            target: self,
            action: "visitorViewDidLogin")
    }
    
    /// 设置表格视图
    private func setupTableView() {
        tableView = UITableView(frame: CGRectZero, style: .Plain)
        
        view.addSubview(tableView!)
        
        // 自动布局－让子视图和根视图同样大小！
        tableView?.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }
        
        // 设置数据源
        tableView?.dataSource = self
        tableView?.delegate = self
    }
    
    /// 设置刷新控件
    /// 需要刷新控件的子控制器单独调用 `setupRefreshControl`
    /// 私有函数不能被子类`继承`
    func setupRefreshControl() {
        // 如果 tableView 不存在，直接返回
        guard let tableView = tableView else {
            return
        }
        
        // 默认没有刷新控件，但是，如果 `刷新控件` 已经存在，不需要再次添加
        if refreshControl != nil {
            return
        }
        
        refreshControl = HMRefreshControl()
        tableView.addSubview(refreshControl!)
        
        // 设置下拉刷新视图
        refreshControl?.pulldownView = CZPulldownRefreshView.refreshView()
        refreshControl?.normalString = "下拉起飞"
        refreshControl?.pullingString = "放开起飞"
        refreshControl?.refreshingString = "正在起飞"
        refreshControl?.lastRefreshString = "末次 "
        refreshControl?.donotPullupString = "没有更多数据"
        
        // 设置刷新控件的监听方法
        refreshControl?.addTarget(self, action: "loadData", forControlEvents: .ValueChanged)
    }
}

extension RootViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
