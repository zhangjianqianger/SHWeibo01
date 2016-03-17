//
//  VisitorView.swift
//  上海微博
//
//  Created by teacher on 16/2/22.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import SnapKit

/// 访客视图的协议
protocol VisitorViewDelegate: NSObjectProtocol {
    
    /// 访客视图注册
    func visitorViewDidRegister()
    /// 访客视图登录
    func visitorViewDidLogin()
}

/// 访客视图
class VisitorView: UIView {

    // MARK: - 代理属性
    /// 提示：代理一定不要忘记 weak
    weak var delegate: VisitorViewDelegate?
    
    // MARK: - 生命周期函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        
        // 添加监听方法
        registerButton.addTarget(self, action: "clickRegisterButton", forControlEvents: .TouchUpInside)
        loginButton.addTarget(self, action: "clickLoginButton", forControlEvents: .TouchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("访客视图 deinit")
    }
    
    // MARK: - 监听方法
    @objc private func clickRegisterButton() {
        print("点击注册")
        delegate?.visitorViewDidRegister()
    }
    
    @objc private func clickLoginButton() {
        print("点击登录")
        delegate?.visitorViewDidLogin()
    }
    
    // MARK: - 公共方法
    /// 设置访客视图信息
    ///
    /// - parameter imageName: 图像名，首页默认为 nil
    /// - parameter message:   提示文字
    func setupInfo(imageName: String? = nil, message: String) {
        
        messageLabel.text = message
        
        // 如果图像为nil，表示是首页
        guard let imageName = imageName else {
            startAnimation()
            
            return
        }
        
        // 不是首页需要隐藏房子
        homeIconView.hidden = true
        maskIconView.hidden = true
        
        iconView.image = UIImage(named: imageName)
    }
    
    /// 开始动画
    private func startAnimation() {
        
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        
        anim.toValue = 2 * M_PI
        anim.repeatCount = MAXFLOAT
        anim.duration = 20
        // 提示：对于需要循环播放的动画，可以设置此属性为 false
        // 视图离开屏幕后，不会被销毁！当 动画所在视图被销毁后，动画会连带销毁
        // 不需要考虑释放问题
        anim.removedOnCompletion = false
        
        iconView.layer.addAnimation(anim, forKey: nil)
    }
    
    // MARK: - 私有控件
    /// 图标视图
    private lazy var iconView: UIImageView = UIImageView(cz_imageName: "visitordiscover_feed_image_smallicon")
    /// 遮罩视图 - 提示不要写 maskView，父类有 maskView 的属性
    private lazy var maskIconView: UIImageView = UIImageView(cz_imageName: "visitordiscover_feed_mask_smallicon")
    /// 小房子图标
    private lazy var homeIconView: UIImageView = UIImageView(cz_imageName: "visitordiscover_feed_image_house")
    /// 消息标签
    private lazy var messageLabel: UILabel = UILabel(
        cz_text: "关注一些人，回这里看看有什么惊喜关注一些人，回这里看看有什么惊喜",
        alignment: .Center)
    /// 注册按钮
    private lazy var registerButton: UIButton = UIButton(
        cz_title: "注册",
        color: UIColor.orangeColor(),
        backImageName: "common_button_white_disable")
    /// 登录按钮
    private lazy var loginButton: UIButton = UIButton(
        cz_title: "登录",
        backImageName: "common_button_white_disable")
}

// MARK: - 设置界面
extension VisitorView {
    
    private func setupUI() {
        
        // 1. 添加控件
        addSubview(iconView)
        addSubview(maskIconView)
        addSubview(homeIconView)
        addSubview(messageLabel)
        addSubview(registerButton)
        addSubview(loginButton)
        
        // 2. 自动布局
        // 1> 参照属性一致，可以省略
        // 2> 参照属性不一致，使用 snp_参照属性 的格式
        // 图标视图
        iconView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-60)
        }
        // 小房子视图
        homeIconView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(iconView)
        }
        // 提示文字
        messageLabel.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(iconView)
            make.top.equalTo(iconView.snp_bottom).offset(20)
            make.size.equalTo(CGSize(width: 224, height: 36))
        }
        // 注册按钮
        registerButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(messageLabel.snp_bottom).offset(20)
            make.left.equalTo(messageLabel)
            make.size.equalTo(CGSize(width: 100, height: 36))
        }
        // 登录按钮
        loginButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(messageLabel)
            make.top.equalTo(registerButton)
            make.size.equalTo(registerButton)
        }
        // 遮罩视图
        maskIconView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(registerButton)
        }
        // 空白区域可以使用背景色(能够使用颜色，就不要使用图片)
        backgroundColor = UIColor(white: 237.0 / 255.0, alpha: 1.0)
    }
}
