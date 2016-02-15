//
//  ViewController.swift
//  旧暦カレンダー
//
//  Created by foresthill on 2016/1/29.
//  Copyright (c) 2016 foresthill. All rights reserved.
//

import UIKit
import EventKit
import Foundation   //floor関数使用のため

//CALayerクラスのインポート
import QuartzCore

class ViewController: UIViewController {

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
    var isLeapMonth:Int! //閏月の場合は-1（2016/02/06）
    
    //メンバ変数の設定（カレンダー関数から取得したものを渡す）
    var comps: NSDateComponents!
    
    //メンバ変数の設定（カレンダーの背景色）
    var calendarBackGroundColor: UIColor!
    
    //プロパティを指定
    @IBOutlet var calendarBar: UILabel!
    @IBOutlet var prevMonthButton: UIButton!
    @IBOutlet var nextMonthButton: UIButton!
    @IBOutlet weak var presentMode: UILabel!
    @IBOutlet weak var toolBar: UIToolbar!
    
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
    
    // 発見したイベントを格納する配列を生成（Segueで呼び出すために外だし）2015/12/23
    var eventItems = [String]()   //配列を渡す
    var events: [EKEvent]!
    
    //旧暦・新暦変換テーブル（秘伝のタレ）
    let o2ntbl = [[611,2350],[468,3222]	,[316,7317]	,[559,3402]	,[416,3493]
        ,[288,2901]	,[520,1388]	,[384,5467]	,[637,605]	,[494,2349]	,[343,6443]
        ,[585,2709]	,[442,2890]	,[302,5962]	,[533,2901]	,[412,2741]	,[650,1210]
        ,[507,2651]	,[369,2647]	,[611,1323]	,[468,2709]	,[329,5781]	,[559,1706]
        ,[416,2773]	,[288,2741]	,[533,1206]	,[383,5294]	,[624,2647]	,[494,1319]
        ,[356,3366]	,[572,3475]	,[442,1450]];
    
    //カレンダーの閾値（1999年〜2030年まで閲覧可能）
    let minYear = 1999
    let maxYear = 2030
    
    //旧暦テーブル（ディクショナリではなく二次元配列）
//    var otbl: [Int:Int]
//    var ancientTbl: [[Int]]!
    var ancientTbl: [[Int]] = Array(count: 14, repeatedValue:[0, 0])
//    var ancientTbl: [[Int]] = Array<Int>[14]
    
    //モード（通常モード、旧暦モード）
    var calendarMode: Int!      //一旦いいや→ゆくゆくは３モード切替にしたいため、boolではなくintで。（量子コンピュータ）1:通常（新暦）-1:旧暦
    
    //曜日ラベル削除用（2016/02/11外だし）
    var mArrayForLabel: NSMutableArray!
    
    //閏月（外だし）
    var leapMonth: Int! = 0
    
    //月数（その年に閏月があるかないかを判定する）
    var ommax:Int! = 12
    
    //今が閏月かどうか（他にいい方法あったら教えて。）
    var nowLeapMonth :Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //カレンダーモード（2016/02/06追加）
        calendarMode = 1    //1:通常（新暦）-1:旧暦
        
        //閏月（2016/02/06、なぜかエラー出るように）
        isLeapMonth = 0
        
        //画面初期化・最適化
        screenInit()
        
        //GregorianCalendarセットアップ
        setupGregorianCalendar()
        
        //ウィンドウ（2015/07/21）
//        popUpWindow = UIWindow()        // インスタンス化しとかないとダメ
//        popUpWindowButton = UIButton()  // 同上
        
        // EventStoreを作成する（2015/08/05）
        myEventStore = EKEventStore()
        
        // ユーザーにカレンダーの使用許可を求める（2015/08/06）
        allowAuthorization()
        
        //NavigationViewControllerのタイトル
//        self.navigationItem.title = "旧暦カレンダー"
        self.navigationItem.title = "\(year)年"
        
        //ツールバー表示（2016/01/30）
//        self.navigationController!.toolbarHidden = false
//        let delButton :UIBarButtonItem! = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "onClickDelButton")
//        let addButton :UIBarButtonItem! = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "onClickAddButton")
//        
//        self.navigationController!.toolbarItems = [delButton, addButton]
//        toolbarItems?.append(delButton)
        
        //Editボタンを作成
//        var btn: UIBarButtonItem = UIBarButtonItem.init(title: "" , style: UIBarButtonItemStyle.Plain, target: self, action: "calendarChange")
        let btn: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Undo , target: self, action: "calendarChange")
        navigationItem.rightBarButtonItem = btn
        
        

     }
    
    //画面初期化・最適化
    func screenInit(){
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
            
            self.prevMonthButton.frame = CGRectMake(15, 438, CGFloat(calendarSize), CGFloat(calendarSize));
            self.nextMonthButton.frame = CGRectMake(314, 438, CGFloat(calendarSize), CGFloat(calendarSize));
            
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
            
            self.prevMonthButton.frame = CGRectMake(18, 468, CGFloat(calendarSize), CGFloat(calendarSize));
            self.nextMonthButton.frame = CGRectMake(348, 468, CGFloat(calendarSize), CGFloat(calendarSize));
        }
        
        //ボタンを角丸にする
        //prevMonthButton.layer.cornerRadius = CGFloat(buttonRadius)
        //nextMonthButton.layer.cornerRadius = CGFloat(buttonRadius)
        

    }
    
    //GregorianCalendarセットアップ
    func setupGregorianCalendar(){
        //現在の日付を取得する
        now = NSDate()
        
        //inUnit:で指定した単位（月）の中で、rangeOfUnit:で指定した単位（日）が取り得る範囲
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
//        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierJapanese)!
        let range: NSRange = calendar.rangeOfUnit(NSCalendarUnit.Day, inUnit:NSCalendarUnit.Month, forDate:now)
        
        //最初にメンバ変数に格納するための現在日付の情報を取得する
        comps = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday],fromDate:now)
        
        /*
        if(calendarMode == -1){
            //ConvertAncientCalendar
            convertForAncientCalendar(comps)
        }
*/
        
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
        
        print("\(year),\(month),\(day),\(dayOfWeek),\(maxDay)")
        
        //空の配列を作成する（カレンダーデータの格納用）
        mArray = NSMutableArray()
        
        //曜日ラベルの配列を格納する（削除用）2016/02/11
        mArrayForLabel = NSMutableArray()
        

        //曜日ラベルを動的に配置
        setupCalendarLabel()
        
        //初期表示時のカレンダーをセットアップする
        setupCurrentCalendar()
    }
    
    
    //曜日ラベルの動的配置関数
    func setupCalendarLabel() {
        
        //曜日ラベル初期定義（2016/02/11外出し）
        var monthName:[String]
        
        switch calendarMode{
        case -1:
            monthName = ["大安","赤口","先勝","友引","先負","仏滅"]
            break
        default:
            monthName = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        }
        
        let calendarLabelCount = monthName.count
        print("calendarLabelCount=\(calendarLabelCount)")
        
        let reviseX:Double =  7.0 / Double(calendarLabelCount)
        var tempCalendarLabelX = Int(ceil(Double(calendarLabelX) * reviseX))
        
        if(calendarMode == -1){
            tempCalendarLabelX += 1      //微調整
        }
        
        for i in 0...calendarLabelCount-1{
            
            var calendarBaseLabel:UILabel
            
            //インスタンス作成（必要？）
            calendarBaseLabel = UILabel()
            
            //X座標の値をCGFloat型へ変換して設定
            calendarBaseLabel.frame = CGRectMake(
                CGFloat(calendarLabelIntervalX + tempCalendarLabelX * (i % calendarLabelCount)),
                CGFloat(calendarLabelY),
                CGFloat(calendarLabelWidth),
                CGFloat(calendarLabelHeight)
            )
            
            //大安の場合は赤色を指定
            if(i == 0){
                
                //RGBカラーの設定は小数値をCGFloat型にしてあげる
                calendarBaseLabel.textColor = UIColor(
                    red: CGFloat(0.831), green: CGFloat(0.349), blue: CGFloat(0.224), alpha: CGFloat(1.0)
                )
                
                //仏滅の場合は青色を指定
            }else if(i == calendarLabelCount-1){
                
                //RGBカラーの設定は小数値をCGFloat型にしてあげる
                calendarBaseLabel.textColor = UIColor(
                    red: CGFloat(0.400), green: CGFloat(0.471), blue: CGFloat(0.980), alpha: CGFloat(1.0)
                )
                
                //その他の場合は灰色を指定
            }else{
                
                //既に用意されている配色パターンの場合
                calendarBaseLabel.textColor = UIColor.lightGrayColor()
                
            }
            
            //曜日ラベルの配置
            calendarBaseLabel.text = String(monthName[i] as! NSString)
            calendarBaseLabel.textAlignment = NSTextAlignment.Center
            calendarBaseLabel.font = UIFont(name: "System", size: CGFloat(calendarLableFontSize))
            self.view.addSubview(calendarBaseLabel)
            mArrayForLabel.addObject(calendarBaseLabel) //削除用（2016/02/11）
        }
        

    }
    
    //カレンダーを生成する関数
    func generateCalendar(){
        
        //イマを刻むコンポーネント（2016/02/07）
        let nowCalendar: NSCalendar = NSCalendar.currentCalendar()
        let nowComps = nowCalendar.components([.Year, .Month, .Day], fromDate: NSDate())
        
        var tagNumber = 1   //タグナンバー（日数）
        var numberOfDaysInWeek: Int //1週間に含まれる日数 旧暦なら6日（六曜）、新暦なら7日（七曜日）
        var total: Int //トータルカウント（ボタンの総数）
        
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
            
            maxDay = ancientTbl[month][0] - ancientTbl[month-1][0]
    
        //新暦モード
        } else {
            
            numberOfDaysInWeek = 7
            total     = 6 * numberOfDaysInWeek
    
        }
        
        let reviseX:Double =  7.0 / Double(numberOfDaysInWeek)
        var tempCalendarX = Int(ceil(Double(calendarX) * reviseX))
        
        if(calendarMode == -1){
            tempCalendarX += 1      //微調整
        }
        
        //ボタンのアニメーション（2016/02/15）
        var transform:CGAffineTransform = CGAffineTransformIdentity
        transform = CGAffineTransformMakeScale(-1, 1)
        let duration:Double = 0.3
    
        //numberOfDaysInWeek×6個（36個 or 42個）のボタン要素を作る
        for i in 0...total-1{
            
            //配置場所の定義
            let positionX   = calendarIntervalX + tempCalendarX * (i % numberOfDaysInWeek)   //Intervalは間隔ではなくて初期値でしたorz
            let positionY   = calendarIntervalY + calendarY * (i / numberOfDaysInWeek)
            let buttonSizeX = calendarSize;
            let buttonSizeY = calendarSize;
            
//            var reviseX:Double =  7.0 / Double(numberOfDaysInWeek)
//            //positionX = Int(round(Double(positionX) * reviseX))
//            positionX = Int(ceil(Double(positionX) * reviseX))
            
            //ボタンをつくる
            let button: UIButton = UIButton()
            button.frame = CGRectMake(
                CGFloat(positionX),
                CGFloat(positionY),
                CGFloat(buttonSizeX),
                CGFloat(buttonSizeY)
            );
            

            
            //ボタンの初期設定をする
            if(i < dayOfWeek - 1){
                
                //日付の入らない部分はボタンを押せなくする
                button.setTitle("", forState: .Normal)
                button.enabled = false
                
            }else if(i == dayOfWeek - 1 || i < dayOfWeek + maxDay - 1){
                
                //日付の入る部分はボタンのタグを設定する（日にち）
//                button.setTitle(String(tagNumber), forState: .Normal)
                
                var strBtn :String = String(tagNumber) + " "
//                var atrBtn :NSAttributedString = NSAttributedString.init(string: strBtn)
//                var atrBtn :NSAttributedString = NSAttributedString.attribute()
//                atrBtn.attribute(NSFontAttributeName, atIndex: 0, effectiveRange: NSMakeRange(3, 5))
//                var atr = [NSFontAttributeName:UIFont.systemFontOfSize(10.0)]
                
                var tmpComps :NSDateComponents = nowCalendar.components([.Year, .Month, .Day], fromDate: NSDate())
                tmpComps.year = year
                tmpComps.month = month
                //tmpComps.day = i
                tmpComps.day = tagNumber
                
//                print(tmpComps)
                
                var addDate:String = ""
                
                if(calendarMode == -1){ //旧暦モード
                    
                    if(!nowLeapMonth){  //通常月
                        tmpComps = convertForGregorianCalendar([year, month, tagNumber, 0])
                        
                    } else {    //閏月
                        tmpComps = convertForGregorianCalendar([year, -month, tagNumber, 0])
                    }
                    
                    addDate += "\(tmpComps.month)/\(tmpComps.day)"
                    
                } else {
                    var array:[Int] = convertForAncientCalendar(tmpComps)
//                    print("array=\(array)")
                    
                    if(array[3] == -1){
                        addDate += "閏"
                    }
                    
                    addDate += "\(array[1])/\(array[2])"
                }
            
                
                strBtn += addDate
                
                var myMutableString:NSMutableAttributedString = NSMutableAttributedString(
                    string: strBtn,
                    attributes: [NSFontAttributeName:UIFont.systemFontOfSize(11.9)])    //12.3
                
                myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location: 0, length: (strBtn.characters.count - addDate.characters.count)))
                    
                myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor(
                    red: CGFloat(0.989), green: CGFloat(0.919), blue: CGFloat(0.756), alpha: CGFloat(0.9)),
                    range: NSRange(location: (strBtn.characters.count - addDate.characters.count), length: addDate.characters.count))   //0.971,0.749, 0.456
                    
                myMutableString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(7.3),
                    range: NSRange(location: (strBtn.characters.count - addDate.characters.count), length: addDate.characters.count))   //7.6
                
//                button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                
//                button.setTitle(strBtn, forState: .Normal)
//                button.setTitle(myMutableString, forState: .Normal)
                
//                button.setAttributedTitle(atr, forState: .Normal)
                
//                button.setAttributedTitle(atrBtn, forState: .Normal)
                button.setAttributedTitle(myMutableString, forState: .Normal)
                
                if(nowComps.year == year && nowComps.month == month && nowComps.day == i){   //当日については、赤くする
                    button.setTitleColor(UIColor.redColor(), forState: .Normal)
                    print("ここが赤くなっているか→\(year).\(month).\(day)")
                }
                
                button.tag = tagNumber
                tagNumber++
                
            }else if(i == dayOfWeek + maxDay - 1 || i < total){
                
                //日付の入らない部分はボタンを押せなくする
                button.setTitle("", forState: .Normal)
                button.enabled = false
                
            }
            
          
//            print("i=\(i)")
            
            //ボタンの配色の設定
            //@remark:このサンプルでは正円のボタンを作っていますが、背景画像の設定等も可能です。
            if(i % numberOfDaysInWeek == 0){
                calendarBackGroundColor = UIColor(
                    red: CGFloat(0.831), green: CGFloat(0.349), blue: CGFloat(0.224), alpha: CGFloat(1.0)
                )
            }else if(i % numberOfDaysInWeek == numberOfDaysInWeek-1){
                calendarBackGroundColor = UIColor(
                    red: CGFloat(0.400), green: CGFloat(0.471), blue: CGFloat(0.980), alpha: CGFloat(1.0)
                )
            }else{
                calendarBackGroundColor = UIColor.lightGrayColor()
            }
            
            //ボタンのデザインを決定する
            button.backgroundColor = calendarBackGroundColor    //ここに置かないと色がずれちゃうよ。
            
            button.titleLabel!.font = UIFont(name: "System", size: CGFloat(calendarFontSize))
            
            //旧暦モードの場合は、日付を丸くする。
            if(calendarMode == -1){
                button.layer.cornerRadius = CGFloat(buttonRadius)
            }
            
            //配置したボタンに押した際のアクションを設定する
            button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
            
            //ボタンを配置する
            self.view.addSubview(button)
            
            //アニメーション
            UIView.animateWithDuration(duration, animations: { () -> Void in
                button.transform = transform
                })
                {(Bool) -> Void in
                    UIView.animateWithDuration(duration, animations: { () -> Void in
                        button.transform = CGAffineTransformIdentity
                        })
                        { (Bool) -> Void in
                    }
            }
            
            mArray.addObject(button)
    
        }
        
    }
    
    //タイトル表記を設定する関数
    func setupCalendarTitleLabel() {
        //calendarBar.text = String("\(year)年\(month)月のカレンダー")
        self.navigationItem.title = "\(year)年"
        
        var calendarTitle: String;
        var jpnMonth = ["睦月", "如月", "弥生", "卯月", "皐月", "水無月", "文月", "葉月", "長月", "神無月", "霜月", "師走"]
        calendarTitle = "\(month)月"
//        if(isLeapMonth < 0){
        if((month == leapMonth) && nowLeapMonth){
            calendarTitle = "閏\(month)月"
        }
        
        print("setupCalendarTitleLabelの中で、leapMonth=\(leapMonth)、month=\(month)、isLeapMonth=\(isLeapMonth)")
        /*
        if(leapMonth == month){
            isLeapMonth = -1
        }
        */
        
        switch calendarMode {
            case -1:
                calendarBar.text = String("" + jpnMonth[month-1] + "（旧暦 \(calendarTitle)）")
                presentMode.text = "旧暦モード"
                break
            default:
                calendarBar.text = String("新暦 \(month)月")
                presentMode.text = "通常モード（新暦）"
        }
        
    }
    
    //現在（初期表示時）の年月に該当するデータを取得する関数
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
    
    //前の年月に該当するデータを取得する関数
    func setupPrevCalendarData() {
        
        //旧暦モード（閏月の考慮が必要）
        if(calendarMode == -1){
            
            //まず、現在の月に対して-1をする
            if(!nowLeapMonth){
                
                if(month == 0){
                    year = year - 1;
                    month = 12;
                    tblExpand(year)     //閏月が12月の可能性があるため、tblExpandで閏つき情報を更新する（nextの場合は、いきなり閏月に成る事はないので不要）
                }else{
                    month = month - 1;
                }
                
                
                
                //閏年になった場合は、
                if((month == leapMonth)){
                    nowLeapMonth = true
                }

            }else{
                nowLeapMonth = false
            }
            
            
        } else {    //閏月の考慮が必要なし
            //現在の月に対して-1をする
            if(month == 0){
                year = year - 1;
                month = 12;
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
    
    //次の年月に該当するデータを取得する関数
    func setupNextCalendarData() {
        
        //旧暦モード（閏月の考慮が必要）
        if(calendarMode == -1){
            
            //現在の月に対して+1をする
            if(month >= 12){
                year = year + 1;
                month = 1;
                nowLeapMonth = false
            }else{
                if((month == leapMonth) && !nowLeapMonth){
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
    
    //カレンダーモードを変更した際に呼び出す関数
    func setupAnotherCalendarData(){
        
           /*************
         * (重要ポイント)
         * 現在月の1日のdayOfWeek(曜日の値)を使ってカレンダーの始まる位置を決めるので、
         * yyyy年mm月1日のデータを作成する。
         * 後述の関数 setupPrevCalendarData, setupNextCalendarData も同様です。
         *************/
        let currentCalendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        var currentComps: NSDateComponents = NSDateComponents()//ここでインスタンス化してるから、変換するときダメなんや！いや違った。
        
        //        let currentComps = currentCalendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday],fromDate:NSDate();

        
        self.navigationItem.title = "旧暦カレンダー"
        
        if(calendarMode == -1){  //旧暦モード
            
            //これ入れないとおかしくなる。なんで？converForAncientCalendarの洗礼を通れなくなるから、みたい。
            currentComps.year  = year
            currentComps.month = month
//            currentComps.day   = 1        //NavigationViewControllerのタイトル
            currentComps.day   = day    //必要？
            
            print("convertForAncientCalendar返還前:year=\(year),month=\(month),day=\(day),isLeapMonth=\(isLeapMonth)")
            let ancientDate:[Int] = convertForAncientCalendar(currentComps)
            print("convertFor取得後：\(ancientDate)")
            //            year = ancientDate[0]
            //            month = ancientDate[1]
            //            day = ancientDate[2]
            currentComps.year = ancientDate[0]
            currentComps.month = ancientDate[1]
            currentComps.day = ancientDate[2]
            isLeapMonth = ancientDate[3]
        
        } else {    //新暦モード
            print("convertForAncientCalendar返還前:year=\(year),month=\(month),day=\(day),isLeapMonth=\(isLeapMonth)")
            currentComps = convertForGregorianCalendar([year, month, 29, 0])
            print("convertFor取得後：\(currentComps)")
            
        }
        
        print("setupCurrentCalendar（変換後）:year=\(year),month=\(month),day=\(day),isLeapMonth=\(isLeapMonth)")
        
        let currentDate: NSDate = currentCalendar.dateFromComponents(currentComps)!
        recreateCalendarParameter(currentCalendar, currentDate: currentDate)

    }
    
    //カレンダーのパラメータを再作成する関数（前月・次月への遷移、カレンダー切り替え時）
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
        
        print("recreateCalendarParameterの中で、leapMonth=\(leapMonth)、month=\(month)、isLeapMonth=\(isLeapMonth)")
        
        if(leapMonth == month){
            isLeapMonth = -1
        } else {
            isLeapMonth = 0
        }
        
    }
    
    //表示されているボタンオブジェクトを一旦削除する関数
    func removeCalendarButtonObject() {
        
        //ビューからボタンオブジェクトを削除する
        for i in 0..<mArray.count {
             mArray[i].removeFromSuperview()
        }
        
        //配列に格納したボタンオブジェクトも削除する
        mArray.removeAllObjects()
        
    }
    
    //表示されている曜日オブジェクトを一旦削除する関数
    func removecalendarBaseLabel(){
        
        //ビューから曜日オブジェクトを削除する
        for i in 0..<mArrayForLabel.count {
            mArrayForLabel[i].removeFromSuperview()
        }
        
        mArrayForLabel.removeAllObjects()
        
    }
    
    //現在のカレンダーをセットアップする関数
    func setupCurrentCalendar() {
        
        setupCurrentCalendarData()
        generateCalendar()
        setupCalendarTitleLabel()
    }
    
    //カレンダーボタンをタップした時のアクション
    func buttonTapped(button: UIButton){
        
        // @todo:画面遷移等の処理を書くことができます。
        
        // コンソール表示
        print("\(year)年\(month)月\(button.tag)日が選択されました！")

        day = button.tag
        
        // NSCalendarを生成
        let myCalendar: NSCalendar = NSCalendar.currentCalendar()
        
        // ユーザのカレンダーを取得
        var myEventCalendars = myEventStore.calendarsForEntityType(EKEntityType.Event)

        // 終了日（一日後）コンポーネントの作成
        let comps: NSDateComponents = NSDateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        
        let SelectedDay: NSDate = myCalendar.dateFromComponents(comps)!
        
        comps.day += 1
        
        
        let oneDayFromSelectedDay: NSDate = myCalendar.dateFromComponents(comps)!
        
        print("oneDayFromSelcetedDay=\(oneDayFromSelectedDay)")

        
        // イベントストアのインスタントメソッドで述語を生成
        var predicate = NSPredicate()
        
        predicate = myEventStore.predicateForEventsWithStartDate(SelectedDay, endDate: oneDayFromSelectedDay, calendars: nil)
        
        print("predicate=\(predicate)")
        
        // 選択された一日分をフェッチ
        events = myEventStore.eventsMatchingPredicate(predicate)
        

        performSegueWithIdentifier("toScheduleView", sender: self)
    }
    
    
    //画面遷移時に呼ばれるメソッド
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //セゲエ用にダウンキャストしたScheduleViewControllerのインスタンス
        let svc = segue.destinationViewController as! ScheduleViewController
        //変数を渡す
        //svc.myItems = eventItems;
        svc.myEvents = events
        
        //タップされた日を渡す
        svc.year = year
        svc.month = month
        svc.day = day
        
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
    
    // モードを切り替えるメソッド
    @IBAction func changeCalendarMode(sendar: UIBarButtonItem){
        calendarMode = calendarMode * -1
        print("changeCalendarMode :\(calendarMode)")

        removeCalendarButtonObject()
        setupAnotherCalendarData()
        removecalendarBaseLabel()   //曜日のラベルを全削除
        setupCalendarLabel()        //曜日のラベルを作成
        generateCalendar()
        setupCalendarTitleLabel()
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
    
    // TODO:旧暦を作成するメソッド（月のデザイン）
    
    

    
    /**
     認証ステータスを取得
     **/
    func getAuthorization_status() -> Bool {
        
        // ステータスを取得
        let status: EKAuthorizationStatus = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        // ステータスを表示 許可されている場合のみtrueを返す
        switch status {
        case EKAuthorizationStatus.NotDetermined:
            print("NotDetermined")
            return false
            
        case EKAuthorizationStatus.Denied:
            print("Denied")
            return false
            
        case EKAuthorizationStatus.Authorized:
            print("Authorized")
            return true
            
        case EKAuthorizationStatus.Restricted:
            print("Restricted")
            return false
            
        default:
            print("error")
            return false
            
        }
    }
    
    //旧暦変換（2016/02/06）
    func convertForAncientCalendar(comps:NSDateComponents) -> [Int]{
        
//        print("In convertForAncientCalendar")
        
        var yearByAncient:Int = comps.year
        var monthByAncient:Int = comps.month
        var dayByAncient:Int = comps.day
        
        /*
        if(nowLeapMonth){   //今が閏月の場合
            monthByAncient = monthByAncient*(-1)
        }
        */
        
//        print("yearByAncient=\(yearByAncient) ,monthByAncient=\(monthByAncient), dayByAncient=\(dayByAncient)")
        
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        //        let comps2 = calendar.components([.Year, .Month, .Day, .Weekday],fromDate:now)
        //var dayOfYear = calendar.ordinalityOfUnit(.Day, inUnit:.Year, forDate: now)
        var dayOfYear = calendar.ordinalityOfUnit(.Day, inUnit:.Year, forDate: calendar.dateFromComponents(comps)!)
        
        
        //        var yearByAncient:Int = comps2.year
        
        
        //        print(comps2)
        //        print(o2ntbl[0])
        //        print(o2ntbl[0][1])
        
        //旧暦テーブルを作成する
        //        tblExpand(yearByAncient)
        tblExpand(yearByAncient)
        
//        print("yearByAncient=\(yearByAncient)")
        
        if(dayOfYear < ancientTbl[0][0]){   //旧暦で表すと、１年前になる場合
            yearByAncient--;
            dayOfYear += (365 + isLeapYear(yearByAncient))
            //            tblExpand(yearByAncient)    //旧暦テーブル再作成（手間？）
            tblExpand(yearByAncient)
        }
        
        
        
        //どの月の、何日目かをancientTblから引き出す
        //        for i in 12...0 {
        for(var i=12; i>=0; i--){
            if(ancientTbl[i][1] != 0){
                if(ancientTbl[i][0] <= dayOfYear){
                    monthByAncient = ancientTbl[i][1]
                    dayByAncient = dayOfYear - ancientTbl[i][0] + 1
                    break
                }
            }
        }
        
        //閏月判定
        if (monthByAncient < 0){
            isLeapMonth = -1;
            monthByAncient = -monthByAncient
        } else {
            isLeapMonth = 0
        }
        
        //        comps.year = yearByAncient
        //        comps.month = monthByAncient
        //        comps.day = dayByAncient
        
        print(yearByAncient,monthByAncient,dayByAncient,isLeapMonth)
        return [yearByAncient,monthByAncient,dayByAncient,isLeapMonth]
        
    }
    
    
    //旧暦→新暦変換
    func convertForGregorianCalendar(dateArray:[Int]) -> NSDateComponents{
        
        //イマを刻むコンポーネント（2016/02/07）
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        
        var compsByGregorian = calendar.components([.Year, .Month, .Day], fromDate: NSDate())    //とりあえずイマを返す
        
        var yearByGregorian = dateArray[0]
        var monthByGregorian = dateArray[1]
        var dayByGregorian = dateArray[2]
        var templeapMonth = dateArray[3]
        
        tblExpand(yearByGregorian)
        
        var dayOfYear:Int!
        
        dayOfYear = -1
        
        for i in 0 ... 13{
            if(ancientTbl[i][1] == monthByGregorian){
                dayOfYear = ancientTbl[i][0] + dayByGregorian - 1
                break
            }
        }
        
        if(dayOfYear < 0){
            //該当日なし
            return compsByGregorian
        }
        
        var tmp:Int = 365 + isLeapYear(yearByGregorian)
        
        if(dayOfYear > tmp){
            dayOfYear = dayOfYear - tmp;
            yearByGregorian++
        }
        
        dayByGregorian = -1
        
        compsByGregorian.day = 1
        
        for(var i=12; i>=1; i--){
            compsByGregorian.month = i
            tmp = calendar.ordinalityOfUnit(.Day, inUnit:.Year, forDate:calendar.dateFromComponents(compsByGregorian)!)
            if(dayOfYear >= tmp){
                dayByGregorian = dayOfYear - tmp + 1
                break
            }
        }
        
        if(dayByGregorian < 0){
            return compsByGregorian   //とりあえずイマを返す
            
        }
        
        compsByGregorian.year = yearByGregorian
        //compsByGregorian.month = monthByGregorian
        compsByGregorian.day = dayByGregorian
        
        return compsByGregorian
        
    }
    
    
    //閏年判定（trueなら1、falseなら0を返す）→逆になっているのは、閏年の場合convertForAncientCalendar内で365に1追加したいため
    //func isLeapYear(year: Int) -> Int{
    func isLeapYear(inYear: Int) -> Int{
        var isLeap = 0
        if(inYear % 400 == 0 || (inYear % 4 == 0 && inYear % 100 != 0)){
            isLeap = 1
        }
        return isLeap
    }
    
    //旧暦・新暦テーブル生成（ancientTbl）
    func tblExpand(inYear: Int){
        //    func tblExpand(){
        
        //        var year = comps.year
        
//        print(inYear - minYear)
//        print(inYear)
//        print(minYear)
        var days:Double = Double(o2ntbl[inYear - minYear][0])
        var bits:Int = o2ntbl[inYear - minYear][1]    //bit？
        leapMonth = Int(days) % 13          //閏月
        
        days = floor((Double(days) / 13.0) + 0.001) //旧暦年初の新暦年初からの日数
        
        ancientTbl[0] = [Int(days), 1]  //旧暦正月の通日と、月数
        //        ancientTbl.append([Int(days), 1])
        
        if(leapMonth == 0){
            bits *= 2   //閏無しなら、１２ヶ月
            ommax = 12
        } else {
            ommax = 13
        }
        
        for i in 1...ommax {
            ancientTbl[i] = [ancientTbl[i-1][0]+29, i+1]    //[旧暦の日数, 月]をループで入れる
            if(bits >= 4096) {
                ancientTbl[i][0]++    //大の月（30日ある月）
            }
            bits = (bits % 4096) * 2;
            
        }
        ancientTbl[ommax][1] = 0    //テーブルの終わり＆旧暦の翌年年初
        
        if (ommax > 12){    //閏月のある年
            for i in leapMonth+1 ... 12{
                ancientTbl[i][1] = i    //月を再計算
            }
            ancientTbl[leapMonth][1] = -leapMonth;   //識別のため閏月はマイナスで記録
            print("閏ある！\(leapMonth)月。")
        } else {
            ancientTbl[13] = [0, 0] //使ってないけどエラー防止で。
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
            myEventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
                (granted, error) -> Void in
                
                // 許可を得られなかった場合アラート発動
                if granted {
                    return
                }
                else {
                    
                    // メインスレッド 画面制御.非同期.
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        // アラート作成
                        let myAlert = UIAlertController(title: "許可されませんでした", message: "Privacy->App->Reminderで変更してください", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        // アラートアクション
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                    })
                }
            })
        }
    }
    

    
    // どのクラスにもあるメソッド Memory監視？
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
