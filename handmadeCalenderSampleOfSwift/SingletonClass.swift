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
    static let sharedInstance = SingletonClass()
    
    private init() {
        // 初期化処理があればここに記述
    }
};