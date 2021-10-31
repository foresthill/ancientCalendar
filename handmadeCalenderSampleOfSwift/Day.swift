//
//  Day.swift
//  AncientCalendar
//  日付の情報一式を格納するクラス
//
//  Created by Morioka Naoya on H28/09/24.
//  Copyright © 平成28年 just1factory. All rights reserved.
//

import Foundation

class Day {
    
    /** 新暦（年） */
    var gregorianYear: Int!
    /** 新暦（月） */
    var gregorianMonth: Int!
    /** 新暦（日） */
    var gregorianDay: Int!
    /** 新暦（曜日） */
    var gregorianDayOfWeek: Int!
    /** 旧暦（年） */
    var ancientYear: Int!
    /** 旧暦（月） */
    var ancientMonth: Int!
    /** 旧暦（日） */
    var ancientDay: Int!
    /** 旧暦（曜日） */
    var ancientDayOfWeek: Int!
    /** 月齢 */
    var moonAge: Double!
    /** 月名 */
    var moonName: String!
    /** イベント（題名） */
    var eventTitle: String!
    /** イベント（詳細） */
    var eventDetail: String!
    
    /** 初期化メソッド */
    init() {
        
    }
    
    
}
