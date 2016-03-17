//
//  ComposePictureCell.swift
//  上海微博
//
//  Created by teacher on 16/3/4.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

/// 发布微博选择图像 Cell 协议
@objc protocol ComposePictureCellDelegate: NSObjectProtocol {
    
    optional func composePictureCellDidAddPicture(cell: ComposePictureCell)
    optional func composePictureCellDidRemovePicture(cell: ComposePictureCell)
}

/// 发布微博选择图像 Cell
class ComposePictureCell: UICollectionViewCell {
    
    /// 代理
    weak var delegate: ComposePictureCellDelegate?
    
    /// 图像
    var image: UIImage? {
        didSet {
            // 如果没有图像，隐藏删除按钮
            removePictureButton.hidden = (image == nil)
            
            // 1. 如果 image == nil，显示默认的加号按钮
            if image == nil {
                addPictureButton.setBackgroundImage(UIImage(named: "compose_pic_add"), forState: .Normal)
                addPictureButton.setBackgroundImage(UIImage(named: "compose_pic_add_highlighted"), forState: .Highlighted)
                
                // 清空按钮图像
                addPictureButton.setImage(nil, forState: .Normal)
                
                return
            }
            // 2. 否则显示图像
            addPictureButton.setImage(image, forState: .Normal)
            addPictureButton.setBackgroundImage(nil, forState: .Normal)
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
    
    // MARK: - 监听方法
    @objc private func clickAddPictureButton() {
        delegate?.composePictureCellDidAddPicture?(self)
    }
    
    @objc private func clickRemovePictureButton() {
        delegate?.composePictureCellDidRemovePicture?(self)
    }
    
    // MARK: - 私有控件
    /// 添加照片按钮
    private lazy var addPictureButton = UIButton(cz_title: nil, backImageName: "compose_pic_add")
    /// 删除按钮
    private lazy var removePictureButton = UIButton(cz_title: nil, imageName: "compose_photo_close")
}

// MARK: - 设置界面
extension ComposePictureCell {
    
    private func setupUI() {
        
        // 1. 添加控件
        contentView.addSubview(addPictureButton)
        contentView.addSubview(removePictureButton)
        
        // 2. 自动布局
        let margin: CGFloat = 10
        addPictureButton.snp_makeConstraints { (make) -> Void in
            // snp 的 edges 设置 UIEdgeInsets 的 offset 的时候，才会有内存泄漏
            // make.edges.equalTo(contentView).offset(UIEdgeInsets(top: 10, left: 10, bottom: -10, right: -10))
            make.left.equalTo(contentView).offset(margin)
            make.right.equalTo(contentView).offset(-margin)
            make.top.equalTo(contentView).offset(margin)
            make.bottom.equalTo(contentView).offset(-margin)
        }
        removePictureButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(contentView)
            make.top.equalTo(contentView)
        }
        
        // 3. 添加监听方法
        addPictureButton.addTarget(self, action: "clickAddPictureButton", forControlEvents: .TouchUpInside)
        removePictureButton.addTarget(self, action: "clickRemovePictureButton", forControlEvents: .TouchUpInside)
        
        // 4. 设置内容模式 － 一定设置 imageView 的内容模式
        // addPictureButton.contentMode = .ScaleAspectFill
        addPictureButton.imageView?.contentMode = .ScaleAspectFill
    }
}
