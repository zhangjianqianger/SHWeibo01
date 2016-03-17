//
//  NSDate+Extension.swift
//  上海微博
//
//  Created by teacher on 16/2/28.
//  Copyright © 2016年 itcast. All rights reserved.
//

import Foundation

/// NSDateFormatter 常量
private let cz_sharedDateFormatter = NSDateFormatter()
/// 当前日历对象
private let cz_sharedCalendar = NSCalendar.currentCalendar()

/**
 在 iOS 开发中 NSDateFormatter / NSCalendar 性能异常糟糕！
 每次 `创建`／销毁非常消耗性能
 
 - 解决办法：定义一个常量，在 OC 中专门定义一个单例
*/
extension NSDate {
    
    /// 返回指定时间差值的日期字符串
    ///
    /// - parameter delta: 时间差值
    ///
    /// - returns: 日期字符串
    class func cz_dateStringWithDelta(delta: NSTimeInterval) -> String {
        
        cz_sharedDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cz_sharedDateFormatter.locale = NSLocale(localeIdentifier: "en")
        
        let date = NSDate(timeIntervalSinceNow: delta)
        
        return cz_sharedDateFormatter.stringFromDate(date)
    }
    
    /// 将新郎日期格式字符串转换成日期
    ///
    /// - parameter create_at: Sun Feb 28 16:42:06 +0800 2016
    ///
    /// - returns: 日期对象
    class func cz_sinaDate(create_at: String?) -> NSDate? {
        
        guard let create_at = create_at else {
            return nil
        }
        
        cz_sharedDateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        // 注意：一定要设置区域，如果不设置，模拟器工作正常，真机无法正常计算
        cz_sharedDateFormatter.locale = NSLocale(localeIdentifier: "en")
        
        // 转换结果
        return cz_sharedDateFormatter.dateFromString(create_at)
    }
    
    /** 返回日期格式字符串
     
    刚刚(一分钟内)
    X分钟前(一小时内)
    X小时前(当天)
    昨天 HH:mm(昨天)
    MM-dd HH:mm(一年内)
    yyyy-MM-dd HH:mm(更早期)
    */
    var cz_dateDescription: String {
        
        // 1. 判断是否是今天
        if cz_sharedCalendar.isDateInToday(self) {
            
            // 计算当前系统时间和 self 之间的时间差值
            let delta = Int(NSDate().timeIntervalSinceDate(self))
            
            if delta < 60 {
                return "刚刚"
            }
            if delta < 60 * 60 {
                return "\(delta / 60) 分钟前"
            }
            
            return "\(delta / 3600) 小时前"
        }
        
        // 2. 判断是否是昨天
        /**
            1> 在 iOS 开发中，如果设计日期转换，首先考虑 calendar
            2> components方法，可以指定任意的日期组件，查询日期
                Swift 写法 [.Year, .Month, .Day]
                OC 写法 NSCalendarUnitYear | NSCalendarUnitMonth
        
            coms = cz_sharedCalendar.components([.Year, .Month, .Day], fromDate: self)
        */
        var format = " HH:mm"
        if cz_sharedCalendar.isDateInYesterday(self) {
            format = "昨天" + format
        } else {
            format = "MM-dd" + format
            
            let year = cz_sharedCalendar.component(.Year, fromDate: self)
            let thisYear = cz_sharedCalendar.component(.Year, fromDate: NSDate())

            if year != thisYear {
                format = "yyyy-" + format
            }
        }
        
        // 转换日期
        cz_sharedDateFormatter.dateFormat = format
        cz_sharedDateFormatter.locale = NSLocale(localeIdentifier: "en")
        
        return cz_sharedDateFormatter.stringFromDate(self)
    }
}