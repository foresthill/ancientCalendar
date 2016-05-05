//
//  MyNavigationController.swift
//  AncientCalendar
//
//  Created by Morioka Naoya on H28/05/04.
//  Copyright © 平成28年 foresthill. All rights reserved.
//

import UIKit

class MyNavigationController: UINavigationController {
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return self.visibleViewController
    }
}
