//
//  AppDelegate.swift
//  上海微博
//
//  Created by teacher on 16/2/21.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import AFNetworking
import QorumLogs

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        QorumLogs.enabled = true
        // 设置仅输出某一个文件的调试信息
        // QorumLogs.onlyShowThisFile("HomeViewController")
        
        QL2(UserAccount.sharedUserAccount)
        QL1(SQLiteManager.sharedManager)
        
        setupAFNetworking()
        // 设置外观应该尽量早
        setupAppearance()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        
        // 会将控制器的视图添加为 window 的子视图
        window?.rootViewController = MainViewController()
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    /// 应用程序进入后台
    func applicationDidEnterBackground(application: UIApplication) {
        StatusDAL.cleanDatabaseCache()
    }
}

// MARK: - 设置应用程序
extension AppDelegate {
    
    /// 设置 AFN
    private func setupAFNetworking() {
        
        // 1. 设置网络指示器 - 如果 SDWebImage 下载图像不会显示！
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
        
        // 2. 设置缓存大小 - diskPath: nil 会使用系统默认的缓存路径
        // AFN 使用系统默认的缓存路径 `MATTT`，但是，如果图片太大或者太小，NSURLCache 都不会缓存
        NSURLCache.setSharedURLCache(
            NSURLCache(
                memoryCapacity: 4 * 1024 * 1024,
                diskCapacity: 20 * 1024 * 1024,
                diskPath: nil))
    }
    
    /// 设置全局外观，一经设置全局有效
    private func setupAppearance() {
        UINavigationBar.appearance().tintColor = CZAppearanceTintColor
        UITabBar.appearance().tintColor = CZAppearanceTintColor
        
        // 设置导航栏标题字体
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(16)]
    }
}

