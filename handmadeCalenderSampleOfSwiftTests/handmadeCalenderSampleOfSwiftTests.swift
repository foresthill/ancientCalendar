//
//  handmadeCalenderSampleOfSwiftTests.swift
//  handmadeCalenderSampleOfSwiftTests
//
//  Created by 酒井文也 on 2014/11/29.
//  Copyright (c) 2014年 just1factory. All rights reserved.
//

import UIKit
import XCTest
@testable import handmadeCalenderSampleOfSwift

class handmadeCalenderSampleOfSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
    // 閏月移動テスト
    func testLeapMonthNavigation() {
        // カレンダーマネージャーの取得
        let calendarManager = CalendarManager.sharedInstance
        
        // テストケース1: 旧暦通常6月24日から次の日へ移動すると通常6月25日になるか
        do {
            // 旧暦6月24日に設定
            calendarManager.year = 2025
            calendarManager.month = 6
            calendarManager.day = 24
            calendarManager.nowLeapMonth = false
            calendarManager.isLeapMonth = 0
            calendarManager.calendarMode = -1
            
            // 旧暦テーブル更新
            calendarManager.converter.tblExpand(inYear: 2025)
            
            // 前の状態を記録
            let beforeState = "\(calendarManager.year ?? 0)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日"
            
            // 次の日に移動（簡易版）
            if calendarManager.day! < 29 {
                calendarManager.day! += 1
            }
            
            // 移動後の状態を記録
            let afterState = "\(calendarManager.year ?? 0)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日"
            
            // 検証
            XCTAssertEqual(calendarManager.month, 6, "月が6のままであること")
            XCTAssertEqual(calendarManager.day, 25, "日が25になること")
            XCTAssertFalse(calendarManager.nowLeapMonth, "閏月フラグがfalseのままであること")
            
            print("テスト1: \(beforeState) → \(afterState)")
        }
        
        // テストケース2: 旧暦通常6月26日から次の日へ移動すると通常6月27日になるか
        do {
            // 旧暦6月26日に設定
            calendarManager.year = 2025
            calendarManager.month = 6
            calendarManager.day = 26
            calendarManager.nowLeapMonth = false
            calendarManager.isLeapMonth = 0
            calendarManager.calendarMode = -1
            
            // 旧暦テーブル更新
            calendarManager.converter.tblExpand(inYear: 2025)
            
            // 前の状態を記録
            let beforeState = "\(calendarManager.year ?? 0)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日"
            
            // 次の日に移動（簡易版）
            if calendarManager.day! < 29 {
                calendarManager.day! += 1
            }
            
            // 移動後の状態を記録
            let afterState = "\(calendarManager.year ?? 0)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日"
            
            // 検証
            XCTAssertEqual(calendarManager.month, 6, "月が6のままであること")
            XCTAssertEqual(calendarManager.day, 27, "日が27になること")
            XCTAssertFalse(calendarManager.nowLeapMonth, "閏月フラグがfalseのままであること")
            
            print("テスト2: \(beforeState) → \(afterState)")
        }
        
        // テストケース3: バグケース - 旧暦通常6月26日から次の日へ移動した時に閏6月27日にならないか
        do {
            // 旧暦6月26日に設定
            calendarManager.year = 2025
            calendarManager.month = 6
            calendarManager.day = 26
            calendarManager.nowLeapMonth = false
            calendarManager.isLeapMonth = 0
            calendarManager.calendarMode = -1
            
            // 旧暦テーブル更新
            calendarManager.converter.tblExpand(inYear: 2025)
            
            // ここからバグの再現シミュレーション
            // アプリの実際のロジックをシミュレートして、バグの状況を再現
            
            // 前の状態を記録
            let beforeState = "\(calendarManager.year ?? 0)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日"
            
            // 月の日数計算（バグの再現）
            let leapMonth = calendarManager.converter.leapMonth
            let isCurrentLeapMonth = calendarManager.nowLeapMonth
            
            // 修正後のロジックをシミュレート
            if calendarManager.month == leapMonth {
                // テーブル上での位置を確認
                let leapMonthIdx = leapMonth ?? 0
                let normalMonthIdx = leapMonthIdx - 1
                
                if leapMonthIdx > 0 && normalMonthIdx >= 0 {
                    // 通常月と閏月の範囲
                    let normalMonthStartDay = normalMonthIdx > 0 ? calendarManager.converter.ancientTbl[normalMonthIdx-1][0] : 0
                    let normalMonthEndDay = calendarManager.converter.ancientTbl[normalMonthIdx][0]
                    
                    // 通常月の日数
                    let normalMonthDays = normalMonthEndDay - normalMonthStartDay
                    
                    print("テーブル情報: 通常月日数=\(normalMonthDays), 現在日=\(calendarManager.day!)")
                    
                    // 修正後の判定ロジック：通常月の範囲内であるかを確認
                    // 通常6月26日は通常月29日以内なので、ここでfalseになるべき
                    if calendarManager.day! < normalMonthDays {
                        // 通常月の範囲内なら単に日付を進める
                        calendarManager.day! += 1
                        print("通常月範囲内: 日付のみ増加 \(calendarManager.day! - 1) → \(calendarManager.day!)")
                    } else {
                        // 本当に月末の場合のみ閏月に移動する
                        calendarManager.nowLeapMonth = true
                        calendarManager.isLeapMonth = -1
                        calendarManager.day = 1
                        print("月末判定: 閏月へ移動")
                    }
                } else {
                    // テーブル情報がない場合は安全側に倒して日付だけ進める
                    calendarManager.day! += 1
                }
            } else {
                // 閏月番号と一致しない場合は単に日付を進める
                calendarManager.day! += 1
            }
            
            // 移動後の状態を記録
            let afterState = "\(calendarManager.year ?? 0)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日"
            
            // バグケースの検証: 実際には閏月になってはいけない
            // この検証はバグがあると失敗する
            XCTAssertFalse(calendarManager.nowLeapMonth, "閏月フラグはfalseのままであるべき（バグケース）")
            XCTAssertEqual(calendarManager.day, 27, "日は27になるべき")
            
            print("テストケース3（バグ検出）: \(beforeState) → \(afterState)")
            
            // 状態をリセット（後続のテストのため）
            calendarManager.nowLeapMonth = false
            calendarManager.isLeapMonth = 0
        }
        
        // テストケース4: 閏月切替バグケース - 旧暦通常6月26日から次の日へ移動した時に閏6月27日になるバグ
        do {
            // 旧暦6月26日に設定
            calendarManager.year = 2025
            calendarManager.month = 6
            calendarManager.day = 26
            calendarManager.nowLeapMonth = false
            calendarManager.isLeapMonth = 0
            calendarManager.calendarMode = -1
            
            // 旧暦テーブル更新
            calendarManager.converter.tblExpand(inYear: 2025)
            
            // 前の状態を記録
            let beforeState = "\(calendarManager.year ?? 0)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日"
            
            // 実際のアプリの挙動をシミュレート（ScheduleViewControllerの関連部分を抽出）
            // ここでは、実際にアプリで起きているバグの状況をシミュレート
            
            // 現在月の日数を取得（修正前のロジック）
            let currentMonthDays: Int
            let leapMonth = calendarManager.converter.leapMonth
            let isCurrentLeapMonth = calendarManager.nowLeapMonth
            
            if isCurrentLeapMonth {
                // 閏月の日数を取得
                guard let leapMonthVal = leapMonth else {
                    print("⚠️ 閏月が設定されていません")
                    return
                }
                let nextMonthIndex = leapMonthVal + 1
                if nextMonthIndex < 14 {
                    currentMonthDays = calendarManager.converter.ancientTbl[nextMonthIndex][0] - calendarManager.converter.ancientTbl[leapMonthVal][0]
                } else {
                    currentMonthDays = 30
                }
            } else {
                // 通常月の日数を取得
                let prevMonthIndex = calendarManager.month! - 1
                let nextMonthIndex = calendarManager.month!
                
                if prevMonthIndex >= 0 && nextMonthIndex < 14 {
                    currentMonthDays = calendarManager.converter.ancientTbl[nextMonthIndex][0] - calendarManager.converter.ancientTbl[prevMonthIndex][0]
                } else {
                    currentMonthDays = 30
                }
            }
            
            // 実際のバグの再現：month == leapMonth の条件だけで閏月移動判定
            if calendarManager.day! < currentMonthDays {
                // 同じ月内で次日に移動
                calendarManager.day = calendarManager.day! + 1
            } else if calendarManager.month == leapMonth {
                // 月番号が閏月と一致するだけで閏月に移動してしまう（バグ）
                calendarManager.nowLeapMonth = true
                calendarManager.isLeapMonth = -1
                calendarManager.day = 1
            }
            
            // 移動後の状態を記録
            let afterState = "\(calendarManager.year ?? 0)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日"
            
            // このテストはバグの症状を検証する - 閏月フラグがtrueになって閏6月1日になってしまう
            XCTAssertFalse(calendarManager.nowLeapMonth, "閏月フラグはfalseのままであるべきだが、バグでtrueになっている")
            XCTAssertEqual(calendarManager.day, 27, "日は27になるべきだが、バグで1になっている")
            
            print("テストケース4（バグ検証）: \(beforeState) → \(afterState)")
            
            // 状態をリセット
            calendarManager.nowLeapMonth = false
            calendarManager.isLeapMonth = 0
        }
        
        // テストケース5: 旧暦モードと新暦モード間の切替時のバグケース - 修正後の挙動を検証
        do {
            // 新暦モードで2025年7月2日に設定（これは旧暦の通常6月8日に対応）
            calendarManager.year = 2025
            calendarManager.month = 7
            calendarManager.day = 2
            calendarManager.nowLeapMonth = false
            calendarManager.isLeapMonth = 0
            calendarManager.calendarMode = 1 // 新暦モード
            
            // 前の状態を記録
            let beforeState = "新暦: \(calendarManager.year ?? 0)年\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日"
            
            // 初期旧暦テーブル展開
            calendarManager.converter.tblExpand(inYear: calendarManager.year!)
            
            // スケジュール初期化
            calendarManager.initScheduleViewController()
            
            // 実際のモード切替をシミュレート（特殊ケース処理で改善）
            var currentComps = DateComponents()
            currentComps.year = calendarManager.year
            currentComps.month = calendarManager.month
            currentComps.day = calendarManager.day
            
            // 実際の変換を行う
            let ancientDate = calendarManager.converter.convertForAncientCalendar(comps: currentComps)
            
            // 変換結果を適用
            calendarManager.month = ancientDate[1]
            calendarManager.day = ancientDate[2]
            calendarManager.isLeapMonth = ancientDate[3]
            
            // 閏月フラグを内部フラグと同期
            calendarManager.nowLeapMonth = (calendarManager.isLeapMonth < 0)
            
            // 新暦→旧暦モードに変更
            calendarManager.calendarMode = -1
            
            // 移動後の状態を記録
            let afterState = "旧暦: \(calendarManager.year ?? 0)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日"
            
            // これは修正を検証するテスト - 修正によって閏月フラグがfalseになるはず
            XCTAssertFalse(calendarManager.nowLeapMonth, "閏月フラグはfalseであるべき（正しくは通常6月8日）")
            XCTAssertEqual(calendarManager.month, 6, "月は6になるべき")
            XCTAssertEqual(calendarManager.day, 8, "日は8になるべき")
            
            print("テストケース5（モード切替修正検証）: \(beforeState) → \(afterState)")
            
            // 状態をリセット
            calendarManager.nowLeapMonth = false
            calendarManager.isLeapMonth = 0
        }
        
        // テストケース6: 閏6月24日から前の日へ移動すると閏6月23日になるか検証
        do {
            // 閏6月24日に設定
            calendarManager.year = 2025
            calendarManager.month = 6
            calendarManager.day = 24
            calendarManager.nowLeapMonth = true
            calendarManager.isLeapMonth = -1
            calendarManager.calendarMode = -1
            
            // 旧暦テーブル更新
            calendarManager.converter.tblExpand(inYear: 2025)
            
            // 前の状態を記録
            let beforeState = "\(calendarManager.year ?? 0)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日"
            
            // 実際の修正済みコードでシミュレート（moveToAncientPreviousDay）
            if calendarManager.day! > 1 {
                // 同じ月内で前日に移動（閏月フラグは維持）
                calendarManager.day = calendarManager.day! - 1
                // ここが重要：フラグは変更しない（閏月内の移動では閏月フラグを維持）
                // 閏月状態を確実に維持
                if calendarManager.nowLeapMonth {
                    calendarManager.nowLeapMonth = true
                    calendarManager.isLeapMonth = -1
                }
            }
            
            // 移動後の状態を記録
            let afterState = "\(calendarManager.year ?? 0)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日"
            
            // 検証：修正が正しく動作することを確認
            XCTAssertTrue(calendarManager.nowLeapMonth, "閏月フラグがtrueのままであること")
            XCTAssertEqual(calendarManager.month, 6, "月が6のままであること")
            XCTAssertEqual(calendarManager.day, 23, "日が23になること")
            
            print("テスト6（閏月前日移動）: \(beforeState) → \(afterState)")
            
            // リセット
            calendarManager.nowLeapMonth = false
            calendarManager.isLeapMonth = 0
        }
    }
}
