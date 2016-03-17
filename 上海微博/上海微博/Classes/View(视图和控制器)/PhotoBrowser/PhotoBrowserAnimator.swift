//
//  PhotoBrowserAnimator.swift
//  上海微博
//
//  Created by teacher on 16/3/11.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

/// 照片浏览器的`动画器` - 提供｀转场动画的一切细节｀
class PhotoBrowserAnimator: NSObject, UIViewControllerTransitioningDelegate {

    /// 标记是否展现
    private var isPresent = false
    /// 展现参考视图
    var presentingImageView: UIImageView?
    
    /// 返回提供真正实现展现动画对象
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        isPresent = true
        
        return self
    }
    
    /// 返回提供真正实现 dismiss 动画的对象
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        isPresent = false
        
        return self
    }
}

// MARK: - UIViewControllerAnimatedTransitioning - 具体的动画实现功能逻辑
extension PhotoBrowserAnimator: UIViewControllerAnimatedTransitioning {
    
    /// 动画的执行时长
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    /// 指定具体的动画逻辑 - 一旦实现了此方法，系统默认的转场失效，所有的动画需要程序猿来提供
    ///
    /// 负责 展现 ／ dismiss 的动画效果
    ///
    /// - parameter transitionContext: 转场上下文，提供转场所需的相关内容
    ///
    /// `转场`需要的内容，`从from`一个视图转换`到to`另外一个视图
    /// 1. 位置
    /// 2. 方式
    /// 3. 容器视图(存放`被展现视图`控制器的`视图`)－动画代码实现的`舞台`
    ///
    /// 注意：`completeTransition` 告诉系统，转场动画结束，可以继续开始监听 UI 交互，结束之前，默认没有交互
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        isPresent ? presentTransition(transitionContext) : dismissTransition(transitionContext)
    }
    
    // MARK: - 动画函数
    /// 展现动画 - 从 homeVC 到 browserVC
    /// 容器视图是动画的舞台
    private func presentTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // 0. 判断`展现视图`是否传递，如果有，可以继续
        guard let presentingImageView = presentingImageView else {
            return
        }
        
        // 1. 容器视图
        let containerView = transitionContext.containerView()
        
        // 2. 根据展现视图，创建一个`临时`的 imageView，不会对界面造成任何的影响，只是负责动画显示
        let imageView = UIImageView()
        
        imageView.image = presentingImageView.image
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        // 坐标转换 - frame是参照`父视图`的坐标位置
        imageView.frame = containerView!.convertRect(presentingImageView.frame,
            fromView: presentingImageView.superview)
        
        // 3. 添加imageView
        containerView?.addSubview(imageView)
    
        // 4. 计算目标位置(根据屏幕宽度计算)
        let targetRect = imageRectWithScreen(presentingImageView.image!)
        // imageView.frame = targetRect
        
        // 5. 目标视图
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        containerView?.addSubview(toView)
        
        // 6. 动画实现
        toView.alpha = 0
        UIView.animateWithDuration(
            transitionDuration(transitionContext),
            animations: { () -> Void in
                
                // 设置目标位置
                imageView.frame = targetRect
                toView.alpha = 1
            }) { (_) -> Void in
                // 1> 删除临时图像
                imageView.removeFromSuperview()
                
                // 3> 告诉上下文转场动画结束
                transitionContext.completeTransition(true)
        }
    }
    
    /// 根据屏幕宽度，计算给定图像的目标位置
    ///
    /// - parameter image: 图像
    ///
    /// - returns: 目标位置
    /// - 如果是短图，需要居中显示
    /// - 如果是长度，需要置顶
    private func imageRectWithScreen(image: UIImage) -> CGRect {
        
        let screenSize = UIScreen.mainScreen().bounds.size
        var imageSize = screenSize
        
        // 等比例缩放
        imageSize.height = image.size.height * imageSize.width / image.size.width
        var rect = CGRect(origin: CGPointZero, size: imageSize)
        
        // 计算短图
        if imageSize.height < screenSize.height {
            rect.origin.y = (screenSize.height - imageSize.height) * 0.5
        }
        
        return rect
    }
    
    /// 解除动画 - 目标：从 browser 回到 homeVC
    private func dismissTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // 1. 照片浏览视图 to? / from?
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        
        print(fromVC)
        print(fromView)
        
        // 2. 动画代码
        UIView.animateWithDuration(
            transitionDuration(transitionContext),
            animations: { () -> Void in
                fromView.alpha = 0
            }) { (_) -> Void in
                
                // 3. 将照片视图从容器视图删除
                fromView.removeFromSuperview()
                
                // 4. 结束转场
                transitionContext.completeTransition(true)
        }
    }
}
