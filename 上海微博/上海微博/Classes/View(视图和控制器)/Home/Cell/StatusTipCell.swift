//
//  StatusTipCell.swift
//  上海微博
//
//  Created by teacher on 16/2/27.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

/// 微博提示 Cell
class StatusTipCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel?.text = "世界上最遥远的距离是没有网络"
        contentView.backgroundColor = UIColor.cz_colorWithHex(0xFFFF00)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
