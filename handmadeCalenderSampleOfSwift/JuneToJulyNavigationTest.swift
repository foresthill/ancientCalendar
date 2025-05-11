import Foundation
import UIKit

/**
 * 2025年6月-7月の日付ナビゲーションテスト
 * 閏月を含む期間での移動テストを網羅的に実施
 */
class JuneToJulyNavigationTest {
    
    // シングルトン
    static let shared = JuneToJulyNavigationTest()
    
    // CalendarManager参照
    private let calendarManager = CalendarManager.sharedInstance
    
    // CalendarDateHandler参照
    private let dateHandler = CalendarDateHandler.shared
    
    // 初期化
    private init() {}
    
    /**
     * テストを実行
     */
    func runTests() {
        print("======== 2025年6-7月 日付ナビゲーションテスト ========")
        
        // テーブル情報確認
        printTableInfo()
        
        // 閏月修正特殊ケースのテスト
        testJune8LeapFlagCorrection()
        
        // 通常移動テスト（シーケンシャル）
        testJuneToJulySequentialNavigation()
        
        // 日付境界テスト
        testJune26ToJune27Navigation()
        testJune30ToJuly1Navigation()
        testJuly1ToJune30Navigation()
        
        // 閏月間移動テスト
        testNormalToLeapMonthNavigation()
        testLeapToNormalMonthNavigation()
        
        print("============= テスト終了 =============")
    }
    
    /**
     * 旧暦テーブル情報表示
     */
    private func printTableInfo() {
        print("\n=== 2025年テーブル情報 ===")
        
        // テーブル展開
        calendarManager.converter.tblExpand(inYear: 2025)
        
        // 閏月情報
        let leapMonth = calendarManager.converter.leapMonth
        print("2025年の閏月: \(leapMonth ?? 0)月")
        
        // 月ごとの通日表示
        print("\n月ごとの通日と新暦日付情報:")
        for i in 0..<min(15, calendarManager.converter.ancientTbl.count) {
            let monthInfo = calendarManager.converter.ancientTbl[i]
            if monthInfo.count < 2 {
                continue // 防御的プログラミング
            }
            
            var monthName = ""
            if i == 0 {
                monthName = "年初"
            } else if monthInfo[1] < 0 {
                monthName = "閏\(abs(monthInfo[1]))月"
            } else {
                monthName = "\(monthInfo[1])月"
            }
            
            // 通日値と新暦変換
            let dayOfYear = monthInfo[0]
            
            // テスト用の日付作成（各月の初日）
            let testDay = 1
            let testMonth = abs(monthInfo[1])
            let testIsLeap = monthInfo[1] < 0
            
            // 新暦日付も表示
            if testMonth > 0 {
                let gregorianDate = dateHandler.convertAncientToGregorian(
                    year: 2025, 
                    month: testMonth, 
                    day: testDay, 
                    isLeapMonth: testIsLeap
                )
                
                print("[\(i)] \(monthName): 通日=\(dayOfYear), 新暦=\(gregorianDate.year)/\(gregorianDate.month)/\(gregorianDate.day)")
            } else {
                print("[\(i)] \(monthName): 通日=\(dayOfYear)")
            }
        }
        
        print("")
    }
    
    /**
     * 2025年6月8日の閏月フラグ修正テスト
     * （特殊ケース：新暦7月2日に対応する旧暦日付）
     */
    private func testJune8LeapFlagCorrection() {
        print("\n=== テスト1: 2025年6月8日の閏月フラグ修正 ===")
        
        // 2025年6月8日を通常月と閏月の両方でテスト
        let normalResult = dateHandler.validateAndCorrectAncientDate(
            year: 2025,
            month: 6,
            day: 8,
            isLeapMonth: false
        )
        
        let leapResult = dateHandler.validateAndCorrectAncientDate(
            year: 2025,
            month: 6,
            day: 8,
            isLeapMonth: true
        )
        
        print("通常6月8日 → \(normalResult.isLeapMonth ? "閏" : "通常")6月8日")
        print("閏6月8日 → \(leapResult.isLeapMonth ? "閏" : "通常")6月8日")
        
        // 新暦への変換
        let normalGregorian = dateHandler.convertAncientToGregorian(
            year: 2025,
            month: 6,
            day: 8,
            isLeapMonth: false
        )
        
        let leapGregorian = dateHandler.convertAncientToGregorian(
            year: 2025,
            month: 6,
            day: 8,
            isLeapMonth: true
        )
        
        print("通常6月8日 → 新暦 \(normalGregorian.year)/\(normalGregorian.month)/\(normalGregorian.day)")
        print("閏6月8日 → 新暦 \(leapGregorian.year)/\(leapGregorian.month)/\(leapGregorian.day)")
    }
    
    /**
     * 6月から7月への連続移動テスト
     * 水無月から文月への移動を日付順に確認
     */
    private func testJuneToJulySequentialNavigation() {
        print("\n=== テスト2: 6月から7月への連続移動 ===")
        
        // 6月1日から開始
        var currentYear = 2025
        var currentMonth = 6
        var currentDay = 1
        var currentIsLeap = false
        
        print("開始: \(currentYear)年\(currentIsLeap ? "閏" : "")\(currentMonth)月\(currentDay)日")
        
        // 7月10日まで進む
        let days = 40 // 6月と7月の日数をカバーするのに十分
        
        for i in 1...days {
            let nextResult = dateHandler.moveToNextDate(
                year: currentYear,
                month: currentMonth,
                day: currentDay,
                isLeapMonth: currentIsLeap
            )
            
            // 結果を保存
            currentYear = nextResult.year
            currentMonth = nextResult.month
            currentDay = nextResult.day
            currentIsLeap = nextResult.isLeapMonth
            
            // 新暦日付も取得
            let gregorianDate = dateHandler.convertAncientToGregorian(
                year: currentYear,
                month: currentMonth,
                day: currentDay,
                isLeapMonth: currentIsLeap
            )
            
            print("\(i)日目: \(currentYear)年\(currentIsLeap ? "閏" : "")\(currentMonth)月\(currentDay)日 → 新暦 \(gregorianDate.year)/\(gregorianDate.month)/\(gregorianDate.day)")
            
            // 7月10日に達したら終了
            if currentMonth == 7 && currentDay == 10 {
                break
            }
        }
    }
    
    /**
     * 6月26日→6月27日の移動テスト
     * 特殊ケース：旧暦の6月26日から27日への移動で閏月にならないことを確認
     */
    private func testJune26ToJune27Navigation() {
        print("\n=== テスト3: 6月26日→6月27日の移動 ===")
        
        // 2025年6月26日（通常月）を設定
        let startYear = 2025
        let startMonth = 6
        let startDay = 26
        let startIsLeap = false
        
        // 新暦日付
        let startGregorian = dateHandler.convertAncientToGregorian(
            year: startYear,
            month: startMonth,
            day: startDay,
            isLeapMonth: startIsLeap
        )
        
        print("開始: \(startYear)年\(startIsLeap ? "閏" : "")\(startMonth)月\(startDay)日 → 新暦 \(startGregorian.year)/\(startGregorian.month)/\(startGregorian.day)")
        
        // 次の日に移動
        let result = dateHandler.moveToNextDate(
            year: startYear,
            month: startMonth,
            day: startDay,
            isLeapMonth: startIsLeap
        )
        
        // 結果の新暦日付
        let resultGregorian = dateHandler.convertAncientToGregorian(
            year: result.year,
            month: result.month,
            day: result.day,
            isLeapMonth: result.isLeapMonth
        )
        
        print("結果: \(result.year)年\(result.isLeapMonth ? "閏" : "")\(result.month)月\(result.day)日 → 新暦 \(resultGregorian.year)/\(resultGregorian.month)/\(resultGregorian.day)")
        
        // 期待通りか確認
        let isExpectedResult = result.month == 6 && result.day == 27 && !result.isLeapMonth
        print("テスト結果: \(isExpectedResult ? "✅ 成功" : "❌ 失敗")")
    }
    
    /**
     * 6月30日→7月1日の移動テスト
     * 特殊ケース：旧暦の6月30日から7月1日への移動（閏月にならない）
     */
    private func testJune30ToJuly1Navigation() {
        print("\n=== テスト4: 6月30日→7月1日の移動 ===")
        
        // 2025年6月30日（通常月）を設定
        let startYear = 2025
        let startMonth = 6
        let startDay = 30
        let startIsLeap = false
        
        // 新暦日付
        let startGregorian = dateHandler.convertAncientToGregorian(
            year: startYear,
            month: startMonth,
            day: startDay,
            isLeapMonth: startIsLeap
        )
        
        print("開始: \(startYear)年\(startIsLeap ? "閏" : "")\(startMonth)月\(startDay)日 → 新暦 \(startGregorian.year)/\(startGregorian.month)/\(startGregorian.day)")
        
        // 次の日に移動
        let result = dateHandler.moveToNextDate(
            year: startYear,
            month: startMonth,
            day: startDay,
            isLeapMonth: startIsLeap
        )
        
        // 結果の新暦日付
        let resultGregorian = dateHandler.convertAncientToGregorian(
            year: result.year,
            month: result.month,
            day: result.day,
            isLeapMonth: result.isLeapMonth
        )
        
        print("結果: \(result.year)年\(result.isLeapMonth ? "閏" : "")\(result.month)月\(result.day)日 → 新暦 \(resultGregorian.year)/\(resultGregorian.month)/\(resultGregorian.day)")
        
        // 期待通りか確認
        let isExpectedResult = result.month == 7 && result.day == 1 && !result.isLeapMonth
        print("テスト結果: \(isExpectedResult ? "✅ 成功" : "❌ 失敗")")
    }
    
    /**
     * 7月1日→6月30日の移動テスト
     * 特殊ケース：旧暦の7月1日から6月30日への移動（閏月にならない）
     */
    private func testJuly1ToJune30Navigation() {
        print("\n=== テスト5: 7月1日→6月30日の移動 ===")
        
        // 2025年7月1日（通常月）を設定
        let startYear = 2025
        let startMonth = 7
        let startDay = 1
        let startIsLeap = false
        
        // 新暦日付
        let startGregorian = dateHandler.convertAncientToGregorian(
            year: startYear,
            month: startMonth,
            day: startDay,
            isLeapMonth: startIsLeap
        )
        
        print("開始: \(startYear)年\(startIsLeap ? "閏" : "")\(startMonth)月\(startDay)日 → 新暦 \(startGregorian.year)/\(startGregorian.month)/\(startGregorian.day)")
        
        // 前の日に移動
        let result = dateHandler.moveToPreviousDate(
            year: startYear,
            month: startMonth,
            day: startDay,
            isLeapMonth: startIsLeap
        )
        
        // 結果の新暦日付
        let resultGregorian = dateHandler.convertAncientToGregorian(
            year: result.year,
            month: result.month,
            day: result.day,
            isLeapMonth: result.isLeapMonth
        )
        
        print("結果: \(result.year)年\(result.isLeapMonth ? "閏" : "")\(result.month)月\(result.day)日 → 新暦 \(resultGregorian.year)/\(resultGregorian.month)/\(resultGregorian.day)")
        
        // 期待通りか確認
        let isExpectedResult = result.month == 6 && result.day == 30 && !result.isLeapMonth
        print("テスト結果: \(isExpectedResult ? "✅ 成功" : "❌ 失敗")")
    }
    
    /**
     * 通常月から閏月への移動テスト
     */
    private func testNormalToLeapMonthNavigation() {
        print("\n=== テスト6: 通常月から閏月への移動 ===")
        
        // 通常月から閏月への連続移動をテスト
        // 2025年では6月が閏月を持つ
        
        var currentYear = 2025
        var currentMonth = 6
        var currentDay = 25
        var currentIsLeap = false
        
        print("開始: \(currentYear)年\(currentIsLeap ? "閏" : "")\(currentMonth)月\(currentDay)日")
        
        // 10日分進む
        for i in 1...10 {
            let nextResult = dateHandler.moveToNextDate(
                year: currentYear,
                month: currentMonth,
                day: currentDay,
                isLeapMonth: currentIsLeap
            )
            
            // 結果を保存
            currentYear = nextResult.year
            currentMonth = nextResult.month
            currentDay = nextResult.day
            currentIsLeap = nextResult.isLeapMonth
            
            // 新暦日付も取得
            let gregorianDate = dateHandler.convertAncientToGregorian(
                year: currentYear,
                month: currentMonth,
                day: currentDay,
                isLeapMonth: currentIsLeap
            )
            
            print("\(i)日目: \(currentYear)年\(currentIsLeap ? "閏" : "")\(currentMonth)月\(currentDay)日 → 新暦 \(gregorianDate.year)/\(gregorianDate.month)/\(gregorianDate.day)")
        }
    }
    
    /**
     * 閏月から通常月への移動テスト
     */
    private func testLeapToNormalMonthNavigation() {
        print("\n=== テスト7: 閏月から通常月への移動 ===")
        
        // 閏月から通常月への連続移動をテスト
        // 閏6月9日から前へ移動
        
        var currentYear = 2025
        var currentMonth = 6
        var currentDay = 9
        var currentIsLeap = true
        
        print("開始: \(currentYear)年\(currentIsLeap ? "閏" : "")\(currentMonth)月\(currentDay)日")
        
        // 10日分戻る
        for i in 1...10 {
            let prevResult = dateHandler.moveToPreviousDate(
                year: currentYear,
                month: currentMonth,
                day: currentDay,
                isLeapMonth: currentIsLeap
            )
            
            // 結果を保存
            currentYear = prevResult.year
            currentMonth = prevResult.month
            currentDay = prevResult.day
            currentIsLeap = prevResult.isLeapMonth
            
            // 新暦日付も取得
            let gregorianDate = dateHandler.convertAncientToGregorian(
                year: currentYear,
                month: currentMonth,
                day: currentDay,
                isLeapMonth: currentIsLeap
            )
            
            print("\(i)日目: \(currentYear)年\(currentIsLeap ? "閏" : "")\(currentMonth)月\(currentDay)日 → 新暦 \(gregorianDate.year)/\(gregorianDate.month)/\(gregorianDate.day)")
        }
    }
}