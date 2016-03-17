//
//  PhotoViewerController.swift
//  上海微博
//
//  Created by teacher on 16/3/11.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import SDWebImage

/// 单张照片查看控制器 - 显示单张照片使用
class PhotoViewerController: UIViewController {

    // MARK: - 属性和控件
    private lazy var scrollView = UIScrollView()
    lazy var imageView = UIImageView()
    
    /// 显示图像的 URL 字符串
    private let urlString: String
    /// 显示照片对应数组中的下标索引
    let photoIndex: Int
    
    // MARK: - 构造函数，不要通过 setter 方法传递，因为`视图控制器`被实例化之后，如果不调用 view
    // 视图不会被创建，回顾`私人通讯录的编辑功能`
    init(urlString: String, photoIndex: Int) {
        self.urlString = urlString
        self.photoIndex = photoIndex
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadImage()
    }
    
    deinit {
        print("\(classForCoder) \(__FUNCTION__)")
    }
    
    /// 加载图像 - URLString 对应的图像
    private func loadImage() {
        
        guard let url = NSURL(string: urlString) else {
            return
        }
        
        // 错误的代码
        // imageView.sd_setImageWithURL(url)
        imageView.sd_setImageWithURL(url, placeholderImage: nil) { (image, _, _, _) -> Void in
            
            guard let image = image else {
                return
            }
            
            // 设置图像视图大小
            self.setImagePosition(image)
        }
    }
    
    /// 设置图像位置(长短图)
    ///
    /// - parameter image: 图像
    private func setImagePosition(image: UIImage) {

        let size = imageSizeWithScreen(image)
        
        imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        // 长图需要`滚动`
        scrollView.contentSize = size
        
        // 短图(size.height < scrollView.bounds.height)调整 y 值
        if size.height < scrollView.bounds.height {
            imageView.frame.origin.y = (scrollView.bounds.height - size.height) * 0.5
        }
    }
    
    /// 将指定图像按照屏幕宽度计算显示尺寸
    ///
    /// - parameter image: 图像
    private func imageSizeWithScreen(image: UIImage) -> CGSize {
        var size = UIScreen.mainScreen().bounds.size
        
        size.height = image.size.height * size.width / image.size.width
        
        return size
    }
}

// MARK: - 设置界面
extension PhotoViewerController {
    
    private func setupUI() {
        view.backgroundColor = UIColor.blueColor()
        
        // 1. 添加控件
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        // 2. 指定大小
        scrollView.frame = view.bounds

        // 3. 测试 - imageView 的大小需要根据显示的图片，动态调整
        imageView.backgroundColor = UIColor.lightGrayColor()
    }
}
