//
//  User.swift
//  上海微博
//
//  Created by teacher on 16/2/27.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

/// 用户数据模型
class User: NSObject {
    
    /// 用户UID
    var id: Int64 = 0
    /// 用户昵称
    var screen_name: String?
    /// 用户头像地址（中图），50×50像素
    var profile_image_url: String?
    /// 认证类型，-1：没有认证，0，认证用户，2,3,5: 企业认证，220: 达人
    var verified_type: Int = 0
    /// 会员等级 0-6
    var mbrank: Int = 0
    
    override var description: String {
        let keys = ["id", "screen_name", "profile_image_url", "verified_type", "mbrank"]
        
        return dictionaryWithValuesForKeys(keys).description
    }
}
