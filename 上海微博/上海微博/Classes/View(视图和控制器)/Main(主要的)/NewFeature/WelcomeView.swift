//
//  WelcomeView.swift
//  上海微博
//
//  Created by teacher on 16/2/25.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import SDWebImage

/// 欢迎视图
class WelcomeView: UIView {

    // MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: UIScreen.mainScreen().bounds)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(classForCoder) \(__FUNCTION__)")
    }
    
    // MARK: - 生命周期
    // 添加到父视图
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        print("\(__FUNCTION__)")
    }
    
    // 添加到窗口 - 已经显示
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        print("\(__FUNCTION__)")
        
        // 更新约束
        avatarView.snp_updateConstraints { (make) -> Void in
            make.centerY.equalTo(self).offset(-100)
        }
        
        // 动画
        // Damping: 弹力 0 ~ 1，越小越弹
        // Velocity: 速度，10 符合重力规则
        UIView.animateWithDuration(
            1.2,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 10,
            options: [],
            animations: { () -> Void in
                
                self.layoutIfNeeded()
            }) { (_) -> Void in
                // 从 bundle 中加载启动图片
                let launchImageView = UIImageView(image: NSBundle.cz_launchImageView)
                launchImageView.frame = self.bounds
                self.addSubview(launchImageView)
                
                UIView.animateWithDuration(
                    1.0,
                    animations: { () -> Void in
                        launchImageView.transform = CGAffineTransformMakeScale(2.0, 2.0)
                        launchImageView.alpha = 0
                        self.alpha = 0
                    }) { _ in
                        self.removeFromSuperview()
                }
        }
    }
    
    /// 布局子视图 - 自动布局设置完成后调用，通常此方法使用自动布局开发的时候，不需要重写
    /// 有可能调用非常频繁，一定不要有太耗时的操作！
    override func layoutSubviews() {
        super.layoutSubviews()
        
        print("\(__FUNCTION__)")
    }
    
    // MARK: - 私有控件
    /// 头像视图
    private lazy var avatarView = UIImageView(cz_imageName: "avatar_default_big")
    /// 欢迎标签
    private lazy var welcomeLabel = UILabel(cz_text: "欢迎归来", fontSize: 18)
}

// MARK: - 设置界面
extension WelcomeView {
    
    private func setupUI() {
        
        // 1. 设置背景
        backgroundColor = UIColor(patternImage: UIImage(named: "ad_background")!)
        
        // 2. 添加控件
        addSubview(avatarView)
        addSubview(welcomeLabel)
        
        let iconWH: CGFloat = 45
        avatarView.layer.cornerRadius = iconWH
        avatarView.layer.masksToBounds = true
        
        // 3. 自动布局
        avatarView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(100)
            make.size.equalTo(CGSize(width: iconWH * 2, height: iconWH * 2))
        }
        welcomeLabel.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(avatarView)
            make.top.equalTo(avatarView.snp_bottom).offset(20)
        }
        
        // 4. 强行更新约束
        layoutIfNeeded()
        
        // 5. 设置头像
        avatarView.cz_setImageWithURL(UserAccount.sharedUserAccount.avatar_large,
            placeholderName: "avatar_default_big")
    }
}