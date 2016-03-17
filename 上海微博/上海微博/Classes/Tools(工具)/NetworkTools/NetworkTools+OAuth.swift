//
//  NetworkTools+OAuth.swift
//  上海微博
//
//  Created by teacher on 16/2/24.
//  Copyright © 2016年 itcast. All rights reserved.
//

import Foundation

/// 网络工具 - 身份授权部分
extension NetworkTools {
    
    /// 返回身份验证 URL
    /**
        1. 没有参数，只有返回值的函数，在调用的时候，有一个 ()
        2. 使用计算型属性，直接返回某一个类型的结果
        3. 计算型属性不能接参数
        4. 阅读的语义会更好！
    */
    //func oauthURL() -> NSURL {
    var oauthURL: NSURL {
        
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(appkey)&redirect_uri=\(redirectUri)"
        
        return NSURL(string: urlString)!
    }
    
    /// 加载 access token + token 成功之后，直接加载用户数据
    ///
    /// - parameter code:     code 授权码
    /// - parameter finished: 完成回调 (字典)
    func loadAccessToken(code: String, finished: ([String: AnyObject]?)->()) {
        
        let urlString = "https://api.weibo.com/oauth2/access_token"
        
        let params = ["client_id": appkey,
            "client_secret": appSecret,
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectUri]
        
        request(.POST, URLString: urlString, parameters: params) {[weak self] result in
            
            // result 是 token 的结果字典，是可选的！
            // 如果要使用 key 从字典中取值，必须保证字典存在
            guard let result = result,
                let access_token = result["access_token"] as? String,
                let uid = result["uid"] as? String else {
                    
                    print("数据格式不正确")
                    
                    // 一定要完成回调，通知调用方请求失败
                    finished(nil)
                    return
            }
            
            // 继续加载用户数据
            self?.loadUser(access_token, uid: uid, finished: { (userDict) -> () in                
                // 合并字典
                // 1> 判断用户字典是否有值
                guard var userDict = userDict else {
                    print("用户数据加载错误")
                    
                    finished(nil)
                    return
                }
                
                // 2> 合并字典
                for (k, v) in result {
                    userDict[k] = v
                }
                
                // 3> 完成回调
                finished(userDict)
            })
        }
    }
}
