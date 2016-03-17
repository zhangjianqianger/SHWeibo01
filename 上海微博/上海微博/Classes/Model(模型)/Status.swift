//
//  Status.swift
//  上海微博
//
//  Created by teacher on 16/2/27.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import YYModel

/// 微博模型 - 属性一定符合 KVC 的原则
class Status: NSObject {

    // 注意，不要使用 Int，在 32 位的机器上，是 int，会被截断
    /// 微博ID
    var id: Int64 = 0
    /// 微博信息内容
    var text: String?
    /// 微博创建时间
    var created_at: String?
    /// 微博来源
    var source: String?
    /// 微博作者的用户信息字段
    /**
        如果 OC 中定义，User *user;
    
        可以通过属性的 class，获取到对应 的 类，从而能够自动转换
    */
    var user: User?
    /// 被转发的原微博信息字段
    var retweeted_status: Status?
    /// 配图字典数组
    /**
        如果 OC 中定义数组，NSMutableArray *pic_urls; 数组中默认的数据类型 `id`
        字典转模型框架无法确认数组[容器 Container]内部元素的准确类型，因此无法自动转换！
    
        此特点，是所有 `字典转模型` 框架共有的，每个框架都有类似的解决方法
    */
    var pic_urls: [StatusPictures]?
    
    override var description: String {
        let keys = ["id", "text", "created_at", "source", "user", "pic_urls", "retweeted_status"]
        
        return dictionaryWithValuesForKeys(keys).description
    }
    
    // MARK: - YYModel 方法
    /**
        提示：如果在开发中，模型中存在包含自定义类的数组时，需要实现以下类函数
    
        作用：告诉框架，该数组中保存对象的 `类`
    */
//    class func modelContainerPropertyGenericClass() -> [String: AnyClass] {
//        return ["pic_urls": StatusPictures.self]
//    }
    
    class func modelContainerPropertyGenericClass() -> [String: AnyObject] {
        // 注意：在 Swift 中，完整的类名是 `项目名称(命名空间 namespace).类名`
        // 错误代码，不会崩溃，但是不能正常解析
        // return ["pic_urls": "StatusPictures"]
        // 一定注意：以下代码返回 nil
        // NSClassFromString("StatusPictures")
        return ["pic_urls": "上海微博.StatusPictures"]
    }
}
