//
//  StatusPicturesView.swift
//  上海微博
//
//  Created by teacher on 16/3/1.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

/// 选中照片通知名
let CZStatusPicturesViewDidSelectedNotification = "CZStatusPicturesViewDidSelectedNotification"
/// 选中索引 KEY
let CZStatusPicturesViewSelectedIndexKey = "CZStatusPicturesViewSelectedIndexKey"
/// 当前 URL 字符串 KEY
let CZStatusPicturesViewURLsKey = "CZStatusPicturesViewURLsKey"
/// 当前的所有`可见`的 imageViews
let CZStatusPicturesViewImageViewsKey = "CZStatusPicturesViewImageViewsKey"

/// 微博配图视图
class StatusPicturesView: UIView {
    
    /// 配图视图数组
    var pic_urls: [StatusPictures]? {
        didSet {
            
            // 1. 隐藏所有的图像视图
            for v in subviews {
                v.hidden = true
            }
            
            // 2. 遍历数组，依次设置图像
            var index = 0
            for url in (pic_urls ?? []) {
                
                // 1. 根据遍历的 `索引` 获取到图像视图
                let iv = subviews[index++] as! UIImageView
                
                // 2. 设置图像
                iv.cz_setImageWithURL(url.thumbnail_pic, placeholderName: nil)
                
                // 3. 显示图像
                iv.hidden = false
                
                // 4. 处理4张图像
                if index == 2 && pic_urls?.count == 4 {
                    index++
                }
                
                // 5. 判断是否显示 gif `pathExtension` 获取文件名的扩展名
                iv.subviews[0].hidden = (url.thumbnail_pic ?? "" as NSString).pathExtension.lowercaseString != "gif"
            }
        }
    }
    
    /// 更新图像尺寸
    func updateImageSize(size: CGSize) {
        
        let iv = subviews[0]
        
        // 1. 如果单张图像，需要把 第 0 UIImageView 大小调整
        if pic_urls?.count == 1 {
            iv.frame = CGRect(origin: CGPointZero, size: size)
            
            return
        }
        
        // 2. 如果不是单张图像，恢复 第 0 UIImageView 的大小
        iv.frame = CGRect(origin: CGPointZero, size: CZStatusCellLayout.pictureSize)
    }
    
    // MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 监听方法
    @objc private func tapImageView(recognizer: UITapGestureRecognizer) {
        
        // 1. 根据 tag 获取点击对应的图像
        var index = recognizer.view!.tag
        
        // 针对四张图片单独处理
        if pic_urls?.count == 4 && index > 2 {
            index--
        }
        
        // 2. 获取对应的图像的 url 字符串
        // 传递模型好(当前程序便于开发)，还是传递字符串数组好(便于抽取框架，降低依赖)？
        // 目标：从 pic_urls(数组) 中获得 bmiddle_pic(属性) 的字符串数组 -> KVC
        guard let pic_urls = pic_urls else {
            return
        }
        
        // Swift 中 `String`, `数组`，`字典`在和 OC 的类型转换时，不需要使用 as!/as? 底层语法会自动桥接
        let urls = (pic_urls as NSArray).valueForKey("bmiddle_pic")
        
        // 3. 获取当前所有`可见`的 imageViews
        var imageViews = [UIImageView]()
        for iv in subviews {
            if !iv.hidden {
                imageViews.append(iv as! UIImageView)
            }
        }
        
        // 3. 发送通知
        NSNotificationCenter.defaultCenter().postNotificationName(
            CZStatusPicturesViewDidSelectedNotification,
            object: self,
            userInfo: [CZStatusPicturesViewSelectedIndexKey: index,
                CZStatusPicturesViewURLsKey: urls,
                CZStatusPicturesViewImageViewsKey: imageViews])
    }
}

// MARK: - 设置界面
extension StatusPicturesView {
    
    private func setupUI() {
        // 0. 设置背景颜色
        backgroundColor = superview?.backgroundColor
        // 超出视图范围的内容，全部裁切掉
        // 在用 storyboard 开发的时候，默认是 true，但是，使用 代码开发，默认是 false
        clipsToBounds = true
        
        // 1. 添加 `9` 个图像视图
        // 每张图像的bounds
        let rect = CGRect(origin: CGPointZero, size: CZStatusCellLayout.pictureSize)
        // 移动步长
        let step = CZStatusCellLayout.pictureSize.width + CZStatusCellLayout.picturesMargin
        
        for i in 0..<9 {
            let iv = UIImageView()
            
            // 设置内容填充模式 .ScaleAspectFit 在九宫格能够产生犬牙交错的效果
            iv.contentMode = .ScaleAspectFill
            iv.clipsToBounds = true
            
            // 设置视图的位置
            // 1> 根据 i 计算出每张图片所在的行和列
            let row = CGFloat(i / Int(CZStatusCellLayout.picturesPerRow))
            // `模`数
            let col = CGFloat(i % Int(CZStatusCellLayout.picturesPerRow))
            
            // 2> 设置位置
            iv.frame = CGRectOffset(rect, col * step, row * step)
            
            addSubview(iv)
            
            // 3> 允许 iv 交互
            iv.tag = i
            iv.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: "tapImageView:")
            
            iv.addGestureRecognizer(tap)
            
            // 4> 添加 gif 图片
            let gifImageView = UIImageView(cz_imageName: "timeline_image_gif")
            iv.addSubview(gifImageView)
            
            gifImageView.snp_makeConstraints(closure: { (make) -> Void in
                make.right.equalTo(iv)
                make.bottom.equalTo(iv)
            })
        }
    }
}
