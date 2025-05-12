//
//  MoonAgeComparisonTest.swift
//  handmadeCalenderSampleOfSwift
//
//  Created with Claude Code on 2025/05/09.
//  Copyright © 2025 foresthill. All rights reserved.
//

import Foundation

/**
 * 月齢計算の比較テスト
 * 天文学的計算の小数第二位を切り捨てた場合と伝統的計算（旧暦日-1）を比較する
 */
class MoonAgeComparisonTest {
    
    // CalendarManagerのインスタンス
    let calendarManager = CalendarManager.sharedInstance
    
    // テスト実行関数
    func runTests() {
        print("\n==========================================")
        print("       月齢計算比較テスト（小数点処理）      ")
        print("==========================================\n")
        
        // 3つの期間で連続7日間の月齢変化をテスト
        
        // 1. 新月周辺期間（2025年3月1日前後）
        testConsecutiveDays(startYear: 2025, startMonth: 2, startDay: 28, daysToTest: 7, title: "新月周辺期間")
        
        // 2. 満月周辺期間（2025年3月15日前後）
        testConsecutiveDays(startYear: 2025, startMonth: 3, startDay: 14, daysToTest: 7, title: "満月周辺期間")
        
        // 3. 2025年3月17日を含む期間
        testConsecutiveDays(startYear: 2025, startMonth: 3, startDay: 15, daysToTest: 7, title: "参照日（3/17）周辺期間")
        
        print("\n==========================================")
        print("       月齢計算比較テスト終了              ")
        print("==========================================")
    }
    
    // 連続する日数の月齢を比較するテスト
    private func testConsecutiveDays(startYear: Int, startMonth: Int, startDay: Int, daysToTest: Int, title: String) {
        print("\n=== \(title) (\(startYear)/\(startMonth)/\(startDay)から\(daysToTest)日間) ===\n")
        
        // ヘッダーを表示
        print("日付          | 旧暦          | 旧暦日-1 | 天文学的 | 天文学的(小数点1位) | 天文学的と旧暦日-1の差")
        print("----------------------------------------------------------------------------")
        
        for offset in 0..<daysToTest {
            // 日付を設定
            var dateComponents = DateComponents()
            dateComponents.year = startYear
            dateComponents.month = startMonth
            dateComponents.day = startDay + offset
            
            // 計算前の状態を保存
            let savedComps = calendarManager.comps
            
            // 指定された日付をセット
            calendarManager.comps = dateComponents
            
            // 旧暦日付を取得
            let ancientDate = calendarManager.converter.convertForAncientCalendar(comps: dateComponents)
            let ancientYear = ancientDate[0]
            let ancientMonth = ancientDate[1]
            let ancientDay = ancientDate[2]
            let isLeapMonth = ancientDate[3]
            
            // 旧暦日から月齢を計算（伝統的計算）
            let traditionalAge = Double(ancientDay - 1)
            
            // 天文学的計算による月齢
            let astroAge = calendarManager.calcMoonAgeAstronomical()
            
            // 天文学的計算の小数第一位で切り捨て
            let astroAgeTruncated = floor(astroAge * 10) / 10
            
            // 差分を計算
            let difference = abs(astroAgeTruncated - traditionalAge)
            
            // 結果表示（テーブル形式）
            let newDate = "\(startYear)/\(startMonth)/\(startDay + offset)"
            let ancientDateStr = "\(ancientYear)/\(isLeapMonth < 0 ? "閏" : "")\(ancientMonth)/\(ancientDay)"
            print(String(format: "%-13s | %-13s | %7.1f | %8.2f | %19.1f | %15.1f", 
                         newDate, ancientDateStr, traditionalAge, astroAge, astroAgeTruncated, difference))
            
            // 元のcompsに戻す
            calendarManager.comps = savedComps
        }
    }
}

// テスト実行
let comparisonTest = MoonAgeComparisonTest()
comparisonTest.runTests()