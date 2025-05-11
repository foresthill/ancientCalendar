//
//  MoonAgeTest.swift
//  handmadeCalenderSampleOfSwift
//
//  Created with Claude Code on 2025/05/09.
//  Copyright © 2025 foresthill. All rights reserved.
//

import Foundation

/**
 * 月齢計算のテスト用クラス
 * 指定された日付の月齢を各種計算方法で計算し、結果を比較するためのユーティリティクラスです。
 */
class MoonAgeTest {
    
    // シングルトンインスタンス
    static let sharedInstance = MoonAgeTest()
    
    // CalendarManagerのインスタンス
    let calendarManager = CalendarManager.sharedInstance
    
    // プライベートイニシャライザ
    private init() {}
    
    /**
     * 指定された日付の月齢を全ての計算方法で計算し、結果を表示します
     *
     * - parameter year: 年
     * - parameter month: 月
     * - parameter day: 日
     */
    func testMoonAgeForDate(year: Int, month: Int, day: Int) {
        print("======= 月齢計算テスト =======")
        print("テスト日付: \(year)年\(month)月\(day)日")
        
        // 日付コンポーネントを作成
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
        
        // 3種類の計算方法による月齢を計算
        let simpleAge = calendarManager.calcMoonAgeSimple()
        let astroAge = calendarManager.calcMoonAgeAstronomical()
        let highPrecisionAge = calendarManager.calcMoonAgeHighPrecision()
        
        // 旧暦日からの伝統的な月齢計算
        let traditionalAge = calendarManager.calcMoonAgeForLunarDay(lunarDay: ancientDay)
        
        // 結果表示
        print("旧暦日付: \(ancientYear)年\(isLeapMonth < 0 ? "閏" : "")\(ancientMonth)月\(ancientDay)日")
        print("計算結果:")
        print("- 伝統的計算（旧暦日-1）: \(traditionalAge)")
        print("- 簡易計算: \(simpleAge)")
        print("- 天文学的計算: \(astroAge)")
        print("- 高精度計算: \(highPrecisionAge)")
        
        // 旧暦日との対応関係を表示
        let expectedMoonAge = Double(ancientDay - 1)
        print("\n旧暦に基づく理想値との差分 (旧暦\(ancientDay)日 -> 月齢\(expectedMoonAge)):")
        print("- 簡易計算との差: \(abs(simpleAge - expectedMoonAge))")
        print("- 天文学的計算との差: \(abs(astroAge - expectedMoonAge))")
        print("- 高精度計算との差: \(abs(highPrecisionAge - expectedMoonAge))")
        
        // 元のcompsに戻す
        calendarManager.comps = savedComps
        
        print("==============================")
    }
    
    /**
     * 旧暦日と月齢の対応関係をテストします
     */
    func testLunarDateMoonAgeCorrelation() {
        print("\n====== 旧暦日と月齢の対応関係テスト ======")
        
        // 旧暦の重要な日(1日, 8日, 15日, 23日)に対応する新暦日を取得
        // ここでは2025年2月の例（実際の変換は実行時に行う）
        let lunarDates = [1, 8, 15, 23]
        
        for lunarDay in lunarDates {
            // 旧暦日に対応する理想の月齢（旧暦1日=月齢0、旧暦15日=月齢14）
            let idealMoonAge = Double(lunarDay - 1)
            
            // 旧暦年月日を設定（仮に2025年2月を使用）
            let ancientYear = 2025
            let ancientMonth = 2
            
            // 旧暦から新暦への変換を実行
            let components = calendarManager.converter.convertForGregorianCalendar(dateArray: [ancientYear, ancientMonth, lunarDay, 0])
            
            // 計算前の状態を保存
            let savedComps = calendarManager.comps
            
            // 新暦日付をセット
            calendarManager.comps = components
            
            // 月齢を各方法で計算
            let simpleAge = calendarManager.calcMoonAgeSimple()
            let astroAge = calendarManager.calcMoonAgeAstronomical()
            let highPrecisionAge = calendarManager.calcMoonAgeHighPrecision()
            
            // 結果表示
            if let year = components.year, let month = components.month, let day = components.day {
                print("旧暦 \(ancientYear)年\(ancientMonth)月\(lunarDay)日 → 新暦 \(year)年\(month)月\(day)日")
                print("理想の月齢: \(idealMoonAge)")
                print("- 簡易計算: \(simpleAge) (誤差: \(abs(simpleAge - idealMoonAge)))")
                print("- 天文学的計算: \(astroAge) (誤差: \(abs(astroAge - idealMoonAge)))")
                print("- 高精度計算: \(highPrecisionAge) (誤差: \(abs(highPrecisionAge - idealMoonAge)))")
                print("")
            }
            
            // 元のcompsに戻す
            calendarManager.comps = savedComps
        }
        
        print("=========================================")
    }
    
    /**
     * 特定の旧暦日の月齢を検証
     */
    func testAncientCalendarDates() {
        print("\n===== 特定の旧暦日の月齢検証 =====")
        
        // 特定の旧暦日をテスト
        let testDates = [
            // 旧暦日付と期待される月齢
            (2025, 2, 1, 0.0),  // 新月
            (2025, 2, 8, 7.0),  // 上弦
            (2025, 2, 15, 14.0), // 満月
            (2025, 2, 23, 22.0)  // 下弦
        ]
        
        for (year, month, day, expectedAge) in testDates {
            print("旧暦 \(year)年\(month)月\(day)日")
            
            // 旧暦から新暦への変換
            let components = calendarManager.converter.convertForGregorianCalendar(dateArray: [year, month, day, 0])
            
            if let gYear = components.year, let gMonth = components.month, let gDay = components.day {
                print("新暦: \(gYear)年\(gMonth)月\(gDay)日")
                
                // 計算前の状態を保存
                let savedComps = calendarManager.comps
                
                // 新暦日付をセット
                calendarManager.comps = components
                
                // 月齢を各方法で計算
                let simpleAge = calendarManager.calcMoonAgeSimple()
                let astroAge = calendarManager.calcMoonAgeAstronomical()
                let highPrecisionAge = calendarManager.calcMoonAgeHighPrecision()
                
                // 結果表示
                print("期待される月齢: \(expectedAge)")
                print("- 簡易計算: \(simpleAge) (誤差: \(abs(simpleAge - expectedAge)))")
                print("- 天文学的計算: \(astroAge) (誤差: \(abs(astroAge - expectedAge)))")
                print("- 高精度計算: \(highPrecisionAge) (誤差: \(abs(highPrecisionAge - expectedAge)))")
                print("")
                
                // 元のcompsに戻す
                calendarManager.comps = savedComps
            }
        }
        
        print("================================")
    }
    
    /**
     * 参照サンプル日付での月齢を検証する
     */
    func testSampleDates() {
        print("\n===== 参照サンプル日付の月齢検証 =====")
        
        // 特定の新暦日付をテスト
        let sampleDates = [
            (2025, 3, 17, 17.1),  // ユーザー指定の参照日
            (2025, 2, 28, 29.5),  // 新月前日
            (2025, 3, 1, 0.0),    // 新月
            (2025, 3, 8, 7.0),    // 上弦
            (2025, 3, 15, 14.0)   // 満月
        ]
        
        for (year, month, day, expectedAge) in sampleDates {
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
            
            // 月齢を各方法で計算
            let simpleAge = calendarManager.calcMoonAgeSimple()
            let astroAge = calendarManager.calcMoonAgeAstronomical()
            let highPrecisionAge = calendarManager.calcMoonAgeHighPrecision()
            
            // 結果表示
            print("新暦: \(year)年\(month)月\(day)日")
            print("旧暦: \(ancientYear)年\(isLeapMonth < 0 ? "閏" : "")\(ancientMonth)月\(ancientDay)日")
            print("期待される月齢: \(expectedAge)")
            print("- 簡易計算: \(simpleAge) (誤差: \(abs(simpleAge - expectedAge)))")
            print("- 天文学的計算: \(astroAge) (誤差: \(abs(astroAge - expectedAge)))")
            print("- 高精度計算: \(highPrecisionAge) (誤差: \(abs(highPrecisionAge - expectedAge)))")
            print("")
            
            // 元のcompsに戻す
            calendarManager.comps = savedComps
        }
        
        print("=====================================")
    }
    
    /**
     * 一連のテストを実行する
     */
    func runAllTests() {
        print("==========================================")
        print("             月齢計算テスト開始            ")
        print("==========================================")
        
        // 旧暦日と月齢の対応関係テスト
        testLunarDateMoonAgeCorrelation()
        
        // 特定の旧暦日の月齢検証
        testAncientCalendarDates()
        
        // 参照サンプル日付での月齢を検証
        testSampleDates()
        
        print("==========================================")
        print("             月齢計算テスト終了            ")
        print("==========================================")
    }
}