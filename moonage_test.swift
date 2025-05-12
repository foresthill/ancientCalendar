import Foundation

// 天文学的計算に基づく月齢計算
func calcAstronomicalMoonAge(year: Int, month: Int, day: Int) -> Double {
    // 計算する日付のDateオブジェクトを作成
    let calendar = Calendar(identifier: .gregorian)
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    dateComponents.hour = 12 // 正午を基準に
    dateComponents.minute = 0
    dateComponents.second = 0
    
    guard let date = calendar.date(from: dateComponents) else {
        return 0.0
    }
    
    // 基準日: 2000年1月6日 18:14 GMT (天文学的な新月)
    var referenceComponents = DateComponents()
    referenceComponents.year = 2000
    referenceComponents.month = 1
    referenceComponents.day = 6
    referenceComponents.hour = 18
    referenceComponents.minute = 14
    referenceComponents.second = 0
    
    guard let referenceDate = calendar.date(from: referenceComponents) else {
        return 0.0
    }
    
    // 現在の日付と基準日との差を計算
    let timeInterval = date.timeIntervalSince(referenceDate)
    
    // 月の周期 (29.53059日 = 29日12時間44分3秒)
    let lunarCycle = 29.53059 * 24 * 60 * 60 // 秒単位に変換
    
    // 月齢の計算 (0〜29.53059の値)
    var age = (timeInterval.truncatingRemainder(dividingBy: lunarCycle)) / (24 * 60 * 60) // 日単位に変換
    
    // 月齢を0〜29.53059の範囲に正規化
    if age < 0 {
        age += 29.53059
    }
    
    // 小数点第一位までに整形
    return floor(age * 10) / 10
}

// 簡易計算式による月齢計算
func calcSimpleMoonAge(year: Int, month: Int, day: Int) -> Double {
    //(Y - 2004)×10.88 + (M - 7)×0.97 + (D - 1) + 13.3
    var temp = Double(year - 2004) * 10.88
    temp += Double(month - 7) * 0.97
    temp += Double(day - 1) + 13.3
    
    // 30日周期内に収める
    let result = floor((temp.truncatingRemainder(dividingBy: 30.0)) * 10) / 10
    return result
}

// テスト用の日付
let testDates = [
    (2025, 5, 9),   // 今日
    (2025, 5, 10),  // 明日
    (2025, 5, 16),  // 一週間後
    (2025, 5, 23),  // 二週間後
    (2025, 4, 16),  // 前月
    (2025, 6, 16),  // 来月
    (2000, 1, 6),   // 基準日
    (2000, 1, 20),  // 基準日から2週間後
    (2023, 1, 1),   // 年始
    (2023, 12, 31)  // 年末
]

// テスト結果を表示
print("日付 | 天文学的月齢 | 簡易計算月齢 | 差分")
print("----|------------|------------|----")

for date in testDates {
    let year = date.0
    let month = date.1
    let day = date.2
    
    let astroAge = calcAstronomicalMoonAge(year: year, month: month, day: day)
    let simpleAge = calcSimpleMoonAge(year: year, month: month, day: day)
    let diff = abs(astroAge - simpleAge)
    
    print("\(year)/\(month)/\(day) | \(astroAge) | \(simpleAge) | \(diff)")
}

// 2025年における月齢テスト（新月と満月の日）
print("\n2025年の新月と満月の日付：")
print("日付 | 天文学的月齢 | 簡易計算月齢 | 差分")
print("----|------------|------------|----")

// 2025年の新月と満月の日付（天文学的データに基づく近似値）
let moonPhases2025 = [
    ("新月", 2025, 1, 7),
    ("満月", 2025, 1, 22),
    ("新月", 2025, 2, 6),
    ("満月", 2025, 2, 20),
    ("新月", 2025, 3, 7),
    ("満月", 2025, 3, 22),
    ("新月", 2025, 4, 6),
    ("満月", 2025, 4, 21),
    ("新月", 2025, 5, 5),
    ("満月", 2025, 5, 20),
    ("新月", 2025, 6, 4),
    ("満月", 2025, 6, 19),
    ("新月", 2025, 7, 3),
    ("満月", 2025, 7, 18),
    ("新月", 2025, 8, 1),
    ("満月", 2025, 8, 17),
    ("新月", 2025, 8, 31),
    ("満月", 2025, 9, 15),
    ("新月", 2025, 9, 29),
    ("満月", 2025, 10, 15),
    ("新月", 2025, 10, 29),
    ("満月", 2025, 11, 13),
    ("新月", 2025, 11, 27),
    ("満月", 2025, 12, 13),
    ("新月", 2025, 12, 27)
]

for phase in moonPhases2025 {
    let phaseName = phase.0
    let year = phase.1
    let month = phase.2
    let day = phase.3
    
    let astroAge = calcAstronomicalMoonAge(year: year, month: month, day: day)
    let simpleAge = calcSimpleMoonAge(year: year, month: month, day: day)
    let diff = abs(astroAge - simpleAge)
    
    let expectedAge = phaseName == "新月" ? 0.0 : 15.0
    let astroError = abs(astroAge - expectedAge)
    let simpleError = abs(simpleAge - expectedAge)
    
    print("\(phaseName) \(year)/\(month)/\(day) | \(astroAge) (誤差\(astroError)) | \(simpleAge) (誤差\(simpleError)) | \(diff)")
}