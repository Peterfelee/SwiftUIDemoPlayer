//
//  Constant.swift
//  MoviePlayer
//
//  Created by peterlee on 2019/9/19.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height
let kControlPlayerViewNextPlayNotificationName = "ControlPlayerViewNextPlayNotificationName "

func dpNew(value:CGFloat) -> CGFloat
{
    return (min(ScreenWidth, ScreenHeight)*value/375.0);
}
