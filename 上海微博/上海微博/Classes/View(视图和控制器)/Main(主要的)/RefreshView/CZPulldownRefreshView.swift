//
//  CZPulldownRefreshView.swift
//  上海微博
//
//  Created by teacher on 16/2/24.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import HMRefresh

class CZPulldownRefreshView: UIView, HMRefreshViewDelegate {

    /// 下拉提示图像
    @IBOutlet weak var pulldownIcon: UIImageView?
    /// 刷新指示器
    @IBOutlet weak var refreshIndicator: UIActivityIndicatorView?
    /// 提示标签
    @IBOutlet weak var tipLabel: UILabel?
    /// 刷新时间标签
    @IBOutlet weak var timeLabel: UILabel?
    
    /// 从 XIB 加载 自定义视图
    class func refreshView() -> CZPulldownRefreshView {
        
        let nib = UINib(nibName: "CZPulldownRefreshView", bundle: nil)
        
        return nib.instantiateWithOwner(nil, options: nil).last as! CZPulldownRefreshView
    }
}
