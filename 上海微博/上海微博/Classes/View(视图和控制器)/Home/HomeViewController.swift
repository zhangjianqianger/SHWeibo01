//
//  HomeViewController.swift
//  上海微博
//
//  Created by teacher on 16/2/21.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import YYModel
import AFNetworking
import SVProgressHUD
import QorumLogs
import HMPhotoBrowser

/// 微博 Cell 可重用标识符号
private let CZStatusCellID = "CZStatusCellID"
/// 微博提示 Cell 可重用标识符号
private let CZStatusTipCellID = "CZStatusTipCellID"

class HomeViewController: RootViewController {

    override func viewDidLoad() {
        QL2("我加载了...")
        
        // 设置刷新控件
        setupRefreshControl()

        // 调用 RootViewController 的 viewDidLoad 函数，会直接调用 loadData
        super.viewDidLoad()
        
        prepareTableView()
        
        // 设置访客视图信息 - 如果用登录成功，访客视图为 nil，什么也不做！
        visitorView?.setupInfo(message: "关注一些人，回这里看看有什么惊喜")
        
        // 注册网络连接监听
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "reachabilityChanged",
            name: AFNetworkingReachabilityDidChangeNotification,
            object: nil)
        // 注册选中照片通知
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "selectedPhoto:",
            name: CZStatusPicturesViewDidSelectedNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "clickURLtext:",
            name: CZStatusCellDidClickURLNotification,
            object: nil)
    }
    
    /// 准备表格视图
    private func prepareTableView() {
        // 注册可重用 cell
        tableView?.registerClass(StatusCell.self, forCellReuseIdentifier: CZStatusCellID)
        tableView?.registerClass(StatusTipCell.self, forCellReuseIdentifier: CZStatusTipCellID)
        
        // 取消分隔线
        tableView?.separatorStyle = .None
    }
    
    deinit {
        // 注销通知 - 在控制器被销毁执行。目前的程序，会在应用程序销毁时销毁，可以不写！
        // 但是从代码逻辑和习惯上，建议保留！
        // 在注销通知的时候，如果指定名称，可以注销名称对应的通知，否则，会注销所有注册过的通知！
//        NSNotificationCenter.defaultCenter().removeObserver(
//            self,
//            name: AFNetworkingReachabilityDidChangeNotification,
//            object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    /// 接收到内存警告！
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // On iOS 6.0 it will no longer clear the view by default.
        // 在 iOS 6.0 之后，默认不再清除 view，再 iOS 6.0 之前，收到内存警告后
        // `如果视图当前没有显示`，会被从内存中销毁，下次需要使用的时候，会再次调用 loadView 创建 view
        // 只需要释放能够被再次创建的资源，例如：从网络加载的数据数组
        // 图像的内存管理 SDWebImage 自行管理，会释放内存中的图像，下次使用，会重新从磁盘缓存加载，如果瓷盘缓存没有，下载图片
        
        print("Home 的 window \(self.view.window)")
        // 如果视图当前正在显示，window 不为nil
        // 注意：Swift 中 lazy 的属性 ** 千万不要设置成 nil！！！
        if self.view.window == nil {
            // 1. 清理数组
            // self.listViewModel.statusList.removeAll()
            self.listViewModel.cleanup()
            
            // 2. 刷新数据
            self.loadData()
        }
    }
    
    // MARK: - 监听方法
    @objc private func clickURLtext(notification: NSNotification) {
    
        print(notification.object)
        guard let urlString = notification.object as? String,
            url = NSURL(string: urlString) else {
                return
        }
        
        let webVC = StatusWebViewController()
        webVC.url = url
        
        webVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    /// 选中照片通知方法
    @objc private func selectedPhoto(notificatin: NSNotification) {
//        print(notificatin)
        guard let selectedIndex = notificatin.userInfo?[CZStatusPicturesViewSelectedIndexKey] as? Int else {
            return
        }
        guard let urls = notificatin.userInfo?[CZStatusPicturesViewURLsKey] as? [String] else {
            return
        }
        guard let imageViews = notificatin.userInfo?[CZStatusPicturesViewImageViewsKey] as? [UIImageView] else {
            return
        }
        
        // 展现控制器
        let browser = HMPhotoBrowserController.photoBrowserWithSelectedIndex(
            selectedIndex,
            urls: urls,
            parentImageViews: imageViews)        
//        PhotoBrowserController(selectedIndex: selectedIndex,
//            urls: urls,
//            releatedImageViews: imageViews)
        
        presentViewController(browser, animated: true, completion: nil)
    }
    
    /// 网路连接状态监听方法
    @objc private func reachabilityChanged() {
        // 刷新表格的第一个分组
        self.tableView?.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    }
    
    /// 加载数据
    override func loadData() {
        
        // 1. 判断是否是上拉刷新，如果上拉刷新动画启动，认为是上拉刷新
        let isPullup = refreshControl?.isPullupRefresh ?? false
        
        // 显示刷新控件
        refreshControl?.beginRefreshing()
        
        // 加载数据
        listViewModel.loadStatus(isPullup) { (isSuccessed) -> () in
            
            print("加载数据完成")
            
            // 结束刷新
            self.refreshControl?.endRefreshing()
            
            // 判断网络请求是否成功
            if !isSuccessed {
                SVProgressHUD.showInfoWithStatus("您的网络不给力")
                
                return
            }
            // 刷新数据
            self.tableView?.reloadData()
            
            // 显示下拉刷新提示
            self.showPulldownTip()
        }
    }
    
    /// 显示下拉刷新提示
    private func showPulldownTip() {
        
        guard let count = listViewModel.pulldownCount else {
            return
        }
        
        // count 一定是刷新得到的数据！
        let message = count > 0 ? "刷新到 \(count) 条微博" : "没有新微博"
        
        pulldownTipLabel.text = message
        let rect = pulldownTipLabel.frame
        
        // 动画效果
        let duration: NSTimeInterval = 1.2
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.pulldownTipLabel.frame = CGRectOffset(rect, 0, 3 * rect.height)
            }) { (_) -> Void in
                UIView.animateWithDuration(duration) {
                    self.pulldownTipLabel.frame = rect
                }
        }
    }
    
    // MARK: - 私有属性
    /// 微博列表视图模型
    private lazy var listViewModel = StatusListViewModel()
    private lazy var pulldownTipLabel: UILabel = {
       
        let label = UILabel(cz_text: "", fontSize: 18, color: UIColor.whiteColor(), alignment: .Center)
        label.backgroundColor = UIColor.orangeColor()

        let rect = CGRect(x: 0, y: 64, width: self.view.bounds.width, height: 44)
        
        label.frame = CGRectOffset(rect, 0, -3 * rect.height)
        
        // 提示：如果是 tableViewController label 需要添加到 nav.NavigationBar 的底层视图
        // 使用 window 是 iOS 6.0 的时代，很常用的做法！
        // 提示：如果当前视图的资源不可用，从`内向外`，找办法！建议所有的控制器都是 `UIViewController`
        self.view.addSubview(label)
        
        return label
    }()
}

// extension 本身是对本类的一个扩展，方法的优先级相对较低，本质上，应该不隶属于本类
// MARK: - UITableViewDataSource
// Redundant conformance of 'HomeViewController' to protocol 'UITableViewDataSource'
// 如果父类已经遵守协议，子类不用再次遵守协议，否则会报 重复遵守协议 错误
extension HomeViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    /// 重写数据源方法
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 分组 0 对应的是提示 cell，如果（网络连接没有）需要提示，才返回 1
        if section == 0 {
            return NetworkTools.sharedTools.reachable ? 0 : 1
        }
        
        // 分组 1 对应正常的微博 cell
        return listViewModel.statusList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 分组 0 对应的是提示 cell
        if indexPath.section == 0 {
            return tableView.dequeueReusableCellWithIdentifier(CZStatusTipCellID, forIndexPath: indexPath)
        }
        
        // 分组 1，对应正常的微博 Cell
        let cell = tableView.dequeueReusableCellWithIdentifier(CZStatusCellID, forIndexPath: indexPath) as! StatusCell
        
        // 设置视图模型
        cell.viewModel = listViewModel.statusList[indexPath.row]
        
        return cell
    }
    
    /// 返回行高属性
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // 分组 0 返回默认行高
        if indexPath.section == 0 {
            return 44
        }
        
        // 返回视图模型的行高属性
        return listViewModel.statusList[indexPath.row].rowHeight
    }
}
