//
//  LeapMonthNavigationTests.swift
//  handmadeCalenderSampleOfSwiftTests
//
//  Created with Claude Code
//

import XCTest
@testable import handmadeCalenderSampleOfSwift

/**
 * 閏月移動のテストケース
 * 特に2025年6月と閏6月の間の移動を検証する
 */
class LeapMonthNavigationTests: XCTestCase {
    
    // テスト対象
    var calendarManager: CalendarManager!
    var viewController: ScheduleViewController!
    
    // 旧暦テーブルの境界値（2025年6月）
    var normalMonth6StartDay: Int = 0
    var normalMonth6EndDay: Int = 0
    var leapMonth6StartDay: Int = 0
    var leapMonth6EndDay: Int = 0
    
    override func setUp() {
        super.setUp()
        
        // CalendarManagerの準備
        calendarManager = CalendarManager.sharedInstance
        
        // テスト用に2025年を設定
        calendarManager.year = 2025
        calendarManager.month = 6
        calendarManager.day = 1
        
        // 旧暦モードに設定
        calendarManager.calendarMode = -1
        
        // 旧暦テーブルを展開して2025年の閏月情報を取得
        calendarManager.converter.tblExpand(inYear: 2025)
        
        // 2025年6月の通常月と閏月の範囲を取得
        if let leapMonth = calendarManager.converter.leapMonth, leapMonth == 6 {
            let leapMonthIdx = leapMonth
            let normalMonthIdx = leapMonthIdx - 1
            
            if normalMonthIdx >= 0 && leapMonthIdx < calendarManager.converter.ancientTbl.count {
                normalMonth6StartDay = normalMonthIdx > 0 ? calendarManager.converter.ancientTbl[normalMonthIdx-1][0] : 0
                normalMonth6EndDay = calendarManager.converter.ancientTbl[normalMonthIdx][0]
                leapMonth6StartDay = calendarManager.converter.ancientTbl[leapMonthIdx-1][0]
                leapMonth6EndDay = calendarManager.converter.ancientTbl[leapMonthIdx][0]
                
                print("テスト環境セットアップ:")
                print("- 通常6月: 通日\(normalMonth6StartDay+1)〜\(normalMonth6EndDay)日 (全\(normalMonth6EndDay-normalMonth6StartDay)日)")
                print("- 閏6月: 通日\(leapMonth6StartDay+1)〜\(leapMonth6EndDay)日 (全\(leapMonth6EndDay-leapMonth6StartDay)日)")
            }
        }
        
        // ViewControllerの準備（実際のテストではMockを使用するとよい）
        // このテストでは実際のUIは使わず、CalendarManagerの状態変化のみを確認
    }
    
    override func tearDown() {
        calendarManager = nil
        viewController = nil
        super.tearDown()
    }
    
    // MARK: - テストヘルパーメソッド
    
    /**
     * 旧暦の次の日に移動
     */
    func moveToNextDay() {
        // 実装コードから抽出した閏月移動ロジック
        guard let year = calendarManager.year,
              let month = calendarManager.month,
              let day = calendarManager.day else {
            XCTFail("カレンダー情報が取得できませんでした")
            return
        }
        
        // テーブル情報を確実に更新
        calendarManager.converter.tblExpand(inYear: year)
        
        // 現在が閏月かどうか
        let isCurrentLeapMonth = calendarManager.nowLeapMonth && ((calendarManager.isLeapMonth ?? 0) < 0)
        
        // 閏月の情報を取得
        let leapMonth = calendarManager.converter.leapMonth
        
        // 月の日数を取得
        var currentMonthDays = 30 // デフォルト値
        
        if isCurrentLeapMonth {
            if let leapMonthVal = leapMonth {
                let nextMonthIndex = leapMonthVal + 1
                if nextMonthIndex < 14 {
                    currentMonthDays = calendarManager.converter.ancientTbl[nextMonthIndex][0] - calendarManager.converter.ancientTbl[leapMonthVal][0]
                }
            }
        } else {
            let prevMonthIndex = month - 1
            let nextMonthIndex = month
            
            if prevMonthIndex >= 0 && nextMonthIndex < 14 {
                currentMonthDays = calendarManager.converter.ancientTbl[nextMonthIndex][0] - calendarManager.converter.ancientTbl[prevMonthIndex][0]
            }
        }
        
        // 日付の移動
        if day < currentMonthDays {
            // 同じ月内で次日に移動
            calendarManager.day = day + 1
        } else {
            // 月末から次月へ
            if isCurrentLeapMonth {
                // 閏月の最終日から通常の次月初日へ
                calendarManager.month = month + 1
                calendarManager.nowLeapMonth = false
                calendarManager.isLeapMonth = 0
                calendarManager.day = 1
            } else if month == leapMonth {
                // 月番号が閏月と一致する場合のみ、閏月へ
                let leapMonthIdx = leapMonth ?? 0
                let normalMonthIdx = leapMonthIdx - 1
                
                if leapMonthIdx > 0 && normalMonthIdx >= 0 && leapMonthIdx < calendarManager.converter.ancientTbl.count {
                    let normalMonthStartDay = normalMonthIdx > 0 ? calendarManager.converter.ancientTbl[normalMonthIdx-1][0] : 0
                    let normalMonthEndDay = calendarManager.converter.ancientTbl[normalMonthIdx][0]
                    let leapMonthStartDay = calendarManager.converter.ancientTbl[leapMonthIdx-1][0]
                    
                    let currentDayOfYear = normalMonthStartDay + day
                    let nextDayOfYear = currentDayOfYear + 1
                    
                    if currentDayOfYear == normalMonthEndDay - 1 || nextDayOfYear == leapMonthStartDay {
                        // 通常月の最終日なら閏月へ
                        calendarManager.nowLeapMonth = true
                        calendarManager.isLeapMonth = -1
                        calendarManager.day = 1
                    } else if nextDayOfYear < leapMonthStartDay {
                        // まだ通常月内
                        calendarManager.day = day + 1
                    } else {
                        // デフォルト: 閏月へ
                        calendarManager.nowLeapMonth = true
                        calendarManager.isLeapMonth = -1
                        calendarManager.day = 1
                    }
                } else {
                    // テーブル検索できない場合
                    calendarManager.nowLeapMonth = true
                    calendarManager.isLeapMonth = -1
                    calendarManager.day = 1
                }
            } else if month < 12 {
                // 通常の次月
                calendarManager.month = month + 1
                calendarManager.nowLeapMonth = false
                calendarManager.isLeapMonth = 0
                calendarManager.day = 1
            } else {
                // 次年1月
                calendarManager.year = year + 1
                calendarManager.month = 1
                calendarManager.nowLeapMonth = false
                calendarManager.isLeapMonth = 0
                calendarManager.day = 1
            }
        }
    }
    
    /**
     * 旧暦の前の日に移動
     */
    func moveToPreviousDay() {
        // 実装コードから抽出した閏月移動ロジック
        guard let year = calendarManager.year,
              let month = calendarManager.month,
              let day = calendarManager.day else {
            XCTFail("カレンダー情報が取得できませんでした")
            return
        }
        
        // テーブル情報を確実に更新
        calendarManager.converter.tblExpand(inYear: year)
        
        // 現在が閏月かどうか
        let isCurrentLeapMonth = calendarManager.nowLeapMonth && ((calendarManager.isLeapMonth ?? 0) < 0)
        
        // 閏月の情報を取得
        let leapMonth = calendarManager.converter.leapMonth
        
        // 前日移動
        if day > 1 {
            // 同じ月内で前日に移動
            calendarManager.day = day - 1
        } else if isCurrentLeapMonth {
            // 閏月の初日から通常月の末日へ
            calendarManager.nowLeapMonth = false
            calendarManager.isLeapMonth = 0
            
            // 通常月の日数を取得
            let normalMonthIndex = month - 1
            let prevMonthIndex = normalMonthIndex - 1
            
            if prevMonthIndex >= 0 && normalMonthIndex < 14 {
                let normalMonthDays = calendarManager.converter.ancientTbl[normalMonthIndex][0] - calendarManager.converter.ancientTbl[prevMonthIndex][0]
                calendarManager.day = normalMonthDays
            } else {
                calendarManager.day = 30
            }
        } else if month > 1 {
            // 通常月の初日から前月末日へ
            let prevMonth = month - 1
            
            // 前月が閏月かどうか
            if prevMonth == leapMonth {
                // 前月が閏月なら閏月へ
                calendarManager.month = prevMonth
                calendarManager.nowLeapMonth = true
                calendarManager.isLeapMonth = -1
                
                // 閏月の日数
                guard let leapMonthIndex = leapMonth else {
                    calendarManager.day = 30
                    return
                }
                let nextMonthIndex = leapMonthIndex + 1
                
                if nextMonthIndex < 14 {
                    let leapMonthDays = calendarManager.converter.ancientTbl[nextMonthIndex][0] - calendarManager.converter.ancientTbl[leapMonthIndex][0]
                    calendarManager.day = leapMonthDays
                } else {
                    calendarManager.day = 30
                }
            } else {
                // 通常前月
                calendarManager.month = prevMonth
                calendarManager.nowLeapMonth = false
                calendarManager.isLeapMonth = 0
                
                // 通常月の日数
                let prevMonthIndex = prevMonth - 1
                let prevPrevMonthIndex = prevMonthIndex - 1
                
                if prevPrevMonthIndex >= 0 && prevMonthIndex < 14 {
                    let prevMonthDays = calendarManager.converter.ancientTbl[prevMonthIndex][0] - calendarManager.converter.ancientTbl[prevPrevMonthIndex][0]
                    calendarManager.day = prevMonthDays
                } else {
                    calendarManager.day = 30
                }
            }
        } else if month == 1 && day == 1 {
            // 1月1日から前年12月末日へ
            calendarManager.year = year - 1
            calendarManager.month = 12
            
            // 前年の閏月情報
            calendarManager.converter.tblExpand(inYear: year - 1)
            let prevYearLeapMonth = calendarManager.converter.leapMonth
            
            // 前年12月が閏月か
            if prevYearLeapMonth == 12 {
                calendarManager.nowLeapMonth = true
                calendarManager.isLeapMonth = -1
            } else {
                calendarManager.nowLeapMonth = false
                calendarManager.isLeapMonth = 0
            }
            
            // 12月の日数
            let monthIndex = calendarManager.nowLeapMonth ? 12 : 11
            let prevMonthIndex = monthIndex - 1
            
            if prevMonthIndex >= 0 && monthIndex < 14 {
                let monthDays = calendarManager.converter.ancientTbl[monthIndex][0] - calendarManager.converter.ancientTbl[prevMonthIndex][0]
                calendarManager.day = monthDays
            } else {
                calendarManager.day = 30
            }
        }
    }
    
    /**
     * 旧暦日付の文字列表現を取得
     */
    func getLunarDateString() -> String {
        let leapPrefix = calendarManager.nowLeapMonth ? "閏" : ""
        return "\(calendarManager.year ?? 0)年\(leapPrefix)\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日"
    }
    
    // MARK: - 境界テストケース
    
    /**
     * テストケース1: 旧暦通常6月24日から次の日へ移動すると通常6月25日になるか
     */
    func testNormalMonth6Day24ToDay25() {
        // 旧暦6月24日に設定
        calendarManager.year = 2025
        calendarManager.month = 6
        calendarManager.day = 24
        calendarManager.nowLeapMonth = false
        calendarManager.isLeapMonth = 0
        
        // 前の状態を記録
        let beforeState = getLunarDateString()
        
        // 次の日に移動
        moveToNextDay()
        
        // 移動後の状態を記録
        let afterState = getLunarDateString()
        
        // 検証
        XCTAssertEqual(calendarManager.month, 6, "月が6のままであること")
        XCTAssertEqual(calendarManager.day, 25, "日が25になること")
        XCTAssertFalse(calendarManager.nowLeapMonth, "閏月フラグがfalseのままであること")
        
        print("テスト1: \(beforeState) → \(afterState)")
    }
    
    /**
     * テストケース2: 旧暦通常6月26日から次の日へ移動すると通常6月27日になるか
     */
    func testNormalMonth6Day26ToDay27() {
        // 旧暦6月26日に設定
        calendarManager.year = 2025
        calendarManager.month = 6
        calendarManager.day = 26
        calendarManager.nowLeapMonth = false
        calendarManager.isLeapMonth = 0
        
        // 前の状態を記録
        let beforeState = getLunarDateString()
        
        // 次の日に移動
        moveToNextDay()
        
        // 移動後の状態を記録
        let afterState = getLunarDateString()
        
        // 検証
        XCTAssertEqual(calendarManager.month, 6, "月が6のままであること")
        XCTAssertEqual(calendarManager.day, 27, "日が27になること")
        XCTAssertFalse(calendarManager.nowLeapMonth, "閏月フラグがfalseのままであること")
        
        print("テスト2: \(beforeState) → \(afterState)")
    }
    
    /**
     * テストケース3: 旧暦通常6月28日から次の日へ移動すると通常6月29日（月末）になるか
     */
    func testNormalMonth6Day28ToDay29() {
        // 通常6月28日に設定
        calendarManager.year = 2025
        calendarManager.month = 6
        calendarManager.day = 28
        calendarManager.nowLeapMonth = false
        calendarManager.isLeapMonth = 0
        
        // 前の状態を記録
        let beforeState = getLunarDateString()
        
        // 次の日に移動
        moveToNextDay()
        
        // 移動後の状態を記録
        let afterState = getLunarDateString()
        
        // 検証
        XCTAssertEqual(calendarManager.month, 6, "月が6のままであること")
        XCTAssertEqual(calendarManager.day, 29, "日が29になること（月末）")
        XCTAssertFalse(calendarManager.nowLeapMonth, "閏月フラグがfalseのままであること")
        
        print("テスト3: \(beforeState) → \(afterState)")
    }
    
    /**
     * テストケース4: 旧暦通常6月29日（月末）から次の日へ移動すると閏6月1日になるか
     */
    func testNormalMonth6Day29ToLeapMonth6Day1() {
        // 通常6月29日（月末）に設定
        calendarManager.year = 2025
        calendarManager.month = 6
        calendarManager.day = 29
        calendarManager.nowLeapMonth = false
        calendarManager.isLeapMonth = 0
        
        // 前の状態を記録
        let beforeState = getLunarDateString()
        
        // 次の日に移動
        moveToNextDay()
        
        // 移動後の状態を記録
        let afterState = getLunarDateString()
        
        // 検証
        XCTAssertEqual(calendarManager.month, 6, "月が6のままであること")
        XCTAssertEqual(calendarManager.day, 1, "日が1になること")
        XCTAssertTrue(calendarManager.nowLeapMonth, "閏月フラグがtrueになること")
        XCTAssertEqual(calendarManager.isLeapMonth, -1, "isLeapMonthが-1になること")
        
        print("テスト4: \(beforeState) → \(afterState)")
    }
    
    /**
     * テストケース5: 旧暦閏6月1日から前の日へ移動すると通常6月29日（月末）になるか
     */
    func testLeapMonth6Day1ToPreviousNormalMonth6Day29() {
        // 閏6月1日に設定
        calendarManager.year = 2025
        calendarManager.month = 6
        calendarManager.day = 1
        calendarManager.nowLeapMonth = true
        calendarManager.isLeapMonth = -1
        
        // 前の状態を記録
        let beforeState = getLunarDateString()
        
        // 前の日に移動
        moveToPreviousDay()
        
        // 移動後の状態を記録
        let afterState = getLunarDateString()
        
        // 検証
        XCTAssertEqual(calendarManager.month, 6, "月が6のままであること")
        XCTAssertEqual(calendarManager.day, 29, "日が29になること（月末）")
        XCTAssertFalse(calendarManager.nowLeapMonth, "閏月フラグがfalseになること")
        XCTAssertEqual(calendarManager.isLeapMonth, 0, "isLeapMonthが0になること")
        
        print("テスト5: \(beforeState) → \(afterState)")
    }
    
    /**
     * テストケース6: 旧暦閏6月25日から前の日へ移動すると閏6月24日になるか
     */
    func testLeapMonth6Day25ToPreviousDay24() {
        // 閏6月25日に設定
        calendarManager.year = 2025
        calendarManager.month = 6
        calendarManager.day = 25
        calendarManager.nowLeapMonth = true
        calendarManager.isLeapMonth = -1
        
        // 前の状態を記録
        let beforeState = getLunarDateString()
        
        // 前の日に移動
        moveToPreviousDay()
        
        // 移動後の状態を記録
        let afterState = getLunarDateString()
        
        // 検証
        XCTAssertEqual(calendarManager.month, 6, "月が6のままであること")
        XCTAssertEqual(calendarManager.day, 24, "日が24になること")
        XCTAssertTrue(calendarManager.nowLeapMonth, "閏月フラグがtrueのままであること")
        
        print("テスト6: \(beforeState) → \(afterState)")
    }
    
    /**
     * テストケース7: 旧暦閏6月最終日から次の日へ移動すると通常7月1日になるか
     */
    func testLeapMonth6LastDayToNormalMonth7Day1() {
        // テーブルから閏6月の最終日を取得
        let leapMonth6Days = leapMonth6EndDay - leapMonth6StartDay
        
        // 閏6月最終日に設定
        calendarManager.year = 2025
        calendarManager.month = 6
        calendarManager.day = leapMonth6Days
        calendarManager.nowLeapMonth = true
        calendarManager.isLeapMonth = -1
        
        // 前の状態を記録
        let beforeState = getLunarDateString()
        
        // 次の日に移動
        moveToNextDay()
        
        // 移動後の状態を記録
        let afterState = getLunarDateString()
        
        // 検証
        XCTAssertEqual(calendarManager.month, 7, "月が7になること")
        XCTAssertEqual(calendarManager.day, 1, "日が1になること")
        XCTAssertFalse(calendarManager.nowLeapMonth, "閏月フラグがfalseになること")
        
        print("テスト7: \(beforeState) → \(afterState)")
    }
    
    /**
     * テストケース8: 旧暦通常7月1日から前の日へ移動すると閏6月最終日になるか
     */
    func testNormalMonth7Day1ToPreviousLeapMonth6LastDay() {
        // テーブルから閏6月の最終日を取得
        let leapMonth6Days = leapMonth6EndDay - leapMonth6StartDay
        
        // 通常7月1日に設定
        calendarManager.year = 2025
        calendarManager.month = 7
        calendarManager.day = 1
        calendarManager.nowLeapMonth = false
        calendarManager.isLeapMonth = 0
        
        // 前の状態を記録
        let beforeState = getLunarDateString()
        
        // 前の日に移動
        moveToPreviousDay()
        
        // 移動後の状態を記録
        let afterState = getLunarDateString()
        
        // 検証
        XCTAssertEqual(calendarManager.month, 6, "月が6になること")
        XCTAssertEqual(calendarManager.day, leapMonth6Days, "日が閏6月の最終日になること")
        XCTAssertTrue(calendarManager.nowLeapMonth, "閏月フラグがtrueになること")
        
        print("テスト8: \(beforeState) → \(afterState)")
    }
}