//
//  CalendarManager.swift
//  handmadeCalenderSampleOfSwift
//
//  Created by Morioka Naoya on 2022/04/01.
//  Copyright © 2022年 just1factory. All rights reserved.
//

import Foundation

class CalendarManager {
    
    // シングルトンインスタンス
    static let shared = CalendarManager()
    
    private init() {
        // 初期化処理
    }
    
    /** 月齢計算２（2016/09/24）
    http://news.local-group.jp/moonage/moonage.js.txt
 
    - parameter : 新暦（DateComponents）
    - returns: 月齢（Float）
    */
    //func calcMoonAge() -> Double {
    func calcMoonAge(_ comps: DateComponents) -> Double {
        var moonAge: Double
        
        //var nowDate = Date()
        
        let julian = getJulian(comps)
        print("julian = \(julian)")
        
        //var year = nowDate.getYear()
        //var year = comps.year
        
        var nmoon = getNewMoon(julian: julian)
        //getNewMoonは新月直前の日を与えるとうまく計算できないのでその対処
        //（一日前の日付で再計算してみる）
        if(nmoon > Double(julian)) {
            nmoon = getNewMoon(julian: julian - 1)
        }
        print("nmoon = \(nmoon)")
        
        //julian - nmoonが現在時刻の月齢
        moonAge = Double(julian) - nmoon
        
        print("moonAge = \(moonAge)")
        return moonAge
        
    }
    
    /** 月齢計算２ー新月日計算
     http://news.local-group.jp/moonage/moonage.js.txt
     
     - parameter : ユリウス
     - returns: 月齢（Float）
     */
    func getNewMoon(julian: UInt64) -> Double {
        let k     = Foundation.floor((Double(julian) - 2451550.09765) / 29.530589)
        let t     = k / 1236.85;
        let s     = Foundation.sin(2.5534 +  29.1054 * k)
        var nmoon = 2451550.09765
        nmoon += 29.530589  * k
        nmoon +=  0.0001337 * t * t
        nmoon -=  0.40720   * Foundation.sin((201.5643 + 385.8169 * k) * 0.017453292519943)
        nmoon +=  0.17241   * (s * 0.017453292519943);
        return nmoon;         // julian - nmoonが現在時刻の月齢
    }
    
    /** 月齢計算２ーユリウス通日計算
     http://news.local-group.jp/moonage/moonage.js.txt
     
     - parameter : 新暦（DateComponents）
     - returns: 月齢（Float）
     */
    func getJulian(_ comps: DateComponents) -> UInt64 {
        let today = Date()
        let sec = today.timeIntervalSince1970
        let millisec = UInt64(sec * 1000)   //intだとあふれるので注意
        print(millisec)
        return millisec
    }
}
