//
//  ScheduleViewControllerDebug.swift
//  handmadeCalenderSampleOfSwift
//
//  Created by Claude on 2025/05/09.
//  Copyright © 2025 foresthill. All rights reserved.
//

import Foundation
import UIKit

/// 閏月の移動ロジック問題を検証するためのデバッグヘルパー
extension ScheduleViewController {
    
    /// 旧暦テーブルの内容をデバッグ出力する
    func dumpAncientTable() {
        print("\n=== 旧暦テーブル(ancientTbl)の内容 ===")
        
        // 現在の年の閏月情報を表示
        let year = calendarManager.year ?? 0
        let leapMonth = calendarManager.converter.leapMonth
        let ommax = calendarManager.converter.ommax
        
        print("- 現在の年: \(year)年")
        print("- 閏月: \(leapMonth)月")
        print("- 月数: \(ommax)月（閏月含む）")
        
        // テーブルの内容を表示
        print("\nインデックス  通日  月")
        print("-----------------")
        
        for i in 0..<14 {
            let tblMonthValue = calendarManager.converter.ancientTbl[i][1]
            let description: String
            
            if tblMonthValue < 0 {
                // 負の値は閏月を示す
                description = "閏\(-tblMonthValue)月"
            } else if tblMonthValue == 0 {
                description = "テーブル終端"
            } else {
                description = "\(tblMonthValue)月"
            }
            
            print("[\(i)]  \(calendarManager.converter.ancientTbl[i][0])  \(description)")
        }
        
        print("=== テーブル表示終了 ===\n")
    }
    
    /// 閏月の移動をテストするための関数
    func testLeapMonthNavigation() {
        // 例：2025年の閏月を確認
        let testYear = 2025
        calendarManager.converter.tblExpand(inYear: testYear)
        
        let leapMonth = calendarManager.converter.leapMonth
        let ommax = calendarManager.converter.ommax
        
        print("===== 閏月の移動テスト開始 =====")
        print("テスト年: \(testYear)年")
        print("閏月: \(leapMonth)月")
        print("月数: \(ommax)月（閏月含む）")
        
        // 旧暦テーブルの表示
        dumpAncientTable()
        
        // テストケース1: 通常月から閏月への移動（例：6月末日→閏6月1日）
        if leapMonth > 0 {
            // 通常月の設定
            calendarManager.year = testYear
            calendarManager.month = leapMonth
            calendarManager.nowLeapMonth = false
            
            // 月末日を設定
            let monthDays = calendarManager.converter.ancientTbl[leapMonth][0] - calendarManager.converter.ancientTbl[leapMonth-1][0]
            calendarManager.day = monthDays
            
            print("\nテストケース1: 通常\(leapMonth)月\(monthDays)日 → 閏\(leapMonth)月1日")
            print("移動前: \(calendarManager.year!)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month!)月\(calendarManager.day!)日")
            
            // 次の日に移動
            moveToAncientNextDay()
            
            print("移動後: \(calendarManager.year!)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month!)月\(calendarManager.day!)日")
        }
        
        // テストケース2: 閏月から次の月への移動（例：閏6月末日→7月1日）
        if leapMonth > 0 {
            // 閏月の設定
            calendarManager.year = testYear
            calendarManager.month = leapMonth
            calendarManager.nowLeapMonth = true
            
            // 閏月の日数を取得
            let nextMonthIndex = leapMonth + 1
            let leapMonthDays = calendarManager.converter.ancientTbl[nextMonthIndex][0] - calendarManager.converter.ancientTbl[leapMonth][0]
            calendarManager.day = leapMonthDays
            
            print("\nテストケース2: 閏\(leapMonth)月\(leapMonthDays)日 → \(leapMonth + 1)月1日")
            print("移動前: \(calendarManager.year!)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month!)月\(calendarManager.day!)日")
            
            // 次の日に移動
            moveToAncientNextDay()
            
            print("移動後: \(calendarManager.year!)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month!)月\(calendarManager.day!)日")
        }
        
        // テストケース3: 次の月から閏月への移動（例：7月1日→閏6月末日）
        if leapMonth > 0 && leapMonth < 12 {
            // 閏月の次の月を設定
            calendarManager.year = testYear
            calendarManager.month = leapMonth + 1
            calendarManager.nowLeapMonth = false
            calendarManager.day = 1
            
            print("\nテストケース3: \(leapMonth + 1)月1日 → 閏\(leapMonth)月末日")
            print("移動前: \(calendarManager.year!)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month!)月\(calendarManager.day!)日")
            
            // 前の日に移動
            moveToAncientPreviousDay()
            
            print("移動後: \(calendarManager.year!)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month!)月\(calendarManager.day!)日")
        }
        
        // テストケース4: 閏月から通常月への移動（例：閏6月1日→6月末日）
        if leapMonth > 0 {
            // 閏月の設定
            calendarManager.year = testYear
            calendarManager.month = leapMonth
            calendarManager.nowLeapMonth = true
            calendarManager.day = 1
            
            print("\nテストケース4: 閏\(leapMonth)月1日 → \(leapMonth)月末日")
            print("移動前: \(calendarManager.year!)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month!)月\(calendarManager.day!)日")
            
            // 前の日に移動
            moveToAncientPreviousDay()
            
            print("移動後: \(calendarManager.year!)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month!)月\(calendarManager.day!)日")
        }
        
        print("\n===== 閏月の移動テスト終了 =====")
    }
}