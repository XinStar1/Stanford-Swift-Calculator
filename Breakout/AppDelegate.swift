//
//  AppDelegate.swift
//  Breakout
//
//  Created by azx on 15/12/24.
//  Copyright © 2015年 azx. All rights reserved.
//

import UIKit
import CoreMotion

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    struct Motion {
        static let Manager = CMMotionManager()
    }

}

