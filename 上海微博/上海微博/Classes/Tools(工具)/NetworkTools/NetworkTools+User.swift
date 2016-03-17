//
//  NetworkTools+User.swift
//  上海微博
//
//  Created by teacher on 16/2/25.
//  Copyright © 2016年 itcast. All rights reserved.
//

import Foundation

// MARK: - 网络工具 - 用户接口
extension NetworkTools {
    
    /// 加载用户信息
    ///
    /// - parameter access_token: access_token
    /// - parameter uid:          uid
    /// - parameter finished:     完成回调(字典)
    func loadUser(access_token: String, uid: String, finished: ([String: AnyObject]?)->()) {
        
        // 连接到的网络地址，想象：一个网络服务器对象提供的`函数`
        let urlString = "https://api.weibo.com/2/users/show.json"
        
        // 想像成给网络服务器函数传递的参数，以字典的格式传递
        let params = ["access_token": access_token, "uid": uid]
        
        // 发起网络请求，`异步`调用函数，通过闭包/block的参数获得函数执行的结果
        request(.GET, URLString: urlString, parameters: params, finished: finished)
    }
}