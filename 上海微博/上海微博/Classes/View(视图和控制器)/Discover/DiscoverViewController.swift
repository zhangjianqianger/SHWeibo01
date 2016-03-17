//
//  DiscoverViewController.swift
//  上海微博
//
//  Created by teacher on 16/2/21.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

/// Cell 的可重用标识符号
private let CZDiscoverCellID = "CZDiscoverCellID"

/// 发现控制器
class DiscoverViewController: RootViewController {

    override func viewDidLoad() {
        // 设置刷新控件
        setupRefreshControl()
        
        super.viewDidLoad()

        // 注册可重用 cell
        tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: CZDiscoverCellID)
        
        // 设置访客视图
        visitorView?.setupInfo("visitordiscover_image_message",
            message: "登录后，最新、最热微博尽在掌握，不再会与实事潮流擦肩而过")
    }

    override func loadData() {
        
        // 开始刷新
        refreshControl?.beginRefreshing()
        
        /**
         参数
         1. 现在
         2. 时间差：纳秒／秒
        */
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 1.0))
        dispatch_after(when, dispatch_get_main_queue()) { () -> Void in
            
            self.dataCount += 10
            
            // 结束刷新
            self.refreshControl?.endRefreshing()
            
            self.tableView?.reloadData()
        }
    }

    // MARK: - 私有属性
    private var dataCount = 0
}

// MARK: - 数据源方法
extension DiscoverViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataCount
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CZDiscoverCellID, forIndexPath: indexPath)
        
        cell.textLabel?.text = "\(indexPath.row)"
        
        return cell
    }
}
