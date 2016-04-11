//
//  SingletonClass.swift
//  AncientCalendar
//
//  Created by Morioka Naoya on H28/04/12.
//  Copyright © 平成28年 just1factory. All rights reserved.
//

import Foundation
import EventKit
import EventKitUI

class SingletonClass
{
    class var sharedInstance: SingletonClass {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: SingletonClass? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = SingletonClass()
        }
        return Static.instance!
    }
};