//
//  NewFeatureView.swift
//  上海微博
//
//  Created by teacher on 16/2/25.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import SnapKit

/// 新特性图像数量
private let CZNewFeatureImageCount = 4

/// 新特性视图
class NewFeatureView: UIView {

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
    
    // MARK: - 私有属性
    /// 分页控件
    private lazy var pageControl = UIPageControl()
}

// MARK: - 设置界面
extension NewFeatureView {
    
    private func setupUI() {
        
        // 2. 使用 UIScrollView 
        let scrollView = UIScrollView(frame: bounds)
        addSubview(scrollView)
        
        // 3. 添加图像
        for i in 0..<CZNewFeatureImageCount {
            let imageName = "new_feature_\(i + 1)"
            let iv = UIImageView(cz_imageName: imageName)
            
            scrollView.addSubview(iv)
            
            // 设置frame
            iv.frame = CGRectOffset(bounds, CGFloat(i) * bounds.width, 0)
        }
        
        // 4. 设置 contentSize，多加一页，保证最后一页仍然可以滚动
        scrollView.contentSize = CGSize(width: CGFloat(CZNewFeatureImageCount + 1) * bounds.width, height: 0)
        
        // 5. 设置其他属性
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.pagingEnabled = true
        
        // 6. 设置分页控件
        addSubview(pageControl)
        
        pageControl.hidesForSinglePage = true
        pageControl.numberOfPages = CZNewFeatureImageCount
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.blackColor()
        pageControl.currentPageIndicatorTintColor = CZAppearanceTintColor
        // 禁用交互
        pageControl.userInteractionEnabled = false
        
        // 7. 自动布局
        pageControl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).offset(-80)
        }
        
        // 8. 设置代理
        scrollView.delegate = self
    }
}

// MARK: - UIScrollViewDelegate
extension NewFeatureView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // 1. 计算当前所在页
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        // 2. 如果是最后一页，销毁当前视图
        if page == CZNewFeatureImageCount {
            removeFromSuperview()
        }
    }
    
    // 只要滚动视图发生滚动就会被调用
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width + 0.5)

        pageControl.currentPage = page
        
        // 如果最后一页，隐藏分页控件
        pageControl.hidden = (page == CZNewFeatureImageCount)
    }
}
