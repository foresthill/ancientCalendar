import Foundation
import UIKit

/**
 * 旧暦月日ナビゲーションテスト実行
 * アプリ内でテストを実行するためのエントリーポイント
 */
class RunNavigationTest {
    
    static func execute() {
        print("旧暦日付ナビゲーションテストを実行します")
        
        // 2025年6-7月の日付ナビゲーションテスト実行
        let test = JuneToJulyNavigationTest.shared
        test.runTests()
    }
}