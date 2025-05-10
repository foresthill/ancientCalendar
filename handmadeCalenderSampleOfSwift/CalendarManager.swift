//
//  CalendarManager.swift
//  AncientCalendar
//
//  Created by Morioka Naoya on H28/07/10.
//  Copyright © 2016-2025 just1factory. All rights reserved.
//

import Foundation
import EventKit

class CalendarManager {
    
    //シングルトン
    static let sharedInstance = CalendarManager()
    
    //メンバ変数の設定（カレンダー用）
    var now: Date!
    var year: Int!
    var month: Int!
    var day: Int!
    var maxDay: Int!
    var dayOfWeek: Int!
    var isLeapMonth: Int! = 0 //閏月の場合は-1（2016/02/06）
    
    //今が閏月かどうか（他にいい方法あったら教えて。）
    var nowLeapMonth: Bool = false
    
    //1週間に含まれる日数 旧暦なら6日（六曜）、新暦なら7日（七曜日）
    var numberOfDaysInWeek: Int!
    
    //旧暦時間を受け取るコンポーネント（不要？）
    var ancientYear: Int!
    var ancientMonth: Int!
    var ancientDay: Int!
    
    //新暦時間を受け取るコンポーネント（冗長だけど）
    var gregorianYear: Int!
    var gregorianMonth: Int!
    var gregorianDay: Int!
    
    //サブ表示用日数（新暦カレンダーの場合は旧暦、旧暦カレンダーの場合は新暦）
//    var subDispYear: Int!
//    var subDispMonth: Int!
//    var subDispDay: Int!
    
    //トータルカウント（ボタンの総数）
    var total: Int!
    
    // カレンダーを呼び出すための認証情報（2015/07/29）
    var eventStore: EKEventStore!
    
    //カレンダー外出し
    var calendar: Calendar!
    
    // 発見したイベントを格納する配列を生成（Segueで呼び出すために外だし）2015/12/23
    //var events: [EKEvent]!
    
    //カレンダーの閾値（1999年〜2030年まで閲覧可能）
    //let minYear = 1999
    //let maxYear = 2030
    
    //モード（通常モード、旧暦モード）
    var calendarMode: Int!      //ゆくゆくは３モード切替にしたいため、boolではなくintで。（量子コンピュータ）1:通常（新暦）-1:旧暦
    
    //メンバ変数の設定（カレンダー関数から取得したものを渡す）
    var comps: DateComponents!
    
    //タイトル
    var calendarBarTitle: String!
    var scheduleBarTitle: String!
    var scheduleBarPrompt: String!
    var presentMode: String!
    
    //旧暦変換クラス（シングルトン）※あとでまとめるかも。
    let converter: AncientCalendarConverter2 = AncientCalendarConverter2.sharedInstance
    
    /** 月の名前（和暦） */
    let jpnMonth = ["睦月", "如月", "弥生", "卯月", "皐月", "水無月", "文月", "葉月", "長月", "神無月", "霜月", "師走"]
    
    /** 曜日名（西暦）*/
    let dayOfWeekName = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    
    /** 曜日名（和暦）*/
    let dayOfWeekNameJp = ["大安","赤口","先勝","友引","先負","仏滅"]

    /** 月齢 */
    var moonAge = 0.0
    
    /** 月の満ち欠け */
    let moonName = ["新月", "", "繊月", "三日月", "", "", "", "上弦の月", "", "", "十日夜の月",         //0〜10
                    "", "", "十三夜月", "小望月", "満月", "十六夜", "立待月", "居待月", "寝待月", "更待月", //11〜20
                    "", "", "下弦の月", "", "", "有明月", "", "", "", "三十日月"]  //21〜30
    
    /** 初期化処理（インスタンス化禁止） */
    private init() {
        //カレンダーモード（2016/02/06追加）
        calendarMode = 1    //1:通常（新暦）-1:旧暦
        
        //閏月（2016/02/06、なぜかエラー出るように）
        isLeapMonth = 0
        
        //EventStoreを作成する（2015/08/05）
        eventStore = EKEventStore()
        
        // カレンダー初期化
        calendar = Calendar.current
        //calendar = Calendar(identifier: .gregorian)
    }
    
    /** GregorianCalendarセットアップ */
    func setupGregorianCalendar() {
        //現在の日付を取得する
        now = Date()
        
        //inUnit:で指定した単位（月）の中で、rangeOfUnit:で指定した単位（日）が取り得る範囲
        let inCalendar = Calendar(identifier: .gregorian)
        let range = inCalendar.range(of: .day, in: .month, for: now)
        
        //最初にメンバ変数に格納するための現在日付の情報を取得する
        comps = inCalendar.dateComponents([.year, .month, .day, .weekday], from: now)
        
        //年月日と最後の日付と曜日を取得(NSIntegerをintへのキャスト不要)
        let orgYear = comps.year!
        let orgMonth = comps.month!
        let orgDay = comps.day!
        let orgDayOfWeek = comps.weekday!
        let max = range!.count
        
        year      = orgYear
        month     = orgMonth
        day       = orgDay
        dayOfWeek = orgDayOfWeek
        maxDay    = max
    }
    
    /** タイトル表記を設定する関数 */
//    func setupCalendarTitleLabel(calendarMode: Int) {
    func setupCalendarTitleLabel() {
            
        //self.navigationItem.title = "\(year)年"
        
        var calendarTitle: String;
        calendarTitle = "\(month ?? 0)月"
        
        if((month == converter.leapMonth) && nowLeapMonth) {   //leapMonth→converter.leapMonth（2016/04/17）
            calendarTitle = "閏\(month ?? 0)月"
        }
        
        switch calendarMode {
        case -1:
            //calendarBar.text = String("" + jpnMonth[month-1] + "（旧暦 \(calendarTitle)）")
            calendarBarTitle = String("【旧暦】" + "\(year ?? 0)年" + jpnMonth[month-1] + "（\(calendarTitle)）")
            presentMode = "旧暦モード"
            break
        default:
            //calendarBar.text = String("新暦 \(month)月")
            calendarBarTitle = String("【新暦】" + "\(year ?? 0)年" + "\(month ?? 0)月")
            presentMode = "通常モード（新暦）"
        }
        
    }
    
    /** 曜日名 */
    func dayOfTheWeekName() -> [String] {
        var monthName: [String]
        switch calendarMode {
        case -1:
            monthName = dayOfWeekNameJp
            break
        default:
            monthName = dayOfWeekName
        }
        return monthName
    }
    
    /** GenerateCalendar実行前に呼ばれるメソッド */
    func setupGenerateCalendar() {
        
//        var tagNumber = 1   //タグナンバー（日数）
        
        //旧暦モード
        if(calendarMode == -1) {
            
            numberOfDaysInWeek = 6
            total  = 6 * numberOfDaysInWeek
            
            switch month {
            case 1, 7:   //1月と7月は先勝から始まる
                dayOfWeek = 3
                break
            case 2, 8:      //2月と8月は友引から始まる
                dayOfWeek = 4
                break
            case 3, 9:   //3月と9月は先負から始まる
                dayOfWeek = 5
                break
            case 4, 10:  //4月と10月は仏滅から始まる
                dayOfWeek = 6
                break
            case 5, 11: //5月と11月は大安から始まる
                dayOfWeek = 1
                break
            case 6, 12: //6月と12月は赤口から始まる
                dayOfWeek = 2
                break
            default:
                dayOfWeek = 1
                //TODO:閏月はどうする？
            }
            
            //閏月より後の月の日数がおかしいバグ修正（2016/03/20）
            var tempMonth: Int = month
            
            if(converter.leapMonth > 0 && tempMonth > converter.leapMonth) { //leapMonth→converter.leapMonth（2016/04/17）
                tempMonth = tempMonth + 1
            }
            
            maxDay = converter.ancientTbl[tempMonth][0] - converter.ancientTbl[tempMonth-1][0]
            
        //新暦モード
        } else {
            
            numberOfDaysInWeek = 7
            total = 6 * numberOfDaysInWeek
            
        }

    }
    
    /** 現在（初期表示時）の年月に該当するデータを取得する関数 */
    func setupCurrentCalendarData() {
        
        /*************
         * (重要ポイント)
         * 現在月の1日のdayOfWeek(曜日の値)を使ってカレンダーの始まる位置を決めるので、
         * yyyy年mm月1日のデータを作成する。
         * 後述の関数 setupPrevCalendarData, setupNextCalendarData も同様です。
         *************/
        let currentCalendar = Calendar(identifier: .gregorian)
        var currentComps = DateComponents()
        
        currentComps.year  = year
        currentComps.month = month
        currentComps.day   = 1
        
        let currentDate = currentCalendar.date(from: currentComps)!
        recreateCalendarParameter(currentCalendar, currentDate: currentDate)
    }
    
    /** 前の年月に該当するデータを取得する関数 */
    func setupPrevCalendarData() {
        
        //旧暦モード（閏月の考慮が必要）
        if(calendarMode == -1) {
            
            //まず、現在の月に対して-1をする
            if(!nowLeapMonth) {
                
                if(month <= 1) {     //2016.05.03修正
                    year = year - 1;
                    month = 12;
                    converter.tblExpand(inYear: year) //2016.05.03　閏月が12月の可能性があるため→ancientTblを更新する必要があるため
                } else {
                    month = month - 1;
                }
                
                //閏年になった場合は、
                if((month == converter.leapMonth) && (month >= 1)) {   //0を弾かないと、毎年12月が閏となり、結果おかしな演算となってしまう。leapMonth→converter.leapMonth（2016/04/17）
                    nowLeapMonth = true
                }
                
            } else {
                nowLeapMonth = false
            }
            
            
        } else {    //閏月の考慮が必要
            //現在の月に対して-1をする
            if(month <= 1) {
                year = year - 1;
                month = 12;
                converter.tblExpand(inYear: year) //2016.05.03　閏月が12月の可能性があるため→ancientTblを更新する必要があるため
            } else {
                month = month - 1;
            }
        }
        
        //setupCurrentCalendarData()と同様の処理を行う
        let prevCalendar = Calendar(identifier: .gregorian)
        var prevComps = DateComponents()
        
        prevComps.year  = year
        prevComps.month = month
        prevComps.day   = 1
        
        let prevDate = prevCalendar.date(from: prevComps)!
        recreateCalendarParameter(prevCalendar, currentDate: prevDate)
        
        //2016/09/24 デバッグ用
        moonAge = calcMoonAge()
    }
    
    /** 次の年月に該当するデータを取得する関数 */
    func setupNextCalendarData() {
        
        //旧暦モード（閏月の考慮が必要）
        if(calendarMode == -1) {
            
            //現在の月に対して+1をする
            if(month >= 12) {
                year = year + 1;
                month = 1;
                nowLeapMonth = false
            } else {
                if((month == converter.leapMonth) && !nowLeapMonth) {    //leapMonth→converter.leapMonth（2016/04/17）
                    nowLeapMonth = true
                    
                } else {
                    month = month + 1;
                    nowLeapMonth = false
                }
            }
            
        } else {    //閏月の考慮が必要なし
            //現在の月に対して+1をする
            if(month == 12) {
                year = year + 1;
                month = 1;
            } else {
                month = month + 1;
            }
            
        }
        
        //setupCurrentCalendarData()と同様の処理を行う
        let nextCalendar = Calendar(identifier: .gregorian)
        var nextComps = DateComponents()
        
        nextComps.year  = year
        nextComps.month = month
        nextComps.day   = 1
        
        let nextDate = nextCalendar.date(from: nextComps)!
        recreateCalendarParameter(nextCalendar, currentDate: nextDate)
    }
    
    /** カレンダーモードを変更した際に呼び出す関数 */
    func setupAnotherCalendarData() {
        
        let currentCalendar = Calendar(identifier: .gregorian)
        var currentComps = DateComponents()
        
        if(calendarMode == -1) {  //旧暦モードへ
            //これ入れないとおかしくなる。なんで？converForAncientCalendarの洗礼を通れなくなるから、みたい。
            currentComps.year  = year
            currentComps.month = month
            currentComps.day   = day    //必要？
            
            //新暦→旧暦へ変換
            let ancientDate: [Int] = converter.convertForAncientCalendar(comps: currentComps)   //2016/04/17
            
            currentComps.year = ancientDate[0]
            currentComps.month = ancientDate[1]
            currentComps.day = ancientDate[2]
            isLeapMonth = ancientDate[3]
            
            if(isLeapMonth < 0) {
                nowLeapMonth = true
            }
            
        } else {    //新暦モードへ戻す
            //旧暦→新暦へ変換
            if(!nowLeapMonth) {  //閏月でない場合
                currentComps = converter.convertForGregorianCalendar(dateArray: [year, month, 29, 0]) as DateComponents
                
            } else {
                currentComps = converter.convertForGregorianCalendar(dateArray: [year, -month, 29, 0]) as DateComponents
                nowLeapMonth = false    //閏月の初期化
            }
            
            // 新暦変換時に曜日を設定し直す #46
            currentComps.day = 1
            
        }
                
        //self.navigationItem.title = "\(year)"
        
        let currentDate = currentCalendar.date(from: currentComps)!
        recreateCalendarParameter(currentCalendar, currentDate: currentDate)
        
    }
    
    /** カレンダーのパラメータを再作成する関数（前月・次月への遷移、カレンダー切り替え時）*/
    func recreateCalendarParameter(_ currentCalendar: Calendar, currentDate: Date) {
        
        //引数で渡されたものをもとに日付の情報を取得する
        let currentRange = currentCalendar.range(of: .day, in: .month, for: currentDate)
        
        comps = currentCalendar.dateComponents([.year, .month, .day, .weekday], from: currentDate)
        
        //年月日と最後の日付と曜日を取得(NSIntegerをintへのキャスト不要)
//        let currentYear: NSInteger      = comps.year
//        let currentMonth: NSInteger     = comps.month
//        let currentDay: NSInteger       = comps.day
//        let currentDayOfWeek: NSInteger = comps.weekday
//        let currentMax: NSInteger       = currentRange.length
        
        year      = comps.year
        month     = comps.month
        day       = comps.day
        dayOfWeek = comps.weekday
        maxDay    = currentRange!.count
        
        if(converter.leapMonth == month) { //leapMonth→converter.leapMonth（2016/04/17）
            isLeapMonth = -1
        } else {
            isLeapMonth = 0
        }
        
    }
    
    /** ScheduleViewControllerの初期化 */
    func initScheduleViewController() {
        
        //comps = NSDateComponents()
        
        if(calendarMode == 1) {  //新暦モード
            
            //旧暦時間を渡す（2016/04/15）
            comps.year = year
            comps.month = month
            comps.day = day
            
            //冗長だな〜（2016/07/15）
            gregorianYear = year
            gregorianMonth = month
            gregorianDay = day
            
            //print("\(comps.year). \(comps.month). \(comps.day)")
            
            let ancientDate: [Int] = converter.convertForAncientCalendar(comps: comps)
            ancientYear = ancientDate[0]
            ancientMonth = ancientDate[1]
            ancientDay = ancientDate[2]
            isLeapMonth = ancientDate[3]
            
        } else {    //旧暦モード
            
            ancientYear = year
            ancientMonth = month
            ancientDay = day
            
            //新暦時間を渡す（これだと
            comps = converter.convertForGregorianCalendar(dateArray: [ancientYear, ancientMonth, ancientDay, isLeapMonth]) as DateComponents
            gregorianYear = comps.year
            gregorianMonth = comps.month
            gregorianDay = comps.day
            
        }
        
        //今日1日分のイベントをフェッチ
        //fetchEvent(comps)
        //fetchEvent()
        
        //タイトルを設定
        //setScheduleTitle()
        
        // カレンダー初期化
        //calendar = NSCalendar.currentCalendar()
    }
    
    /** 本日1日分のイベントをフェッチするメソッド */
    //func fetchEvent(inComps: NSDateComponents) -> [EKEvent] {
    func fetchEvent() -> [EKEvent] {
        
        // NSCalendarを生成
        //let calendar: NSCalendar = NSCalendar.currentCalendar() //新たにインスタンス化しないとダメ→コメントアウト（2016/07/15）
        //calendar = NSCalendar.currentCalendar()
        
        let selectedDay = calendar.date(from: comps)!
        
        comps.day! += 1
        
        let oneDayFromSelectedDay = calendar.date(from: comps)!
        
        comps.day! -= 1    //ここで-1をしないと整合性がとれなくなる
        
        // イベントストアのインスタントメソッドで述語を生成
        let predicate = eventStore.predicateForEvents(withStart: selectedDay, end: oneDayFromSelectedDay, calendars: nil)
        
        // 選択された一日分をフェッチ
        //let events = eventStore.eventsMatchingPredicate(predicate)

        // 取得したイベントをフィルタリング
        let allEvents = eventStore.events(matching: predicate)
        
        // テスト用のフィルター：「夏至」や「イベントの詳細」などのシステム生成イベントを除外
        let filteredEvents = allEvents.filter { event in
            // タイトルが空でないかチェック
            guard let title = event.title, !title.isEmpty else {
                return false
            }
            
            // 特定のシステムイベントを除外（部分一致で検査）
            let excludedTitles = ["夏至", "冬至", "春分", "秋分", "イベント", "詳細", "説明"]
            for excludedTitle in excludedTitles {
                if title.contains(excludedTitle) {
                    return false
                }
            }
            
            // カレンダーのソースがローカルか地域のホリデーカレンダーの場合は除外
            if let calendar = event.calendar, 
               (calendar.title == "日本の祝日" || calendar.title == "Holiday" || calendar.title == "祝日" || 
                calendar.title.contains("Holiday") || calendar.title.contains("holiday") || 
                calendar.type == .birthday || calendar.type == .subscription) {
                return false
            }
            
            return true
        }
        
        return filteredEvents
    }
    
    /** ScheduleViewControllerのタイトルを設定して表示するメソッド */
    //func setScheduleTitle(inComps: NSDateComponents){
    func setScheduleTitle() {
        
        /*
        var ancientDate:[Int] = converter.convertForAncientCalendar(inComps)
        ancientYear = ancientDate[0]
        ancientMonth = ancientDate[1]
        ancientDay = ancientDate[2]
        isLeapMonth = ancientDate[3]
         */
        
        // Safely unwrap the optional ancientMonth
        guard let month = ancientMonth else {
            return // Return early if ancientMonth is nil
        }

        var ancientMonthStr: String = String(month)

        if(isLeapMonth < 0) {
            ancientMonthStr = "閏\(month)"
        }
        
        //タイトル
        if(calendarMode == 1) {
            //新暦モード
            //scheduleBarTitle = "\(inComps.year)年\(inComps.month)月\(inComps.day)日"
            scheduleBarTitle = "\(comps.year ?? 0)年\(comps.month ?? 0)月\(comps.day ?? 0)日"
            //            self.navigationItem.title = "\(inComps.day)日"     //TODO:#60
            scheduleBarPrompt = "（旧暦：\(ancientYear ?? 0)年\(ancientMonthStr)月\(ancientDay ?? 0)日）"
        } else {
            //旧暦モード
            scheduleBarTitle = "\(ancientYear ?? 0)年\(ancientMonthStr)月\(ancientDay ?? 0)日"
            //scheduleBarPrompt = "（新暦：\(inComps.year)年\(inComps.month)月\(inComps.day)日）"
            scheduleBarPrompt = "（新暦：\(gregorianYear ?? 0)年\(gregorianMonth ?? 0)月\(gregorianDay ?? 0)日）"
        }
    }
    
    /** tableViewのdetailTextに表示する文字列を生成する */
    func tableViewDetailText(startDate: Date, endDate: Date) -> String {
        let df = DateFormatter()
        let df2 = DateFormatter()
        
        // カレンダーの時間表示を「２４時間制」にする #56
        df.dateFormat = "HH:mm(yyyy/MM/dd)"
        df2.dateFormat = "HH:mm"
        
        var detailText: String
        
        if(calendar.isDate(startDate, inSameDayAs: endDate)) {
            //同日の場合は時間のみ表示
            detailText = "\(df2.string(from: startDate)) - \(df2.string(from: endDate))"
        } else {
            //別日の場合は日付も表示
            detailText = "\(df2.string(from: startDate)) - \(df.string(from: endDate))"
        }
        
        return detailText
    }
    
    // MARK: - 月齢計算関連のメソッド
    
    /// 月の周期（日）- 29日12時間44分3秒
    let lunarCycle: Double = 29.53059
    
    /// 月齢計算の基準日 (2000年1月6日 18:14 GMT - 天文学的な新月)
    let referenceNewMoon = "2000-01-06T18:14:00Z"
    
    /**
     月齢計算 - 簡易版（2016/08/15 旧実装）
     http://koyomi8.com/reki_doc/doc_0250.htm
     
     この計算式は、入力された日付が旧暦であれば「旧暦日からの相対的な月齢」と近い値を返します。
     例：旧暦1日→月齢0（新月）、旧暦15日→月齢14（満月）に近い値
     
     新暦日付を入力すると、実際の天文学的月齢とはずれが生じます。
     
     - parameter : なし (内部のcompsを使用、コンポーネントは新暦日付を想定)
     - returns: 月齢（Double、0〜29.5）
     */
    func calcMoonAgeSimple() -> Double {
        // コンポーネントから年月日を取得
        guard let year = comps.year, let month = comps.month, let day = comps.day else {
            return 0.0
        }
        
        // デバッグ情報
        print("月齢簡易計算に使用されるデータ:")
        print("- 使用コンポーネント: year=\(year), month=\(month), day=\(day)")
        print("- 入力は旧暦日か: \(calendarMode == -1 ? "はい" : "いいえ")")
        
        //(Y - 2004)×10.88 + (M - 7)×0.97 + (D - 1) + 13.3
        var temp = Double(year - 2004) * 10.88
        temp += Double(month - 7) * 0.97
        temp += Double(day - 1) + 13.3
        
        // 30日周期内に収める (% 30と同じ意味)
        let result = floor((temp.truncatingRemainder(dividingBy: 30.0)) * 10) / 10
        
        print("月齢簡易計算結果: \(result)")
        return result
    }
    
    /**
     旧暦日に対応した月齢を計算（伝統的な旧暦表示に最適）
     旧暦1日を新月(0)、旧暦15日を満月(14)とする伝統的な月齢計算
     
     - parameter lunarDay: 旧暦の日付（1〜30）
     - returns: 月齢（Double、0〜29）
     */
    func calcMoonAgeForLunarDay(lunarDay: Int) -> Double {
        let age = Double(lunarDay - 1)
        print("旧暦\(lunarDay)日に対応する月齢: \(age)")
        return age
    }
    
    /** 月齢計算 - 基準日からの経過日数による計算
     
     - parameter : なし (内部のcompsを使用)
     - returns: 月齢（Double）
     */
    func calcMoonAgeAstronomical() -> Double {
        // コンポーネントから年月日を取得
        guard let year = comps.year, let month = comps.month, let day = comps.day else {
            return 0.0
        }
        
        // デバッグ情報
        print("月齢天文計算に使用されるデータ:")
        print("- 使用コンポーネント: year=\(year), month=\(month), day=\(day)")
        
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
        let result = floor(age * 10) / 10
        return result
    }
    
    /** 月齢計算 - 高精度計算（NASA計算式に基づく）
     複数の修正項を含む精密な天文学的月齢計算
     
     - parameter : なし (内部のcompsを使用)
     - returns: 月齢（Double）
     */
    func calcMoonAgeHighPrecision() -> Double {
        // コンポーネントから年月日を取得
        guard let year = comps.year, let month = comps.month, let day = comps.day else {
            return 0.0
        }
        
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
        let result = floor(moonAge * 10) / 10
        
        print("月齢高精度計算結果: \(result)")
        return result
    }
    
    /** 既存メソッドの互換性維持のため（旧来の計算方法を使用） */
    func calcMoonAge() -> Double {
        // コンポーネントから年月日を取得
        guard let year = comps.year, let month = comps.month, let day = comps.day else {
            return 0.0
        }
        
        // デバッグ情報（月齢計算に使用される値）
        print("月齢計算に使用されるデータ:")
        print("- 使用コンポーネント: year=\(year), month=\(month), day=\(day)")
        print("- 現在の内部状態: calendarManager.year=\(self.year ?? 0), calendarManager.month=\(self.month ?? 0), calendarManager.day=\(self.day ?? 0)")
        print("- モード: \(self.calendarMode == 1 ? "新暦" : "旧暦")")
        
        // 従来の簡易計算式を使用（互換性のため）
        var temp = Double(year - 2004) * 10.88
        temp += Double(month - 7) * 0.97
        temp += Double(day - 1) + 13.3
        
        // 30日周期内に収める
        let result = floor((temp.truncatingRemainder(dividingBy: 30.0)) * 10) / 10
        
        // 結果を保存してから返す
        moonAge = result
        print("月齢計算結果: \(result)")
        return result
    }
    
    /** ユリウス日の計算
     
     - parameter year: 年
     - parameter month: 月
     - parameter day: 日
     - returns: ユリウス日
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
    
    /** 月の位相名を取得
     
     - parameter moonAge: 月齢（0〜29.5）
     - returns: 月の位相名
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
}
