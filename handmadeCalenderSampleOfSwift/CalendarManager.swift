//
//  CalendarManager.swift
//  AncientCalendar
//
//  Created by Morioka Naoya on H28/07/10.
//  Copyright © 平成28年 just1factory. All rights reserved.
//

import Foundation
import EventKit

class CalendarManager {
    
    //シングルトン
    static let sharedInstance = CalendarManager()
    
    //メンバ変数の設定（カレンダー用）
    var now: NSDate!
    var year: Int!
    var month: Int!
    var day: Int!
    var maxDay: Int!
    var dayOfWeek: Int!
    var isLeapMonth:Int! = 0 //閏月の場合は-1（2016/02/06）
    
    //今が閏月かどうか（他にいい方法あったら教えて。）
    var nowLeapMonth: Bool = false
    
    //1週間に含まれる日数 旧暦なら6日（六曜）、新暦なら7日（七曜日）
    var numberOfDaysInWeek: Int!
    
    //旧暦時間を受け取るコンポーネント
    var ancientYear: Int!
    var ancientMonth: Int!
    var ancientDay: Int!
    
    //トータルカウント（ボタンの総数）
    var total: Int!
    
    // カレンダーを呼び出すための認証情報（2015/07/29）
    var eventStore: EKEventStore!
    
    //カレンダー外出し
    var calendar: NSCalendar!
    
    // 発見したイベントを格納する配列を生成（Segueで呼び出すために外だし）2015/12/23
    //var events: [EKEvent]!
    
    //カレンダーの閾値（1999年〜2030年まで閲覧可能）
    //let minYear = 1999
    //let maxYear = 2030
    
    //モード（通常モード、旧暦モード）
    var calendarMode: Int!      //ゆくゆくは３モード切替にしたいため、boolではなくintで。（量子コンピュータ）1:通常（新暦）-1:旧暦
    
    //メンバ変数の設定（カレンダー関数から取得したものを渡す）
    var comps: NSDateComponents!
    
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

    
    
    /** 初期化処理（インスタンス化禁止） */
    private init() {
        //カレンダーモード（2016/02/06追加）
        calendarMode = 1    //1:通常（新暦）-1:旧暦
        
        //閏月（2016/02/06、なぜかエラー出るように）
        isLeapMonth = 0
        
        //EventStoreを作成する（2015/08/05）
        eventStore = EKEventStore()
        
        // カレンダー初期化
        calendar = NSCalendar.currentCalendar()
        //calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    }
    
    /** GregorianCalendarセットアップ */
    func setupGregorianCalendar(){
        //現在の日付を取得する
        now = NSDate()
        
        //inUnit:で指定した単位（月）の中で、rangeOfUnit:で指定した単位（日）が取り得る範囲
        let inCalendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let range: NSRange = inCalendar.rangeOfUnit(NSCalendarUnit.Day, inUnit:NSCalendarUnit.Month, forDate:now)
        
        //最初にメンバ変数に格納するための現在日付の情報を取得する
        comps = inCalendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday],fromDate:now)
        
        //年月日と最後の日付と曜日を取得(NSIntegerをintへのキャスト不要)
        let orgYear: NSInteger      = comps.year
        let orgMonth: NSInteger     = comps.month
        let orgDay: NSInteger       = comps.day
        let orgDayOfWeek: NSInteger = comps.weekday
        let max: NSInteger          = range.length
        
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
        calendarTitle = "\(month)月"
        
        if((month == converter.leapMonth) && nowLeapMonth){   //leapMonth→converter.leapMonth（2016/04/17）
            calendarTitle = "閏\(month)月"
        }
        
        switch calendarMode {
        case -1:
            //calendarBar.text = String("" + jpnMonth[month-1] + "（旧暦 \(calendarTitle)）")
            calendarBarTitle = String("【旧暦】" + "\(year)年" + jpnMonth[month-1] + "（\(calendarTitle)）")
            presentMode = "旧暦モード"
            break
        default:
            //calendarBar.text = String("新暦 \(month)月")
            calendarBarTitle = String("【新暦】" + "\(year)年" + "\(month)月")
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
        if(calendarMode == -1){
            
            numberOfDaysInWeek = 6
            total  = 6 * numberOfDaysInWeek
            
            switch month{
            case 1,7:   //1月と7月は先勝から始まる
                dayOfWeek = 3
                break
            case 2,8:      //2月と8月は友引から始まる
                dayOfWeek = 4
                break
            case 3,9:   //3月と9月は先負から始まる
                dayOfWeek = 5
                break
            case 4,10:  //4月と10月は仏滅から始まる
                dayOfWeek = 6
                break
            case 5,11: //5月と11月は大安から始まる
                dayOfWeek = 1
                break
            case 6,12: //6月と12月は赤口から始まる
                dayOfWeek = 2
                break
            default:
                dayOfWeek = 1
                //TODO:閏月はどうする？
            }
            
            //閏月より後の月の日数がおかしいバグ修正（2016/03/20）
            var tempMonth:Int = month
            
            if(converter.leapMonth > 0 && tempMonth > converter.leapMonth){ //leapMonth→converter.leapMonth（2016/04/17）
                tempMonth = tempMonth + 1
            }
            
            maxDay = converter.ancientTbl[tempMonth][0] - converter.ancientTbl[tempMonth-1][0]
            
            //新暦モード
        } else {
            
            numberOfDaysInWeek = 7
            total     = 6 * numberOfDaysInWeek
            
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
        let currentCalendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let currentComps: NSDateComponents = NSDateComponents()
        
        currentComps.year  = year
        currentComps.month = month
        currentComps.day   = 1
        
        let currentDate: NSDate = currentCalendar.dateFromComponents(currentComps)!
        recreateCalendarParameter(currentCalendar, currentDate: currentDate)
    }
    
    /** 前の年月に該当するデータを取得する関数 */
    func setupPrevCalendarData() {
        
        //旧暦モード（閏月の考慮が必要）
        if(calendarMode == -1){
            
            //まず、現在の月に対して-1をする
            if(!nowLeapMonth){
                
                if(month <= 1){     //2016.05.03修正
                    year = year - 1;
                    month = 12;
                    converter.tblExpand(year) //2016.05.03　閏月が12月の可能性があるため→ancientTblを更新する必要があるため
                }else{
                    month = month - 1;
                }
                
                //閏年になった場合は、
                if((month == converter.leapMonth) && (month >= 1)){   //0を弾かないと、毎年12月が閏となり、結果おかしな演算となってしまう。leapMonth→converter.leapMonth（2016/04/17）
                    nowLeapMonth = true
                }
                
            }else{
                nowLeapMonth = false
            }
            
            
        } else {    //閏月の考慮が必要
            //現在の月に対して-1をする
            if(month <= 1){
                year = year - 1;
                month = 12;
                converter.tblExpand(year) //2016.05.03　閏月が12月の可能性があるため→ancientTblを更新する必要があるため
            }else{
                month = month - 1;
            }
        }
        
        //setupCurrentCalendarData()と同様の処理を行う
        let prevCalendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let prevComps: NSDateComponents = NSDateComponents()
        
        prevComps.year  = year
        prevComps.month = month
        prevComps.day   = 1
        
        let prevDate: NSDate = prevCalendar.dateFromComponents(prevComps)!
        recreateCalendarParameter(prevCalendar, currentDate: prevDate)
    }
    
    /** 次の年月に該当するデータを取得する関数 */
    func setupNextCalendarData() {
        
        //旧暦モード（閏月の考慮が必要）
        if(calendarMode == -1){
            
            //現在の月に対して+1をする
            if(month >= 12){
                year = year + 1;
                month = 1;
                nowLeapMonth = false
            }else{
                if((month == converter.leapMonth) && !nowLeapMonth){    //leapMonth→converter.leapMonth（2016/04/17）
                    nowLeapMonth = true
                    
                } else {
                    month = month + 1;
                    nowLeapMonth = false
                }
            }
            
        } else {    //閏月の考慮が必要なし
            //現在の月に対して+1をする
            if(month == 12){
                year = year + 1;
                month = 1;
            }else{
                month = month + 1;
            }
            
        }
        
        //setupCurrentCalendarData()と同様の処理を行う
        let nextCalendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let nextComps: NSDateComponents = NSDateComponents()
        
        nextComps.year  = year
        nextComps.month = month
        nextComps.day   = 1
        
        let nextDate: NSDate = nextCalendar.dateFromComponents(nextComps)!
        recreateCalendarParameter(nextCalendar, currentDate: nextDate)
    }
    
    /** カレンダーモードを変更した際に呼び出す関数 */
    func setupAnotherCalendarData(){
        
        let currentCalendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        var currentComps: NSDateComponents = NSDateComponents()
        
        if(calendarMode == -1){  //旧暦モードへ
            //これ入れないとおかしくなる。なんで？converForAncientCalendarの洗礼を通れなくなるから、みたい。
            currentComps.year  = year
            currentComps.month = month
            currentComps.day   = day    //必要？
            
            //新暦→旧暦へ変換
            let ancientDate:[Int] = converter.convertForAncientCalendar(currentComps)   //2016/04/17
            
            currentComps.year = ancientDate[0]
            currentComps.month = ancientDate[1]
            currentComps.day = ancientDate[2]
            isLeapMonth = ancientDate[3]
            
            if(isLeapMonth < 0){
                nowLeapMonth = true
            }
            
        } else {    //新暦モードへ戻す
            //旧暦→新暦へ変換
            if(!nowLeapMonth){  //閏月でない場合
                currentComps = converter.convertForGregorianCalendar([year, month, 29, 0])
                
            }else {
                currentComps = converter.convertForGregorianCalendar([year, -month, 29, 0])
                nowLeapMonth = false    //閏月の初期化
            }
            
            // 新暦変換時に曜日を設定し直す #46
            currentComps.day = 1
            
        }
                
        //self.navigationItem.title = "\(year)"
        
        let currentDate: NSDate = currentCalendar.dateFromComponents(currentComps)!
        recreateCalendarParameter(currentCalendar, currentDate: currentDate)
        
    }
    
    /** カレンダーのパラメータを再作成する関数（前月・次月への遷移、カレンダー切り替え時）*/
    func recreateCalendarParameter(currentCalendar: NSCalendar, currentDate: NSDate) {
        
        //引数で渡されたものをもとに日付の情報を取得する
        let currentRange: NSRange = currentCalendar.rangeOfUnit(NSCalendarUnit.Day, inUnit:NSCalendarUnit.Month, forDate:currentDate)
        
        comps = currentCalendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday],fromDate:currentDate)
        
        //年月日と最後の日付と曜日を取得(NSIntegerをintへのキャスト不要)
        let currentYear: NSInteger      = comps.year
        let currentMonth: NSInteger     = comps.month
        let currentDay: NSInteger       = comps.day
        let currentDayOfWeek: NSInteger = comps.weekday
        let currentMax: NSInteger       = currentRange.length
        
        year      = currentYear
        month     = currentMonth
        day       = currentDay
        dayOfWeek = currentDayOfWeek
        maxDay    = currentMax
        
        if(converter.leapMonth == month){ //leapMonth→converter.leapMonth（2016/04/17）
            isLeapMonth = -1
        } else {
            isLeapMonth = 0
        }
        
    }
    
    /** ScheduleViewControllerの初期化 */
    func initScheduleViewController() {
        
        //comps = NSDateComponents()
        
        if(calendarMode == 1){  //新暦モード
            
            //旧暦時間を渡す（2016/04/15）
            comps.year = year
            comps.month = month
            comps.day = day
            
            var ancientDate:[Int] = converter.convertForAncientCalendar(comps)
            ancientYear = ancientDate[0]
            ancientMonth = ancientDate[1]
            ancientDay = ancientDate[2]
            isLeapMonth = ancientDate[3]
            
        } else {    //旧暦モード
            
            ancientYear = year
            ancientMonth = month
            ancientDay = day
            
            //新暦時間を渡す
            comps = converter.convertForGregorianCalendar([ancientYear, ancientMonth, ancientDay, isLeapMonth])
            year = comps.year
            month = comps.month
            day = comps.day
            
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
    func fetchEvent(inComps: NSDateComponents) -> [EKEvent] {
        //    func fetchEvent(){
        
        // NSCalendarを生成
        let calendar: NSCalendar = NSCalendar.currentCalendar() //新たにインスタンス化しないとダメ
        
        let SelectedDay: NSDate = calendar.dateFromComponents(inComps)!
        
        inComps.day += 1
        
        let oneDayFromSelectedDay: NSDate = calendar.dateFromComponents(inComps)!
        
        // イベントストアのインスタントメソッドで述語を生成
        var predicate = NSPredicate()
        
        predicate = eventStore.predicateForEventsWithStartDate(SelectedDay, endDate: oneDayFromSelectedDay, calendars: nil)
        
        // 選択された一日分をフェッチ
        //let events = eventStore.eventsMatchingPredicate(predicate)
        
        return eventStore.eventsMatchingPredicate(predicate)
        
        //inComps.day -= 1    //かっこ悪りぃ。。inCompsはメソッド内だけでないの？ポインタ渡してるのか。。
    }
    
    /** ScheduleViewControllerのタイトルを設定して表示するメソッド */
    //func setScheduleTitle(inComps: NSDateComponents){
    func setScheduleTitle(){
        
        /*
        var ancientDate:[Int] = converter.convertForAncientCalendar(inComps)
        ancientYear = ancientDate[0]
        ancientMonth = ancientDate[1]
        ancientDay = ancientDate[2]
        isLeapMonth = ancientDate[3]
         */
        
        var ancientMonthStr:String = String(ancientMonth)
        
        if(isLeapMonth < 0){
            ancientMonthStr = "閏\(ancientMonth)"
        }
        
        if(calendarMode == 1){
            //新暦モード
            //scheduleBarTitle = "\(inComps.year)年\(inComps.month)月\(inComps.day)日"
            scheduleBarTitle = "\(comps.year)年\(comps.month)月\(comps.day)日"
            //            self.navigationItem.title = "\(inComps.day)日"     //TODO:#60
            scheduleBarPrompt = "（旧暦：\(ancientYear)年\(ancientMonthStr)月\(ancientDay)日）"
        } else {
            //旧暦モード
            scheduleBarTitle = "\(ancientYear)年\(ancientMonthStr)月\(ancientDay)日"
            //scheduleBarPrompt = "（新暦：\(inComps.year)年\(inComps.month)月\(inComps.day)日）"
            scheduleBarPrompt = "（新暦：\(comps.year)年\(comps.month)月\(comps.day)日）"
        }
    }
    
    /** tableViewのdetailTextに表示する文字列を生成する */
    func tableViewDetailText(startDate: NSDate, endDate: NSDate) -> String {
        let df:NSDateFormatter = NSDateFormatter()
        let df2:NSDateFormatter = NSDateFormatter()
        
        // カレンダーの時間表示を「２４時間制」にする #56
        df.dateFormat = "HH:mm(yyyy/MM/dd)"
        df2.dateFormat = "HH:mm"
        
        var detailText:String
        
        if(calendar.isDate(startDate, inSameDayAsDate: endDate)){
            //同日の場合は時間のみ表示
            detailText = "\(df2.stringFromDate(startDate)) - \(df2.stringFromDate(endDate))"
        } else {
            //別日の場合は日付も表示
            detailText = "\(df2.stringFromDate(startDate)) - \(df.stringFromDate(endDate))"
        }
        
        return detailText

    }
    
    
}