//
//  SQLiteManager.swift
//  FMDB-01-演练
//
//  Created by teacher on 16/3/12.
//  Copyright © 2016年 itcast. All rights reserved.
//

import Foundation
import FMDB

/// 数据库名称
private let CZDatabaseName = "status.db"

/// SQLite 管理器
class SQLiteManager {
    
    /// 单例
    static let sharedManager = SQLiteManager()
    
    /// 全局数据库访问队列
    let queue: FMDatabaseQueue
    
    /// 构造函数，进行初始化工作，private 可以保证 统一使用全局访问点访问对象
    private init() {
        
        var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask,
            true)[0]
        path = (path as NSString).stringByAppendingPathComponent(CZDatabaseName)
        
        print("数据库路径 \(path)")
        
        // 初始化队列 sqlit3_openDB -> &db 返回全局操作句柄
        // 参数：数据库文件的完整路径
        // - 如果数据库不存在，会新建`空白`数据库，并且实例化队列
        // - 如果数据库存在，会打开数据库，并且实例化队列
        queue = FMDatabaseQueue(path: path)
        
        createTable()
    }
    
    /// 执行 SQL 返回结果集合
    ///
    /// - parameter sql: SQL
    ///
    /// - returns: 结果集合 [字典数组]?
    func execRecordset(sql: String) -> [[String: AnyObject]]? {
        
        var recordSet: [[String: AnyObject]]?
        
        // 执行 SQL
        queue.inDatabase { (db) -> Void in
            guard let rs = try? db.executeQuery(sql, values: []) else {
                // SQL 语句错误
                print("查询失败")
                
                return
            }
            
            recordSet = [[String: AnyObject]]()
            
            // 遍历结果集合
            while rs.next() {
                
                // 0. 创建集合
                var row = [String: AnyObject]()
                
                // 1. 知道有几列
                let colCount = rs.columnCount()
                
                // 2. 遍历每一列
                for col in 0..<colCount {
                    // - 列名
                    let name = rs.columnNameForIndex(col)
                    
                    // - 值
                    let value = rs.objectForColumnIndex(col)
                    // print("\(name) - \(value)")
                    
                    // 设置 row
                    row[name] = value
                }
                
                // 3. 一行记录结束添加到数组
                recordSet?.append(row)
            }
        }
        
        return recordSet
    }
    
    /// 创建数据表
    private func createTable() {
        
        // 1. 准备 SQL
        let path = NSBundle.mainBundle().pathForResource("db.sql", ofType: nil)
        let sql = try! String(contentsOfFile: path!)
        
        // 2. 执行 SQL
        queue.inDatabase { (db) -> Void in
            // 执行多条语句，用于建表使用
            if db.executeStatements(sql) {
                // NSThread.sleepForTimeInterval(2.0)
                print("创表成功")
            } else {
                print("创表失败")
            }
        }
    }
}