//
//  NetworkTools.swift
//  练习-04-Swift AFN
//
//  Created by teacher on 16/2/24.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import AFNetworking

/// 网络请求枚举类型，Swift中的枚举可以指定不同的数据类型
enum CZRequestMethod: String {
    case GET = "GET"
    case POST = "POST"
}

class NetworkTools: AFHTTPSessionManager {
    
    // MARK: - 应用程序信息
    let appkey = "3749801249"
    let appSecret = "81b0bf80479524c5e6fc8d21b4d75d39"
    let redirectUri = "http://www.baidu.com"
    
    /// 单例
    static let sharedTools: NetworkTools = {
        let tools = NetworkTools(baseURL: nil)
        
        // 设置 AFN 的网络 `请求` 超时
        tools.requestSerializer.timeoutInterval = 15
        
        // 设置反序列化支持数据格式
        tools.responseSerializer.acceptableContentTypes?.insert("text/plain")
        // 将 JSON 中的 NULL 值过滤，有些第三方框架在做字典转模型时，如果遇到 NULL 值会崩溃！
        (tools.responseSerializer as! AFJSONResponseSerializer).removesKeysWithNullValues = true
        
        // 启动连接状态监听 - 通过通知中心发布的
        tools.reachabilityManager.startMonitoring()
        
        return tools
    }()
    
    deinit {
        // 停止连接状态监听
        reachabilityManager.stopMonitoring()
    }
    
    /// 判断当前网络是否能够连接
    var reachable: Bool {
        return reachabilityManager.reachable
    }
    
    /// 封装 AFN 方法发起网络请求
    ///
    /// - parameter method:     GET / POST
    /// - parameter URLString:  URLString
    /// - parameter parameters: 参数字典
    /// - parameter finished:   完成回调(json字典)
    func request(method: CZRequestMethod, URLString: String, parameters: [String: AnyObject]?, finished: (result: [String: AnyObject]?)->()) {
        
        // 回调方法的参数，可以从 AFN 的方法直接粘贴
        // 成功回调
        let success = { (task: NSURLSessionDataTask, responseObject: AnyObject?) -> Void in
            
            if let result = responseObject as? [String: AnyObject] {
                finished(result: result)
            } else {
                
                print("数据格式错误")
                finished(result: nil)
            }
        }
        // 失败回调
        let failure = { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            print("网络请求错误 \(error)")
            
            // 判断是否限制权限
            if let response = task?.response as? NSHTTPURLResponse where response.statusCode == 403 {
                // 清空 token
                UserAccount.sharedUserAccount.access_token = nil
                
                // 发送通知
                NSNotificationCenter.defaultCenter().postNotificationName(CZWeiBoAccessTokenInvalidNotification, object: nil)
            }
            
            finished(result: nil)
        }
        
        if method == .GET {
            // GET 请求
            GET(URLString, parameters: parameters, progress: nil, success: success, failure: failure)
        } else {
            // POST 请求
            POST(URLString, parameters: parameters, progress: nil, success: success, failure: failure)
        }
    }
    
    /// 上传文件
    func upload(URLString: String, parameters: [String: AnyObject]?, data: NSData, name: String, finished: (result: [String: AnyObject]?)->()) {
        
//        let formData: AFMultipartFormData
        /**
        参数
        
        1. data 要上传到服务器的二进制数据
        2. name 服务器指定上传数据的 `字段名`，在开发的时候，一定要咨询后台或者查阅文档，新浪微博 pic
        3. fileName 保存在服务器上的文件名，目前大多数公司的服务器接口，`文件名可以随便值`，后台接口会自动生成文件名
            后台接口，在接收到上传图片后，会生成缩略图／中等尺寸图／大图／原图
        4. mimeType 告诉服务器上传二进制数据的类型，与 contentType 等价
            格式：
                大类型/小类型
                text/plain
                text/html
                image/png
                image/jpg
                image/gif
                如果不知道准确的 mimeType，例如上传图片有 png／jpg／gif，可以直接使用二进制数据的 mimeType
                application/octet-stream
                application/json
        */
        POST(URLString, parameters: parameters, constructingBodyWithBlock: { (formData) -> Void in
            
            // 拼接上传的二进制数据
            formData.appendPartWithFileData(data, name: name, fileName: "helloworld", mimeType: "application/octet-stream")
            
            }, progress: nil, success: { (_, responseObject) -> Void in
                
                if let result = responseObject as? [String: AnyObject] {
                    finished(result: result)
                } else {
                    
                    print("数据格式错误")
                    finished(result: nil)
                }
                
            }) { (_, error) -> Void in
                
                print("网络请求错误 \(error)")
                finished(result: nil)
        }
    }
}

