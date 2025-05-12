import Foundation

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
        let newMoonPhase = 2 * .pi * (daysSince2000 / lunarCycle).truncatingRemainder(dividingBy: 1.0)
        
        // 月の位相角から月齢を計算
        var moonAge = lunarCycle * (newMoonPhase / (2 * .pi))
        
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
        case newMoon = "新月"              // 0
        case waxingCrescent1 = "繊月"      // 1-2
        case waxingCrescent2 = "三日月"    // 3-4
        case waxingQuarter = "上弦の月"    // 7
        case waxingGibbous1 = "十日夜の月" // 10
        case waxingGibbous2 = "十三夜月"   // 13
        case waxingGibbous3 = "小望月"     // 14
        case fullMoon = "満月"             // 15
        case waningGibbous1 = "十六夜"     // 16
        case waningGibbous2 = "立待月"     // 17
        case waningGibbous3 = "居待月"     // 18
        case waningGibbous4 = "寝待月"     // 19
        case waningGibbous5 = "更待月"     // 20
        case lastQuarter = "下弦の月"      // 23
        case waningCrescent1 = "有明月"    // 26
        case waningCrescent2 = "三十日月"  // 30
        case unnamed = ""                 // その他
    }
    
    /**
     月齢から詳細な月の位相名を取得
     
     - parameter moonAge: 月齢（0〜29.5）
     - returns: 月の位相
     */
    static func getPhaseName(moonAge: Double) -> String {
        // 月齢に対応する月の満ち欠けの名称（詳細版）
        let moonNames = ["新月", "", "繊月", "三日月", "", "", "", "上弦の月", "", "", "十日夜の月",     //0〜10
                        "", "", "十三夜月", "小望月", "満月", "十六夜", "立待月", "居待月", "寝待月", "更待月", //11〜20
                        "", "", "下弦の月", "", "", "有明月", "", "", "", "三十日月"]  //21〜30
        
        // 整数部分を取得して配列のインデックスとして使用
        let index = Int(moonAge)
        if index >= 0 && index < moonNames.count {
            return moonNames[index]
        }
        return ""
    }
    
    /**
     月齢から月の位相を判定（シンプル版）
     
     - parameter moonAge: 月齢（0〜29.5）
     - returns: 月の位相
     */
    static func getPhase(moonAge: Double) -> MoonPhase {
        let intAge = Int(moonAge)
        
        switch intAge {
        case 0:
            return .newMoon
        case 1, 2:
            return .waxingCrescent1
        case 3, 4:
            return .waxingCrescent2
        case 7:
            return .waxingQuarter
        case 10:
            return .waxingGibbous1
        case 13:
            return .waxingGibbous2
        case 14:
            return .waxingGibbous3
        case 15:
            return .fullMoon
        case 16:
            return .waningGibbous1
        case 17:
            return .waningGibbous2
        case 18:
            return .waningGibbous3
        case 19:
            return .waningGibbous4
        case 20:
            return .waningGibbous5
        case 23:
            return .lastQuarter
        case 26:
            return .waningCrescent1
        case 30:
            return .waningCrescent2
        default:
            return .unnamed
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
    
    // MARK: - 月齢計算方法4: 伝統的な旧暦日ベースの計算
    
    /**
     伝統的な日本の旧暦日に基づく月齢計算
     
     旧暦1日が新月(月齢0)、旧暦15日が満月(月齢14)となる伝統的な計算方法です。
     日本の旧暦の考え方に完全に一致します。
     
     - parameter lunarDay: 旧暦の日
     - returns: 月齢（0〜29）
     */
    static func calculateFromLunarDay(lunarDay: Int) -> Double {
        return Double(lunarDay - 1)
    }
    
    /**
     指定した旧暦日の月齢を計算し、すべての計算方法の結果を返す
     
     - parameter lunarDay: 旧暦の日
     - returns: 伝統的計算による月齢（0〜29）
     */
    static func calculateTraditional(lunarDay: Int) -> Double {
        return calculateFromLunarDay(lunarDay: lunarDay)
    }
    
    /**
     複数の計算方法を比較するための詳細な結果を返す
     
     異なる月齢計算方法の結果を比較し、旧暦日との相関関係を調査するために使用します。
     
     - parameter gregorianDate: 新暦日付 (年, 月, 日)
     - parameter lunarDate: 旧暦日付 (年, 月, 日)
     - returns: 各計算方法の結果と差分を含む詳細情報
     */
    static func compareCalculationMethods(gregorianDate: (year: Int, month: Int, day: Int), 
                                        lunarDate: (year: Int, month: Int, day: Int)) -> [String: Any] {
        // 各計算方法による月齢を取得
        let simpleMoonAge = calculateSimple(year: gregorianDate.year, month: gregorianDate.month, day: gregorianDate.day)
        let astronomicalMoonAge = calculateAstronomical(year: gregorianDate.year, month: gregorianDate.month, day: gregorianDate.day)
        let highPrecisionMoonAge = calculateHighPrecision(year: gregorianDate.year, month: gregorianDate.month, day: gregorianDate.day)
        let traditionalMoonAge = calculateFromLunarDay(lunarDay: lunarDate.day)
        
        // 伝統的方法と他の計算方法との差を計算
        let diffSimple = traditionalMoonAge - simpleMoonAge
        let diffAstro = traditionalMoonAge - astronomicalMoonAge
        let diffHigh = traditionalMoonAge - highPrecisionMoonAge
        
        // 月相の名前を取得
        let phaseName = getPhaseName(moonAge: traditionalMoonAge)
        
        // 詳細な結果を辞書として返す
        return [
            "gregorianDate": "\(gregorianDate.year)/\(gregorianDate.month)/\(gregorianDate.day)",
            "lunarDate": "\(lunarDate.year)/\(lunarDate.month)/\(lunarDate.day)",
            "traditionalMoonAge": traditionalMoonAge,
            "simpleMoonAge": simpleMoonAge,
            "astronomicalMoonAge": astronomicalMoonAge,
            "highPrecisionMoonAge": highPrecisionMoonAge,
            "diffSimple": diffSimple,
            "diffAstronomical": diffAstro,
            "diffHighPrecision": diffHigh,
            "phaseName": phaseName,
            "imageNumber": Int(traditionalMoonAge)
        ]
    }
    
    /**
     指定した日付の月齢情報を取得するユーティリティメソッド
     
     旧暦日に基づく伝統的な月齢計算に加えて、月相の名前と画像番号も返します。
     
     - parameter lunarDay: 旧暦の日
     - returns: 月齢情報（月齢, 月相名, 画像番号）
     */
    static func getMoonAgeInfo(lunarDay: Int) -> (age: Double, phaseName: String, imageNumber: Int) {
        let moonAge = calculateFromLunarDay(lunarDay: lunarDay)
        let phaseName = getPhaseName(moonAge: moonAge)
        let imageNumber = Int(moonAge)
        
        return (moonAge, phaseName, imageNumber)
    }
}