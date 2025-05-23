//
//  CalendarView.swift
//  handmadeCalenderSampleOfSwift
//
//  Created by Morioka Naoya on H27/08/08.
//  Copyright (c) 平成27年 just1factory. All rights reserved.
//

//import Foundation
import UIKit
import EventKit

//CALayerクラスのインポート
import QuartzCore

class CalendarViewController: UIViewController {


    //メンバ変数の設定（配列格納用）
    var count: Int!
    var mArray: NSMutableArray!

    //メンバ変数の設定（カレンダー用）
    var now: NSDate!
    var year: Int!
    var month: Int!
    var day: Int!
    var maxDay: Int!
    var dayOfWeek: Int!

    //メンバ変数の設定（カレンダー関数から取得したものを渡す）
    var comps: NSDateComponents!

    //メンバ変数の設定（カレンダーの背景色）
    var calendarBackGroundColor: UIColor!

    //プロパティを指定
    @IBOutlet var calendarBar: UILabel!
    @IBOutlet var prevMonthButton: UIButton!
    @IBOutlet var nextMonthButton: UIButton!


    //カレンダーの位置決め用メンバ変数
    var calendarLabelIntervalX: Int!
    var calendarLabelX: Int!
    var calendarLabelY: Int!
    var calendarLabelWidth: Int!
    var calendarLabelHeight: Int!
    var calendarLableFontSize: Int!

    var buttonRadius: Float!

    var calendarIntervalX: Int!
    var calendarX: Int!
    var calendarIntervalY: Int!
    var calendarY: Int!
    var calendarSize: Int!
    var calendarFontSize: Int!

    //その他追加機能（2015/07/21）
    var popUpWindow: UIWindow!
    private var popUpWindowButton: UIButton!

    // カレンダーを呼び出すための認証情報（2015/07/29）
    var myEventStore: EKEventStore!
    var myEvents: NSArray!
    var myTargetCalendar: EKCalendar!

    // 旧暦
    //    var jpnMonth: NSArray!

//    @IBOutlet var mapView: UIView!

    override func viewDidLoad() {
        //現在起動中のデバイスを取得（スクリーンの幅・高さ）
        let screenWidth  = DeviseSize.screenWidth()
        let screenHeight = DeviseSize.screenHeight()
        
        //iPhone4s
        if(screenWidth == 320 && screenHeight == 480){
            
            calendarLabelIntervalX = 5;
            calendarLabelX         = 45;
            calendarLabelY         = 93;
            calendarLabelWidth     = 40;
            calendarLabelHeight    = 25;
            calendarLableFontSize  = 14;
            
            buttonRadius           = 20.0;
            
            calendarIntervalX      = 5;
            calendarX              = 45;
            calendarIntervalY      = 120;
            calendarY              = 45;
            calendarSize           = 40;
            calendarFontSize       = 17;
            
            //iPhone5またはiPhone5s
        }else if (screenWidth == 320 && screenHeight == 568){
            
            calendarLabelIntervalX = 5;
            calendarLabelX         = 45;
            calendarLabelY         = 93;
            calendarLabelWidth     = 40;
            calendarLabelHeight    = 25;
            calendarLableFontSize  = 14;
            
            buttonRadius           = 20.0;
            
            calendarIntervalX      = 5;
            calendarX              = 45;
            calendarIntervalY      = 120;
            calendarY              = 45;
            calendarSize           = 40;
            calendarFontSize       = 17;
            
            //iPhone6
        }else if (screenWidth == 375 && screenHeight == 667){
            
            calendarLabelIntervalX = 15;
            calendarLabelX         = 50;
            calendarLabelY         = 95;
            calendarLabelWidth     = 45;
            calendarLabelHeight    = 25;
            calendarLableFontSize  = 16;
            
            buttonRadius           = 22.5;
            
            calendarIntervalX      = 15;
            calendarX              = 50;
            calendarIntervalY      = 125;
            calendarY              = 50;
            calendarSize           = 45;
            calendarFontSize       = 19;
        
            self.prevMonthButton.frame = CGRect(x: 15, y: 438, width: CGFloat(calendarSize), height: CGFloat(calendarSize));
            self.nextMonthButton.frame = CGRect(x: 314, y: 438, width: CGFloat(calendarSize), height: CGFloat(calendarSize));
            
            //iPhone6 plus
        }else if (screenWidth == 414 && screenHeight == 736){
            
            calendarLabelIntervalX = 15;
            calendarLabelX         = 55;
            calendarLabelY         = 95;
            calendarLabelWidth     = 55;
            calendarLabelHeight    = 25;
            calendarLableFontSize  = 18;
            
            buttonRadius           = 25;
            
            calendarIntervalX      = 18;
            calendarX              = 55;
            calendarIntervalY      = 125;
            calendarY              = 55;
            calendarSize           = 50;
            calendarFontSize       = 21;
            
            self.prevMonthButton.frame = CGRect(x: 18, y: 468, width: CGFloat(calendarSize), height: CGFloat(calendarSize));
            self.nextMonthButton.frame = CGRect(x: 348, y: 468, width: CGFloat(calendarSize), height: CGFloat(calendarSize));
        }
        
        //ボタンを角丸にする
        //prevMonthButton.layer.cornerRadius = CGFloat(buttonRadius)
        //nextMonthButton.layer.cornerRadius = CGFloat(buttonRadius)
        
        //現在の日付を取得する
        now = NSDate()
        
        //inUnit:で指定した単位（月）の中で、rangeOfUnit:で指定した単位（日）が取り得る範囲
        var calendar: Calendar = Calendar(identifier: .gregorian)
        var range = calendar.range(of: .day, in: .month, for: now as Date)
        var nsRange = NSRange(location: 1, length: range?.count ?? 0)
        
        //最初にメンバ変数に格納するための現在日付の情報を取得する
        comps = calendar.dateComponents([.year, .month, .day, .weekday], from: now as Date) as NSDateComponents
        
        //年月日と最後の日付と曜日を取得(NSIntegerをintへのキャスト不要)
        var orgYear: NSInteger      = comps.year
        var orgMonth: NSInteger     = comps.month
        var orgDay: NSInteger       = comps.day
        var orgDayOfWeek: NSInteger = comps.weekday
        var max: NSInteger          = nsRange.length
        
        year      = orgYear
        month     = orgMonth
        day       = orgDay
        dayOfWeek = orgDayOfWeek
        maxDay    = max
        
        //空の配列を作成する（カレンダーデータの格納用）
        mArray = NSMutableArray()
        
        //曜日ラベル初期定義
        var monthName:[String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        
        //曜日ラベルを動的に配置
        setupCalendarLabel(array: monthName as NSArray)
        
        //初期表示時のカレンダーをセットアップする
        setupCurrentCalendar()
        
        //ウィンドウ（2015/07/21）
        popUpWindow = UIWindow()        // インスタンス化しとかないとダメ
        popUpWindowButton = UIButton()  // 同上
        
        
        // EventStoreを作成する（2015/08/05）
        myEventStore = EKEventStore()
        
        // ユーザーにカレンダーの使用許可を求める（2015/08/06）
        allowAuthorization()

    }
    
    //曜日ラベルの動的配置関数
    func setupCalendarLabel(array: NSArray) {
        
        var calendarLabelCount = 7
        
        for i in 0...6{
            
            //ラベルを作成
            var calendarBaseLabel: UILabel = UILabel()
            
            //X座標の値をCGFloat型へ変換して設定
            calendarBaseLabel.frame = CGRect(
                x: CGFloat(calendarLabelIntervalX + calendarLabelX * (i % calendarLabelCount)),
                y: CGFloat(calendarLabelY),
                width: CGFloat(calendarLabelWidth),
                height: CGFloat(calendarLabelHeight)
            )
            
            //日曜日の場合は赤色を指定
            if(i == 0){
                
                //RGBカラーの設定は小数値をCGFloat型にしてあげる
                calendarBaseLabel.textColor = UIColor(
                    red: CGFloat(0.831), green: CGFloat(0.349), blue: CGFloat(0.224), alpha: CGFloat(1.0)
                )
                
                //土曜日の場合は青色を指定
            }else if(i == 6){
                
                //RGBカラーの設定は小数値をCGFloat型にしてあげる
                calendarBaseLabel.textColor = UIColor(
                    red: CGFloat(0.400), green: CGFloat(0.471), blue: CGFloat(0.980), alpha: CGFloat(1.0)
                )
                
                //平日の場合は灰色を指定
            }else{
                
                //既に用意されている配色パターンの場合
                calendarBaseLabel.textColor = UIColor.lightGray
                
            }
            
            //曜日ラベルの配置
            calendarBaseLabel.text = String(array[i] as! NSString)
            calendarBaseLabel.textAlignment = NSTextAlignment.center
            calendarBaseLabel.font = UIFont(name: "System", size: CGFloat(calendarLableFontSize))
            self.view.addSubview(calendarBaseLabel)
        }
    }
    
    //カレンダーを生成する関数
    func generateCalendar(){
        
        //タグナンバーとトータルカウントの定義
        var tagNumber = 1
        var total     = 42
        
        //7×6=42個のボタン要素を作る
        for i in 0...41{
            
            //配置場所の定義
            var positionX   = calendarIntervalX + calendarX * (i % 7)   //Intervalは間隔ではなくて初期値でしたorz
            var positionY   = calendarIntervalY + calendarY * (i / 7)
            var buttonSizeX = calendarSize;
            var buttonSizeY = calendarSize;
            
            //ボタンをつくる
            var button: UIButton = UIButton()
            button.frame = CGRect(
                x: CGFloat(positionX),
                y: CGFloat(positionY),
                width: CGFloat(buttonSizeX!),
                height: CGFloat(buttonSizeY!)
            )
            
            //ボタンの初期設定をする
            if(i < dayOfWeek - 1){
                
                //日付の入らない部分はボタンを押せなくする
                button.setTitle("", for: .normal)
                button.isEnabled = false
                
            }else if(i == dayOfWeek - 1 || i < dayOfWeek + maxDay - 1){
                
                //日付の入る部分はボタンのタグを設定する（日にち）
                button.setTitle(String(tagNumber), for: .normal)
                button.tag = tagNumber
                tagNumber += 1
                
            }else if(i == dayOfWeek + maxDay - 1 || i < total){
                
                //日付の入らない部分はボタンを押せなくする
                button.setTitle("", for: .normal)
                button.isEnabled = false
                
            }
            
            //ボタンの配色の設定
            //@remark:このサンプルでは正円のボタンを作っていますが、背景画像の設定等も可能です。
            if(i % 7 == 0){
                calendarBackGroundColor = UIColor(
                    red: CGFloat(0.831), green: CGFloat(0.349), blue: CGFloat(0.224), alpha: CGFloat(1.0)
                )
            }else if(i % 7 == 6){
                calendarBackGroundColor = UIColor(
                    red: CGFloat(0.400), green: CGFloat(0.471), blue: CGFloat(0.980), alpha: CGFloat(1.0)
                )
            }else{
                calendarBackGroundColor = UIColor.lightGray
            }
            
            //ボタンのデザインを決定する
            button.backgroundColor = calendarBackGroundColor
            button.setTitleColor(UIColor.white, for: .normal)
            button.titleLabel!.font = UIFont(name: "System", size: CGFloat(calendarFontSize))
            //button.layer.cornerRadius = CGFloat(buttonRadius)
            
            //配置したボタンに押した際のアクションを設定する
            button.addTarget(self, action: "buttonTapped:", for: .touchUpInside)
            
            //ボタンを配置する
            self.view.addSubview(button)
            mArray.add(button)
        }
        
    }

    //タイトル表記を設定する関数
    func setupCalendarTitleLabel() {
        //calendarBar.text = String("\(year)年\(month)月のカレンダー")
        var jpnMonth = ["睦月", "如月", "弥生", "卯月", "皐月", "水無月", "文月", "葉月", "長月", "神無月", "霜月", "師走"]
        calendarBar.text = String(jpnMonth[month-1] + "（旧暦\(month)月）")
    }
    
    //現在（初期表示時）の年月に該当するデータを取得する関数
    func setupCurrentCalendarData() {
        
        /*************
        * (重要ポイント)
        * 現在月の1日のdayOfWeek(曜日の値)を使ってカレンダーの始まる位置を決めるので、
        * yyyy年mm月1日のデータを作成する。
        * 後述の関数 setupPrevCalendarData, setupNextCalendarData も同様です。
        *************/
        var currentCalendar: Calendar = Calendar(identifier: .gregorian)
        var currentComps: DateComponents = DateComponents()
        
        currentComps.year  = year
        currentComps.month = month
        currentComps.day   = 1
        
        var currentDate: NSDate = currentCalendar.date(from: currentComps)! as NSDate
        recreateCalendarParameter(currentCalendar: currentCalendar, currentDate: currentDate)
    }
    
    //前の年月に該当するデータを取得する関数
    func setupPrevCalendarData() {
        
        //現在の月に対して-1をする
        if(month == 0){
            year = year - 1;
            month = 12;
        }else{
            month = month - 1;
        }
        
        //setupCurrentCalendarData()と同様の処理を行う
        var prevCalendar: Calendar = Calendar(identifier: .gregorian)
        var prevComps: DateComponents = DateComponents()
        
        prevComps.year  = year
        prevComps.month = month
        prevComps.day   = 1
        
        var prevDate: NSDate = prevCalendar.date(from: prevComps)! as NSDate
        recreateCalendarParameter(currentCalendar: prevCalendar, currentDate: prevDate)
    }
    
    //次の年月に該当するデータを取得する関数
    func setupNextCalendarData() {
        
        //現在の月に対して+1をする
        if(month == 12){
            year = year + 1;
            month = 1;
        }else{
            month = month + 1;
        }
        
        //setupCurrentCalendarData()と同様の処理を行う
        var nextCalendar: Calendar = Calendar(identifier: .gregorian)
        var nextComps: DateComponents = DateComponents()
        
        nextComps.year  = year
        nextComps.month = month
        nextComps.day   = 1
        
        var nextDate: NSDate = nextCalendar.date(from: nextComps)! as NSDate
        recreateCalendarParameter(currentCalendar: nextCalendar, currentDate: nextDate)
    }

    //カレンダーのパラメータを再作成する関数
    func recreateCalendarParameter(currentCalendar: Calendar, currentDate: NSDate) {
        
        //引数で渡されたものをもとに日付の情報を取得する
        var currentRange = currentCalendar.range(of: .day, in: .month, for: currentDate as Date)
        var nsCurrentRange = NSRange(location: 1, length: currentRange?.count ?? 0)
        
        comps = currentCalendar.dateComponents([.year, .month, .day, .weekday], from: currentDate as Date) as NSDateComponents
        
        //年月日と最後の日付と曜日を取得(NSIntegerをintへのキャスト不要)
        var currentYear: NSInteger      = comps.year
        var currentMonth: NSInteger     = comps.month
        var currentDay: NSInteger       = comps.day
        var currentDayOfWeek: NSInteger = comps.weekday
        var currentMax: NSInteger       = nsCurrentRange.length
        
        year      = currentYear
        month     = currentMonth
        day       = currentDay
        dayOfWeek = currentDayOfWeek
        maxDay    = currentMax
    }
    
    //表示されているボタンオブジェクトを一旦削除する関数
    func removeCalendarButtonObject() {
        
        //ビューからボタンオブジェクトを削除する
        for i in 0..<mArray.count {
            (mArray[i] as AnyObject).removeFromSuperview()
                    }
        
        //配列に格納したボタンオブジェクトも削除する
        mArray.removeAllObjects()
    }
    
    //現在のカレンダーをセットアップする関数
    func setupCurrentCalendar() {
        
        setupCurrentCalendarData()
        generateCalendar()
        setupCalendarTitleLabel()
    }
    

    /**
    カレンダーボタンがタップされた時
    **/
    func buttonTapped(button: UIButton){
        print("buttonTapped")
        
        // コンソール表示
        print("\(year)年\(month)月\(button.tag)日が選択されました！")
        
        // NSCalendarを生成
        var myCalendar: Calendar = Calendar.current
        
        // ユーザのカレンダーを取得
        var myEventCalendars = myEventStore.calendars(for: .event)
        
        // 開始日（昨日）コンポーネントのvar成
        var oneDayAgoComponents: DateComponents = DateComponents()
        oneDayAgoComponents.day = -1
        
        // 昨日から今日までのNSDateを生成
        let oneDayAgo: Date = myCalendar.date(byAdding: oneDayAgoComponents, to: Date())!
        
        // 終了日（一年後）コンポーネントの生成
        var oneYearFromNowComponents: DateComponents = DateComponents()
        oneYearFromNowComponents.year = 1
        
        // 今日から一年後までのNSDateを生成
        let oneYearFromNow: Date = myCalendar.date(byAdding: oneYearFromNowComponents, to: Date())!
        
        // イベントストアのインスタントメソッドで述語を生成
        var predicate = NSPredicate()
        
        // ユーザーの全てのカレンダーからフェッチせよ
        predicate = myEventStore.predicateForEvents(withStart: oneDayAgo,
            end: oneYearFromNow, calendars: nil)
        
        // 述語にマッチする全てのイベントをフェッチ
        var events = myEventStore.events(matching: predicate)
        
        // 発見したイベントを格納する配列を生成
        var eventItems = [String]()
        
        // イベントが見つかった
        if !events.isEmpty {
            for i in events{
                print(i.title)
                print(i.startDate)
                print(i.endDate)
                
                // 配列に格納
                eventItems += ["\(i.title): \(i.startDate)"]
                
            }
        }
        
        // 画面遷移.
        moveViewController(events: eventItems as NSArray)
        
    }
    
    func moveViewController(events: NSArray) {
        print("moveViewController")
        
        // TableViewControllerがUIViewControllerのサブクラスであるため一時的に修正
        let myTableViewController = UIViewController()
        
        // TableViewに表示する内容として発見したイベントを入れた配列を渡す
        // myTableViewController.myItems = events // 一時的にコメントアウト
        
        // 画面遷移
        //self.navigationController?.pushViewController(myTableViewController, animated: true)
        
        // アニメーションを定義する
        myTableViewController.modalTransitionStyle = UIModalTransitionStyle.partialCurl
        
        // Viewの移動する
        self.present(myTableViewController, animated: true, completion: nil)
        
    }



    // スケジュール画面に遷移
    internal func toSchedule(button: UIButton){
        // 遷移するViewを定義する
        let mySecondViewController: UIViewController = SecondViewController()
        
        // アニメーションを定義する
        mySecondViewController.modalTransitionStyle = UIModalTransitionStyle.partialCurl
        
        // Viewの移動する
        self.present(mySecondViewController, animated: true, completion: nil)
    }
    
    /**
    認証ステータスを取得
    **/
    func getAuthorization_status() -> Bool {
        
        // ステータスを取得
        let status: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
        
        // ステータスを表示 許可されている場合のみtrueを返す
        switch status {
        case .notDetermined:
            print("NotDetermined")
            return false
            
        case .denied:
            print("Denied")
            return false
            
        case .authorized:
            print("Authorized")
            return true
            
        case .restricted:
            print("Restricted")
            return false
            
        default:
            print("error")
            return false
            
        }
    }
    
    /**
    認証許可
    **/
    func allowAuthorization() {
        
        // 許可されていなかった場合、認証許可を求める
        if getAuthorization_status() {
            return
        } else {
            
            // ユーザーに許可を求める
            myEventStore.requestAccess(to: .event, completion: {
                (granted, error) -> Void in
                
                // 許可を得られなかった場合アラート発動
                if granted {
                    return
                }
                else {
                    
                    // メインスレッド 画面制御.非同期.
                    DispatchQueue.main.async { 
                        
                        // アラート作成
                        let myAlert = UIAlertController(title: "許可されませんでした", message: "Privacy->App->Reminderで変更してください", preferredStyle: UIAlertController.Style.alert)
                        
                        // アラートアクション
                        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                    }
                }
            })
        }
    }
    
    //前の月のボタンを押した際のアクション
    @IBAction func getPrevMonthData(sender: UIButton) {
        prevCalendarSettings()
    }
    
    //次の月のボタンを押した際のアクション
    @IBAction func getNextMonthData(sender: UIButton) {
        nextCalendarSettings()
    }
    
    //左スワイプで前月を表示
    @IBAction func swipePrevCalendar(sender: UISwipeGestureRecognizer) {
        prevCalendarSettings()
    }
    
    //右スワイプで次月を表示
    @IBAction func swipeNextCalendar(sender: UISwipeGestureRecognizer) {
        nextCalendarSettings()
    }
    
    //前月を表示するメソッド
    func prevCalendarSettings() {
        removeCalendarButtonObject()
        setupPrevCalendarData()
        generateCalendar()
        setupCalendarTitleLabel()
    }
    
    //次月を表示するメソッド
    func nextCalendarSettings() {
        removeCalendarButtonObject()
        setupNextCalendarData()
        generateCalendar()
        setupCalendarTitleLabel()
    }

    // どのクラスにもあるメソッド Memory監視？
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
}
