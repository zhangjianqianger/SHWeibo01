//
//  StatusListViewModel.swift
//  上海微博
//
//  Created by teacher on 16/3/2.
//  Copyright © 2016年 itcast. All rights reserved.
//

import Foundation
import SDWebImage
import QorumLogs

/// 微博列表视图模型 - 负责加载[网络 / 本地数据库缓存]的数据
/// 视图模型 只管理逻辑和数据，不负责和 UI 打交道！
class StatusListViewModel {
    
    /// 微博视图模型数组
    lazy var statusList = [StatusViewModel]()
    /// 下拉刷新计数
    var pulldownCount: Int?
    
    /// 清理数据 - 在接收到内容警告时调用
    func cleanup() {
        statusList.removeAll()
    }
    
    /**
     重构方法的步骤
     
     1. 新建方法
     2. 将要抽取的代码复制到新方法中
     3. 检查参数，以及代码逻辑
    */
    /// 加载微博数据
    ///
    /// - parameter isPullup: 是否上拉刷新
    /// - parameter finished: 完成回调(是否成功)
    func loadStatus(isPullup: Bool, finished: (isSuccessed: Bool)->()) {
        
        // 下拉刷新索引 - 取数组第一项 id
        let since_id = isPullup ? 0 : (statusList.first?.status.id ?? 0)
        // 上拉刷新索引 - 去数组最后一项 id
        let max_id = !isPullup ? 0 : (statusList.last?.status.id ?? 0)
        
        // 加载微博数据
        StatusDAL.loadStatus(since_id, max_id: max_id) { (result, isSuccessed) -> () in
            
            if !isSuccessed {
                finished(isSuccessed: false)
                
                return
            }
            
            // 字典转模型
            // 遍历数组，字典转`模型`
            // 提示，在实际开发中，如果以下代码性能不好，也可以放在异步执行！
            var arrayM = [StatusViewModel]()
            for dict in (result ?? []) {
                arrayM.append(StatusViewModel(status: Status.yy_modelWithJSON(dict)!))
            }
            
            print("本次刷新数据条数 \(arrayM.count)")
            // 记录`下拉`刷新条数
            self.pulldownCount = (since_id > 0) ? arrayM.count : nil
            
            // 如果是上拉刷新，将刷新的数组放在后面
            if max_id > 0 {
                self.statusList += arrayM
            } else {
                self.statusList = arrayM + self.statusList
            }
            
            // 缓存单张图片，完成之后，再执行成功回调
            self.cacheSingleWebImage(arrayM, finished: finished)
        }
    }
    
    /// 缓存网路单张图片
    ///
    /// - parameter array: 本次网路请求获得的微博视图模型数据
    /// `应该在缓存单张图片完成`／更新视图模型中的配图视图的大小／ `完成回调刷新表格`
    /// 所有的图像框架，下载图像之前都会检查本地缓存，如果本地缓存已经存在，不会再次下次
    private func cacheSingleWebImage(array: [StatusViewModel], finished: (isSuccessed: Bool)->()) {
        
        // 1> 创建调度组
        let group = dispatch_group_create()
        // 数据长度 - 提示：一定要有办法计算缓存的数据长度！
        var dataLength = 0
        
        // 遍历数组，判断`原创微博／转发微博`是否是单张图片，如果单张图片需要缓存
        // 只有单张图片需要按照比例显示
        for viewModel in array {
            
            // 1. 判断微博配图数量
            if viewModel.picturesURLs?.count != 1 {
                continue
            }
            
            // 2. 一定是单张图片，获取 URL
            guard let urlString = viewModel.picturesURLs?[0].thumbnail_pic,
                url = NSURL(string: urlString) else {
                    continue
            }
            QL1(viewModel.picturesURLs)
            
            // 3. 下载图像，调用框架的核心函数
            // 2> 入组
            dispatch_group_enter(group)
            // 无论本地是否有缓存，都会返回图像
            SDWebImageManager.sharedManager().downloadImageWithURL(url,
                options: [],
                progress: nil,
                completed: { (image, _, _, _, _) -> Void in
                    
                    // 判断图像是否下载成功
                    if let image = image, data = UIImagePNGRepresentation(image) {
                        // 累加数据长度，注意：即使本地缓存存在，回调方法同样会被调用
                        dataLength += data.length
                        
                        // 更新模型对应的配图视图大小
                        viewModel.updateSingleImagePicturesViewSize()
                    }
                    
                    // 3> 出组
                    dispatch_group_leave(group)
            })
        }
        
        // 4> 监听下载完成，完成代码在异步执行！
        dispatch_group_notify(group, dispatch_get_global_queue(0, 0)) { () -> Void in
            // dataLength 中很有可能已经包含了本地缓存图像的大小
            print("单张图片缓存完成 \(dataLength / 1024) K \(NSThread.currentThread())")
            
            // 计算本次加载数据视图模型对应的行高
            for viewModel in array {
                viewModel.calcRowHeight()
            }
            
            // 主队列回调，执行完成回调
            dispatch_async(dispatch_get_main_queue()) {
                finished(isSuccessed: true)
            }
        }
    }
}