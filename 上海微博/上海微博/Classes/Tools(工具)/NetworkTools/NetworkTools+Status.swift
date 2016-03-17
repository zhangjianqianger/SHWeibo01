//
//  NetworkTools+Status.swift
//  上海微博
//
//  Created by teacher on 16/2/27.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

extension NetworkTools {
    
    /// 加载微博
    ///
    /// - parameter since_id: 若指定此参数，则返回ID比since_id `大` 的微博（即比since_id时间晚的微博），默认为0
    /// - parameter max_id:   若指定此参数，则返回ID `小于或等于` max_id的微博，默认为0
    /// - parameter finished: 完成回调(字典)
    func loadStatus(since_id since_id: Int64 = 0, max_id: Int64 = 0, finished: ([String: AnyObject]?)->()) {
        
        // 1. 判断 token 是否存在，如果不存在，用户没有登录
        guard let accessToken = UserAccount.sharedUserAccount.access_token else {
            assert(true, "登录之后才能加载微博数据")
            return
        }
        
        let urlString = "https://api.weibo.com/2/statuses/home_timeline.json"
        var params: [String: AnyObject] = ["access_token" : accessToken]
        
        // 判断下拉 id
        // Cannot assign value of type 'Int64' to type 'String?'
        // 在 Swift 中可以将 Int 类型自动转换成 NSNumber，添加到字典，但是 In64 不行，需要自己转换
        if since_id > 0 {
            params["since_id"] = NSNumber(longLong: since_id)
        }
        if max_id > 0 {
            params["max_id"] = NSNumber(longLong: max_id - 1)
        }
        
        request(.GET, URLString: urlString, parameters: params, finished: finished)
    }
    
    /// 发布微博
    ///
    /// - parameter text:     微博文本
    /// - parameter image:    微博图片(官方只支持一张图片上传)，如果为 nil，发布文本微博／否则上传图片
    /// - parameter finished: 完成回调
    func postStatus(text: String, image: UIImage?, finished:(result: [String: AnyObject]?) -> ()) {
        
        // 1. 判断 token 是否存在，如果不存在，用户没有登录
        guard let accessToken = UserAccount.sharedUserAccount.access_token else {
            assert(true, "登录之后才能加载微博数据")
            return
        }
        
        let params = ["access_token": accessToken, "status": text]
        
        // 2. 根据 image == nil 发布文本微博
        if image == nil {
            
            let urlString = "https://api.weibo.com/2/statuses/update.json"
            
            request(.POST, URLString: urlString, parameters: params, finished: finished)
        } else {
         
            let urlString = "https://upload.api.weibo.com/2/statuses/upload.json"
            
            // 将图像转换成二进制数据
            let data = UIImagePNGRepresentation(image!)
            
            upload(urlString, parameters: params, data: data!, name: "pic", finished: finished)
        }
    }
}