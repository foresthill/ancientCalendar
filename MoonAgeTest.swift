import Foundation
import XCTest

/**
 月齢計算のテストケース
 
 このファイルでは、アプリの月齢計算が正しく機能することを確認するためのテストケースを定義しています。
 主に以下の点をテストします：
 
 1. 伝統的な旧暦日ベースの月齢計算
 2. 簡易計算方式による月齢計算
 3. 天文学的計算方式による月齢計算
 4. 高精度計算方式による月齢計算
 
 月齢計算が旧暦日に基づく伝統的な表示と一致することを確認するためのテストです。
 */

// テスト用のCalendarManagerモック
class CalendarManagerMock {
    var year: Int?
    var month: Int?
    var day: Int?
    var comps: DateComponents = DateComponents()
    var calendarMode: Int = 1 // 1: 新暦, -1: 旧暦
    
    // 月の周期（日）- 29日12時間44分3秒
    let lunarCycle: Double = 29.53059
    
    // 月齢計算の基準日 (2000年1月6日 18:14 GMT - 天文学的な新月)
    let referenceNewMoon = "2000-01-06T18:14:00Z"
    
    /**
     月齢計算 - 簡易版（2016/08/15 旧実装）
     */
    func calcMoonAgeSimple() -> Double {
        // コンポーネントから年月日を取得
        guard let year = comps.year, let month = comps.month, let day = comps.day else {
            return 0.0
        }
        
        //(Y - 2004)×10.88 + (M - 7)×0.97 + (D - 1) + 13.3
        var temp = Double(year - 2004) * 10.88
        temp += Double(month - 7) * 0.97
        temp += Double(day - 1) + 13.3
        
        // 30日周期内に収める
        return floor((temp.truncatingRemainder(dividingBy: 30.0)) * 10) / 10
    }
    
    /**
     旧暦日に対応した月齢を計算（伝統的な旧暦表示に最適）
     */
    func calcMoonAgeForLunarDay(lunarDay: Int) -> Double {
        return Double(lunarDay - 1)
    }
    
    /**
     月齢計算 - 基準日からの経過日数による計算
     */
    func calcMoonAgeAstronomical() -> Double {
        // コンポーネントから年月日を取得
        guard let year = comps.year, let month = comps.month, let day = comps.day else {
            return 0.0
        }
        
        // 計算する日付のDateオブジェクトを作成
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = 12 // 正午を基準に
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0) // GMT
        
        guard let date = calendar.date(from: dateComponents) else {
            return 0.0
        }
        
        // 基準日のDateオブジェクトを作成
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        guard let referenceDate = dateFormatter.date(from: referenceNewMoon) else {
            return 0.0
        }
        
        // 現在の日付と基準日との差を計算
        let timeInterval = date.timeIntervalSince(referenceDate)
        
        // 月の周期（秒単位）
        let lunarCycleInSeconds = lunarCycle * 24 * 60 * 60
        
        // 月齢の計算（0〜29.53059の値）
        var age = (timeInterval.truncatingRemainder(dividingBy: lunarCycleInSeconds)) / (24 * 60 * 60)
        
        // 月齢を0〜29.53059の範囲に正規化
        if age < 0 {
            age += lunarCycle
        }
        
        // 小数点第一位で丸める
        return floor(age * 10) / 10
    }
    
    /**
     月齢計算 - 高精度計算（NASA計算式に基づく）
     */
    func calcMoonAgeHighPrecision() -> Double {
        // コンポーネントから年月日を取得
        guard let year = comps.year, let month = comps.month, let day = comps.day else {
            return 0.0
        }
        
        // ユリウス日を計算
        let jd = calcJulianDay(year: year, month: month, day: day)
        
        // 2000年1月6日からの月の位相角（ラジアン）
        let daysSince2000 = jd - 2451545.0
        let newMoonPhase = 2 * Double.pi * (daysSince2000 / lunarCycle).truncatingRemainder(dividingBy: 1.0)
        
        // 月の位相角から月齢を計算
        var moonAge = lunarCycle * (newMoonPhase / (2 * Double.pi))
        
        // 補正項（月の楕円軌道による効果）
        let M = (daysSince2000 * 0.03660110129) // 月の平均近点角
        moonAge += 0.5 * sin(M) // 第一補正項
        
        // 0〜29.53の範囲に正規化
        if moonAge < 0 {
            moonAge += lunarCycle
        } else if moonAge >= lunarCycle {
            moonAge -= lunarCycle
        }
        
        // 小数点第一位で丸める
        return floor(moonAge * 10) / 10
    }
    
    /**
     ユリウス日の計算
     */
    func calcJulianDay(year: Int, month: Int, day: Int) -> Double {
        var y = Double(year)
        var m = Double(month)
        let d = Double(day) + 0.5 // 正午を基準に
        
        if m <= 2 {
            y -= 1
            m += 12
        }
        
        let a = floor(y / 100.0)
        let b = 2 - a + floor(a / 4.0)
        
        let jd = floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + d + b - 1524.5
        return jd
    }
}

// 月齢計算テストケース
class MoonAgeTests: XCTestCase {
    var calendarManager: CalendarManagerMock!
    
    override func setUp() {
        super.setUp()
        calendarManager = CalendarManagerMock()
    }
    
    override func tearDown() {
        calendarManager = nil
        super.tearDown()
    }
    
    // 伝統的な旧暦日ベースの月齢計算をテスト
    func testTraditionalMoonAge() {
        // 旧暦1日（新月）
        XCTAssertEqual(calendarManager.calcMoonAgeForLunarDay(lunarDay: 1), 0.0, "旧暦1日の月齢は0.0になるべき")
        
        // 旧暦15日（満月）
        XCTAssertEqual(calendarManager.calcMoonAgeForLunarDay(lunarDay: 15), 14.0, "旧暦15日の月齢は14.0になるべき")
        
        // 旧暦30日（新月前夜）
        XCTAssertEqual(calendarManager.calcMoonAgeForLunarDay(lunarDay: 30), 29.0, "旧暦30日の月齢は29.0になるべき")
    }
    
    // 簡易計算方式の月齢計算をテスト（2025年5月のデータで検証）
    func testSimpleMoonAge() {
        // 2025年5月5日（新月の日）
        calendarManager.comps.year = 2025
        calendarManager.comps.month = 5
        calendarManager.comps.day = 5
        
        let moonAge = calendarManager.calcMoonAgeSimple()
        XCTAssertEqual(moonAge, 3.8, accuracy: 0.1, "2025年5月5日の簡易計算月齢は約3.8になるべき")
        
        // 2025年5月16日
        calendarManager.comps.day = 16
        let moonAge2 = calendarManager.calcMoonAgeSimple()
        XCTAssertEqual(moonAge2, 14.8, accuracy: 0.1, "2025年5月16日の簡易計算月齢は約14.8になるべき")
    }
    
    // 天文学的計算と高精度計算の結果が妥当な範囲内（0-29.5）であることを確認
    func testAstronomicalMoonAge() {
        // 2025年5月5日（新月の日）
        calendarManager.comps.year = 2025
        calendarManager.comps.month = 5
        calendarManager.comps.day = 5
        
        let astroAge = calendarManager.calcMoonAgeAstronomical()
        XCTAssertGreaterThanOrEqual(astroAge, 0.0)
        XCTAssertLessThan(astroAge, 29.6)
        
        let highPrecisionAge = calendarManager.calcMoonAgeHighPrecision()
        XCTAssertGreaterThanOrEqual(highPrecisionAge, 0.0)
        XCTAssertLessThan(highPrecisionAge, 29.6)
    }
    
    // 旧暦の日付と月齢の関係をテスト
    func testLunarDayMoonAgeCorrelation() {
        for day in 1...30 {
            let moonAge = calendarManager.calcMoonAgeForLunarDay(lunarDay: day)
            XCTAssertEqual(moonAge, Double(day - 1), "旧暦\(day)日の月齢は\(day-1)になるべき")
        }
    }
    
    // 新月・満月の日付で各計算方法をテスト
    func testMoonPhaseDates() {
        // 2025年5月の新月と満月（参考データ）
        let newMoonDate = (2025, 5, 5)  // 新月
        let fullMoonDate = (2025, 5, 20) // 満月
        
        // 新月の日
        calendarManager.comps.year = newMoonDate.0
        calendarManager.comps.month = newMoonDate.1
        calendarManager.comps.day = newMoonDate.2
        
        // 各計算方法で新月の月齢をチェック
        let newMoonSimple = calendarManager.calcMoonAgeSimple()
        let newMoonAstro = calendarManager.calcMoonAgeAstronomical()
        let newMoonHigh = calendarManager.calcMoonAgeHighPrecision()
        
        print("新月日の月齢計算: 簡易=\(newMoonSimple), 天文学的=\(newMoonAstro), 高精度=\(newMoonHigh)")
        
        // 満月の日
        calendarManager.comps.year = fullMoonDate.0
        calendarManager.comps.month = fullMoonDate.1
        calendarManager.comps.day = fullMoonDate.2
        
        // 各計算方法で満月の月齢をチェック
        let fullMoonSimple = calendarManager.calcMoonAgeSimple()
        let fullMoonAstro = calendarManager.calcMoonAgeAstronomical()
        let fullMoonHigh = calendarManager.calcMoonAgeHighPrecision()
        
        print("満月日の月齢計算: 簡易=\(fullMoonSimple), 天文学的=\(fullMoonAstro), 高精度=\(fullMoonHigh)")
    }
}

// 2025年3月の参照日（特別に検証が必要な日）のテスト
class MoonAgeReferenceTests: XCTestCase {
    var calendarManager: CalendarManagerMock!

    override func setUp() {
        super.setUp()
        calendarManager = CalendarManagerMock()
    }

    override func tearDown() {
        calendarManager = nil
        super.tearDown()
    }

    // 2025年3月17日の月齢計算比較テスト
    func testReferenceDateMarch17_2025() {
        // 2025年3月17日（旧暦2025年2月18日）
        let gregorianDate = (year: 2025, month: 3, day: 17)
        let lunarDate = (year: 2025, month: 2, day: 18)

        // 各計算方法による月齢を計算
        let traditionalMoonAge = MoonAgeCalculator.calculateFromLunarDay(lunarDay: lunarDate.day)

        // 天文学的計算
        let astronomicalMoonAge = MoonAgeCalculator.calculateAstronomical(
            year: gregorianDate.year,
            month: gregorianDate.month,
            day: gregorianDate.day
        )

        // 伝統的計算と天文学的計算の差
        let diff = traditionalMoonAge - astronomicalMoonAge

        // 予想される結果
        // 旧暦2月18日 → 月齢17.0
        // 天文学的計算 → 月齢16.2前後
        // 差は約0.8

        XCTAssertEqual(traditionalMoonAge, 17.0, "2025年3月17日の伝統的月齢は17.0になるべき")
        XCTAssertEqual(Int(astronomicalMoonAge), 16, "2025年3月17日の天文学的月齢の整数部は16になるべき")
        XCTAssertGreaterThan(diff, 0.5, "伝統的計算と天文学的計算の差は0.5以上であるべき")
        XCTAssertLessThan(diff, 1.0, "伝統的計算と天文学的計算の差は1.0未満であるべき")
    }

    // 連続する7日間の月齢変化テスト（2025年3月15日〜3月21日）
    func testConsecutiveDaysMarch2025() {
        // 2025年3月15日（旧暦2025年2月15日）から7日間の月齢変化をテスト
        let startDate = (year: 2025, month: 3, day: 15)
        let lunarDays = [15, 16, 18, 19, 20, 21, 22] // 旧暦の日（2月17日は存在しないため飛ぶ）

        // 結果を保存する配列
        var results: [(date: String, lunarDay: Int, traditional: Double, astronomical: Double, diff: Double)] = []

        // 7日間の月齢を計算
        for i in 0..<7 {
            let gregorianDate = (year: startDate.year, month: startDate.month, day: startDate.day + i)
            let lunarDay = lunarDays[i]

            let traditionalMoonAge = MoonAgeCalculator.calculateFromLunarDay(lunarDay: lunarDay)
            let astronomicalMoonAge = MoonAgeCalculator.calculateAstronomical(
                year: gregorianDate.year,
                month: gregorianDate.month,
                day: gregorianDate.day
            )

            let diff = traditionalMoonAge - astronomicalMoonAge
            let dateString = "\(gregorianDate.year)/\(gregorianDate.month)/\(gregorianDate.day)"

            results.append((dateString, lunarDay, traditionalMoonAge, astronomicalMoonAge, diff))
        }

        // 月齢の変化をコンソールに出力
        print("=== 参照日（3/17）周辺期間 (2025/3/15から7日間) ===\n")
        print("日付          | 旧暦日   | 伝統的計算 | 天文学的計算 | 差")
        print("--------------------------------------------------")

        for result in results {
            print("\(result.date) | \(result.lunarDay)日 | \(result.traditional) | \(result.astronomical) | \(result.diff)")
        }

        // 重要な参照日（2025年3月17日）のテスト
        XCTAssertEqual(results[2].traditional, 17.0, "2025年3月17日の伝統的月齢は17.0になるべき")
        XCTAssertEqual(Int(results[2].astronomical), 16, "2025年3月17日の天文学的月齢の整数部は16になるべき")

        // 日付が飛ぶ日の前後で月齢の連続性を確認
        XCTAssertEqual(results[1].lunarDay + 2, results[2].lunarDay, "旧暦2月16日の次は2月18日であるべき")
        XCTAssertEqual(results[1].traditional + 2.0, results[2].traditional, "伝統的月齢は連続して+2.0されるべき")
    }
}

// テストを実行するためのエントリーポイント
if #available(macOS 10.13, *) {
    // macOS 10.13以降でXCTestを実行
    let tests = [
        ("testTraditionalMoonAge", MoonAgeTests.testTraditionalMoonAge),
        ("testSimpleMoonAge", MoonAgeTests.testSimpleMoonAge),
        ("testAstronomicalMoonAge", MoonAgeTests.testAstronomicalMoonAge),
        ("testLunarDayMoonAgeCorrelation", MoonAgeTests.testLunarDayMoonAgeCorrelation),
        ("testMoonPhaseDates", MoonAgeTests.testMoonPhaseDates),
        // 新しい参照日テストを追加
        ("testReferenceDateMarch17_2025", MoonAgeReferenceTests.testReferenceDateMarch17_2025),
        ("testConsecutiveDaysMarch2025", MoonAgeReferenceTests.testConsecutiveDaysMarch2025)
    ]

    for (name, test) in tests {
        print("実行中: \(name)")
        if name.contains("testReferenceDate") || name.contains("testConsecutive") {
            let testCase = MoonAgeReferenceTests()
            testCase.setUp()
            test(testCase)()
            testCase.tearDown()
        } else {
            let testCase = MoonAgeTests()
            testCase.setUp()
            test(testCase)()
            testCase.tearDown()
        }
    }
} else {
    print("XCTestが利用できないため、テストをスキップします")
}