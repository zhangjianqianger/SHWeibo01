//
//  ProfileViewController.swift
//  上海微博
//
//  Created by teacher on 16/2/21.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

class ProfileViewController: RootViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置访客视图
        visitorView?.setupInfo("visitordiscover_image_profile",
            message: "登录后，你的微博、相册、个人资料会显示在这里，展示给别人")
        
        // 测试 token 失效
        UserAccount.sharedUserAccount.access_token = "123456"
        print("token 已经被设置成无效字符串，模拟 token 过期")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
