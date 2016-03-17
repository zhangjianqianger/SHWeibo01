//
//  StatusCell.swift
//  上海微博
//
//  Created by teacher on 16/2/28.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import SnapKit

/// 微博 Cell
class StatusCell: UITableViewCell {

    /// 微博视图模型
    var viewModel: StatusViewModel? {
        didSet {
            // 设置数据
            originalView.viewModel = viewModel
            retwteedView.viewModel = viewModel
        }
    }
    
    // MARK: - 构造函数
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 私有控件
    /// 原创微博
    private let originalView: StatusOriginalView = StatusOriginalView()
    /// 被转发微博
    private let retwteedView: StatusRetweetedView = StatusRetweetedView()
    /// 工具栏
    private let toolbar: StatusToolbar = StatusToolbar()
}

// MARK: - 设置界面
extension StatusCell {
    
    private func setupUI() {
        
        // 1. 设置背景颜色
        backgroundColor = UIColor.cz_colorWithHex(0xF2F2F2)
        
        // 2. 添加控件
        contentView.addSubview(originalView)
        contentView.addSubview(retwteedView)
        contentView.addSubview(toolbar)
        
        // 3. 自动布局
        let margin = CZStatusCellLayout.margin
        originalView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.top.equalTo(contentView).offset(margin)
        }
        retwteedView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.top.equalTo(originalView.snp_bottom)
        }
        toolbar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.top.equalTo(retwteedView.snp_bottom)
            
            make.height.equalTo(36)
        }
        
        // 4. 异步绘制
        self.layer.drawsAsynchronously = true
        
        // 5. 栅格化 - 会将 cell 的图层内容生成一张图像并且缓存，在滚动中，不再生成 cell 的内容
        self.layer.shouldRasterize = true
        // 一定要设置分辨率
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
    }
}
