//
//  MoonAgeTestRunner.swift
//  handmadeCalenderSampleOfSwift
//
//  Created with Claude Code on 2025/05/09.
//  Copyright © 2025 foresthill. All rights reserved.
//

import Foundation

// テスト実行用のスクリプト
class MoonAgeTestRunner {
    
    // CalendarManagerのインスタンス
    let calendarManager = CalendarManager.sharedInstance
    
    // 実行関数
    func run() {
        print("\n==========================================")
        print("          月齢計算テスト実行開始          ")
        print("==========================================\n")
        
        // 1. 旧暦の重要な日のテスト（新月、上弦、満月、下弦）
        testLunarKeyDates()
        
        // 2. 特定の日付での月齢テスト
        testSpecificDates()
        
        // 3. 連続する数日間の月齢変化
        testConsecutiveDays()
        
        print("\n==========================================")
        print("          月齢計算テスト実行終了          ")
        print("==========================================")
    }
    
    // 旧暦の重要な日のテスト
    func testLunarKeyDates() {
        print("\n=== 旧暦の重要な日の月齢テスト ===\n")
        
        // 旧暦の日付と期待される月齢のペア
        let lunarDates = [
            // 旧暦日付(年月日)と期待される月齢
            (2025, 2, 1, 0.0),  // 新月
            (2025, 2, 8, 7.0),  // 上弦
            (2025, 2, 15, 14.0), // 満月
            (2025, 2, 23, 22.0)  // 下弦
        ]
        
        for (year, month, day, expectedAge) in lunarDates {
            // 旧暦から新暦への変換
            let components = calendarManager.converter.convertForGregorianCalendar(dateArray: [year, month, day, 0])
            
            if let gYear = components.year, let gMonth = components.month, let gDay = components.day {
                print("旧暦: \(year)年\(month)月\(day)日 → 新暦: \(gYear)年\(gMonth)月\(gDay)日")
                
                // 計算前の状態を保存
                let savedComps = calendarManager.comps
                
                // 新暦日付をセット
                calendarManager.comps = components
                
                // 旧暦日から月齢を計算（伝統的計算）
                let traditionalAge = calendarManager.calcMoonAgeForLunarDay(lunarDay: day)
                
                // 各方法で月齢を計算
                let simpleAge = calendarManager.calcMoonAgeSimple()
                let astroAge = calendarManager.calcMoonAgeAstronomical()
                let highPrecisionAge = calendarManager.calcMoonAgeHighPrecision()
                
                // 結果表示
                print("期待される月齢: \(expectedAge) (旧暦日-1に基づく)")
                print("- 伝統的計算（旧暦日-1）: \(traditionalAge) (誤差: \(abs(traditionalAge - expectedAge)))")
                print("- 簡易計算: \(simpleAge) (誤差: \(abs(simpleAge - expectedAge)))")
                print("- 天文学的計算: \(astroAge) (誤差: \(abs(astroAge - expectedAge)))")
                print("- 高精度計算: \(highPrecisionAge) (誤差: \(abs(highPrecisionAge - expectedAge)))")
                print("")
                
                // 元のcompsに戻す
                calendarManager.comps = savedComps
            }
        }
    }
    
    // 特定の日付での月齢テスト
    func testSpecificDates() {
        print("\n=== 特定の日付での月齢テスト ===\n")
        
        // 特定の新暦日付
        let specificDates = [
            (2025, 3, 17, 17.1),  // ユーザー指定の参照日
            (2025, 1, 1, nil),    // 2025年元日
            (2024, 12, 31, nil),  // 2024年大晦日
            (2025, 2, 1, nil),    // 2025年2月1日
            (2025, 3, 1, 0.0),    // 新月の日（近似値）
            (2025, 3, 15, 14.0)   // 満月の日（近似値）
        ]
        
        for (year, month, day, expectedAge) in specificDates {
            // 日付の設定
            let dateComponents = DateComponents(year: year, month: month, day: day)
            
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
            let traditionalAge = calendarManager.calcMoonAgeForLunarDay(lunarDay: ancientDay)
            
            // 各方法で月齢を計算
            let simpleAge = calendarManager.calcMoonAgeSimple()
            let astroAge = calendarManager.calcMoonAgeAstronomical()
            let highPrecisionAge = calendarManager.calcMoonAgeHighPrecision()
            
            // 結果表示
            print("新暦: \(year)年\(month)月\(day)日")
            print("旧暦: \(ancientYear)年\(isLeapMonth < 0 ? "閏" : "")\(ancientMonth)月\(ancientDay)日")
            
            if let expected = expectedAge {
                print("期待される月齢: \(expected)")
                print("- 伝統的計算（旧暦日-1）: \(traditionalAge) (誤差: \(abs(traditionalAge - expected)))")
                print("- 簡易計算: \(simpleAge) (誤差: \(abs(simpleAge - expected)))")
                print("- 天文学的計算: \(astroAge) (誤差: \(abs(astroAge - expected)))")
                print("- 高精度計算: \(highPrecisionAge) (誤差: \(abs(highPrecisionAge - expected)))")
            } else {
                print("月齢計算結果:")
                print("- 伝統的計算（旧暦日-1）: \(traditionalAge)")
                print("- 簡易計算: \(simpleAge)")
                print("- 天文学的計算: \(astroAge)")
                print("- 高精度計算: \(highPrecisionAge)")
            }
            print("")
            
            // 元のcompsに戻す
            calendarManager.comps = savedComps
        }
    }
    
    // 連続する数日間の月齢変化
    func testConsecutiveDays() {
        print("\n=== 連続する数日間の月齢変化 ===\n")
        
        // 特定の開始日から数日間をテスト
        let startYear = 2025
        let startMonth = 3
        let startDay = 15
        let daysToTest = 7
        
        print("[\(startYear)年\(startMonth)月\(startDay)日] から \(daysToTest)日間の月齢変化\n")
        
        // 結果をテーブル形式で表示
        print("日付          | 旧暦          | 伝統的 | 簡易  | 天文学 | 高精度")
        print("----------------------------------------------------------")
        
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
            let traditionalAge = calendarManager.calcMoonAgeForLunarDay(lunarDay: ancientDay)
            
            // 各方法で月齢を計算
            let simpleAge = calendarManager.calcMoonAgeSimple()
            let astroAge = calendarManager.calcMoonAgeAstronomical()
            let highPrecisionAge = calendarManager.calcMoonAgeHighPrecision()
            
            // 結果表示（テーブル形式）
            let newDate = "\(startYear)/\(startMonth)/\(startDay + offset)"
            let ancientDateStr = "\(ancientYear)/\(isLeapMonth < 0 ? "閏" : "")\(ancientMonth)/\(ancientDay)"
            print(String(format: "%-13s | %-13s | %6.1f | %5.1f | %6.1f | %6.1f", 
                         newDate, ancientDateStr, traditionalAge, simpleAge, astroAge, highPrecisionAge))
            
            // 元のcompsに戻す
            calendarManager.comps = savedComps
        }
    }
}

// テストの実行
let testRunner = MoonAgeTestRunner()
testRunner.run()