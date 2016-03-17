//
//  MessageViewController.swift
//  上海微博
//
//  Created by teacher on 16/2/21.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

class MessageViewController: RootViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置访客视图
        visitorView?.setupInfo("visitordiscover_image_message",
            message: "登录后，别人评论你的微博，发给你的消息，都会在这里收到通知")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        print("Message 的 window \(self.view.window)")
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
