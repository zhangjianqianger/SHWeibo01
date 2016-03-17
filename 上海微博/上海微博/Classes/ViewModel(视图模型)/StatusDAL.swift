//
//  StatusDAL.swift
//  上海微博
//
//  Created by teacher on 16/3/14.
//  Copyright © 2016年 itcast. All rights reserved.
//

import Foundation
import QorumLogs

/// 数据缓存时间
private let CZDatabaseCacheTime: NSTimeInterval = -60 //-24 * 60 * 60

/// 微博数据数据访问层，负责底层数据[网络／数据库的操作]
class StatusDAL {
    
    /// 清理数据库缓存
    /**
        关于数据库的清除：
    
        1. 一定要定期删除数据
        2. SQLite 的数据库，随着数据的增加，文件会不断变大，即使清除数据，数据库的文件也不会变小
        3. 数据库最重要的是 `检索`
        4. 不要把 图片／音频／视频 放在数据库中
            - 将无法检索的文件保存在 cache 目录中，数据库中存放 `URL` 或者文件路径即可
            - 例如：SDWebImage / YYWebImage 可以通过 URL 直接找到本地的缓存文件，不需要上网下载
    */
    class func cleanDatabaseCache() {
        
        // 1. 获得当前系统时间对应的`差值`日期字符串
        let dateStr = NSDate.cz_dateStringWithDelta(CZDatabaseCacheTime)
        
        // 2. 生成 SQL - 提示：在写 删除 SQL 的时候，一定一定一定，使用 `SELECT`，因为没有 undo
        // 调试完成后，将 SELECT * 修改为 DELETE
        let sql = "DELETE FROM T_Status WHERE createTime < ?;"
        
        // 3. 执行 SQL
        SQLiteManager.sharedManager.queue.inDatabase { (db) -> Void in
            
            _ = try? db.executeUpdate(sql, values: [dateStr])
            
            QL2("删除了 \(db.changes()) 条记录")
        }
    }
    
    /// 加载`本地数据库`或者`网络数据`
    ///
    /// - parameter since_id: 下拉刷新 id
    /// - parameter max_id:   上拉刷新 id
    /// - parameter finished: 完成回调[字典数组]
    class func loadStatus(since_id: Int64, max_id: Int64, finished:(result: [[String: AnyObject]]?, isSuccessed: Bool)->()) {
        
        // 1. 检查本地是否有数据
        let array = checkDBCache(since_id, max_id: max_id)
        
        // 2. 如果有数据，直接返回
        if array.count > 0 {
            finished(result: array, isSuccessed: true)
            
            return
        }
        
        // 3. 如果没有数据，发起网络请求
        NetworkTools.sharedTools.loadStatus(since_id: since_id, max_id: max_id) { (result) -> () in
            
            guard let array = result?["statuses"] as? [[String: AnyObject]] else {
                
                finished(result: nil, isSuccessed: false)
                return
            }
            
            // 4. 网络请求结束后，将网络的字典数组保存到数据库
            self.saveWebData(array)
            
            // 5. 返回字典数组
            finished(result: array, isSuccessed: true)
        }
    }
    
    /// 检查本地`缓存数据`
    private class func checkDBCache(since_id: Int64, max_id: Int64) -> [[String: AnyObject]] {
        
        guard let userId = UserAccount.sharedUserAccount.uid else {
            QL4("用户没有登录")
            
            return []
        }

        // 强烈建议，拼接字符串末尾 \n，便于调试，便于阅读！
        var sql = "SELECT statusId, userId, status FROM T_Status \n"
        sql += "WHERE userId = \(userId) \n"
        
        // 下拉／上拉刷新
        if since_id > 0 {
            sql += "AND statusId > \(since_id) \n"
        } else if max_id > 0 {
            sql += "AND statusId < \(max_id) \n"
        }
        
        sql += "ORDER BY statusId DESC LIMIT 20;"
        
        // 重要：测试 SQL 的正确性！
        QL1(sql)
        
        // 执行 SQL 生成数据
        let array = SQLiteManager.sharedManager.execRecordset(sql)
        
        // array 是数据库返回的查询结果，需要将 status 字段内容，反序列化成`字典`
        var arrayM = [[String: AnyObject]]()
        
        for dict in (array ?? []) {
            // 1. 获取 status 字段内容
            let statusData = dict["status"] as! NSData
            // 2. 反序列化
            let jsonDict = try! NSJSONSerialization.JSONObjectWithData(statusData, options: [])
            
            // 3. 添加到数组
            arrayM.append(jsonDict as! [String : AnyObject])
        }
        
        return arrayM
    }
    
    /// 将网络返回的字典数组保存到数据
    ///
    /// - parameter array: 网络返回的字典数组
    /// - 1. 测试准备 SQL - 在开发数据库应用时，绝大多数，错误出在 SQL 本身
    /// - 2. 根据 SQL 需要的参数确定需求
    /// - 3. 编写代码
    private class func saveWebData(array: [[String: AnyObject]]) {
        
        guard let userId = UserAccount.sharedUserAccount.uid else {
            QL4("用户没有登录")
            
            return
        }
        
        /**
         1. statusId - 从字典中获取 `id`
         2. userId - 当前登录用户的 id
         3. status - 将整个字典反序列化成 json 字符串
        */
        let sql = "INSERT OR REPLACE INTO T_Status (statusId, userId, status) VALUES (?, ?, ?);"
        
        // 循环插入数据 - array 是网络框架 AFN 刚刚做过`序列化`生成的数组
        SQLiteManager.sharedManager.queue.inTransaction { (db, rollback) -> Void in
            for dict in array {
                
                let statusId = dict["id"] as! NSNumber
                // .PrettyPrinted 格式漂亮，便于人阅读！存储不需要
                let status = try! NSJSONSerialization.dataWithJSONObject(dict, options: [])
                
                // 执行 SQL 插入数据
                do {
                    try db.executeUpdate(sql, values: [statusId, userId, status])
                } catch {
                    rollback.memory = true
                    break
                }
            }
        }
        
        QL2("保存数据到本地数据库完成")

        // 注意：for 要放在 fmdb 的内部，否则每一次循环都会开启事务！
        // 否则，性能慢，一旦出错，无法回滚！
//        for dict in array {
//            SQLiteManager.sharedManager.queue.inTransaction { (db, rollback) -> Void in
//            
//            }
//        }
    }
    
}