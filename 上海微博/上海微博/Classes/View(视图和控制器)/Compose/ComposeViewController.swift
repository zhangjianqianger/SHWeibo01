//
//  ComposeViewController.swift
//  上海微博
//
//  Created by teacher on 16/3/2.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import SVProgressHUD
import HMImagePicker
import HMEmoticon

/// 最大文字长度
private let CZComposeMaxLength = 140
/// 最大选择照片数量
private let CZComposeMaxPicturesCount = 6
/// 选择图像可重用标识符
private let CZComposePictureCellIdentifier = "CZComposePictureCellIdentifier"

/// 撰写微博控制器
class ComposeViewController: UIViewController {

    // MARK: - 视图生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        // `监听`键盘变化
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillChanged:",
            name: UIKeyboardWillChangeFrameNotification,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // 激活键盘
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 退出键盘
        textView.resignFirstResponder()
    }
    
    // MARK: - 监听方法
    /// 键盘变化监听方法
    /**
        键盘变化时，会提示
        -[UIWindow endDisablingInterfaceAutorotationAnimated:] 错误
        发生在 2009 年，偶尔会好，经常会出现
    */
    @objc private func keyboardWillChanged(notification: NSNotification) {
        print(notification)
        
        // 1. 从字典中获取目标键盘位置
        // `CG的结构体` CGPoint/CGSize/CGRect 要保存在字典中，需要转换成 NSValue
        let rect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        // 动画时长
        let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        // 动画曲线 7
        let curve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue
        
        // 2. 更新 toolbar 的位置
        let offset = view.bounds.height - rect.origin.y
        toolbar.snp_updateConstraints { (make) -> Void in
            make.bottom.equalTo(view).offset(-offset)
        }
        
        // 3. 动画显示约束变化
        UIView.animateWithDuration(duration) { () -> Void in
            
            // 设置`动画曲线`
            // 曲线值 7，官方没有文档，但是通过测试和谷歌，有一个特点
            // 1> 如果连续多次动画，并且之前的动画没有结束，让`动画的视图`，直接运行到最后一个动画的目标位置，可以避免跳跃
            // 2> 一旦设置了动画曲线 7，duration 无效，并且动画时长固定在 `0.5s`
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve)!)
            
            self.view.layoutIfNeeded()
        }
        
        // 4. 测试 toolbar 上的动画时长，系统内部的动画，绝大多数，可以通过 key path 得值获取动画对象
        // 如果今后开发中，需要指定 动画的 key，直接使用 key path 即可！
        let anim = toolbar.layer.animationForKey("position")
        print("动画时长 \(anim?.duration)")
    }
    
    /// 点击取消按钮
    @objc private func clickCancelButton() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// 点击发布按钮
    @objc private func clickPostButton() {
        // 1. 获取文本
        guard let text = textView.emoticonText else {
            return
        }
        
        // 2. 判断文本长度
        if text.characters.count > CZComposeMaxLength {
            SVProgressHUD.showInfoWithStatus("输入的文本过长", maskType: .Gradient)
            
            return
        }

        // 3. 发布微博
        NetworkTools.sharedTools.postStatus(text, image: images.first) { (result) -> () in
            
            // 1> 判断 result == nil，表示网络访问失败
            if result == nil {
                SVProgressHUD.showInfoWithStatus("您的网络不给力")

                return
            }
            
            // 2> 发布完成
            SVProgressHUD.showInfoWithStatus("发布成功")
            
            // 3> 返回
            delay() {
                self.clickCancelButton()
            }
        }
    }
    
    /// 选择图片
    @objc private func selectPicture() {
        // 显示 图片视图
        collectionView.hidden = false
        
        // 更新约束
        textView.updateTipLabelBottomConstraints(collectionView)
        
        // 退掉键盘
        textView.resignFirstResponder()
        
        // 退掉键盘会触发键盘监听方法，会更新视图的布局约束
//        textView.updateTipLabelConstraints(collectionView)
    }
    
    /// 选择表情
    @objc private func selectEmotion() {
        textView.useEmoticonInputView = !textView.useEmoticonInputView
    }
    
    // MARK: - 私有控件
    /// 工具栏
    private lazy var toolbar: UIToolbar = UIToolbar()
    /// 文本视图
    private lazy var textView: HMEmoticonTextView = HMEmoticonTextView()
    /// 选择图片视图
    private lazy var collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: ComposePictureViewLayout())
    /// 图像数组
    private lazy var images: [UIImage] = [UIImage]()
    /// 选中素材集合（通过素材集合可以和底层相册通讯）
    private var selectedAssets: [PHAsset]?
    /// 用户选中照片索引
    private var selectedIndex = 0
}

// MARK: - 私有类
/// 视图布局
private class ComposePictureViewLayout: UICollectionViewFlowLayout {
    
    private override func prepareLayout() {
        super.prepareLayout()
        
        // 此方法是在 collectionView 准备布局的时候被调用
        // 此时 collectionView 的 bounds 已经设置完毕！
        print(collectionView)
        
        // 计算 cell 的大小
        let margin: CGFloat = 10
        let count: CGFloat = 3
        let width = (collectionView!.bounds.width - (count - 1) * margin) / count
        
        itemSize = CGSize(width: width, height: width)
        minimumInteritemSpacing = margin
        minimumLineSpacing = margin
    }
}

// MARK: - UITextViewDelegate
extension ComposeViewController: UITextViewDelegate {
    
    /// 文本发生变化代理方法
    ///
    /// - parameter textView: textView
    func textViewDidChange(textView: UITextView) {
        // 根据文本内容确定是否激活右侧发布按钮
        navigationItem.rightBarButtonItem?.enabled = textView.hasText()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ComposeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 如果已经到达最大数量，显示 images.count 
        // 否则，比图像数组多 1，末尾的按钮显示加号按钮
        return (images.count >= CZComposeMaxPicturesCount) ? images.count : images.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CZComposePictureCellIdentifier, forIndexPath: indexPath) as! ComposePictureCell
        
        // 比图像数组多 1，末尾的按钮显示加号按钮
        // cell.backgroundColor = UIColor.cz_randomColor()
        // 设置 cell 的图像，最后一张为 `nil`，显示默认的 + 按钮
        // Result values in '? :' expression have mismatching types '_' and 'UIImage'
        let image: UIImage? = (indexPath.item == images.count) ? nil : images[indexPath.item]
        
        cell.image = image
        
        // 设置代理
        cell.delegate = self
        
        return cell
    }
}

// MARK: - ComposePictureCellDelegate
extension ComposeViewController: ComposePictureCellDelegate {
    /// 删除照片
    func composePictureCellDidRemovePicture(cell: ComposePictureCell) {
        print("删除照片")
        
        // 1. 根据 cell 获得对应的 indexPath
        let indexPath = collectionView.indexPathForCell(cell)!
        
        // 2. 根据 indexPath 删除数据源 images 中的图像
        images.removeAtIndex(indexPath.item)
        
        // 3. 刷新表格
        collectionView.reloadData()
    }
    
    /// 添加照片
    func composePictureCellDidAddPicture(cell: ComposePictureCell) {
        print("添加照片")
        // 记录用户当前选中的照片索引
        selectedIndex = collectionView.indexPathForCell(cell)!.item
        
        // 实例化照片选择器
        let picker = HMImagePickerController(selectedAssets: selectedAssets)
        
        // 设置最大图片数量
        picker.maxPickerCount = CZComposeMaxPicturesCount
        
        picker.pickerDelegate = self
        
        presentViewController(picker, animated: true, completion: nil)
    }
}

extension ComposeViewController: HMImagePickerControllerDelegate {
    
    func imagePickerController(picker: HMImagePickerController, didFinishSelectedImages images: [UIImage], selectedAssets: [PHAsset]?) {
        
        self.images = images
        self.selectedAssets = selectedAssets
        
        collectionView.reloadData()
        
        // 关闭控制器
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ComposeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // print(info)
        
        // 在开发相册的应用程序的时候，必须要考虑内存！
        // 从 info 字典获取图像
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        // 指定目标宽度
        let width: CGFloat = 600
        let height = width * image.size.height / image.size.width
        
        image.cz_asyncDrawImage(CGSize(width: width, height: height)) { (image) -> () in
            
            // 判断 selectedIndex 是否超出数组范围，如果超出，新建
            if self.selectedIndex >= self.images.count {
                // 添加到图像数组
                self.images.append(image)
            } else {
                // 更新索引对应的图像
                self.images[self.selectedIndex] = image
            }
            
            // 刷新数据
            self.collectionView.reloadData()
            
            // 提示：如果实现代理方法，必须手动关闭控制器
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

// MARK: - 设置界面
extension ComposeViewController {
    
    private func setupUI() {
        view.backgroundColor = UIColor.whiteColor()
        
        // 1. 准备导航栏
        prepareNavigationBar()
        
        // 2. 准备工具栏
        prepareToolbar()
        
        // 3. 准备textView
        prepareTextView()
        
        // 4. 选择图片
        prepareCollectionView()
    }
  
    /// 准备选择图像视图
    private func prepareCollectionView() {
        
        // 是文本视图的子视图
        textView.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.cz_colorWithHex(0xF5F5F5)
        
        // 自动布局
        let margin = CZStatusCellLayout.margin
        collectionView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(margin)
            make.right.equalTo(view).offset(-margin)
            
            make.height.equalTo(collectionView.snp_width)
            make.top.equalTo(textView).offset(100)
        }
        
        // 设置数据源和代理
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 注册可重用 cell
        collectionView.registerClass(ComposePictureCell.self,
            forCellWithReuseIdentifier: CZComposePictureCellIdentifier)
        
        // 隐藏图片视图
        collectionView.hidden = true
    }
    
    /// 准备文本视图
    private func prepareTextView() {
        
        // 添加控件
        view.addSubview(textView)
        
        // 自动布局
        textView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view)
            make.right.equalTo(view)
            
            // snp_topLayoutGuideBottom 如果上方有导航栏／状态栏..能够让开
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.bottom.equalTo(toolbar.snp_top)
        }
        
        // 设置文本变化监听代理
        textView.delegate = self
        
        // 设置最大文本长度
        textView.maxInputLength = CZComposeMaxLength
        textView.placeholder = "我是占位文本..."
    }
    
    /// 准备工具栏
    private func prepareToolbar() {
        
        // 1. 添加控件
        view.addSubview(toolbar)
        
        // 2. 自动布局
        toolbar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            
            make.height.equalTo(44)
        }
        
        // 3. 添加按钮
        let itemSettings = [["imageName": "compose_toolbar_picture", "actionName": "selectPicture"],
            ["imageName": "compose_mentionbutton_background"],
            ["imageName": "compose_trendbutton_background"],
            ["imageName": "compose_emoticonbutton_background", "actionName": "selectEmotion"],
            ["imageName": "compose_add_background"]]
        
        toolbar.items = [UIBarButtonItem]()
        
        for dict in itemSettings {
            
            let imageName = dict["imageName"]!
            let itemButton = UIButton(cz_title: nil, imageName: imageName)
            
            // 判断是否有 actionName
            if let actionName = dict["actionName"] {
                
                // 提示：如果用常量创建，需要使用 Selector(actionName) 构造函数
                itemButton.addTarget(self, action: Selector(actionName), forControlEvents: .TouchUpInside)
            }
            
            toolbar.items?.append(UIBarButtonItem(customView: itemButton))

            // 添加弹簧
            toolbar.items?.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil))
        }
        toolbar.items?.removeLast()
    }
    
    /// 准备导航栏
    private func prepareNavigationBar() {
        
        // 1. 设置导航按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "取消",
            style: .Plain,
            target: self,
            action: "clickCancelButton")
        
        // 右侧按钮
        let postButton = UIButton(
            cz_title: "发布",
            fontSize: 14,
            color: UIColor.whiteColor(),
            backImageName: "common_button_orange")
        postButton.addTarget(self, action: "clickPostButton", forControlEvents: .TouchUpInside)
        
        // 1> 大小
        postButton.frame = CGRect(x: 0, y: 0, width: 50, height: 35)
        // 2> 禁用设置
        postButton.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
        postButton.setBackgroundImage(UIImage(named: "common_button_white_disable"), forState: .Disabled)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: postButton)
        // 需要有内容，才允许发布
        navigationItem.rightBarButtonItem?.enabled = false
        
        // 2. 设置导航标题
        let titleLabel = UILabel()
        
        // 属性文本
        let attrText = NSMutableAttributedString(
            string: "发微博\n",
            attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15),
                NSForegroundColorAttributeName: UIColor.darkGrayColor()])
        
        let userName = UserAccount.sharedUserAccount.screen_name ?? ""
        let nameText = NSAttributedString(
            string: userName,
            attributes: [NSFontAttributeName: UIFont.systemFontOfSize(12),
                NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        
        attrText.appendAttributedString(nameText)
        
        titleLabel.attributedText = attrText
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
        titleLabel.textAlignment = .Center
        
        navigationItem.titleView = titleLabel
    }
}
