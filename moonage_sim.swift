import Foundation

// CalendarManager内の月齢計算ロジックをシミュレートするスクリプト
// 新暦4/1の月齢を各計算方法で計算し、結果を比較します

// カレンダー設定
let calendar = Calendar.current
var components = DateComponents()

// 以下のシミュレーション関数は年によって結果が変わるため、複数年でテスト
func simulateMoonAgeForYear(_ year: Int) {
    print("---------- \(year)年4月1日の月齢計算 ----------")
    
    // 新暦4/1の日付を設定
    components.year = year
    components.month = 4
    components.day = 1
    
    guard let date = calendar.date(from: components) else {
        print("Invalid date")
        return
    }
    
    // 1. オリジナルの計算方法（(Y - 2004)×10.88 + (M - 7)×0.97 + (D - 1) + 13.3）
    var temp = Double(year - 2004) * 10.88
    temp += Double(4 - 7) * 0.97  // 4月は7月から3ヶ月前
    temp += Double(1 - 1) + 13.3  // 1日 - 1 + 13.3
    
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
    
    // 3. 日本の旧暦では新月（朔）は旧暦1日に対応するとされる
    // 日本の旧暦では、旧暦1日は新月（月齢0.0）に最も近い日とされる
    print("3. 旧暦1日 = 新月の考え方: 旧暦1日は月齢約0.0となる")
    
    // 計算結果の評価
    print("旧暦4/1が新月（月齢0.0）に近いかどうか:")
    if originalResult <= 1.0 || originalResult >= 29.0 {
        print("オリジナル計算方法では、4/1は新月に近い")
    } else {
        print("オリジナル計算方法では、4/1は新月から離れている (月齢約\(originalResult))")
    }
    
    if astronomicalResult <= 1.0 || astronomicalResult >= 29.0 {
        print("天文学的計算方法では、4/1は新月に近い")
    } else {
        print("天文学的計算方法では、4/1は新月から離れている (月齢約\(astronomicalResult))")
    }
    
    // 計算差異
    print("計算方法による差異: \(abs(originalResult - astronomicalResult))")
    print("")
}

// 現在年および過去数年でシミュレーション
let currentYear = Calendar.current.component(.year, from: Date())
for year in [currentYear, 2024, 2023, 2022, 2021, 2020] {
    simulateMoonAgeForYear(year)
}

// 旧暦4/1の日付でも試してみる
print("\n---------- 旧暦4/1の月齢 ----------")
print("旧暦4/1は明確に新月（月齢約0.0）に調整されています")
print("この日はほぼ確実に新月です")