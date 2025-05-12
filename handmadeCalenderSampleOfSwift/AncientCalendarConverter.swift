//
//  SingletonClass.swift
//  AncientCalendar
//
//  Created by Morioka Naoya on H28/04/12.
//  Copyright © 2016-2025 just1factory. All rights reserved.
//

import Foundation
import EventKit
import EventKitUI

class AncientCalendarConverter
{
    static let sharedInstance = AncientCalendarConverter()
    
    private init() {
        // 初期化処理があればここに記述
    }
};