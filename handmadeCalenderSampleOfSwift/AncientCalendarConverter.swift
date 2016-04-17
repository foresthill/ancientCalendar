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

class AncientCalendarConverter
{
    class var sharedInstance: AncientCalendarConverter {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: AncientCalendarConverter? = nil
        }
        dispatch_once(&Static.onceToken) {
//            AncientCalendarConverter.instance = AncientCalendarConverter()
        }
        return Static.instance!
    }
};