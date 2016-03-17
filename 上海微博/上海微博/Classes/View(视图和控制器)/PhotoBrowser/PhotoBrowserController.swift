//
//  PhotoBrowserController.swift
//  上海微博
//
//  Created by teacher on 16/3/11.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import QorumLogs
import SVProgressHUD

/// 照片浏览控制器，负责用户交互
class PhotoBrowserController: UIViewController {

    // MARK: - 属性
    /// 选中照片索引
    private let selectedIndex: Int
    /// 照片 url 字符串数组
    private let urls: [String]
    /// 参照的图像视图，用于展现和解除转场使用
    private let releatedImageViews: [UIImageView]
    
    /// 当前显示的单图查看器
    private var currentViewer: PhotoViewerController?
    
    /// 转场动画器
    private let animator: PhotoBrowserAnimator
    
    // MARK: - 构造函数
    /// 实例化照片浏览器
    ///
    /// - parameter selectedIndex:      当前选中索引
    /// - parameter urls:               所有配图的 url 字符串数组
    /// - parameter releatedImageViews: 参照图像视图，用于展现和返回
    ///
    /// - returns: 照片浏览器
    init(selectedIndex: Int, urls: [String], releatedImageViews: [UIImageView]) {
        self.selectedIndex = selectedIndex
        self.urls = urls
        self.releatedImageViews = releatedImageViews
        
        // 1> 创建动画器
        animator = PhotoBrowserAnimator()
        animator.presentingImageView = releatedImageViews[selectedIndex]
        
        super.init(nibName: nil, bundle: nil)
        
        // 2> 指定专场动画代理(weak)
        transitioningDelegate = animator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(selectedIndex)
        print(urls)
        
        setupUI()
    }
    
    // MARK: - 监听方法
    @objc private func tapGesture() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// 长按手势 - 长按有状态，必须要判断状态，否则代码会执行两次
    @objc private func longGesture(recognizer: UILongPressGestureRecognizer) {
        
        if recognizer.state == .Began {
         
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "保存到相册", style: .Destructive, handler: { (_) -> Void in
            
                QL2("保存到相册 \(self.currentViewer?.photoIndex)")
                // 1. 取出图像
                guard let image = self.currentViewer?.imageView.image else {
                    return
                }
                
                // 2. 保存图像
                UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
            }))
            
            actionSheet.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            
            presentViewController(actionSheet, animated: true, completion: nil)
        }
    }
    
    //  - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
    @objc private func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        let message = (error == nil) ? "保存成功" : "保存失败"
        
        SVProgressHUD.showInfoWithStatus(message)
    }
}

// MARK: - UIPageViewControllerDataSource
/**
    1. viewController 并没有被`复用`
    2. 会预先加载将要显示的控制器
    3. 不需要的控制器会被释放

    提问：使用 `复用` 能够提高哪方面的性能：内存＋创建并且分配空间(alloc/init) CPU 开销不明显

    类似的框架：AsyncDisplay 框架(FaceBook) `异步`绘制 UI 的一套框架，重写了 iOS 的所有 UI
    超重量级框架，不建议使用！
    TableViewCell 就不会`复用`
*/
extension PhotoBrowserController: UIPageViewControllerDataSource {
 
    /// 返回前一页控制器
    ///
    /// - parameter pageViewController: pageViewController
    /// - parameter viewController:     当前显示的控制器
    ///
    /// - returns: 返回前一页控制器，如果返回 nil，到头了
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        // 从控制器中获取当前照片的索引
        var index = (viewController as! PhotoViewerController).photoIndex
        
        // 判断是否到头
        if index <= 0 {
            return nil
        }
        
        index--;
        // 创建并返回查看视图控制器
        return PhotoViewerController(urlString: urls[index], photoIndex: index)
    }
    
    /// 返回后一页控制器
    ///
    /// - parameter pageViewController: pageViewController
    /// - parameter viewController:     当前显示的控制器
    ///
    /// - returns: 返回后一页控制器，如果返回 nil，到尾了
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        var index = (viewController as! PhotoViewerController).photoIndex
        
        // 判断是否到尾
        if ++index >= urls.count {
            return nil
        }
        
        return PhotoViewerController(urlString: urls[index], photoIndex: index)
    }
}

// MARK: - UIPageViewControllerDelegate
extension PhotoBrowserController: UIPageViewControllerDelegate {
    
    /// 分页停止动画 - 第一次启动，不会调用此代理方法
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // viewControllers[0] 是当前显示的控制器，随着分页控制器的滚动，调整数组的内容次序
        // 始终保证当前显示的控制器的下标是 0
        // 一定注意，不要使用 childViewControllers
        guard let viewer = pageViewController.viewControllers?[0] as? PhotoViewerController else {
            return
        }
        
        currentViewer = viewer
        QL2("当前照片索引 \(viewer.photoIndex)")
    }
}

// MARK: - 设置 UI
extension PhotoBrowserController {
    
    private func setupUI() {
        // 1. 设置背景颜色
        view.backgroundColor = UIColor.orangeColor()
        
        // 2. 分页控制器
        // 1> 实例化
        let pageViewController = UIPageViewController(
            transitionStyle: .Scroll,
            navigationOrientation: .Horizontal,
            options: [UIPageViewControllerOptionInterPageSpacingKey: 20])
        
        // 2> 添加分页控制器的子控制器 setViewControllers
        // * 单图控制器 - 分页控制器`初始显示`的控制器
        let viewer = PhotoViewerController(urlString: urls[selectedIndex], photoIndex: selectedIndex)
        pageViewController.setViewControllers(
            [viewer],
            direction: .Forward,
            animated: false,
            completion: nil)
        
        // 记录当前的单图控制器
        currentViewer = viewer
        
        // 3> 将分页控制器的视图和控制器，添加到当前控制器上
        view.addSubview(pageViewController.view)
        // * 添加子控制器，保证响应者链条不会被打断(不是所有的不添加都会出现问题，但是，如果忘记了，非常难找！)
        addChildViewController(pageViewController)
        // * 告诉控制器子控制器添加完成，所有的工作准备就绪，后续的响应会比较连贯！
        pageViewController.didMoveToParentViewController(self)
        
        // 4> 设置手势识别
        view.gestureRecognizers = pageViewController.gestureRecognizers
        
        // 5> 设置数据源 & 代理
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        // 3. 手势监听
        let tap = UITapGestureRecognizer(target: self, action: "tapGesture")
        view.addGestureRecognizer(tap)
        let longPress = UILongPressGestureRecognizer(target: self, action: "longGesture:")
        view.addGestureRecognizer(longPress)
    }
}
