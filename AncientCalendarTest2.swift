import Foundation

// Simple test program to debug the AncientCalendarConverter2 issue with 7/2/2025
// This version tests the conversion from ancient to new calendar

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
    
    /** 旧暦→新暦変換 */
    func convertForGregorianCalendar(dateArray: [Int]) -> DateComponents {
        //イマを刻むコンポーネント
        let calendar: Calendar = Calendar.current
        
        var compsByGregorian = calendar.dateComponents([.year, .month, .day], from: Date())    //とりあえずイマを返す
        
        var yearByGregorian = dateArray[0]
        var monthByGregorian = dateArray[1]
        var dayByGregorian = dateArray[2]
        let leapMonthFlag = dateArray[3]
        
        // デバッグ情報
        print("旧暦→新暦変換: \(yearByGregorian)年\(monthByGregorian < 0 ? "閏" : "")\(abs(monthByGregorian))月\(dayByGregorian)日, isLeapMonth=\(leapMonthFlag)")
        
        // 閏月の場合（マイナス値として渡される）
        let isMonthLeap = monthByGregorian < 0
        if isMonthLeap {
            // マイナス値を絶対値に変換
            monthByGregorian = abs(monthByGregorian)
            print("閏月として計算します: \(monthByGregorian)月")
        }
        
        tblExpand(inYear: yearByGregorian)
        
        // 現在の年の閏月情報を確認
        print("現在の年(\(yearByGregorian))の閏月: \(leapMonth ?? 0)月")
        
        var dayOfYear: Int = -1
        
        for i in 0...13 {
            // 通常月の場合は ancientTbl[i][1] == monthByGregorian
            // 閏月の場合は ancientTbl[i][1] == -monthByGregorian
            if isMonthLeap {
                // 閏月の場合: tblExpandで設定された負数の月と一致するか
                if ancientTbl[i][1] == -monthByGregorian {
                    dayOfYear = ancientTbl[i][0] + dayByGregorian - 1
                    print("閏月のマッチを発見: \(ancientTbl[i][1])月")
                    break
                }
            } else {
                // 通常月の場合
                if ancientTbl[i][1] == monthByGregorian {
                    dayOfYear = ancientTbl[i][0] + dayByGregorian - 1
                    break
                }
            }
        }
        
        if dayOfYear < 0 {
            //該当日なし
            return compsByGregorian
        }
        
        var tmp: Int = 365 + isLeapYear(inYear: yearByGregorian)
        
        if dayOfYear > tmp {
            dayOfYear = dayOfYear - tmp;
            yearByGregorian += 1
        }
        
        dayByGregorian = -1
        
        compsByGregorian.year = yearByGregorian
        compsByGregorian.day = 1
        
        for i in (0...12).reversed() {
            compsByGregorian.month = i
            tmp = calendar.ordinality(of: .day, in: .year, for: calendar.date(from: compsByGregorian)!) ?? 0
            if dayOfYear >= tmp {
                dayByGregorian = dayOfYear - tmp + 1
                break
            }
        }
        
        if dayByGregorian < 0 {
            return compsByGregorian   //とりあえずイマを返す
        }
        
        compsByGregorian.year = yearByGregorian
        compsByGregorian.day = dayByGregorian
        
        return compsByGregorian
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
        print("Year \(inYear) ancientTbl prepared:")
        print("leapMonth = \(leapMonth ?? 0)")
        print("ommax = \(ommax ?? 12)")
        print("ancientTbl summary:")
        for i in 0...6 {
            print("[\(i)]: [\(ancientTbl[i][0]), \(ancientTbl[i][1])]")
        }
        print("...")
    }
    
    /** 両方向のテスト（新暦→旧暦、旧暦→新暦） */
    func testBothDirections(year: Int, month: Int, day: Int, isLeap: Bool = false) {
        // 1. 新暦→旧暦の変換
        print("\n=== Testing New → Ancient: \(year)/\(month)/\(day) ===")
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        
        let ancientResult = convertForAncientCalendar(comps: comps)
        let ancientYear = ancientResult[0]
        let ancientMonth = ancientResult[1]
        let ancientDay = ancientResult[2]
        let ancientIsLeap = ancientResult[3] < 0
        
        print("New calendar: \(year)/\(month)/\(day) → Ancient calendar: \(ancientYear)/\(ancientMonth)/\(ancientDay)")
        print("isLeapMonth from conversion = \(ancientIsLeap ? "Yes" : "No")")
        
        // 2. 旧暦→新暦の変換
        print("\n=== Testing Ancient → New: \(ancientYear)/\(ancientMonth)/\(ancientDay) (isLeap=\(isLeap || ancientIsLeap)) ===")
        
        // 閏月かどうかに基づいてパラメータを調整
        let leapFlag = isLeap || ancientIsLeap ? -1 : 0
        let monthValue = isLeap || ancientIsLeap ? -ancientMonth : ancientMonth
        
        let newResult = convertForGregorianCalendar(dateArray: [ancientYear, monthValue, ancientDay, leapFlag])
        
        print("Ancient calendar: \(ancientYear)/\(ancientMonth)/\(ancientDay) (\(isLeap || ancientIsLeap ? "閏月" : "通常月")) → New calendar: \(newResult.year ?? 0)/\(newResult.month ?? 0)/\(newResult.day ?? 0)")
        
        // 3. 強制的に閏月として計算した場合の結果（問題の検証用）
        if !isLeap && !ancientIsLeap && ancientMonth == leapMonth {
            print("\n=== Testing with FORCED leap month ===")
            let forcedLeapResult = convertForGregorianCalendar(dateArray: [ancientYear, -ancientMonth, ancientDay, -1])
            print("Ancient calendar (forced leap): \(ancientYear)/閏\(ancientMonth)/\(ancientDay) → New calendar: \(forcedLeapResult.year ?? 0)/\(forcedLeapResult.month ?? 0)/\(forcedLeapResult.day ?? 0)")
        }
    }
}

// Main test
let converter = AncientCalendarConverter2Test()

// Test the specific date 7/2/2025 and surrounding dates
print("\n=====================================")
print("Testing 7/2/2025 specifically:")
converter.testBothDirections(year: 2025, month: 7, day: 2)

print("\n=====================================")
print("Testing non-leap vs leap 6/8 explicitly for 2025:")
// Test regular month 6/8
converter.testBothDirections(year: 2025, month: 6, day: 8, isLeap: false)
// Test leap month 6/8
converter.testBothDirections(year: 2025, month: 6, day: 8, isLeap: true)

print("\n=====================================")
print("Testing surrounding dates:")
converter.testBothDirections(year: 2025, month: 7, day: 1)
converter.testBothDirections(year: 2025, month: 7, day: 3)