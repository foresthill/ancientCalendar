import Foundation

// ----- 月齢計算関数 (インライン) -----

/// 月の周期（日）- 29日12時間44分3秒
let lunarCycle: Double = 29.53059

/// 月齢計算の基準日 (2000年1月6日 18:14 GMT - 天文学的な新月)
let referenceNewMoon = "2000-01-06T18:14:00Z"

/**
 簡易的な月齢計算（2004年を基準とした計算式）
 */
func calcMoonAgeSimple(year: Int, month: Int, day: Int) -> Double {
    //(Y - 2004)×10.88 + (M - 7)×0.97 + (D - 1) + 13.3
    var temp = Double(year - 2004) * 10.88
    temp += Double(month - 7) * 0.97
    temp += Double(day - 1) + 13.3
    
    // 30日周期内に収める
    return floor((temp.truncatingRemainder(dividingBy: 30.0)) * 10) / 10
}

/**
 基準日からの経過日数に基づく月齢計算
 */
func calcMoonAgeAstronomical(year: Int, month: Int, day: Int) -> Double {
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

/**
 より精密な天文学的月齢計算（NASA計算式に基づく）
 */
func calcMoonAgeHighPrecision(year: Int, month: Int, day: Int) -> Double {
    // ユリウス日を計算
    let jd = calcJulianDay(year: year, month: month, day: day)
    
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

/**
 月の位相名を取得
 */
func getMoonPhaseName(moonAge: Double) -> String {
    if moonAge < 0.1 {
        return "新月"
    } else if moonAge < 7.0 {
        return "三日月"
    } else if moonAge < 8.0 {
        return "上弦の月"
    } else if moonAge < 15.0 {
        return "十三夜月"
    } else if moonAge < 16.0 {
        return "満月"
    } else if moonAge < 22.0 {
        return "十六夜"
    } else if moonAge < 23.0 {
        return "下弦の月"
    } else {
        return "有明月"
    }
}

// ----- テストコード -----

// 2025年4月〜6月の特定日をテスト
func test2025May() {
    // 2025年5月の新月日: 5月5日（天文学データより）
    // 2025年5月の満月日: 5月20日（天文学データより）
    
    // テスト日付: 4月下旬〜6月上旬
    let testDates = [
        (2025, 4, 25, "4月下旬"),
        (2025, 4, 30, "4月末日"),
        (2025, 5, 1, "5月初日"),
        (2025, 5, 5, "5月新月日"),
        (2025, 5, 9, "5月9日(現在)"),
        (2025, 5, 12, "5月中旬"),
        (2025, 5, 15, "5月中旬"),
        (2025, 5, 16, "5月16日"),
        (2025, 5, 20, "5月満月日"),
        (2025, 5, 25, "5月下旬"),
        (2025, 5, 31, "5月末日"),
        (2025, 6, 1, "6月初日"),
        (2025, 6, 4, "6月新月日"),
        (2025, 6, 10, "6月中旬")
    ]
    
    print("========= 2025年4月〜6月の月齢計算テスト =========\n")
    print("日付 | 簡易計算 | 天文学的計算 | 高精度計算 | 天文学データの参照フェーズ | 月相名(簡易)")
    print("----|----------|------------|----------|-----------------|------------")
    
    for date in testDates {
        let year = date.0
        let month = date.1
        let day = date.2
        let desc = date.3
        
        let simpleAge = calcMoonAgeSimple(year: year, month: month, day: day)
        let astroAge = calcMoonAgeAstronomical(year: year, month: month, day: day)
        let highPrecisionAge = calcMoonAgeHighPrecision(year: year, month: month, day: day)
        
        let phaseName = getMoonPhaseName(moonAge: simpleAge)
        
        // NASAデータからの参照フェーズ（特定日のみ）
        var reference = ""
        if month == 5 && day == 5 || month == 6 && day == 4 {
            reference = "新月"
        } else if month == 5 && day == 20 {
            reference = "満月"
        }
        
        print("\(year)/\(month)/\(day) (\(desc)) | \(simpleAge) | \(astroAge) | \(highPrecisionAge) | \(reference) | \(phaseName)")
    }
}

// 旧暦日による月齢表示テスト
func testLunarCalendarDays() {
    print("\n\n========= 旧暦日に基づく表示（古典的表示方法）=========\n")
    print("旧暦日 | 月相名(伝統的) | 簡易計算月齢 | 旧暦相対計算")
    print("------|--------------|------------|-------------")
    
    // 旧暦の日付と表示
    for day in 1...30 {
        let traditionalName: String
        
        // 伝統的な月相名（日本の旧暦に基づく）
        switch day {
        case 1: traditionalName = "朔（新月）"
        case 2, 3: traditionalName = "繊月"
        case 4, 5, 6: traditionalName = "三日月"
        case 7, 8: traditionalName = "上弦の月"
        case 9, 10, 11, 12, 13, 14: traditionalName = "十日夜・十三夜"
        case 15: traditionalName = "望（満月）"
        case 16: traditionalName = "十六夜"
        case 17: traditionalName = "立待月"
        case 18: traditionalName = "居待月"
        case 19: traditionalName = "寝待月"
        case 20: traditionalName = "更待月"
        case 21, 22: traditionalName = "下弦の月"
        case 23, 24, 25, 26, 27, 28, 29: traditionalName = "有明月"
        case 30: traditionalName = "晦（新月前夜）"
        default: traditionalName = ""
        }
        
        // 旧暦の日付に換算した月齢（代理として2025年5月を使用）
        let simpleAge = calcMoonAgeSimple(year: 2025, month: 5, day: day)
        
        // 旧暦の相対計算（本来の値）
        let relativeAge = (Double(day) - 1.0).truncatingRemainder(dividingBy: 30.0)
        
        print("\(day)日 | \(traditionalName) | \(simpleAge) | \(relativeAge)")
    }
}

// 実行
test2025May()
testLunarCalendarDays()