//
//  StatusRetweetedView.swift
//  上海微博
//
//  Created by teacher on 16/2/28.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import FFLabel

/// 被转发微博 - Cell 的子视图
class StatusRetweetedView: StatusContentView {
    
    // MARK: - 视图模型
    var viewModel: StatusViewModel? {
        didSet {
            
            // 设置转发文本
            // retweetedLabel.text = viewModel?.retweetedText
            retweetedLabel.attributedText = viewModel?.retweetedAttribteText
            
            // 判断是否有转发微博
            if viewModel?.status.retweeted_status == nil {
                
                retweetedLabel.snp_updateConstraints(closure: { (make) -> Void in
                    make.top.equalTo(self)
                })
                picturesView.snp_updateConstraints(closure: { (make) -> Void in
                    make.size.equalTo(CGSizeZero)
                    
                    make.top.equalTo(retweetedLabel.snp_bottom)
                    make.bottom.equalTo(self)
                })
                
                return
            }
            
            // 更新配图视图大小
            var offset: CGFloat = 0
            if viewModel?.status.retweeted_status?.pic_urls?.count > 0 {
                offset = CZStatusCellLayout.margin
            }
            
            retweetedLabel.snp_updateConstraints { (make) -> Void in
                make.top.equalTo(self).offset(CZStatusCellLayout.margin)
            }
            picturesView.snp_updateConstraints { (make) -> Void in
                make.size.equalTo(viewModel!.retweetedPicturesViewSize)
                make.top.equalTo(retweetedLabel.snp_bottom).offset(offset)
                
                make.bottom.equalTo(self).offset(-CZStatusCellLayout.margin)
            }
            // 设置图像
            picturesView.pic_urls = viewModel?.status.retweeted_status?.pic_urls
            // 更新图像大小
            picturesView.updateImageSize(viewModel!.retweetedPicturesViewSize)
        }
    }
    
    // MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 私有控件
    /// 被转发微博标签
    private let retweetedLabel: FFLabel = FFLabel(cz_text: "@作者:微博", fontSize: 14)
    /// 配图视图
    private let picturesView: StatusPicturesView = StatusPicturesView()
}

// MARK: - 设置界面
extension StatusRetweetedView {
    
    private func setupUI() {
        // 0. 设置背景颜色
        backgroundColor = UIColor.cz_colorWithHex(0xF5F5F5)
        
        // 1. 添加控件
        addSubview(retweetedLabel)
        addSubview(picturesView)
        
        // 2. 自动布局
        let layout = CZStatusCellLayout
        
        retweetedLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self).offset(layout.margin)
            make.right.equalTo(self).offset(-layout.margin)
            make.top.equalTo(self).offset(layout.margin)
        }
        picturesView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(retweetedLabel)
            make.top.equalTo(retweetedLabel.snp_bottom).offset(layout.margin)
            
            // 设置大小
            make.size.equalTo(CGSize(width: 150, height: 150))
            
            make.bottom.equalTo(self).offset(-layout.margin)
        }
    }
}