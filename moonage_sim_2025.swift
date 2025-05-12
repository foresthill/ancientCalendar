import Foundation

// CalendarManager内の月齢計算ロジックをシミュレートするスクリプト
// 2025年の各月1日の月齢を各計算方法で計算し、結果を比較します

// カレンダー設定
let calendar = Calendar.current
var components = DateComponents()

// 以下のシミュレーション関数は月によって結果が変わるため、複数月でテスト
func simulateMoonAgeForDate(year: Int, month: Int, day: Int) {
    print("---------- \(year)年\(month)月\(day)日の月齢計算 ----------")
    
    // 日付を設定
    components.year = year
    components.month = month
    components.day = day
    
    guard let date = calendar.date(from: components) else {
        print("Invalid date")
        return
    }
    
    // 1. オリジナルの計算方法（(Y - 2004)×10.88 + (M - 7)×0.97 + (D - 1) + 13.3）
    var temp = Double(year - 2004) * 10.88
    temp += Double(month - 7) * 0.97  // 月と7月の差分
    temp += Double(day - 1) + 13.3    // 日 - 1 + 13.3
    
    let originalResult = floor((temp.truncatingRemainder(dividingBy: 30.0)) * 10) / 10
    print("1. オリジナル計算方法: \(originalResult)")
    
    // 2. 天文学的な計算方法（新月からの経過日数）
    // 2000年1月6日 18:14 GMT (新月の日)
    let referenceDate = Date(timeIntervalSince1970: 947182440)
    
    // 新月の日からの経過時間（秒）
    let elapsedSeconds = date.timeIntervalSince(referenceDate)
    let secondsInLunarCycle = 29.53059 * 24 * 60 * 60
    
    // 経過した月の巡回から月齢を計算
    var moonAge = (elapsedSeconds.truncatingRemainder(dividingBy: secondsInLunarCycle)) / (24 * 60 * 60)
    
    // 0-29.5の範囲に収める
    if moonAge < 0 {
        moonAge += 29.53059
    }
    
    // 小数点以下1桁に丸める
    let astronomicalResult = floor(moonAge * 10) / 10
    print("2. 天文学的計算方法: \(astronomicalResult)")
    
    // 月相の説明を追加
    func describeMoonPhase(_ age: Double) -> String {
        if age < 1.0 || age >= 29.0 {
            return "新月"
        } else if age >= 1.0 && age < 7.0 {
            return "新月〜上弦"
        } else if age >= 7.0 && age < 8.0 {
            return "上弦"
        } else if age >= 8.0 && age < 14.0 {
            return "上弦〜満月"
        } else if age >= 14.0 && age < 16.0 {
            return "満月"
        } else if age >= 16.0 && age < 22.0 {
            return "満月〜下弦"
        } else if age >= 22.0 && age < 23.0 {
            return "下弦"
        } else {
            return "下弦〜新月"
        }
    }
    
    // 月相の説明を出力
    print("オリジナル計算による月相: \(describeMoonPhase(originalResult))")
    print("天文学的計算による月相: \(describeMoonPhase(astronomicalResult))")
    
    // 計算差異
    let difference = abs(originalResult - astronomicalResult)
    print("計算方法による差異: \(difference)")
    
    // 差異が大きい場合に注意を表示
    if difference > 10.0 {
        print("⚠️ 両計算方法の結果に大きな差異があります!")
    }
    print("")
}

// 2025年の各月1日でシミュレーション
let targetYear = 2025
let targetMonths = [1, 2, 3, 4, 5]

for month in targetMonths {
    simulateMoonAgeForDate(year: targetYear, month: month, day: 1)
}

// 月齢と旧暦1日の関係
print("\n---------- 月齢と旧暦の関係 ----------")
print("旧暦では1日は新月に近い日とされています")
print("オリジナルの計算方法は旧暦の日付と月齢を対応させるために調整されている可能性があります")
print("天文学的計算方法は実際の月の位相に基づいています")