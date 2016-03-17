//
//  MainViewController.swift
//  上海微博
//
//  Created by teacher on 16/2/21.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 在 viewDidLoad 只是添加子控制器，不会创建 tabBar 的 UITabBarButton
        // tabBar 的按钮们会在 viewWillAppear(将要显示) 方法之前被创建
        addChildViewControllers()
        
        setupTabbar()
        
        showNewFeature()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 将按钮设置到顶部
        tabBar.bringSubviewToFront(composeButton)
        
        // 计算按钮宽度
        // -1 是防止边界处理
        let width = tabBar.bounds.width / CGFloat(childViewControllers.count) - 1
        // CGRectInset Returns a rectangle that is smaller or larger than the source rectangle
        // > 0，向内缩小
        // < 0，向外
        composeButton.frame = CGRectInset(tabBar.bounds, width * 2, 0)
    }
    
    // MARK: - 监听方法
    // unrecognized selector sent to instance
    // OC 在运行时，向对象发送消息，但是对象没有响应消息，抛出的异常！
    // 一旦使用了 private，函数变成私有，运行循环无法找到此函数，如果发送消息，会抛出异常！
    // @objc 关键字能够在`编译`的时候，让函数能够使用 OC 的消息机制被调用到
    @objc private func clickComposeButton() {
        print("点击撰写按钮")
        
        // 如果用户登录，显示发布微博界面，否则，显示登录界面
        var vcName: String
        let namespace = NSBundle.mainBundle().infoDictionary!["CFBundleExecutable"] as! String
        
        if UserAccount.sharedUserAccount.isLogin {
            vcName = "ComposeViewController"
        } else {
            vcName = "OAuthViewController"
        }
        
        // 以下两行代码是在 Swift 中使用字符串创建类的标准写法！
        // 在 Swift 的 class 需要包含命名空间
        let cls = NSClassFromString(namespace + "." + vcName) as! UIViewController.Type
        let vc = cls.init()
        
        let nav = UINavigationController(rootViewController: vc)

        presentViewController(nav, animated: true, completion: nil)
    }
    
    // MARK: - 私有控件
    /// 撰写按钮
    private lazy var composeButton:UIButton = UIButton(
        cz_title: nil,
        imageName: "tabbar_compose_icon_add",
        backImageName: "tabbar_compose_button")
}

// MARK: - 新特性处理
extension MainViewController {
    
    /// 显示新特性
    private func showNewFeature() {
        // 1. 如果没有登录直接返回
        if !UserAccount.sharedUserAccount.isLogin {
            return
        }
        
        // 2. 判断是否有新版本
        let v = isNewVersion ? NewFeatureView() : WelcomeView()
        
        // 3. 将视图添加到当前视图
        view.addSubview(v)
    }
    
    /// 是否有新版本
    private var isNewVersion: Bool {
        // 1. 获取当前版本 1.2
        let currentVersion = NSBundle.cz_currentVersion
        
        // 2. 获取`之前`的版本，保存在用户偏好 1.2
        let versionKey = "cn.itcast.versionKey"
        let sandboxVersion = NSUserDefaults.standardUserDefaults().stringForKey(versionKey)
        
        // 3. 将当前版本保存在用户偏好
        NSUserDefaults.standardUserDefaults().setObject(currentVersion, forKey: versionKey)
        
        print("是否新版本 \(currentVersion > sandboxVersion)")
        // 4. 返回两个版本的比较
        return currentVersion != sandboxVersion
    }
}

// MARK: - 设置 tabbar
extension MainViewController {

    /// 设置 tabbar
    private func setupTabbar() {
        // 设置tabbar背景图片，以下两句代码必须连用，Nav 的处理类似
        // 以下两个属性都设置成 [[UIImage alloc] init] 就是完全透明
        // 如果提供图像，会自动拉伸
        tabBar.shadowImage = UIImage.cz_singleDotImage(UIColor(white: 0.9, alpha: 1.0))
        tabBar.backgroundImage = UIImage(named: "tabbar_background")
        
        // 添加撰写按钮
        tabBar.addSubview(composeButton)
        
        // 添加监听方法
        composeButton.addTarget(self, action: "clickComposeButton", forControlEvents: .TouchUpInside)
    }
}

// MARK: - 添加控制器
// 通过 extension 把相关的代码进行分组放置
extension MainViewController {
    
    /// 添加所有子控制器
    private func addChildViewControllers() {
        
        addChildViewController(HomeViewController(), title: "首页", imageName: "tabbar_home")
        addChildViewController(MessageViewController(), title: "消息", imageName: "tabbar_message_center")
        
        // 添加一个空白的控制器
        addChildViewController(UIViewController())
        
        addChildViewController(DiscoverViewController(), title: "发现", imageName: "tabbar_discover")
        addChildViewController(ProfileViewController(), title: "我", imageName: "tabbar_profile")
    }
    
    /// 添加一个控制器
    ///
    /// - parameter vc:        视图控制器
    /// - parameter title:     标题
    /// - parameter imageName: 图像名称
    private func addChildViewController(vc: UIViewController, title: String, imageName: String) {
        
        // title 从内向外设置的
        vc.title = title
        
        // 设置文本属性
        // 文本属性的 Key 都包含 AttributeName
        // vc.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.orangeColor()], forState: .Selected)
        // 如果要设置文字大小，需要设置 Normal 状态
        vc.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(10)], forState: .Normal)
        
        vc.tabBarItem.image = UIImage(named: imageName)
        // 默认情况下，tabbar的image会使用系统默认颜色`渲染`
        // AlwaysOriginal 渲染模式，就会直接使用平面设计师提供的素材颜色，系统不再加工
        vc.tabBarItem.selectedImage = UIImage(named: imageName + "_selected") //?.imageWithRenderingMode(.AlwaysOriginal)
        
        let nav = UINavigationController(rootViewController: vc)
        
        // 添加子控制器
        addChildViewController(nav)
    }
    
}
