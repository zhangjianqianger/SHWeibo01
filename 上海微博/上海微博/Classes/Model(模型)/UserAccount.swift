//
//  UserAccount.swift
//  上海微博
//
//  Created by teacher on 16/2/25.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

/// 用户账户 Key
private let CZWeiboUserAccountKey = "cn.itcast.userAccount"

class UserAccount: NSObject {
    
    /// 用户账户单例，全局入口
    static let sharedUserAccount = UserAccount()
    
    /// 用户登录标记
    var isLogin: Bool {
        return access_token != nil
    }
    
    /// 用于调用access_token，接口获取授权后的access token
    var access_token: String?
    /// access_token的生命周期，单位是秒数，`string`
    /// 在设置 expires_in 属性的同时，计算出过期日期
    /// 从创建应用程序开始计算！
    var expires_in: NSTimeInterval = 0 {
        didSet {
            // 计算过期日期
            expiresDate = NSDate(timeIntervalSinceNow: expires_in)
        }
    }
    /// 过期日期
    var expiresDate: NSDate?
    /// 当前授权用户的UID
    var uid: String?
    /// 用户昵称
    var screen_name: String?
    /// 用户头像地址（大图），180×180像素
    var avatar_large: String?
    
    // MARK: - 构造函数
    // 提示：如果在 init 增加 private 修饰符，可以限制外界通过 () 直接创建对象！
    private override init() {
        super.init()
        
        loadUserAccount()
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    /// 类似于 java 的 toString()，在 java 的开发团队是必须要求重写的，便于调试！
    /// iOS 团队，没有硬性要求，建议`模型类`一定重写，理由同上！
    override var description: String {
        // 模型转字典
        let keys = ["access_token", "uid", "expires_in", "expiresDate", "screen_name", "avatar_large"]
        
        return dictionaryWithValuesForKeys(keys).description
    }
}

// MARK: - 加载和保存用户账户
extension UserAccount {
    
    /// 使用字典更新 模型 数据
    ///
    /// - parameter dict: 字典
    func updateUserAccount(dict: [String: AnyObject]) {
        setValuesForKeysWithDictionary(dict)
        
        saveUserAccount()
    }
    
    /// 将当前用户`账户`保存在用户偏好
    private func saveUserAccount() {
        
        // 1. 模型转字典
        let keys = ["access_token", "uid", "expiresDate", "screen_name", "avatar_large"]
        let dict = dictionaryWithValuesForKeys(keys)
        
        // 2. 将字典写入偏好
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey: CZWeiboUserAccountKey)
        print(NSHomeDirectory())
    }
    
    /// 加载用户账户
    private func loadUserAccount() {
        
        // 1. 从用户偏好加载（从磁盘加载）
        // 内存读写速度比磁盘快！
        guard let dict = NSUserDefaults.standardUserDefaults().objectForKey(CZWeiboUserAccountKey) as? [String: AnyObject] else {
            return
        }
        
        // 2. 字典转模型
        setValuesForKeysWithDictionary(dict)
        
        // 3. 判断是否过期，如果过期，将 token 设置为 nil
        // 测试过期日期
        // expiresDate = NSDate(timeIntervalSinceNow: -24 * 60 * 60)
        if isExpired {
            print("token 已经过期")
            access_token = nil
        } else {
            print("token 正常")
        }
    }
    
    /// 判断是否过期
    private var isExpired: Bool {
        // 将过期日期和当前系统日起进行比较
        // 举个栗子
        // 2016-01-01
        // 2016-02-15
        // 2016-12-30
        return expiresDate?.compare(NSDate()) == NSComparisonResult.OrderedAscending
    }
}
