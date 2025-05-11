import Foundation

// モード切替時の閏月問題を検証するためのテストプログラム

// Constants class (minimal)
class Constants {
    static let minYear = 1999
    static let maxYear = 2030
}

// 最小限のCalendarManagerをシミュレート
class CalendarManagerSimulator {
    var year: Int?
    var month: Int?
    var day: Int?
    var calendarMode: Int = 1  // 1: 新暦, -1: 旧暦
    var nowLeapMonth: Bool = false
    var isLeapMonth: Int = 0
    
    var ancientYear: Int?
    var ancientMonth: Int?
    var ancientDay: Int?
    
    let converter = AncientCalendarConverter2Test()
    
    // モード切替をシミュレート
    func toggleMode() {
        let modeDescription = calendarMode == 1 ? "新暦→旧暦" : "旧暦→新暦"
        print("\n=== モード切替（\(modeDescription)） ===")
        print("切替前: \(year ?? 0)年\(nowLeapMonth ? "閏" : "")\(month ?? 0)月\(day ?? 0)日 (mode=\(calendarMode))")
        print("- 閏月フラグ: nowLeapMonth=\(nowLeapMonth), isLeapMonth=\(isLeapMonth)")
        
        // 現在値を保存
        let oldMode = calendarMode
        let oldYear = year
        let oldMonth = month 
        let oldDay = day
        let oldLeapMonth = nowLeapMonth
        
        // モード反転
        calendarMode = calendarMode * -1
        
        if oldMode == 1 {
            // 新暦→旧暦の変換
            setupFromGregorianToAncient()
        } else {
            // 旧暦→新暦の変換
            setupFromAncientToGregorian()
        }
        
        print("切替後: \(year ?? 0)年\(nowLeapMonth ? "閏" : "")\(month ?? 0)月\(day ?? 0)日 (mode=\(calendarMode))")
        print("- 閏月フラグ: nowLeapMonth=\(nowLeapMonth), isLeapMonth=\(isLeapMonth)")
        
        // 二重変換のテスト（往復変換）
        if false { // 必要な場合は true に変更
            toggleMode()
            print("往復変換後: \(year ?? 0)年\(nowLeapMonth ? "閏" : "")\(month ?? 0)月\(day ?? 0)日")
            print("- 往復前: \(oldYear ?? 0)年\(oldLeapMonth ? "閏" : "")\(oldMonth ?? 0)月\(oldDay ?? 0)日")
        }
    }
    
    // 新暦→旧暦への変換をシミュレート
    func setupFromGregorianToAncient() {
        guard let year = year, let month = month, let day = day else {
            print("日付が未設定です")
            return
        }
        
        // 新暦→旧暦の変換
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        
        let result = converter.convertForAncientCalendar(comps: comps)
        
        // 変換結果を設定
        ancientYear = self.year
        ancientMonth = self.month
        ancientDay = self.day
        
        self.year = result[0]
        self.month = result[1]
        self.day = result[2]
        self.isLeapMonth = result[3]
        self.nowLeapMonth = (result[3] < 0)
        
        print("変換: 新暦\(comps.year ?? 0)年\(comps.month ?? 0)月\(comps.day ?? 0)日 → 旧暦\(result[0])年\(result[3] < 0 ? "閏" : "")\(result[1])月\(result[2])日")
        print("この年の閏月: \(converter.leapMonth ?? 0)月")
    }
    
    // 旧暦→新暦への変換をシミュレート
    func setupFromAncientToGregorian() {
        guard let year = year, let month = month, let day = day else {
            print("日付が未設定です")
            return
        }
        
        // 閏月かどうかで変換パラメータを調整
        let monthValue = nowLeapMonth ? -month : month
        let leapFlag = nowLeapMonth ? -1 : 0
        
        // 旧暦→新暦の変換
        let result = converter.convertForGregorianCalendar(dateArray: [year, monthValue, day, leapFlag])
        
        // 変換結果を設定
        ancientYear = self.year
        ancientMonth = self.month
        ancientDay = self.day
        
        self.year = result.year
        self.month = result.month
        self.day = result.day
        self.isLeapMonth = 0
        self.nowLeapMonth = false
        
        print("変換: 旧暦\(year)年\(nowLeapMonth ? "閏" : "")\(month)月\(day)日 → 新暦\(result.year ?? 0)年\(result.month ?? 0)月\(result.day ?? 0)日")
    }
    
    // テスト日付を設定（新暦）
    func setGregorianDate(year: Int, month: Int, day: Int) {
        self.calendarMode = 1
        self.year = year
        self.month = month
        self.day = day
        self.nowLeapMonth = false
        self.isLeapMonth = 0
        
        print("新暦日付設定: \(year)年\(month)月\(day)日")
        
        // 対応する旧暦日付も取得（参考用）
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        
        let ancient = converter.convertForAncientCalendar(comps: comps)
        print("対応する旧暦: \(ancient[0])年\(ancient[3] < 0 ? "閏" : "")\(ancient[1])月\(ancient[2])日")
        print("この年の閏月: \(converter.leapMonth ?? 0)月")
    }
    
    // テスト日付を設定（旧暦）
    func setAncientDate(year: Int, month: Int, day: Int, isLeap: Bool = false) {
        self.calendarMode = -1
        self.year = year
        self.month = month
        self.day = day
        self.nowLeapMonth = isLeap
        self.isLeapMonth = isLeap ? -1 : 0
        
        print("旧暦日付設定: \(year)年\(isLeap ? "閏" : "")\(month)月\(day)日")
        
        // 対応する新暦日付も取得（参考用）
        let monthValue = isLeap ? -month : month
        let leapFlag = isLeap ? -1 : 0
        
        let gregorian = converter.convertForGregorianCalendar(dateArray: [year, monthValue, day, leapFlag])
        print("対応する新暦: \(gregorian.year ?? 0)年\(gregorian.month ?? 0)月\(gregorian.day ?? 0)日")
    }
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
        var isMonthLeap = monthByGregorian < 0
        
        // 月番号と一致するか、フラグで明示的に閏月指定されているかをチェック
        if isMonthLeap || leapMonthFlag < 0 {
            // マイナス値を絶対値に変換
            monthByGregorian = abs(monthByGregorian)
            
            // leapMonthFlagの方が明示的なので優先
            isMonthLeap = true  
            
            print("閏月として計算します: \(monthByGregorian)月 (leapMonthFlag=\(leapMonthFlag))")
        }
        
        tblExpand(inYear: yearByGregorian)
        
        var dayOfYear: Int = -1
        
        // この年の閏月を確認
        print("現在の年(\(yearByGregorian))の閏月: \(leapMonth ?? 0)月")
        
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
            dayOfYear = dayOfYear - tmp
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
        
        // テーブル内容を表示（詳細なデバッグに必要な場合のみ）
        if false { // 詳細表示が必要な場合はtrueに変更
            print("Year \(inYear) ancientTbl:")
            print("leapMonth = \(leapMonth ?? 0)")
            print("ommax = \(ommax ?? 12)")
            for i in 0...13 {
                print("[\(i)]: [\(ancientTbl[i][0]), \(ancientTbl[i][1])]")
            }
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
    }
}

// メイン実行部分
print("===== 閏月のモード切替テスト =====")

// 問題の発生する年の閏月情報を表示
let converter = AncientCalendarConverter2Test()
converter.printLeapMonthInfo(year: 2025)

// CalendarManagerのシミュレータを作成
let manager = CalendarManagerSimulator()

// テストケース: 新暦7/2/2025 → 旧暦（6月8日であるべき、閏6月8日ではない）
print("\n===== テストケース1: 新暦7/2/2025 =====")
manager.setGregorianDate(year: 2025, month: 7, day: 2)
manager.toggleMode()  // 新暦→旧暦
manager.toggleMode()  // 旧暦→新暦（往復）

// テストケース: 旧暦6/8を通常月として設定→新暦→旧暦
print("\n===== テストケース2: 旧暦2025年6月8日（通常月） =====")
manager.setAncientDate(year: 2025, month: 6, day: 8, isLeap: false)
manager.toggleMode()  // 旧暦→新暦
manager.toggleMode()  // 新暦→旧暦（往復）

// テストケース: 旧暦6/8を閏月として設定→新暦→旧暦
print("\n===== テストケース3: 旧暦2025年閏6月8日 =====")
manager.setAncientDate(year: 2025, month: 6, day: 8, isLeap: true)
manager.toggleMode()  // 旧暦→新暦
manager.toggleMode()  // 新暦→旧暦（往復）

// 追加テスト：閏月の月初日と月末日
print("\n===== テストケース4: 閏月の端境値テスト（月初日・月末日） =====")
// 閏月の初日
manager.setAncientDate(year: 2025, month: 6, day: 1, isLeap: true)
manager.toggleMode()  // 旧暦→新暦

// 閏月の末日（30日と仮定）
manager.setAncientDate(year: 2025, month: 6, day: 30, isLeap: true)
manager.toggleMode()  // 旧暦→新暦