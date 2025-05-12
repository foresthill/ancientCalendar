import Foundation
import UIKit

/**
 * 日付ナビゲーションのテスト
 * 特に2025年6月を中心に、閏月との関係を検証
 */
class NavigationTest {
    
    // シングルトン
    static let shared = NavigationTest()
    
    // CalendarManager参照
    private let calendarManager = CalendarManager.sharedInstance
    
    // CalendarDateHandler参照
    private let dateHandler = CalendarDateHandler.shared
    
    // 初期化
    private init() {}
    
    /**
     * テストを実行
     */
    func runFullTest() {
        print("======== 日付ナビゲーションテスト開始 ========")
        
        // 旧暦テーブル情報表示
        checkAncientTable()
        
        // 境界値テスト
        checkJune26ToJune27() // 6/26から6/27への移動
        checkJune30ToJuly1()  // 6/30から7/1への移動
        checkJuly1ToJune30()  // 7/1から6/30への移動
        
        // 閏6月9日の特殊ケース
        checkLeapJune9ToPrevious() // 閏6/9から戻ると閏6/8になることを確認
        
        // 7月から6月への連続移動
        checkJulyToJuneSequence()
        
        print("======== テスト終了 ========")
    }
    
    /**
     * 旧暦テーブル情報を表示
     */
    private func checkAncientTable() {
        print("\n=== 2025年 旧暦テーブル情報 ===")
        
        // テーブル展開
        calendarManager.converter.tblExpand(inYear: 2025)
        
        // 閏月情報
        let leapMonth = calendarManager.converter.leapMonth
        print("2025年の閏月: \(leapMonth ?? 0)月")
        
        // 月ごとの通日表示
        print("\n月ごとの通日情報:")
        for i in 0..<min(14, calendarManager.converter.ancientTbl.count) {
            let monthInfo = calendarManager.converter.ancientTbl[i]
            
            // 不正な月情報をスキップ
            if monthInfo.count < 2 || i >= calendarManager.converter.ancientTbl.count {
                continue
            }
            
            var monthName = ""
            if i == 0 {
                monthName = "年初"
            } else if monthInfo[1] < 0 {
                monthName = "閏\(abs(monthInfo[1]))月"
            } else if monthInfo[1] == 0 {
                monthName = "年末"
            } else {
                monthName = "\(monthInfo[1])月"
            }
            
            print("[\(i)] \(monthName): 通日=\(monthInfo[0])")
        }
        
        print("")
    }
    
    /**
     * 6/26から6/27への移動テスト
     * 特殊ケース: 閏月に移行しない
     */
    private func checkJune26ToJune27() {
        print("\n=== テスト1: 6/26から6/27への移動（閏月に移行しない） ===")
        
        // 2025年6月26日（通常月）を設定
        var year = 2025
        var month = 6
        var day = 26
        var isLeapMonth = false
        
        // 新暦日付も表示
        let gregorianDate = dateHandler.convertAncientToGregorian(
            year: year, 
            month: month, 
            day: day, 
            isLeapMonth: isLeapMonth
        )
        
        print("開始: \(year)年\(isLeapMonth ? "閏" : "")\(month)月\(day)日 → 新暦 \(gregorianDate.year)/\(gregorianDate.month)/\(gregorianDate.day)")
        
        // 次の日に移動
        let result = dateHandler.moveToNextDate(
            year: year, 
            month: month, 
            day: day, 
            isLeapMonth: isLeapMonth
        )
        
        // 結果を保存
        year = result.year
        month = result.month
        day = result.day
        isLeapMonth = result.isLeapMonth
        
        // 結果の新暦日付
        let resultGregorian = dateHandler.convertAncientToGregorian(
            year: year, 
            month: month, 
            day: day, 
            isLeapMonth: isLeapMonth
        )
        
        print("結果: \(year)年\(isLeapMonth ? "閏" : "")\(month)月\(day)日 → 新暦 \(resultGregorian.year)/\(resultGregorian.month)/\(resultGregorian.day)")
        
        // 期待した結果になっているか確認
        let expectedIsLeap = false // 6/27は閏月ではないはず
        let expectedMonth = 6
        let expectedDay = 27
        
        let isSuccess = month == expectedMonth && day == expectedDay && isLeapMonth == expectedIsLeap
        
        print("テスト結果: \(isSuccess ? "✅ 成功" : "❌ 失敗")")
    }
    
    /**
     * 6/30から7/1への移動テスト
     * 特殊ケース: 閏6月には移行せず、7月になる
     */
    private func checkJune30ToJuly1() {
        print("\n=== テスト2: 6/30から7/1への移動（閏月ではなく7月に移行） ===")
        
        // 2025年6月30日（通常月）を設定
        var year = 2025
        var month = 6
        var day = 30
        var isLeapMonth = false
        
        // 新暦日付も表示
        let gregorianDate = dateHandler.convertAncientToGregorian(
            year: year, 
            month: month, 
            day: day, 
            isLeapMonth: isLeapMonth
        )
        
        print("開始: \(year)年\(isLeapMonth ? "閏" : "")\(month)月\(day)日 → 新暦 \(gregorianDate.year)/\(gregorianDate.month)/\(gregorianDate.day)")
        
        // 次の日に移動
        let result = dateHandler.moveToNextDate(
            year: year, 
            month: month, 
            day: day, 
            isLeapMonth: isLeapMonth
        )
        
        // 結果を保存
        year = result.year
        month = result.month
        day = result.day
        isLeapMonth = result.isLeapMonth
        
        // 結果の新暦日付
        let resultGregorian = dateHandler.convertAncientToGregorian(
            year: year, 
            month: month, 
            day: day, 
            isLeapMonth: isLeapMonth
        )
        
        print("結果: \(year)年\(isLeapMonth ? "閏" : "")\(month)月\(day)日 → 新暦 \(resultGregorian.year)/\(resultGregorian.month)/\(resultGregorian.day)")
        
        // 期待した結果になっているか確認
        let expectedIsLeap = false // 7/1は閏月ではない
        let expectedMonth = 7
        let expectedDay = 1
        
        let isSuccess = month == expectedMonth && day == expectedDay && isLeapMonth == expectedIsLeap
        
        print("テスト結果: \(isSuccess ? "✅ 成功" : "❌ 失敗")")
    }
    
    /**
     * 7/1から6/30への移動テスト
     * 特殊ケース: 閏6月には移行せず、通常6月の30日になる
     */
    private func checkJuly1ToJune30() {
        print("\n=== テスト3: 7/1から6/30への移動（閏月ではなく通常6/30になる） ===")
        
        // 2025年7月1日を設定
        var year = 2025
        var month = 7
        var day = 1
        var isLeapMonth = false
        
        // 新暦日付も表示
        let gregorianDate = dateHandler.convertAncientToGregorian(
            year: year, 
            month: month, 
            day: day, 
            isLeapMonth: isLeapMonth
        )
        
        print("開始: \(year)年\(isLeapMonth ? "閏" : "")\(month)月\(day)日 → 新暦 \(gregorianDate.year)/\(gregorianDate.month)/\(gregorianDate.day)")
        
        // 前の日に移動
        let result = dateHandler.moveToPreviousDate(
            year: year, 
            month: month, 
            day: day, 
            isLeapMonth: isLeapMonth
        )
        
        // 結果を保存
        year = result.year
        month = result.month
        day = result.day
        isLeapMonth = result.isLeapMonth
        
        // 結果の新暦日付
        let resultGregorian = dateHandler.convertAncientToGregorian(
            year: year, 
            month: month, 
            day: day, 
            isLeapMonth: isLeapMonth
        )
        
        print("結果: \(year)年\(isLeapMonth ? "閏" : "")\(month)月\(day)日 → 新暦 \(resultGregorian.year)/\(resultGregorian.month)/\(resultGregorian.day)")
        
        // 期待した結果になっているか確認
        let expectedIsLeap = false  // 閏月ではない
        let expectedMonth = 6
        let expectedDay = 30
        
        let isSuccess = month == expectedMonth && day == expectedDay && isLeapMonth == expectedIsLeap
        
        print("テスト結果: \(isSuccess ? "✅ 成功" : "❌ 失敗")")
    }
    
    /**
     * 閏6/9から前日への移動テスト
     * 特殊ケース: 通常6/8ではなく閏6/8になる
     */
    private func checkLeapJune9ToPrevious() {
        print("\n=== テスト4: 閏6/9から前日への移動（閏6/8になる） ===")
        
        // 2025年閏6月9日を設定
        var year = 2025
        var month = 6
        var day = 9
        var isLeapMonth = true
        
        // 新暦日付も表示
        let gregorianDate = dateHandler.convertAncientToGregorian(
            year: year, 
            month: month, 
            day: day, 
            isLeapMonth: isLeapMonth
        )
        
        print("開始: \(year)年\(isLeapMonth ? "閏" : "")\(month)月\(day)日 → 新暦 \(gregorianDate.year)/\(gregorianDate.month)/\(gregorianDate.day)")
        
        // 前の日に移動
        let result = dateHandler.moveToPreviousDate(
            year: year, 
            month: month, 
            day: day, 
            isLeapMonth: isLeapMonth
        )
        
        // 結果を保存
        year = result.year
        month = result.month
        day = result.day
        isLeapMonth = result.isLeapMonth
        
        // 結果の新暦日付
        let resultGregorian = dateHandler.convertAncientToGregorian(
            year: year, 
            month: month, 
            day: day, 
            isLeapMonth: isLeapMonth
        )
        
        print("結果: \(year)年\(isLeapMonth ? "閏" : "")\(month)月\(day)日 → 新暦 \(resultGregorian.year)/\(resultGregorian.month)/\(resultGregorian.day)")
        
        // 期待した結果になっているか確認
        let expectedIsLeap = true  // 閏月のままであるべき
        let expectedMonth = 6
        let expectedDay = 8
        
        let isSuccess = month == expectedMonth && day == expectedDay && isLeapMonth == expectedIsLeap
        
        print("テスト結果: \(isSuccess ? "✅ 成功" : "❌ 失敗")")
    }
    
    /**
     * 7月1日から連続して前日移動するテスト
     * 通常6月30日→通常6月29日→...→通常6月1日→閏6月30日→...と進むことを確認
     */
    private func checkJulyToJuneSequence() {
        print("\n=== テスト5: 7月から6月への連続移動 ===")
        
        // 2025年7月1日から開始
        var year = 2025
        var month = 7
        var day = 1
        var isLeapMonth = false
        
        print("開始: \(year)年\(isLeapMonth ? "閏" : "")\(month)月\(day)日")
        
        // 40日分前に移動（通常6月と閏6月を全てカバーできる日数）
        let days = 40
        
        for i in 1...days {
            // 前の日に移動
            let result = dateHandler.moveToPreviousDate(
                year: year, 
                month: month, 
                day: day, 
                isLeapMonth: isLeapMonth
            )
            
            // 結果を保存
            year = result.year
            month = result.month
            day = result.day
            isLeapMonth = result.isLeapMonth
            
            // 新暦日付も表示
            let gregorianDate = dateHandler.convertAncientToGregorian(
                year: year, 
                month: month, 
                day: day, 
                isLeapMonth: isLeapMonth
            )
            
            print("\(i)日前: \(year)年\(isLeapMonth ? "閏" : "")\(month)月\(day)日 → 新暦 \(gregorianDate.year)/\(gregorianDate.month)/\(gregorianDate.day)")
            
            // 5月になったら終了
            if month == 5 {
                break
            }
        }
    }
}

/**
 * テスト実行
 */
class RunNavigationTest {
    
    static func execute() {
        print("日付ナビゲーションテストを実行します")
        
        let test = NavigationTest.shared
        test.runFullTest()
    }
}