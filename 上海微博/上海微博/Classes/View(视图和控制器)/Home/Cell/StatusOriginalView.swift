//
//  StatusOriginalView.swift
//  上海微博
//
//  Created by teacher on 16/2/28.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import FFLabel

/// 点击 URL 链接通知
let CZStatusCellDidClickURLNotification = "CZStatusCellDidClickURLNotification"

/// 原创微博和转发微博的父类，统一监听 FFLabel 监听方法
class StatusContentView: UIView, FFLabelDelegate {
    func labelDidSelectedLinkText(label: FFLabel, text: String) {
        // 判断文本是否包含 http:// 字头
        if text.hasPrefix("http://") {
            print(text)
            
            NSNotificationCenter.defaultCenter().postNotificationName(CZStatusCellDidClickURLNotification, object: text)
        }
    }
}

/// 原创微博 - 是 Cell 的子视图
class StatusOriginalView: StatusContentView {

    /// 微博视图模型
    var viewModel: StatusViewModel? {
        didSet {
            // 设置圆角头像(需要扩展参数)
            iconView.cz_setImageWithURL(
                viewModel?.status.user?.profile_image_url,
                placeholderName: "avatar_default_big",
                size: CZStatusCellLayout.iconSize,
                isCorner: true)
            
            // 姓名
            nameLabel.text = viewModel?.status.user?.screen_name
            
            // 设置图标
            memberIconView.image = viewModel?.userMemberImage
            vipIconView.image = viewModel?.userVipImage
            
            sourceLabel.text = viewModel?.sourceText
            timeLabel.text = viewModel?.createTime?.cz_dateDescription
            
            // contentLabel.text = viewModel?.status.text
            contentLabel.attributedText = viewModel?.statusAttribteText
            
            // `更新`配图视图大小
            // 根据是否有配图，决定配图视图顶部的约束参照
            let offset = viewModel?.status.pic_urls?.count > 0 ? CZStatusCellLayout.margin : 0
            picturesView.snp_updateConstraints { (make) -> Void in
                make.size.equalTo(viewModel!.picturesViewSize)
                make.top.equalTo(contentLabel.snp_bottom).offset(offset)
            }
            // 设置配图视图内容
            picturesView.pic_urls = viewModel?.status.pic_urls
            // 更新视图大小，注意和上面的代码不要调换位置
            picturesView.updateImageSize(viewModel!.picturesViewSize)
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
    /// 头像图标
    private let iconView: UIImageView = UIImageView(cz_imageName: "avatar_default_big")
    /// 姓名标签
    private let nameLabel: UILabel = UILabel(cz_text: "传智播客")
    /// 会员图标
    private let memberIconView: UIImageView = UIImageView(cz_imageName: "common_icon_membership_level1")
    /// VIP 图标
    private let vipIconView: UIImageView = UIImageView(cz_imageName: "avatar_vip")
    /// 时间
    private let timeLabel: UILabel = UILabel(cz_text: "创建时间", fontSize: 10, color: CZAppearanceTintColor)
    /// 来源
    private let sourceLabel: UILabel = UILabel(cz_text: "来源 上海微博", fontSize: 10)
    /// 内容标签
    private let contentLabel: FFLabel = FFLabel(cz_text: "微博微博", fontSize: 15)
    /// 配图视图
    private let picturesView: StatusPicturesView = StatusPicturesView()
}

// MARK: - 设置界面
extension StatusOriginalView {
    
    private func setupUI() {
        
        // 0. 设置背景颜色
        backgroundColor = UIColor.whiteColor()
        
        // 1. 添加控件
        addSubview(iconView)
        addSubview(nameLabel)
        addSubview(memberIconView)
        addSubview(vipIconView)
        addSubview(timeLabel)
        addSubview(sourceLabel)
        addSubview(contentLabel)
        addSubview(picturesView)
        
        let layout = CZStatusCellLayout
        let margin: CGFloat = layout.margin
        let iconSize = layout.iconSize
        
        // 测试代码
        let count = random() % 20 + 1
        var str = ""
        for _ in 0..<count {
            str += "新浪微博"
        }
        contentLabel.text = str
        
        // 测试头像
        UIImage(named: "avatar_default_big")?.cz_asyncDrawImage(iconSize, isCorner: true, finished: { (image) -> () in
            self.iconView.image = image
        })
    
        // 2. 自动布局
        iconView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(margin)
            make.left.equalTo(margin)
            make.size.equalTo(iconSize)
        }
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(iconView)
            make.left.equalTo(iconView.snp_right).offset(margin)
        }
        memberIconView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(nameLabel)
            make.left.equalTo(nameLabel.snp_right).offset(margin)
        }
        vipIconView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(iconView.snp_right).offset(-4)
            make.centerY.equalTo(iconView.snp_bottom).offset(-4)
        }
        timeLabel.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(iconView)
            make.left.equalTo(iconView.snp_right).offset(margin)
        }
        sourceLabel.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(timeLabel)
            make.left.equalTo(timeLabel.snp_right).offset(margin)
        }
        contentLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(iconView)
            make.top.equalTo(iconView.snp_bottom).offset(margin)
            
            make.right.equalTo(self).offset(-margin)
        }
        picturesView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentLabel)
            make.top.equalTo(contentLabel.snp_bottom).offset(margin)
            
            // 默认不设置配图视图大小
            make.size.equalTo(CGSizeZero)
            
            // 很重要，设置底部约束，能够自动计算高度
            make.bottom.equalTo(self).offset(-margin)
        }
        
        // 3. 设置标签的代理
        contentLabel.labelDelegate = self
    }
}
