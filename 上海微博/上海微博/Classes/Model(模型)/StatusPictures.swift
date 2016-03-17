//
//  StatusPictures.swift
//  上海微博
//
//  Created by teacher on 16/3/1.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

/// 微博配图模型
class StatusPictures: NSObject {

    /// 缩略图 URL 字符串
    var thumbnail_pic: String?
    /// 中等尺寸 URL 字符串
    var bmiddle_pic: String? {
        
        guard let urlString = thumbnail_pic else {
            return nil
        }
        
        // 替换字符串
        return urlString.stringByReplacingOccurrencesOfString("/thumbnail/", withString: "/bmiddle/")
    }
    
    override var description: String {
        return dictionaryWithValuesForKeys(["thumbnail_pic"]).description
    }
}
