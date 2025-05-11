/**
 * 閏月のナビゲーションテスト
 * 
 * 旧暦モードでの前日・翌日移動のテストコード
 * このテストは旧暦における閏月周辺の正確な日付移動を確認するためのもの
 */

import Foundation
import UIKit

class LeapMonthNavigationTest {
    
    /// シングルトンインスタンス
    static let sharedInstance = LeapMonthNavigationTest()
    
    // CalendarManagerのインスタンス
    private let calendarManager = CalendarManager.sharedInstance
    
    // 旧暦変換クラス
    private let converter = AncientCalendarConverter2.sharedInstance
    
    /// 初期化 - privateにしてシングルトンパターンを強制
    private init() {}
    
    /**
     * テストを実行する
     */
    func runTests() {
        print("\n===== 閏月のナビゲーションテスト開始 =====\n")
        
        // テストケース1: 旧暦の閏月周辺をテスト
        testLeapMonthNavigation()
        
        // テストケース2: 月末から月初へのテスト
        testMonthEndToBeginning()
        
        // テストケース3: 閏月から閏ではない月への移動
        testFromLeapMonthToNormal()
        
        // テストケース4: 閏ではない月から閏月への移動
        testFromNormalToLeapMonth()
        
        print("\n===== 閏月のナビゲーションテスト終了 =====\n")
    }
    
    /**
     * テストケース1: 旧暦の閏月周辺をテスト
     */
    private func testLeapMonthNavigation() {
        print("\n=== テストケース1: 旧暦の閏月周辺 ===\n")
        
        // テスト用年を設定（閏月がある年）
        let testYear = 2025 // 2025年は閏2月
        converter.tblExpand(inYear: testYear)
        
        // 閏月を確認
        let leapMonth = converter.leapMonth
        print("テスト年(\(testYear)年)の閏月: \(leapMonth)月")
        
        // テスト開始: 閏月の前月最終日から閏月初日へ
        setupAncientDate(year: testYear, month: leapMonth, day: 30, isLeapMonth: false)
        printCurrentAncientDate("閏月前の月末")
        simulateNextDay()
        printCurrentAncientDate("次の日へ移動後")
        
        // テスト: 閏月初日から閏月2日目へ
        setupAncientDate(year: testYear, month: leapMonth, day: 1, isLeapMonth: true)
        printCurrentAncientDate("閏月初日")
        simulateNextDay()
        printCurrentAncientDate("次の日へ移動後")
        
        // テスト: 閏月最終日から翌月初日へ
        setupAncientDate(year: testYear, month: leapMonth, day: 29, isLeapMonth: true)
        printCurrentAncientDate("閏月最終日")
        simulateNextDay()
        printCurrentAncientDate("次の日へ移動後")
        
        // テスト: 翌月初日から前日（閏月最終日）へ
        setupAncientDate(year: testYear, month: leapMonth + 1, day: 1, isLeapMonth: false)
        printCurrentAncientDate("閏月翌月の初日")
        simulatePreviousDay()
        printCurrentAncientDate("前日へ移動後")
    }
    
    /**
     * テストケース2: 月末から月初へのテスト
     */
    private func testMonthEndToBeginning() {
        print("\n=== テストケース2: 月末から月初への移動 ===\n")
        
        // テスト年月設定
        let testYear = 2025
        let testMonth = 3 // 閏月ではない月を選択
        converter.tblExpand(inYear: testYear)
        
        // 月の日数を取得
        let monthDays = converter.ancientTbl[testMonth][0] - converter.ancientTbl[testMonth - 1][0]
        print("\(testYear)年\(testMonth)月の日数: \(monthDays)日")
        
        // テスト: 月末から翌月初日へ
        setupAncientDate(year: testYear, month: testMonth, day: monthDays, isLeapMonth: false)
        printCurrentAncientDate("月末")
        simulateNextDay()
        printCurrentAncientDate("次の日へ移動後")
        
        // テスト: 月初から前月末へ
        setupAncientDate(year: testYear, month: testMonth + 1, day: 1, isLeapMonth: false)
        printCurrentAncientDate("月初")
        simulatePreviousDay()
        printCurrentAncientDate("前日へ移動後")
    }
    
    /**
     * テストケース3: 閏月から閏ではない月への移動
     */
    private func testFromLeapMonthToNormal() {
        print("\n=== テストケース3: 閏月から通常月への移動 ===\n")
        
        // テスト用年を設定
        let testYear = 2025 // 2025年は閏2月
        converter.tblExpand(inYear: testYear)
        
        // 閏月を確認
        let leapMonth = converter.leapMonth
        print("テスト年(\(testYear)年)の閏月: \(leapMonth)月")
        
        // 閏月の日数を取得
        let leapMonthDays = converter.ancientTbl[leapMonth + 1][0] - converter.ancientTbl[leapMonth][0]
        print("閏\(leapMonth)月の日数: \(leapMonthDays)日")
        
        // テスト: 閏月最終日から次の通常月へ
        setupAncientDate(year: testYear, month: leapMonth, day: leapMonthDays, isLeapMonth: true)
        printCurrentAncientDate("閏月最終日")
        simulateNextDay()
        printCurrentAncientDate("次の日へ移動後")
        
        // 前日に戻って確認
        simulatePreviousDay()
        printCurrentAncientDate("前の日へ移動後（元に戻るはず）")
    }
    
    /**
     * テストケース4: 閏ではない月から閏月への移動
     */
    private func testFromNormalToLeapMonth() {
        print("\n=== テストケース4: 通常月から閏月への移動 ===\n")
        
        // テスト用年を設定
        let testYear = 2025 // 2025年は閏2月
        converter.tblExpand(inYear: testYear)
        
        // 閏月を確認
        let leapMonth = converter.leapMonth
        print("テスト年(\(testYear)年)の閏月: \(leapMonth)月")
        
        // 閏月前の通常月の日数を取得
        let normalMonthDays = converter.ancientTbl[leapMonth][0] - converter.ancientTbl[leapMonth - 1][0]
        print("\(leapMonth)月の日数: \(normalMonthDays)日")
        
        // テスト: 通常月最終日から閏月初日へ
        setupAncientDate(year: testYear, month: leapMonth, day: normalMonthDays, isLeapMonth: false)
        printCurrentAncientDate("通常月最終日")
        simulateNextDay()
        printCurrentAncientDate("次の日へ移動後")
        
        // 前日に戻って確認
        simulatePreviousDay()
        printCurrentAncientDate("前の日へ移動後（元に戻るはず）")
    }
    
    /**
     * 旧暦日付をセットアップする
     */
    private func setupAncientDate(year: Int, month: Int, day: Int, isLeapMonth: Bool) {
        calendarManager.year = year
        calendarManager.month = month
        calendarManager.day = day
        calendarManager.nowLeapMonth = isLeapMonth
        calendarManager.calendarMode = -1 // 旧暦モード
        calendarManager.initScheduleViewController()
    }
    
    /**
     * 次の日へ移動のシミュレーション
     */
    private func simulateNextDay() {
        guard let year = calendarManager.year,
              let month = calendarManager.month,
              let day = calendarManager.day else {
            print("日付情報が不完全です")
            return
        }
        
        // 現在が閏月かどうか
        let isCurrentLeapMonth = calendarManager.nowLeapMonth
        
        print("旧暦モード - 次日移動開始: \(year)年\(isCurrentLeapMonth ? "閏" : "")\(month)月\(day)日")
        
        // 現在月の日数を取得
        var currentMonthDays: Int
        if isCurrentLeapMonth {
            // 閏月の日数を取得
            currentMonthDays = converter.ancientTbl[month + 1][0] - converter.ancientTbl[month][0]
        } else {
            // 通常月の日数を取得
            currentMonthDays = converter.ancientTbl[month][0] - converter.ancientTbl[month - 1][0]
        }
        
        print("現在月の日数: \(currentMonthDays)日")
        
        // 次日の旧暦日付を計算
        if day < currentMonthDays {
            // 同じ月内で次日に移動
            calendarManager.day = day + 1
            print("同じ月内で次日に移動します")
        } else {
            // 次月の初日に移動
            if isCurrentLeapMonth {
                // 閏月から通常の次月へ
                calendarManager.month = month + 1
                calendarManager.nowLeapMonth = false
                print("閏月から通常の次月へ移動します")
            } else if month == converter.leapMonth {
                // 通常月から閏月へ
                calendarManager.nowLeapMonth = true
                print("通常月から閏月へ移動します")
            } else if month < 12 {
                // 通常の次月移動
                calendarManager.month = month + 1
                calendarManager.nowLeapMonth = false
                print("通常の次月移動")
            } else {
                // 次年の1月に移動
                calendarManager.year = year + 1
                calendarManager.month = 1
                calendarManager.nowLeapMonth = false
                // 旧暦テーブルを次年に拡張
                converter.tblExpand(inYear: year + 1)
                print("次年の1月に移動します")
            }
            
            // 次月の初日は常に1日
            calendarManager.day = 1
        }
        
        // 旧暦から新暦への変換も更新
        calendarManager.initScheduleViewController()
    }
    
    /**
     * 前の日へ移動のシミュレーション
     */
    private func simulatePreviousDay() {
        guard let year = calendarManager.year,
              let month = calendarManager.month,
              let day = calendarManager.day else {
            print("日付情報が不完全です")
            return
        }
        
        // 現在が閏月かどうか
        let isCurrentLeapMonth = calendarManager.nowLeapMonth
        
        print("旧暦モード - 前日移動開始: \(year)年\(isCurrentLeapMonth ? "閏" : "")\(month)月\(day)日")
        
        // 前日の旧暦日付を計算
        if day > 1 {
            // 同じ月内で前日に移動
            calendarManager.day = day - 1
            print("同じ月内で前日に移動します")
        } else {
            // 前月の最終日に移動
            if month > 1 {
                let prevMonth = month - 1
                
                // 前月が閏月かどうかを確認
                if prevMonth == converter.leapMonth && !isCurrentLeapMonth {
                    // 前月が閏月の場合、閏月に設定
                    calendarManager.month = prevMonth
                    calendarManager.nowLeapMonth = true
                    print("前月は閏月です。閏月に移動します。")
                    
                    // 閏月の日数を取得
                    let leapMonthDays = converter.ancientTbl[prevMonth + 1][0] - converter.ancientTbl[prevMonth][0]
                    calendarManager.day = leapMonthDays
                    print("閏\(prevMonth)月の最終日: \(leapMonthDays)日")
                } else if isCurrentLeapMonth {
                    // 現在が閏月の場合、同じ月の通常月に移動
                    calendarManager.nowLeapMonth = false
                    print("閏月から同じ月の通常月に移動します")
                    
                    // 通常月の日数を取得
                    let normalMonthDays = converter.ancientTbl[month][0] - converter.ancientTbl[month - 1][0]
                    calendarManager.day = normalMonthDays
                    print("\(month)月の最終日: \(normalMonthDays)日")
                } else {
                    // 通常の前月移動
                    calendarManager.month = prevMonth
                    calendarManager.nowLeapMonth = false
                    print("通常の前月移動")
                    
                    // 前月の日数を取得
                    let prevMonthDays = converter.ancientTbl[prevMonth][0] - converter.ancientTbl[prevMonth - 1][0]
                    calendarManager.day = prevMonthDays
                    print("\(prevMonth)月の最終日: \(prevMonthDays)日")
                }
            } else {
                // 前年の12月に移動
                calendarManager.year = year - 1
                calendarManager.month = 12
                calendarManager.nowLeapMonth = false
                
                // 旧暦テーブルを前年に拡張
                converter.tblExpand(inYear: year - 1)
                
                // 12月の日数を取得
                let monthDays = converter.ancientTbl[12][0] - converter.ancientTbl[11][0]
                calendarManager.day = monthDays
                print("前年12月の最終日: \(monthDays)日に移動します")
            }
        }
        
        // 旧暦から新暦への変換も更新
        calendarManager.initScheduleViewController()
    }
    
    /**
     * 現在の旧暦日付を表示
     */
    private func printCurrentAncientDate(_ prefix: String) {
        let year = calendarManager.year ?? 0
        let month = calendarManager.month ?? 0
        let day = calendarManager.day ?? 0
        let isLeapMonth = calendarManager.nowLeapMonth
        
        var monthStr = "\(month)"
        if isLeapMonth {
            monthStr = "閏\(month)"
        }
        
        print("\(prefix): \(year)年\(monthStr)月\(day)日（isLeapMonth=\(isLeapMonth)）")
        
        if let gregorianYear = calendarManager.gregorianYear,
           let gregorianMonth = calendarManager.gregorianMonth,
           let gregorianDay = calendarManager.gregorianDay {
            print("  対応する新暦: \(gregorianYear)年\(gregorianMonth)月\(gregorianDay)日")
        }
    }
}