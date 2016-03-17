//
//  NSBundle+Extension.swift
//  上海微博
//
//  Created by teacher on 16/2/25.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

extension NSBundle {
    
    /** 获取当前版本号字符串，格式 010.010.010
     
     版本号：主版本号.次版本号.修订版本号
     主版本号: 通常是大的功能改变，甚至使用方式都会发生变化
     - AFN 1.0   AppClient 单例
     - AFN 2.0   对 NSURLConnection / NSURLSession 的封装 2014 年初
     - AFN 3.0   删除了 NSURLConnection，增加了进度回调 2015 年底
     次版本号: 通常会有些函数的参数格式会发生变化，如果第三方框架的使用者，可能会小幅度修改程序
     修订版本号: 内部 bug 修改，对接口没有任何影响
     
     1.2.3
     1.2.10
     
     解决办法: 版本号只能升，不能降，只要版本号不同，就可以当成新版本
     */
    class var cz_currentVersion: String {
        return NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }
    
    /// 获取当前设备对应的启动图片
    class var cz_launchImageView: UIImage? {
        
        guard let images = NSBundle.mainBundle().infoDictionary?["UILaunchImages"] as? [[String: String]] else {
            return nil
        }
        
        // 根据屏幕尺寸过滤数组
        let result = images.filter { (dict) -> Bool in
            let imageSize = CGSizeFromString(dict["UILaunchImageSize"]!)
            let orientation = dict["UILaunchImageOrientation"]!
            
            return orientation == "Portrait" && CGSizeEqualToSize(imageSize, UIScreen.mainScreen().bounds.size)
        }
        
        // 获取图像名称
        guard let imageName = result.first?["UILaunchImageName"] else {
            return nil
        }
        
        return UIImage(named: imageName)
    }
}