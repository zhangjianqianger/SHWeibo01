//
//  StatusViewModel.swift
//  上海微博
//
//  Created by teacher on 16/2/28.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import SDWebImage
import HMEmoticon

/// 结构体 - 在 Swift 中，结构体和类非常像
/**
    1. 可以定义属性
    2. 可以有`构造函数`

    关于结构体，在 Swift 中和对象有一个显著的区别

    在传值的时候，结构体是按`值(copy)`传递，对象是按`址(地址指针)`传递

    在 Swift 的标准语法库中，结构体非常多！类非常少，只有 4 个！
*/
struct StatusCellLayout {
    /// 控件间距
    let margin: CGFloat = 12
    /// 头像大小
    let iconSize = CGSize(width: 36, height: 36)
    
    /// 微博标签字体
    let statusFont = UIFont.systemFontOfSize(15)
    /// 转发微博标签字体
    let retweetedFont = UIFont.systemFontOfSize(14)

    /// 工具栏高度
    let toolbarHeight: CGFloat = 36
    
    /// 图片间距
    let picturesMargin: CGFloat = 2
    /// 每行图片数量
    let picturesPerRow: CGFloat = 3
    /// 配图视图宽度
    let picturesViewWidth: CGFloat
    /// 计算图片尺寸
    let pictureSize: CGSize
    
    init() {
        picturesViewWidth = UIScreen.mainScreen().bounds.width - 2 * margin
        
        let pictureWH = (picturesViewWidth - (picturesPerRow - 1) * picturesMargin) / picturesPerRow
        pictureSize = CGSize(width: pictureWH, height: pictureWH)
    }
}

/// 全局的微博 Cell 的布局信息结构体
let CZStatusCellLayout = StatusCellLayout()

/// 微博视图模型(提示：如果用 OC 开发，仍然继承自 NSObject)
/// Swift 中定义`模型`，继承自 NSObject 目的：使用 KVC 支持字典转模型
/// 如果没有任何父类，类的 `量级` 轻
class StatusViewModel: CustomStringConvertible {
    
    /// 微博模型
    var status: Status
    
    /// 行高属性
    var rowHeight: CGFloat = 0
    
    // MARK: - 用户数据
    /// 会员图标
    var userMemberImage: UIImage?
    /// 认证图标
    var userVipImage: UIImage?
    // MARK: - 微博数据
    /// 来源字符串
    var sourceText: String?
    /// 创建日期
    var createTime: NSDate?
    
    /// 微博属性文字
    var statusAttribteText: NSAttributedString?
    /// 转发微博属性文字
    var retweetedAttribteText: NSAttributedString?
    
    // MARK: - 配图视图，默认无大小
    /// 微博配图数组 - 如果被转发微博存在图像，原创微博没有图像
    var picturesURLs: [StatusPictures]? {
        return status.retweeted_status?.pic_urls ?? status.pic_urls
    }
    
    /// 原创微博的配图视图大小
    var picturesViewSize = CGSizeZero
    /// 被转发微博的配图视图大小
    var retweetedPicturesViewSize = CGSizeZero
    
    // MARK: - 被转发微博文本
    var retweetedText: String? {
        // 没有转发微博
        if status.retweeted_status == nil {
            return nil
        }
        
        // 拼接字符串
        return "@" + (status.retweeted_status?.user?.screen_name ?? "")
            + ":" + (status.retweeted_status?.text ?? "")
    }
    
    // MARK: - 构造函数
    /// 使用微博模型实例化视图模型
    ///
    /// - parameter status: 微博模型
    ///
    /// - returns: 视图模型
    init(status: Status) {
        self.status = status
        
        createUserData()
        createStatusData()
        
        // 测试代码，如果配图数量 >=4，将 pic_urls 只取前 4 个
//        if status.pic_urls?.count >= 4 {
//            let urls = status.pic_urls!
//            
//            status.pic_urls = Array(urls[0..<4])
//        }
        
        // 计算配图视图大小
        picturesViewSize = calcPicturesViewSize(status.pic_urls)
        retweetedPicturesViewSize = calcPicturesViewSize(status.retweeted_status?.pic_urls)
        
        let layout = CZStatusCellLayout
        statusAttribteText = HMEmoticonManager.sharedManager().emoticonStringWithString(
            status.text ?? "",
            font: layout.statusFont,
            textColor: UIColor.darkGrayColor())
        retweetedAttribteText = HMEmoticonManager.sharedManager().emoticonStringWithString(
            retweetedText ?? "",
            font: layout.retweetedFont,
            textColor: UIColor.darkGrayColor())
    }
    
    /// 描述信息
    var description: String {
        return status.description
    }
    
    // MARK: - 公共函数
    func calcRowHeight() {
        
        let layout = CZStatusCellLayout
        let labelSize = CGSize(width: layout.picturesViewWidth, height: CGFloat(MAXFLOAT))
        
        // 1. 原创微博
        // 1> 顶部视图 = 顶部间距 * 2 + 头像高度 + 顶部间距
        rowHeight = 3 * layout.margin + layout.iconSize.height
        
        // 2> 文字 = 文字高度 + 间距
        if let text = statusAttribteText {
            
//            rowHeight += (text as NSString).boundingRectWithSize(
//                labelSize,
//                options: .UsesLineFragmentOrigin,
//                attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15)],
//                context: nil).height
            rowHeight += text.boundingRectWithSize(
                labelSize,
                options: [.UsesLineFragmentOrigin],
                context: nil).height
            
            rowHeight += layout.margin
        }
        
        // 3> 配图视图，如果有：配图视图高度 + 间距
        if status.pic_urls?.count > 0 {
            rowHeight += picturesViewSize.height + layout.margin
        }
        
        // 2. 转发微博，不一定有
        if status.retweeted_status != nil {
            
            // 1> 文字：转发文字 + 2 * 间距
            if let text = retweetedAttribteText {
                
//                rowHeight += (text as NSString).boundingRectWithSize(
//                    labelSize,
//                    options: .UsesLineFragmentOrigin,
//                    attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)],
//                    context: nil).height
                rowHeight += text.boundingRectWithSize(
                    labelSize,
                    options: [.UsesLineFragmentOrigin],
                    context: nil).height
                
                rowHeight += 2 * layout.margin
            }
            
            // 2> 配图，如果有，配图视图高度 + 间距
            if status.retweeted_status?.pic_urls?.count > 0 {
                rowHeight += retweetedPicturesViewSize.height + layout.margin
            }
        }
        
        // 3. 工具栏
        rowHeight += layout.toolbarHeight
    }

    /// 更新`单张图片`的配图视图大小
    func updateSingleImagePicturesViewSize() {
        picturesViewSize = calcSinglePicturesViewSize(status.pic_urls)
        retweetedPicturesViewSize = calcSinglePicturesViewSize(status.retweeted_status?.pic_urls)
    }
    
    // MARK: - 私有函数
    /// 计算单张图像配图视图大小
    ///
    /// - parameter pic_urls: 配图视图数组
    ///
    /// - returns: 配图视图大小
    private func calcSinglePicturesViewSize(pic_urls: [StatusPictures]?) -> CGSize {
        
        // 判断配图数量
        if pic_urls?.count != 1 {
            return CGSizeZero
        }
        
        // 获取 url 字符串
        let urlString = pic_urls![0].thumbnail_pic
        
        // 使用 SDWebImage 的缓存函数，key = url的完整字符串
        // SDWebImage 是自己管理缓存，如果有内存警告，或者磁盘超限，会清理缓存
        guard let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(urlString) else {
            
            return CGSizeZero
        }
        // 提示：SDWebImage 从 3.7.4 开始，会将网络返回图像的自动按照当前设备的分辨率转换
        print("图像分辨率：\(image.scale)")
        // 恢复图像尺寸
        let scale = UIScreen.mainScreen().scale
        var size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        // 针对过窄或者过宽的图片处理
        let minWidth: CGFloat = 20
        let maxWidth: CGFloat = 300
        
        // 如果宽度过小，将宽度调整到20
        size.width = size.width < minWidth ? minWidth : size.width
        
        if size.width > maxWidth {
            // 等比例缩放
            size.width = maxWidth
            
            size.height = size.width * image.size.height / image.size.width
        }
        
        return size
    }
    
    private func calcPicturesViewSize(pic_urls: [StatusPictures]?) -> CGSize {
        
        // 1. 判断图片数量
        let count = pic_urls?.count ?? 0
        
        // 2. 如果没有图，直接返回 CGSizeZero
        if count == 0 {
            return CGSizeZero
        }
        
        // 1> 记录布局属性
        let layout = CZStatusCellLayout
        
        // 2> 计算行数
        let row = CGFloat((count - 1) / Int(layout.picturesPerRow) + 1)
        
        // 3> 根据行数计算视图高度
        let height = row * layout.pictureSize.height + (row - 1) * layout.picturesMargin
        
        return CGSize(width: layout.picturesViewWidth, height: height)
    }
    
    /// 计算微博数据
    private func createStatusData() {
        // 1. 来源字符串
        // <a href=\"http://weibo.com/\" rel=\"nofollow\">微博 weibo.com</a>
        // <a href=\"http://app.weibo.com/t/feed/6BAMHj\" rel=\"nofollow\">HUAWEI Mate 8</a>
        if let source = status.source,
            startIndex = source.rangeOfString("\">")?.endIndex,
            endIndex = source.rangeOfString("</a>")?.startIndex {
                
                // 提取字串
                sourceText = "来自 " + source.substringWithRange(startIndex..<endIndex)
        }
        
        // 2. 创建日期
        createTime = NSDate.cz_sinaDate(status.created_at)
    }
    
    /// 计算用户数据
    private func createUserData() {
        // 会员图标
        if status.user?.mbrank > 0 && status.user?.mbrank < 7 {
            userMemberImage = UIImage(named: "common_icon_membership_level\(status.user!.mbrank)")
        }
        
        // 认证图标 -1：没有认证，0，认证用户，2,3,5: 企业认证，220: 达人
        switch status.user?.verified_type ?? -1 {
        case 0: userVipImage = UIImage(named: "avatar_vip")
        case 2, 3, 5: userVipImage = UIImage(named: "avatar_enterprise_vip")
        case 220: userVipImage = UIImage(named: "avatar_grassroot")
        default: break
        }
    }
}