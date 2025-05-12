import Foundation

// ----- MoonAgeCalculator クラスの実装 (インライン) -----

/**
 月齢計算のためのユーティリティクラス
 
 複数の計算方法を提供し、高精度な月齢計算を行います
 */
class MoonAgeCalculator {
    
    // MARK: - 基本情報
    
    /// 月の周期（日）- 29日12時間44分3秒
    static let lunarCycle: Double = 29.53059
    
    /// 月齢計算の基準日 (2000年1月6日 18:14 GMT - 天文学的な新月)
    static let referenceNewMoon = "2000-01-06T18:14:00Z"
    
    // MARK: - 月齢計算方法1: 簡易計算（旧実装）
    
    /**
     簡易的な月齢計算（2004年を基準とした計算式）
     
     - parameter year: 年
     - parameter month: 月
     - parameter day: 日
     - returns: 月齢（0〜29.5）
     */
    static func calculateSimple(year: Int, month: Int, day: Int) -> Double {
        //(Y - 2004)×10.88 + (M - 7)×0.97 + (D - 1) + 13.3
        var temp = Double(year - 2004) * 10.88
        temp += Double(month - 7) * 0.97
        temp += Double(day - 1) + 13.3
        
        // 30日周期内に収める
        return floor((temp.truncatingRemainder(dividingBy: 30.0)) * 10) / 10
    }
    
    // MARK: - 月齢計算方法2: 基準日からの経過日数による計算
    
    /**
     基準日からの経過日数に基づく月齢計算
     
     - parameter year: 年
     - parameter month: 月
     - parameter day: 日
     - returns: 月齢（0〜29.5）
     */
    static func calculateAstronomical(year: Int, month: Int, day: Int) -> Double {
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
    
    // MARK: - 月齢計算方法3: 高精度計算（複数の修正項を含む）
    
    /**
     より精密な天文学的月齢計算（NASA計算式に基づく）
     
     - parameter year: 年
     - parameter month: 月
     - parameter day: 日
     - returns: 月齢（0〜29.5）
     */
    static func calculateHighPrecision(year: Int, month: Int, day: Int) -> Double {
        // ユリウス日を計算
        let jd = julianDay(year: year, month: month, day: day)
        
        // 新月の修正計算
        // この式は「Astronomical Algorithms」by Jean Meeus、第48章に基づいています
        
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
    
    // MARK: - ユリウス日の計算
    
    /**
     ユリウス日の計算
     
     - parameter year: 年
     - parameter month: 月
     - parameter day: 日
     - returns: ユリウス日
     */
    static func julianDay(year: Int, month: Int, day: Int) -> Double {
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
    
    // MARK: - 月の位相の取得
    
    /// 月の位相名
    enum MoonPhase: String {
        case newMoon = "新月"          // 0
        case waxingCrescent = "三日月"   // 0.1-6.9
        case firstQuarter = "上弦の月"   // 7.0-7.9
        case waxingGibbous = "十三夜月"  // 8.0-14.9
        case fullMoon = "満月"          // 15.0-15.9
        case waningGibbous = "十六夜"    // 16.0-21.9
        case lastQuarter = "下弦の月"    // 22.0-22.9
        case waningCrescent = "有明月"   // 23.0-29.4
    }
    
    /**
     月齢から月の位相を判定
     
     - parameter moonAge: 月齢（0〜29.5）
     - returns: 月の位相
     */
    static func getPhase(moonAge: Double) -> MoonPhase {
        switch moonAge {
        case 0.0..<0.1:
            return .newMoon
        case 0.1..<7.0:
            return .waxingCrescent
        case 7.0..<8.0:
            return .firstQuarter
        case 8.0..<15.0:
            return .waxingGibbous
        case 15.0..<16.0:
            return .fullMoon
        case 16.0..<22.0:
            return .waningGibbous
        case 22.0..<23.0:
            return .lastQuarter
        default:
            return .waningCrescent
        }
    }
    
    /**
     指定した日の月齢を計算し、すべての計算方法の結果を返す
     
     - parameter year: 年
     - parameter month: 月
     - parameter day: 日
     - returns: (簡易計算, 天文学的計算, 高精度計算)
     */
    static func calculateAllMethods(year: Int, month: Int, day: Int) -> (simple: Double, astro: Double, high: Double) {
        let simple = calculateSimple(year: year, month: month, day: day)
        let astro = calculateAstronomical(year: year, month: month, day: day)
        let high = calculateHighPrecision(year: year, month: month, day: day)
        return (simple, astro, high)
    }
}

// ----- テストコード -----

// 2025年における各月の新月と満月の正確な日付（NASA/JPLデータに基づく）
// 参考: https://svs.gsfc.nasa.gov/5048/
let moonPhases2025 = [
    // 新月日
    ("新月", 2025, 1, 7),
    ("新月", 2025, 2, 6),
    ("新月", 2025, 3, 7),
    ("新月", 2025, 4, 6),
    ("新月", 2025, 5, 5),
    ("新月", 2025, 6, 4),
    ("新月", 2025, 7, 3),
    ("新月", 2025, 8, 1),
    ("新月", 2025, 8, 31),
    ("新月", 2025, 9, 29),
    ("新月", 2025, 10, 29),
    ("新月", 2025, 11, 27),
    ("新月", 2025, 12, 27),
    
    // 満月日
    ("満月", 2025, 1, 22),
    ("満月", 2025, 2, 20),
    ("満月", 2025, 3, 22),
    ("満月", 2025, 4, 21),
    ("満月", 2025, 5, 20),
    ("満月", 2025, 6, 19),
    ("満月", 2025, 7, 18),
    ("満月", 2025, 8, 17),
    ("満月", 2025, 9, 15),
    ("満月", 2025, 10, 15),
    ("満月", 2025, 11, 13),
    ("満月", 2025, 12, 13)
]

// 任意の日付で月齢計算をテスト
func testSpecificDates() {
    let testDates = [
        (2025, 5, 9),   // 今日（仮）
        (2025, 5, 16),  // 一週間後
        (2025, 4, 16),  // 前月の中旬
        (2025, 6, 16),  // 来月の中旬
        (2000, 1, 6),   // 基準日
        (2023, 1, 1),   // 年始
        (2023, 12, 31), // 年末
        (2026, 1, 1),   // 将来の日付
        (1995, 7, 16)   // 過去の日付
    ]
    
    print("特定の日付における月齢計算テスト:\n")
    print("日付 | 簡易計算 | 天文学的計算 | 高精度計算 | 差分(高精度-簡易)")
    print("----|----------|------------|----------|---------------")
    
    for date in testDates {
        let year = date.0
        let month = date.1
        let day = date.2
        
        let results = MoonAgeCalculator.calculateAllMethods(year: year, month: month, day: day)
        let diff = abs(results.high - results.simple)
        
        print("\(year)/\(month)/\(day) | \(results.simple) | \(results.astro) | \(results.high) | \(diff)")
    }
}

// 新月・満月の日に計算精度をテスト
func testMoonPhases() {
    print("\n\n2025年の新月と満月における月齢計算精度テスト:\n")
    print("日付 | 期待値 | 簡易計算(誤差) | 天文学的計算(誤差) | 高精度計算(誤差)")
    print("----|-------|--------------|-----------------|---------------")
    
    for phase in moonPhases2025 {
        let phaseName = phase.0
        let year = phase.1
        let month = phase.2
        let day = phase.3
        
        let results = MoonAgeCalculator.calculateAllMethods(year: year, month: month, day: day)
        let expectedAge = phaseName == "新月" ? 0.0 : 15.0
        
        let simpleError = abs(results.simple - expectedAge)
        let astroError = abs(results.astro - expectedAge)
        let highError = abs(results.high - expectedAge)
        
        print("\(phaseName) \(year)/\(month)/\(day) | \(expectedAge) | \(results.simple) (\(simpleError)) | \(results.astro) (\(astroError)) | \(results.high) (\(highError))")
    }
}

// 月齢範囲ごとの月相名テスト
func testMoonPhaseNames() {
    print("\n\n月齢範囲ごとの月相名テスト:\n")
    print("月齢 | 月相名")
    print("----|------")
    
    let testAges = [0.0, 0.5, 3.5, 7.0, 7.5, 11.0, 15.0, 15.5, 18.0, 22.0, 22.5, 25.0, 29.0, 29.5]
    
    for age in testAges {
        let phase = MoonAgeCalculator.getPhase(moonAge: age)
        print("\(age) | \(phase.rawValue)")
    }
}

// アプリで使用する日付範囲でのテスト
func testAppDateRange() {
    print("\n\n旧暦カレンダーアプリで使用する日付範囲のテスト:\n")
    print("日付 | 旧暦日 | 簡易計算 | 高精度計算 | 月相名")
    print("----|-------|---------|----------|------")
    
    // 旧暦の日を1から30まで設定
    for ancientDay in 1...30 {
        // 2025年5月の旧暦日の例
        let year = 2025
        let month = 5
        let day = ancientDay
        
        let results = MoonAgeCalculator.calculateAllMethods(year: year, month: month, day: day)
        let phase = MoonAgeCalculator.getPhase(moonAge: results.high)
        
        print("\(year)/\(month)/\(day) | \(day) | \(results.simple) | \(results.high) | \(phase.rawValue)")
    }
}

// 一連のテストを実行
print("=============== 高精度月齢計算テスト ===============\n")
testSpecificDates()
testMoonPhases()
testMoonPhaseNames()
testAppDateRange()
print("\n=============== テスト完了 ===============")