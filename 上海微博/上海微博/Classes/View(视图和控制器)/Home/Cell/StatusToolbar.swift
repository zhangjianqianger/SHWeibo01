//
//  StatusToolbar.swift
//  上海微博
//
//  Created by teacher on 16/2/28.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

/// 微博工具栏
class StatusToolbar: UIView {
    
    // MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 私有控件
    /// 转发按钮
    private let retweetedButton = UIButton(
        cz_title: " 转发",
        fontSize: 12,
        imageName: "timeline_icon_retweet",
        backImageName: "timeline_card_bottom_background")
    /// 评论按钮
    private let commentButton = UIButton(
        cz_title: " 评论",
        fontSize: 12,
        imageName: "timeline_icon_comment",
        backImageName: "timeline_card_bottom_background")
    /// 点赞按钮
    private let likeButton = UIButton(
        cz_title: " 赞",
        fontSize: 12,
        imageName: "timeline_icon_unlike",
        backImageName: "timeline_card_bottom_background")
}

// MARK: - 设置界面
extension StatusToolbar {
    
    private func setupUI() {
        // 0. 背景颜色
        backgroundColor = superview?.backgroundColor // UIColor.cz_colorWithHex(0xF2F2F2)
        
        // 1. 添加控件
        addSubview(retweetedButton)
        addSubview(commentButton)
        addSubview(likeButton)
        
        // 设置文本间距
//        let margin = CZStatusCellLayout.margin
//        let inset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: 0)
//        retweetedButton.titleEdgeInsets = inset
//        commentButton.titleEdgeInsets = inset
//        likeButton.titleEdgeInsets = inset
        
        // 2. 自动布局
        retweetedButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.left.equalTo(self)
        }
        commentButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(retweetedButton)
            make.bottom.equalTo(retweetedButton)
            make.left.equalTo(retweetedButton.snp_right)
            
            make.width.equalTo(retweetedButton)
        }
        likeButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(commentButton)
            make.bottom.equalTo(commentButton)
            make.left.equalTo(commentButton.snp_right)
            
            make.width.equalTo(commentButton)
            
            // 非常重要，右侧参照
            make.right.equalTo(self)
        }
        
        // 3. 分隔线
        let sep1 = UIImageView(cz_imageName: "timeline_card_bottom_line")
        let sep2 = UIImageView(cz_imageName: "timeline_card_bottom_line")
        
        addSubview(sep1)
        addSubview(sep2)
        
        sep1.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(retweetedButton.snp_right)
            make.centerY.equalTo(retweetedButton)
        }
        sep2.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(commentButton.snp_right)
            make.centerY.equalTo(commentButton)
        }
    }
}
