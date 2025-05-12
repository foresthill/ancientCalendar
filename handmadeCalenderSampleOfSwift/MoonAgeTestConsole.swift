//
//  MoonAgeTestConsole.swift
//  handmadeCalenderSampleOfSwift
//
//  Created with Claude Code on 2025/05/09.
//  Copyright © 2025 foresthill. All rights reserved.
//

import Foundation

/**
 * コンソール実行用のテストスクリプト
 */
class MoonAgeTestConsole {
    
    // CalendarManagerのインスタンス
    let calendarManager = CalendarManager.sharedInstance
    
    // 月齢計算のテスト実行
    func runTests() {
        // 1. 旧暦の重要な日のテスト
        let lunarKeyDates = [
            (2025, 2, 1),   // 旧暦：新月
            (2025, 2, 8),   // 旧暦：上弦
            (2025, 2, 15),  // 旧暦：満月
            (2025, 2, 23)   // 旧暦：下弦
        ]
        
        print("\n=== 旧暦の重要な日の月齢テスト ===\n")
        
        for (lunarYear, lunarMonth, lunarDay) in lunarKeyDates {
            // 旧暦→新暦変換
            let components = calendarManager.converter.convertForGregorianCalendar(dateArray: [lunarYear, lunarMonth, lunarDay, 0])
            
            if let gYear = components.year, let gMonth = components.month, let gDay = components.day {
                print("旧暦: \(lunarYear)年\(lunarMonth)月\(lunarDay)日 → 新暦: \(gYear)年\(gMonth)月\(gDay)日")
                
                // 旧暦日から月齢を計算（伝統的計算）
                let traditionalAge = Double(lunarDay - 1)
                
                // 新暦日付を使用して各種方法で月齢を計算
                let calculatedComponents = DateComponents(year: gYear, month: gMonth, day: gDay)
                let simpleAge = calculateMoonAge(components: calculatedComponents, method: "simple")
                let astroAge = calculateMoonAge(components: calculatedComponents, method: "astronomical")
                let highPrecisionAge = calculateMoonAge(components: calculatedComponents, method: "highPrecision")
                
                // 結果表示
                print("期待される月齢: \(traditionalAge) (旧暦日-1による)")
                print("- 簡易計算: \(simpleAge) (誤差: \(abs(simpleAge - traditionalAge)))")
                print("- 天文学的計算: \(astroAge) (誤差: \(abs(astroAge - traditionalAge)))")
                print("- 高精度計算: \(highPrecisionAge) (誤差: \(abs(highPrecisionAge - traditionalAge)))")
                print("")
            }
        }
        
        // 2. 特定の新暦日付のテスト
        let gregorianDates = [
            (2025, 3, 17),  // 特定の参照日
            (2025, 3, 1),   // 新月の日
            (2025, 3, 15),  // 満月の日
            (2024, 12, 31), // 大晦日
            (2025, 1, 1)    // 元旦
        ]
        
        print("\n=== 特定の新暦日付での月齢テスト ===\n")
        
        for (gYear, gMonth, gDay) in gregorianDates {
            let dateComponents = DateComponents(year: gYear, month: gMonth, day: gDay)
            
            // 新暦→旧暦変換
            let ancientDate = calendarManager.converter.convertForAncientCalendar(comps: dateComponents)
            let ancientYear = ancientDate[0]
            let ancientMonth = ancientDate[1]
            let ancientDay = ancientDate[2]
            let isLeapMonth = ancientDate[3]
            
            print("新暦: \(gYear)年\(gMonth)月\(gDay)日 → 旧暦: \(ancientYear)年\(isLeapMonth < 0 ? "閏" : "")\(ancientMonth)月\(ancientDay)日")
            
            // 旧暦日から月齢を計算（伝統的計算）
            let traditionalAge = Double(ancientDay - 1)
            
            // 新暦日付を使用して各種方法で月齢を計算
            let simpleAge = calculateMoonAge(components: dateComponents, method: "simple")
            let astroAge = calculateMoonAge(components: dateComponents, method: "astronomical")
            let highPrecisionAge = calculateMoonAge(components: dateComponents, method: "highPrecision")
            
            // 結果表示
            print("旧暦日からの月齢: \(traditionalAge)")
            print("- 簡易計算: \(simpleAge)")
            print("- 天文学的計算: \(astroAge)")
            print("- 高精度計算: \(highPrecisionAge)")
            print("")
        }
        
        // 3. 連続する7日間の月齢変化
        let startYear = 2025
        let startMonth = 3
        let startDay = 14  // 満月の前日から
        let daysToTest = 7
        
        print("\n=== 連続する7日間の月齢変化 ===\n")
        print("日付          | 旧暦          | 旧暦日-1 | 簡易  | 天文学 | 高精度")
        print("----------------------------------------------------------")
        
        for i in 0..<daysToTest {
            let dateComponents = DateComponents(year: startYear, month: startMonth, day: startDay + i)
            
            // 新暦→旧暦変換
            let ancientDate = calendarManager.converter.convertForAncientCalendar(comps: dateComponents)
            let ancientYear = ancientDate[0]
            let ancientMonth = ancientDate[1]
            let ancientDay = ancientDate[2]
            let isLeapMonth = ancientDate[3]
            
            // 旧暦日から月齢を計算（伝統的計算）
            let traditionalAge = Double(ancientDay - 1)
            
            // 新暦日付を使用して各種方法で月齢を計算
            let simpleAge = calculateMoonAge(components: dateComponents, method: "simple")
            let astroAge = calculateMoonAge(components: dateComponents, method: "astronomical")
            let highPrecisionAge = calculateMoonAge(components: dateComponents, method: "highPrecision")
            
            // 結果表示（テーブル形式）
            let newDate = "\(startYear)/\(startMonth)/\(startDay + i)"
            let ancientDateStr = "\(ancientYear)/\(isLeapMonth < 0 ? "閏" : "")\(ancientMonth)/\(ancientDay)"
            print(String(format: "%-13s | %-13s | %8.1f | %5.1f | %6.1f | %7.1f", 
                         newDate, ancientDateStr, traditionalAge, simpleAge, astroAge, highPrecisionAge))
        }
    }
    
    // 特定の計算方法で月齢を計算
    private func calculateMoonAge(components: DateComponents, method: String) -> Double {
        // 計算前の状態を保存
        let savedComps = calendarManager.comps
        
        // 指定された日付をセット
        calendarManager.comps = components
        
        // 指定された方法で月齢を計算
        var result: Double = 0.0
        
        switch method {
        case "simple":
            result = calendarManager.calcMoonAgeSimple()
        case "astronomical":
            result = calendarManager.calcMoonAgeAstronomical()
        case "highPrecision":
            result = calendarManager.calcMoonAgeHighPrecision()
        default:
            result = calendarManager.calcMoonAge()
        }
        
        // 元のcompsに戻す
        calendarManager.comps = savedComps
        
        return result
    }
}

// テスト実行
print("\n==========================================")
print("            月齢計算テスト結果           ")
print("==========================================")

let testConsole = MoonAgeTestConsole()
testConsole.runTests()

print("\n==========================================")
print("           ※テスト結果ここまで           ")
print("==========================================\n")