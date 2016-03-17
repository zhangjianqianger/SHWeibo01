//
//  Common.swift
//  上海微博
//
//  Created by teacher on 16/2/24.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

// MARK: - 定义全局共享参数，类似于 OC 的 PCH
/// 全局外观渲染颜色
let CZAppearanceTintColor = UIColor.orangeColor()

/// 登录成功通知
let CZWeiBoLoginSuccessedNotification = "CZWeiBoLoginSuccessedNotification"
/// Token失效通知
let CZWeiBoAccessTokenInvalidNotification = "CZWeiBoAccessTokenInvalidNotification"

// MARK: - 全局函数
/// 延迟 delta 执行 block
func delay(delta: NSTimeInterval = 1.0, block: ()->()) {
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * delta)),
        dispatch_get_main_queue(), { () -> Void in
            
            // 执行 block
            block()
    })
}