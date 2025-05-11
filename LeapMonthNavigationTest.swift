import Foundation

// モード切替と前後ナビゲーションのテストケース
// 特に閏月の問題を詳細に検証する

// Constants class (minimal)
class Constants {
    static let minYear = 1999
    static let maxYear = 2030
}

// 簡略化された旧暦カレンダーコンバーター
class AncientCalendarTestConverter {
    /** 旧暦・新暦変換テーブル（秘伝のタレ）*/
    let o2ntbl:[[Int]] = [[611,2350],[468,3222],
    [316,7317],[559,3402],[416,3493],
    [288,2901],[520,1388],[384,5467],[637,605],[494,2349],[343,6443],
    [585,2709],[442,2890],[302,5962],[533,2901],[412,2741],[650,1210],
    [507,2651],[369,2647],[611,1323],[468,2709],[329,5781],[559,1706],
    [416,2773],[288,2741],[533,1206],[383,5294],[624,2647],[494,1319],
    [356,3366],[572,3475],[442,1450]];
    
    var ancientTbl: [[Int]] // 計算用テーブル
    var isLeapMonth: Int!   // 閏月の場合は-1
    var leapMonth: Int!     // 閏月
    var ommax: Int!         // 月数（その年に閏月があるかないかを判定する）
    
    init() {
        ancientTbl = Array(repeating: [0, 0], count: 14)
        isLeapMonth = 0
        leapMonth = 0
        ommax = 12
    }
    
    /** 閏年判定（trueなら1、falseなら0を返す） */
    func isLeapYear(inYear: Int) -> Int {
        var isLeap = 0
        if(inYear % 400 == 0 || (inYear % 4 == 0 && inYear % 100 != 0)){
            isLeap = 1
        }
        return isLeap
    }
    
    /** 旧暦・新暦テーブル生成（ancientTbl）*/
    func tblExpand(inYear: Int){
        var days: Double = Double(o2ntbl[inYear - Constants.minYear][0])
        var bits: Int = o2ntbl[inYear - Constants.minYear][1]
        leapMonth = Int(days) % 13          // 閏月
        
        days = floor((Double(days) / 13.0) + 0.001) // 旧暦年初の新暦年初からの日数
        
        ancientTbl[0] = [Int(days), 1]  // 旧暦正月の通日と、月数
        
        if(leapMonth == 0){
            bits *= 2   // 閏無しなら、１２ヶ月
            ommax = 12
        } else {
            ommax = 13
        }
        
        for i in 1...ommax {
            ancientTbl[i] = [ancientTbl[i-1][0]+29, i+1]    // [旧暦の日数, 月]をループで入れる
            if(bits >= 4096) {
                ancientTbl[i][0] += 1    // 大の月（30日ある月）
            }
            bits = (bits % 4096) * 2;
        }
        ancientTbl[ommax][1] = 0    // テーブルの終わり＆旧暦の翌年年初
        
        if (ommax > 12){    // 閏月のある年
            for i in leapMonth+1 ... 12{
                ancientTbl[i][1] = i    // 月を再計算
            }
            ancientTbl[leapMonth][1] = -leapMonth;   // 識別のため閏月はマイナスで記録
        } else {
            ancientTbl[13] = [0, 0] // 使ってないけどエラー防止で。
        }
    }
    
    // 指定した年の閏月情報を表示
    func printLeapMonthInfo(year: Int) {
        tblExpand(inYear: year)
        print("\n=== \(year)年の閏月情報 ===")
        print("閏月: \(leapMonth ?? 0)月")
        print("月数: \(ommax ?? 12)ヶ月")
        
        // 通常月と閏月の配置を確認
        print("月の配置:")
        for i in 0...13 {
            let monthValue = ancientTbl[i][1]
            if monthValue != 0 {
                let monthType = monthValue < 0 ? "閏月" : "通常月"
                print("[\(i)]: \(abs(monthValue))月 - \(monthType)")
            }
        }
        
        // 各月の通日範囲を表示
        print("\n各月の通日範囲:")
        for i in 0...12 {
            if i < 13 && ancientTbl[i][1] != 0 {
                let monthStart = ancientTbl[i][0]
                let monthEnd = i + 1 < 14 ? ancientTbl[i+1][0] : 367
                let monthNum = ancientTbl[i][1]
                let isLeapMonthFromTable = monthNum < 0
                print("- \(isLeapMonthFromTable ? "閏" : "")\(abs(monthNum))月: 通日\(monthStart+1)～\(monthEnd)日")
            }
        }
    }
    
    // 新暦から旧暦への変換（簡略化）
    func convertGregorianToAncient(year: Int, month: Int, day: Int) -> (year: Int, month: Int, day: Int, isLeap: Bool) {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        
        // 通日計算
        let calendar = Calendar(identifier: .gregorian)
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: calendar.date(from: comps)!) ?? 0
        
        // テーブル展開
        tblExpand(inYear: year)
        
        // 月を特定
        var ancientYear = year
        var ancientMonth = 0
        var ancientDay = 0
        var isLeap = false
        
        // 年初チェック
        if dayOfYear < ancientTbl[0][0] {
            ancientYear -= 1
            tblExpand(inYear: ancientYear)
        }
        
        // 通日から月日を特定
        for i in (0...12).reversed() {
            if ancientTbl[i][1] != 0 && ancientTbl[i][0] <= dayOfYear {
                let monthValue = ancientTbl[i][1]
                isLeap = monthValue < 0
                ancientMonth = abs(monthValue)
                ancientDay = dayOfYear - ancientTbl[i][0] + 1
                break
            }
        }
        
        return (ancientYear, ancientMonth, ancientDay, isLeap)
    }
    
    // 旧暦から新暦への変換（簡略化）
    func convertAncientToGregorian(year: Int, month: Int, day: Int, isLeap: Bool) -> (year: Int, month: Int, day: Int) {
        // テーブル展開
        tblExpand(inYear: year)
        
        // 月インデックスと通日を特定
        var monthIdx = -1
        var dayOfYear = -1
        let monthValue = isLeap ? -month : month
        
        for i in 0...13 {
            if isLeap {
                if ancientTbl[i][1] == -month {
                    monthIdx = i
                    dayOfYear = ancientTbl[i][0] + day - 1
                    break
                }
            } else {
                if ancientTbl[i][1] == month {
                    monthIdx = i
                    dayOfYear = ancientTbl[i][0] + day - 1
                    break
                }
            }
        }
        
        if monthIdx < 0 || dayOfYear < 0 {
            return (0, 0, 0) // 変換エラー
        }
        
        // 新暦の年月日を計算
        var gregorianYear = year
        var gregorianMonth = 0
        var gregorianDay = 0
        
        // 年をまたぐ場合
        if dayOfYear > 365 + isLeapYear(inYear: year) {
            dayOfYear -= (365 + isLeapYear(inYear: year))
            gregorianYear += 1
        }
        
        // 月日の計算
        let calendar = Calendar(identifier: .gregorian)
        var comps = DateComponents()
        comps.year = gregorianYear
        comps.day = 1
        
        for m in (1...12).reversed() {
            comps.month = m
            let temp = calendar.ordinality(of: .day, in: .year, for: calendar.date(from: comps)!) ?? 0
            if dayOfYear >= temp {
                gregorianMonth = m
                gregorianDay = dayOfYear - temp + 1
                break
            }
        }
        
        return (gregorianYear, gregorianMonth, gregorianDay)
    }
    
    // 前日の日付を計算（旧暦）
    func previousDay(year: Int, month: Int, day: Int, isLeap: Bool) -> (year: Int, month: Int, day: Int, isLeap: Bool) {
        tblExpand(inYear: year)
        
        if day > 1 {
            // 同じ月内で前日に移動
            return (year, month, day - 1, isLeap)
        }
        
        // 月の変わり目
        var prevMonth = month
        var prevMonthIsLeap = false
        var prevYear = year
        
        if isLeap {
            // 閏月の初日から通常月の末日へ
            prevMonthIsLeap = false
            // 通常月の日数を取得
            let normalMonthIdx = month - 1
            let prevMonthIdx = normalMonthIdx - 1
            if prevMonthIdx >= 0 {
                let normalMonthDays = ancientTbl[normalMonthIdx][0] - (prevMonthIdx >= 0 ? ancientTbl[prevMonthIdx][0] : 0)
                return (year, month, normalMonthDays, false)
            }
        } else if month > 1 {
            // 通常月の初日から前月末日へ
            prevMonth = month - 1
            
            // 前月が閏月かチェック
            let leapMonthVal = leapMonth ?? 0
            if prevMonth == leapMonthVal {
                // 前月は閏月
                prevMonthIsLeap = true
                // 閏月の日数を取得
                let leapMonthIdx = leapMonthVal
                let prevMonthIdx = leapMonthIdx - 1
                if leapMonthIdx >= 0 && prevMonthIdx >= 0 {
                    let leapMonthDays = ancientTbl[leapMonthIdx][0] - ancientTbl[prevMonthIdx][0]
                    return (year, prevMonth, leapMonthDays, true)
                }
            } else {
                // 前月は通常月
                let prevMonthIdx = prevMonth - 1
                let prevPrevMonthIdx = prevMonthIdx - 1
                if prevMonthIdx >= 0 && prevPrevMonthIdx >= 0 {
                    let prevMonthDays = ancientTbl[prevMonthIdx][0] - ancientTbl[prevPrevMonthIdx][0]
                    return (year, prevMonth, prevMonthDays, false)
                }
            }
        } else if month == 1 && day == 1 {
            // 1月1日から前年12月末日へ
            prevYear = year - 1
            prevMonth = 12
            
            // 前年の閏月情報を取得
            tblExpand(inYear: prevYear)
            if leapMonth == 12 {
                // 前年12月が閏月
                prevMonthIsLeap = true
            }
            
            // 前年12月の日数を取得
            let monthIdx = prevMonthIsLeap ? 12 : 11
            let prevMonthIdx = monthIdx - 1
            if monthIdx >= 0 && prevMonthIdx >= 0 {
                let monthDays = ancientTbl[monthIdx][0] - ancientTbl[prevMonthIdx][0]
                return (prevYear, 12, monthDays, prevMonthIsLeap)
            }
        }
        
        // デフォルト（エラー時）
        return (year, month, 1, isLeap)
    }
    
    // 次日の日付を計算（旧暦）
    func nextDay(year: Int, month: Int, day: Int, isLeap: Bool) -> (year: Int, month: Int, day: Int, isLeap: Bool) {
        tblExpand(inYear: year)
        
        // 月の日数を取得
        var monthDays = 30 // デフォルト
        let leapMonthVal = leapMonth ?? 0
        
        if isLeap {
            // 閏月の日数
            let leapMonthIdx = leapMonthVal
            let nextMonthIdx = leapMonthIdx + 1
            if leapMonthIdx >= 0 && nextMonthIdx < 14 {
                monthDays = ancientTbl[nextMonthIdx][0] - ancientTbl[leapMonthIdx][0]
            }
        } else {
            // 通常月の日数
            let monthIdx = month - 1
            let nextMonthIdx = month
            if monthIdx >= 0 && nextMonthIdx < 14 {
                monthDays = ancientTbl[nextMonthIdx][0] - ancientTbl[monthIdx][0]
            }
        }
        
        if day < monthDays {
            // 同じ月内で次日に移動
            return (year, month, day + 1, isLeap)
        }
        
        // 月の変わり目
        if isLeap {
            // 閏月の最終日から次月初日へ
            return (year, month + 1, 1, false)
        } else if month == leapMonthVal {
            // 通常月の最終日から閏月初日へ
            return (year, month, 1, true)
        } else if month < 12 {
            // 通常の次月移動
            return (year, month + 1, 1, false)
        } else {
            // 次年の1月に移動
            return (year + 1, 1, 1, false)
        }
    }
}

// テスト用クラス：CalendarManagerをシミュレート
class CalendarManagerSimulator {
    var year: Int
    var month: Int
    var day: Int
    var isLeapMonth: Int  // 閏月の場合は-1、通常月の場合は0
    var nowLeapMonth: Bool  // 閏月の場合はtrue
    var calendarMode: Int  // 1: 新暦, -1: 旧暦
    
    // 新暦日付（calendarMode=1の場合）
    var gregorianYear: Int?
    var gregorianMonth: Int?
    var gregorianDay: Int?
    
    // 旧暦日付（calendarMode=-1の場合）
    var ancientYear: Int?
    var ancientMonth: Int?
    var ancientDay: Int?
    
    let converter = AncientCalendarTestConverter()
    
    init(year: Int, month: Int, day: Int, isLeap: Bool = false, mode: Int = 1) {
        self.year = year
        self.month = month
        self.day = day
        self.isLeapMonth = isLeap ? -1 : 0
        self.nowLeapMonth = isLeap
        self.calendarMode = mode
        
        if mode == 1 {
            // 新暦モード - 旧暦日付を計算
            gregorianYear = year
            gregorianMonth = month
            gregorianDay = day
            
            let ancient = converter.convertGregorianToAncient(year: year, month: month, day: day)
            ancientYear = ancient.year
            ancientMonth = ancient.month
            ancientDay = ancient.day
            
            // 閏月フラグは変換結果から
            if ancient.isLeap {
                isLeapMonth = -1
                nowLeapMonth = true
            }
        } else {
            // 旧暦モード - 新暦日付を計算
            ancientYear = year
            ancientMonth = month
            ancientDay = day
            
            let gregorian = converter.convertAncientToGregorian(year: year, month: month, day: day, isLeap: isLeap)
            gregorianYear = gregorian.year
            gregorianMonth = gregorian.month
            gregorianDay = gregorian.day
        }
    }
    
    // モード切替のシミュレーション
    func toggleMode() -> String {
        let oldMode = calendarMode
        let oldYear = year
        let oldMonth = month
        let oldDay = day
        let oldIsLeap = nowLeapMonth
        
        // モード反転
        calendarMode *= -1
        
        var result = ""
        result += "モード切替: \(oldMode == 1 ? "新暦" : "旧暦") → \(calendarMode == 1 ? "新暦" : "旧暦")\n"
        result += "切替前: \(oldYear)年\(oldIsLeap ? "閏" : "")\(oldMonth)月\(oldDay)日\n"
        
        if oldMode == 1 {
            // 新暦 → 旧暦
            year = ancientYear ?? 0
            month = ancientMonth ?? 0
            day = ancientDay ?? 0
            
            // 閏月フラグは計算時に更新済み
        } else {
            // 旧暦 → 新暦
            year = gregorianYear ?? 0
            month = gregorianMonth ?? 0
            day = gregorianDay ?? 0
            
            // 新暦に切り替わったので閏月フラグをリセット
            isLeapMonth = 0
            nowLeapMonth = false
        }
        
        result += "切替後: \(year)年\(nowLeapMonth ? "閏" : "")\(month)月\(day)日\n"
        return result
    }
    
    // 前日移動のシミュレーション
    func movePreviousDay() -> String {
        let oldYear = year
        let oldMonth = month
        let oldDay = day
        let oldIsLeap = nowLeapMonth
        
        var result = ""
        result += "前日移動: \(oldYear)年\(oldIsLeap ? "閏" : "")\(oldMonth)月\(oldDay)日 → "
        
        if calendarMode == 1 {
            // 新暦モード - 単純に日付を減らす
            let calendar = Calendar(identifier: .gregorian)
            var comps = DateComponents()
            comps.year = year
            comps.month = month
            comps.day = day
            
            if let date = calendar.date(from: comps),
               let prevDate = calendar.date(byAdding: .day, value: -1, to: date) {
                let prevComps = calendar.dateComponents([.year, .month, .day], from: prevDate)
                
                year = prevComps.year ?? 0
                month = prevComps.month ?? 0
                day = prevComps.day ?? 0
                
                // 旧暦日付も再計算
                let ancient = converter.convertGregorianToAncient(year: year, month: month, day: day)
                ancientYear = ancient.year
                ancientMonth = ancient.month
                ancientDay = ancient.day
                
                // 閏月フラグは変換結果から更新
                nowLeapMonth = ancient.isLeap
                isLeapMonth = ancient.isLeap ? -1 : 0
            }
        } else {
            // 旧暦モード - 複雑な計算
            let prev = converter.previousDay(year: year, month: month, day: day, isLeap: nowLeapMonth)
            
            year = prev.year
            month = prev.month
            day = prev.day
            nowLeapMonth = prev.isLeap
            isLeapMonth = prev.isLeap ? -1 : 0
            
            // 新暦日付も再計算
            let gregorian = converter.convertAncientToGregorian(year: year, month: month, day: day, isLeap: nowLeapMonth)
            gregorianYear = gregorian.year
            gregorianMonth = gregorian.month
            gregorianDay = gregorian.day
        }
        
        result += "\(year)年\(nowLeapMonth ? "閏" : "")\(month)月\(day)日\n"
        return result
    }
    
    // 次日移動のシミュレーション
    func moveNextDay() -> String {
        let oldYear = year
        let oldMonth = month
        let oldDay = day
        let oldIsLeap = nowLeapMonth
        
        var result = ""
        result += "次日移動: \(oldYear)年\(oldIsLeap ? "閏" : "")\(oldMonth)月\(oldDay)日 → "
        
        if calendarMode == 1 {
            // 新暦モード - 単純に日付を増やす
            let calendar = Calendar(identifier: .gregorian)
            var comps = DateComponents()
            comps.year = year
            comps.month = month
            comps.day = day
            
            if let date = calendar.date(from: comps),
               let nextDate = calendar.date(byAdding: .day, value: 1, to: date) {
                let nextComps = calendar.dateComponents([.year, .month, .day], from: nextDate)
                
                year = nextComps.year ?? 0
                month = nextComps.month ?? 0
                day = nextComps.day ?? 0
                
                // 旧暦日付も再計算
                let ancient = converter.convertGregorianToAncient(year: year, month: month, day: day)
                ancientYear = ancient.year
                ancientMonth = ancient.month
                ancientDay = ancient.day
                
                // 閏月フラグは変換結果から更新
                nowLeapMonth = ancient.isLeap
                isLeapMonth = ancient.isLeap ? -1 : 0
            }
        } else {
            // 旧暦モード - 複雑な計算
            let next = converter.nextDay(year: year, month: month, day: day, isLeap: nowLeapMonth)
            
            year = next.year
            month = next.month
            day = next.day
            nowLeapMonth = next.isLeap
            isLeapMonth = next.isLeap ? -1 : 0
            
            // 新暦日付も再計算
            let gregorian = converter.convertAncientToGregorian(year: year, month: month, day: day, isLeap: nowLeapMonth)
            gregorianYear = gregorian.year
            gregorianMonth = gregorian.month
            gregorianDay = gregorian.day
        }
        
        result += "\(year)年\(nowLeapMonth ? "閏" : "")\(month)月\(day)日\n"
        return result
    }
}

// テストスイート実行関数
func runTests() {
    let converter = AncientCalendarTestConverter()
    
    // 1. 2025年の閏月情報を確認
    converter.printLeapMonthInfo(year: 2025)
    
    // 2. 特定の日付のテスト - 7/2/2025 (新暦→旧暦)
    print("\n=== 特定の日付テスト: 7/2/2025 (新暦→旧暦) ===")
    let ancient = converter.convertGregorianToAncient(year: 2025, month: 7, day: 2)
    print("新暦: 2025/7/2 → 旧暦: \(ancient.year)/\(ancient.isLeap ? "閏" : "")\(ancient.month)/\(ancient.day)")
    
    // 3. 特定の日付のテスト - 旧暦6/8/2025 (旧暦→新暦)
    print("\n=== 特定の日付テスト: 旧暦6/8/2025 (旧暦→新暦) ===")
    let gregorian1 = converter.convertAncientToGregorian(year: 2025, month: 6, day: 8, isLeap: false)
    print("旧暦: 2025/6/8 → 新暦: \(gregorian1.year)/\(gregorian1.month)/\(gregorian1.day)")
    
    // 4. 特定の日付のテスト - 旧暦閏6/8/2025 (旧暦→新暦)
    print("\n=== 特定の日付テスト: 旧暦閏6/8/2025 (旧暦→新暦) ===")
    let gregorian2 = converter.convertAncientToGregorian(year: 2025, month: 6, day: 8, isLeap: true)
    print("旧暦: 2025/閏6/8 → 新暦: \(gregorian2.year)/\(gregorian2.month)/\(gregorian2.day)")
    
    // 5. モード切替テスト (7/2/2025)
    print("\n=== モード切替テスト: 7/2/2025 ===")
    let manager1 = CalendarManagerSimulator(year: 2025, month: 7, day: 2)
    print(manager1.toggleMode())
    
    // 6. 旧暦からのモード切替テスト (6/8/2025)
    print("\n=== モード切替テスト: 旧暦6/8/2025 ===")
    let manager2 = CalendarManagerSimulator(year: 2025, month: 6, day: 8, isLeap: false, mode: -1)
    print(manager2.toggleMode())
    
    // 7. 閏月からのモード切替テスト (閏6/8/2025)
    print("\n=== モード切替テスト: 旧暦閏6/8/2025 ===")
    let manager3 = CalendarManagerSimulator(year: 2025, month: 6, day: 8, isLeap: true, mode: -1)
    print(manager3.toggleMode())
    
    // 8. 特定のワープ問題のテスト（6/29→前日ボタン→閏6/28になるケース）
    print("\n=== ワープ問題テスト: 旧暦6/29→前日→閏6/28 ===")
    let manager4 = CalendarManagerSimulator(year: 2025, month: 6, day: 29, isLeap: false, mode: -1)
    
    // 日付状態を詳細表示
    print("状態確認: \(manager4.year)年\(manager4.month)月\(manager4.day)日 (isLeap=\(manager4.nowLeapMonth))")
    print("テーブル内の位置確認:")
    converter.tblExpand(inYear: 2025)
    let monthIndex = 5 // 6月の月インデックス
    let day = 29
    let approxDayOfYear = (manager4.month - 1) * 30 + manager4.day
    let normalMonthIdx = converter.leapMonth! - 1
    let leapMonthIdx = converter.leapMonth!
    print("- 通常6月範囲: \(converter.ancientTbl[normalMonthIdx][0]+1)～\(converter.ancientTbl[normalMonthIdx+1][0])日")
    print("- 閏6月範囲: \(converter.ancientTbl[leapMonthIdx][0]+1)～\(converter.ancientTbl[leapMonthIdx+1][0])日")
    print("- 概算通日: \(approxDayOfYear)日")
    
    // 前日ボタンの挙動
    print(manager4.movePreviousDay())
    
    print("\n=== 通常月の日程範囲テスト ===")
    converter.tblExpand(inYear: 2025)
    let normalMonthStartDay = normalMonthIdx > 0 ? converter.ancientTbl[normalMonthIdx-1][0] : 0
    let normalMonthEndDay = converter.ancientTbl[normalMonthIdx][0]
    print("6月（通常）の範囲: \(normalMonthStartDay+1)～\(normalMonthEndDay)日")
    print("6月（通常）の日数: \(normalMonthEndDay - normalMonthStartDay)日")
    
    print("\n閏月の日程範囲テスト")
    let leapMonthStartDay = converter.ancientTbl[leapMonthIdx-1][0]
    let leapMonthEndDay = converter.ancientTbl[leapMonthIdx][0]
    print("6月（閏月）の範囲: \(leapMonthStartDay+1)～\(leapMonthEndDay)日")
    print("6月（閏月）の日数: \(leapMonthEndDay - leapMonthStartDay)日")
    
    print("\n=== 前日移動テスト ===")
    let dates = [
        (year: 2025, month: 6, day: 1, isLeap: false),
        (year: 2025, month: 6, day: 2, isLeap: false),
        (year: 2025, month: 6, day: 28, isLeap: false),
        (year: 2025, month: 6, day: 29, isLeap: false),
        (year: 2025, month: 6, day: 30, isLeap: false),
        (year: 2025, month: 6, day: 1, isLeap: true),
        (year: 2025, month: 6, day: 2, isLeap: true),
        (year: 2025, month: 6, day: 28, isLeap: true),
        (year: 2025, month: 6, day: 29, isLeap: true),
    ]
    
    for date in dates {
        let manager = CalendarManagerSimulator(year: date.year, month: date.month, day: date.day, isLeap: date.isLeap, mode: -1)
        let result = manager.movePreviousDay()
        print("テスト: \(date.year)年\(date.isLeap ? "閏" : "")\(date.month)月\(date.day)日の前日")
        print(result)
    }
}

// テスト実行
print("======= 閏月ナビゲーションテスト開始 =======")
runTests()
print("======= テスト終了 =======")