import Foundation

// Simple test program to debug the AncientCalendarConverter2 issue with 7/2/2025
// Copy just the essential parts of the conversion logic

// Constants class (minimal)
class Constants {
    static let minYear = 1999
    static let maxYear = 2030
}

// Test version of AncientCalendarConverter2
class AncientCalendarConverter2Test {
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
    
    /** 旧暦変換 */
    func convertForAncientCalendar(comps: DateComponents) -> [Int] {
        var yearByAncient: Int = comps.year ?? 0
        var monthByAncient: Int = comps.month ?? 0
        var dayByAncient: Int = comps.day ?? 0
        
        let calendar: Calendar = Calendar(identifier: .gregorian)
        var dayOfYear = calendar.ordinality(of: .day, in:.year, for: calendar.date(from: comps)!) ?? 0
        
        // 旧暦テーブルを作成する
        tblExpand(inYear: yearByAncient)
        
        if(dayOfYear < ancientTbl[0][0]) {   // 旧暦で表すと、１年前になる場合
            yearByAncient -= 1;
            dayOfYear += (365 + isLeapYear(inYear: yearByAncient))
            tblExpand(inYear: yearByAncient)
        }
        
        // どの月の、何日目かをancientTblから引き出す
        for i in (0...12).reversed() {
            if(ancientTbl[i][1] != 0){
                if(ancientTbl[i][0] <= dayOfYear){
                    monthByAncient = ancientTbl[i][1]
                    dayByAncient = dayOfYear - ancientTbl[i][0] + 1
                    break
                }
            }
        }
        
        // 閏月判定
        if (monthByAncient < 0) {
            isLeapMonth = -1;
            monthByAncient = -monthByAncient
        } else {
            isLeapMonth = 0
        }
        
        return [yearByAncient, monthByAncient, dayByAncient, isLeapMonth]
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
    func tblExpand(inYear: Int) {
        var days: Double = Double(o2ntbl[inYear - Constants.minYear][0])
        var bits: Int = o2ntbl[inYear - Constants.minYear][1]
        leapMonth = Int(days) % 13          // 閏月
        
        days = floor((Double(days) / 13.0) + 0.001) // 旧暦年初の新暦年初からの日数
        
        ancientTbl[0] = [Int(days), 1]  // 旧暦正月の通日と、月数
        
        if(leapMonth == 0) {
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
        
        if (ommax > 12) {    // 閏月のある年
            for i in leapMonth+1 ... 12 {
                ancientTbl[i][1] = i    // 月を再計算
            }
            ancientTbl[leapMonth][1] = -leapMonth;   // 識別のため閏月はマイナスで記録
        } else {
            ancientTbl[13] = [0, 0] // 使ってないけどエラー防止で。
        }
        
        // Debug info
        print("Year \(inYear):")
        print("leapMonth = \(leapMonth)")
        print("ommax = \(ommax)")
        print("ancientTbl:")
        for i in 0...13 {
            print("[\(i)]: [\(ancientTbl[i][0]), \(ancientTbl[i][1])]")
        }
    }
    
    /** デバッグ用：年の閏月情報を表示 */
    func printLeapMonthInfo(year: Int) {
        tblExpand(inYear: year)
        print("Year \(year) leap month: \(leapMonth)")
    }
    
    /** 指定した日付の古暦変換をテスト */
    func testConversion(year: Int, month: Int, day: Int) {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        
        let result = convertForAncientCalendar(comps: comps)
        
        print("New calendar: \(year)/\(month)/\(day) → Ancient calendar: \(result[0])/\(result[1])/\(result[2])")
        print("isLeapMonth = \(result[3] < 0 ? "Yes" : "No")")
        
        // 旧暦テーブルと照合して詳細情報を表示
        tblExpand(inYear: result[0])
        
        // 月の情報を詳細に表示
        let monthValue = result[1]
        let isLeap = result[3] < 0
        
        print("Month \(monthValue) info:")
        if let leapMonthVal = leapMonth, leapMonthVal == monthValue {
            print("✓ This is the leap month of the year")
            // テーブル内の閏月の値を確認
            let leapMonthIndex = leapMonthVal
            if leapMonthIndex >= 0 && leapMonthIndex < 14 {
                print("ancientTbl[\(leapMonthIndex)][1] = \(ancientTbl[leapMonthIndex][1])")
            }
            // 閏月の前後のインデックスも確認
            if leapMonthIndex > 0 && leapMonthIndex < 13 {
                print("Previous month: ancientTbl[\(leapMonthIndex-1)][1] = \(ancientTbl[leapMonthIndex-1][1])")
                print("Next month: ancientTbl[\(leapMonthIndex+1)][1] = \(ancientTbl[leapMonthIndex+1][1])")
            }
        } else {
            print("✗ This is NOT the leap month of the year")
        }
        
        // dayOfYear の検証
        let calendar = Calendar(identifier: .gregorian)
        guard let date = calendar.date(from: comps) else {
            print("Invalid date")
            return
        }
        
        let dayOfYear = calendar.ordinality(of: .day, in:.year, for: date) ?? 0
        print("Day of year: \(dayOfYear)")
        
        // 月の範囲を判定
        var monthFound = false
        for i in 0...12 {
            if i < 13 && ancientTbl[i][0] <= dayOfYear && dayOfYear < ancientTbl[i+1][0] {
                let monthDay = dayOfYear - ancientTbl[i][0] + 1
                let monthNum = ancientTbl[i][1]
                let isLeapMonthFromTable = monthNum < 0
                print("✓ Found in ancientTbl[\(i)]: Month \(abs(monthNum)), day \(monthDay)")
                print("  isLeapMonth from table: \(isLeapMonthFromTable ? "Yes" : "No")")
                monthFound = true
                break
            }
        }
        
        if !monthFound {
            print("❌ Month not found in ancientTbl ranges")
        }
    }
}

// Test the specific date 7/2/2025
print("\n=== Testing 7/2/2025 ===")
let converter = AncientCalendarConverter2Test()
converter.testConversion(year: 2025, month: 7, day: 2)

print("\n=== Testing neighboring dates ===")
converter.testConversion(year: 2025, month: 6, day: 30)
converter.testConversion(year: 2025, month: 7, day: 1)
converter.testConversion(year: 2025, month: 7, day: 3)
converter.testConversion(year: 2025, month: 7, day: 4)

print("\n=== Leap month information for 2025 ===")
converter.printLeapMonthInfo(year: 2025)