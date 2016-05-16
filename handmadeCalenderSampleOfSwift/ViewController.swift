//
//  ViewController.swift
//  旧暦カレンダー
//
//  Created by foresthill on 2016/1/29.
//  Copyright (c) 2016 foresthill. All rights reserved.
//

/**
 * 本プログラムは下記のURLで紹介されているコードを基に作成しています。
 * http://blog.just1factory.net/programming/179
 *
 */

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
    var eventStore: EKEventStore!
    
    // 発見したイベントを格納する配列を生成（Segueで呼び出すために外だし）2015/12/23
    var events: [EKEvent]!
    
    //カレンダーの閾値（1999年〜2030年まで閲覧可能）
    let minYear = 1999
    let maxYear = 2030

    //モード（通常モード、旧暦モード）
    var calendarMode: Int!      //ゆくゆくは３モード切替にしたいため、boolではなくintで。（量子コンピュータ）1:通常（新暦）-1:旧暦
    
    //曜日ラベル削除用（2016/02/11外だし）
    var mArrayForLabel: NSMutableArray!
    
    //今が閏月かどうか（他にいい方法あったら教えて。）
    var nowLeapMonth: Bool = false
    
    //旧暦カレンダー変換エンジン外出し（2016/04/17）
    var converter: AncientCalendarConverter2!
    
    //色の標準化・共通化（2016/05/05）
    var baseNormal: UIColor!    //標準のラベルカラー
    var baseRed: UIColor!       //日曜、大安で使用
    var baseBlue: UIColor!      //土曜、仏滅で使用
    var baseBlack: UIColor!     //旧暦表示の背景に表示（2016.05.17追加）
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //カレンダーモード（2016/02/06追加）
        calendarMode = 1    //1:通常（新暦）-1:旧暦
        
        //閏月（2016/02/06、なぜかエラー出るように）
        isLeapMonth = 0
        
        //旧暦カレンダー変換エンジン外出し（2016/04/17）
        converter = AncientCalendarConverter2.sharedSingleton
        converter.minYear = minYear
        
        //色の標準化・共通化（2016/05/05） ※RGBカラーの設定は小数値をCGFloat型にしてあげる
        baseNormal = UIColor.lightGrayColor()
        baseRed = UIColor(red: CGFloat(0.831), green: CGFloat(0.349), blue: CGFloat(0.224), alpha: CGFloat(1.0))
        baseBlue = UIColor(red: CGFloat(0.400), green: CGFloat(0.471), blue: CGFloat(0.980), alpha: CGFloat(1.0))
        baseBlack = UIColor.blackColor()
        
        //画面初期化・最適化
        screenInit()
        
        //GregorianCalendarセットアップ
        setupGregorianCalendar()
        
        // EventStoreを作成する（2015/08/05）
        eventStore = EKEventStore()
        
        // ユーザーにカレンダーの使用許可を求める（2015/08/06）
        allowAuthorization()
        
        //NavigationViewControllerのタイトル（初期表示）
        self.navigationItem.title = "旧暦カレンダー"
        //self.navigationItem.prompt = "\(year)年"   //見栄えが崩れるためコメントアウト

        //TODO: Editボタンを作成（v1.1で実装予定）
        //let btn: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "calendarChange")
        //navigationItem.rightBarButtonItem = btn
        
        //ウィンドウ（2015/07/21）
        //        popUpWindow = UIWindow()        // インスタンス化しとかないとダメ
        //        popUpWindowButton = UIButton()  // 同上
        
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
        let range: NSRange = calendar.rangeOfUnit(NSCalendarUnit.Day, inUnit:NSCalendarUnit.Month, forDate:now)
        
        //最初にメンバ変数に格納するための現在日付の情報を取得する
        comps = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday],fromDate:now)
        
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
            
            if(i == 0){
                //日曜、大安の場合は赤色を指定
                calendarBaseLabel.textColor = baseRed
                
            }else if(i == calendarLabelCount-1){
                //土曜、仏滅の場合は青色を指定
                calendarBaseLabel.textColor = baseBlue
                
            }else{
                //その他の場合は灰色を指定
                calendarBaseLabel.textColor = baseNormal
                
            }
            
            //曜日ラベルの配置
            calendarBaseLabel.text = String(monthName[i] as NSString)
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
            
            //閏月より後の月の日数がおかしいバグ修正（2016/03/20）
            var tempMonth:Int = month
            
            if(converter.leapMonth > 0 && tempMonth > converter.leapMonth){ //leapMonth→converter.leapMonth（2016/04/17）
                tempMonth++
            }
            
            maxDay = converter.ancientTbl[tempMonth][0] - converter.ancientTbl[tempMonth-1][0]
    
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
                
                var tmpComps :NSDateComponents = nowCalendar.components([.Year, .Month, .Day], fromDate: NSDate())
                tmpComps.year = year
                tmpComps.month = month
                tmpComps.day = tagNumber
                
                var addDate:String = ""
                
                if(calendarMode == -1){ //旧暦モード
                    
                    if(!nowLeapMonth){  //通常月
                        tmpComps = converter.convertForGregorianCalendar([year, month, tagNumber, 0])
                        
                    } else {    //閏月
                        tmpComps = converter.convertForGregorianCalendar([year, -month, tagNumber, 0])
                    }
                    
                    addDate += "\(tmpComps.month)/\(tmpComps.day)"
                    
                } else {
                    var array:[Int] = converter.convertForAncientCalendar(tmpComps)
                    
                    if(array[3] == -1){
                        addDate += "閏"
                    }
                    
                    addDate += "\(array[1])/\(array[2])"
                }
            
                
                strBtn += addDate
                
                //文字のフォント・文字色などをNSMutableAttributedStringで設定
                var myMutableString:NSMutableAttributedString = NSMutableAttributedString(
                    string: strBtn,
                    attributes: [NSFontAttributeName:UIFont.systemFontOfSize(11.9)])
                
                myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location: 0, length: (strBtn.characters.count - addDate.characters.count)))
                    
                myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor(
                    red: CGFloat(0.989), green: CGFloat(0.919), blue: CGFloat(0.756), alpha: CGFloat(0.9)),
                    range: NSRange(location: (strBtn.characters.count - addDate.characters.count), length: addDate.characters.count))   //0.971,0.749, 0.456
                    
                myMutableString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(7.3),
                    range: NSRange(location: (strBtn.characters.count - addDate.characters.count), length: addDate.characters.count))   //7.6
                
                button.setAttributedTitle(myMutableString, forState: .Normal)
                
                /*当日については、枠線で色をつける（旧暦に対応していないため、一旦保留）
                if(nowComps.year == year && nowComps.month == month && nowComps.day == tagNumber){
                    //button.setTitleColor(UIColor.redColor(), forState: .Normal)
                    button.layer.borderColor = UIColor(
                        red: CGFloat(0.993), green: CGFloat(0.989), blue: CGFloat(0.856), alpha: CGFloat(0.9)).CGColor
                    button.layer.borderWidth = 1
                }*/
                
                button.tag = tagNumber
                
                //旧暦の場合背景画像（月）を設定
                if(calendarMode == -1){
                    button.setBackgroundImage(UIImage(named:"moon\(tagNumber).png"), forState: UIControlState.Normal)
                }
                
                tagNumber++
                
            }else if(i == dayOfWeek + maxDay - 1 || i < total){
                
                //日付の入らない部分はボタンを押せなくする
                button.setTitle("", forState: .Normal)
                button.enabled = false
                
            }
            
            //ボタンの配色の設定
            //@remark:このサンプルでは正円のボタンを作っていますが、背景画像の設定等も可能です。
            if(calendarMode == 1){
                //通常モード（新暦）
                if(i % numberOfDaysInWeek == 0){
                    //日曜、大安
                    calendarBackGroundColor = baseRed
                    
                } else if (i % numberOfDaysInWeek == numberOfDaysInWeek-1){
                    //土曜、仏滅
                    calendarBackGroundColor = baseBlue
                    
                } else {
                    //それ以外（通常）
                    calendarBackGroundColor = baseNormal
                    
                }
            
            } else {
                //旧暦モード
                calendarBackGroundColor = baseBlack

            }
            
            //ボタンの背景デザインを決定する
            button.backgroundColor = calendarBackGroundColor    //ここに置かないと色がずれちゃうよ。
                
            //フォント
            button.titleLabel!.font = UIFont(name: "System", size: CGFloat(calendarFontSize))
            
            //旧暦モードの場合は、日付を丸くする。
            if(calendarMode == -1){
                button.layer.cornerRadius = CGFloat(buttonRadius)
            }
            
            //配置したボタンに押した際のアクションを設定する
            button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
            
            //ボタンを配置する
            self.view.addSubview(button)
            
            //ボタンが配置された時のアニメーション
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

        //self.navigationItem.title = "\(year)年"
        
        var calendarTitle: String;
        var jpnMonth = ["睦月", "如月", "弥生", "卯月", "皐月", "水無月", "文月", "葉月", "長月", "神無月", "霜月", "師走"]
        calendarTitle = "\(month)月"

        if((month == converter.leapMonth) && nowLeapMonth){   //leapMonth→converter.leapMonth（2016/04/17）
            calendarTitle = "閏\(month)月"
        }

        switch calendarMode {
            case -1:
                //calendarBar.text = String("" + jpnMonth[month-1] + "（旧暦 \(calendarTitle)）")
                calendarBar.text = String("【旧暦】" + "\(year)年" + jpnMonth[month-1] + "（\(calendarTitle)）")
                presentMode.text = "旧暦モード"
                break
            default:
                //calendarBar.text = String("新暦 \(month)月")
                calendarBar.text = String("【新暦】" + "\(year)年" + "\(month)月")
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
    
    //カレンダーモードを変更した際に呼び出す関数
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
        
        //カレンダーのデザインを変更
        setupCalendarDesign()
        
        //self.navigationItem.title = "\(year)"
        
        let currentDate: NSDate = currentCalendar.dateFromComponents(currentComps)!
        recreateCalendarParameter(currentCalendar, currentDate: currentDate)

    }
    
    //デザインを設定・変更する関数（2016/05/05） #5
    func setupCalendarDesign(){
        
        if(calendarMode == -1){
            //旧暦モード
            
            //背景
            self.view.backgroundColor = UIColor(red: 15/255, green: 21/255, blue: 36/255, alpha: 1.0)
            //カレンダバー
            self.calendarBar.backgroundColor = UIColor(red: 8/255, green: 8/255, blue: 21/255, alpha: 1.0)
            //ナビゲーションバー
            self.navigationItem.titleView?.tintColor = UIColor(red: 207/255, green: 215/255, blue: 234/255, alpha: 1.0)
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 207/255, green: 215/255, blue: 234/255, alpha: 1.0)]
            self.navigationController?.navigationBar.barTintColor = UIColor(red: 15/255, green: 16/255, blue: 19/255, alpha: 1.0)
            //「前月」「次月」ボタン
            self.prevMonthButton.backgroundColor = UIColor(red: 30/255, green: 125/255, blue: 108/255, alpha: 1.0)
            self.nextMonthButton.backgroundColor = UIColor(red: 47/255, green: 103/255, blue: 127/255, alpha: 1.0)
            
        } else {
            //新暦モード
            
            //背景
            self.view.backgroundColor = UIColor.whiteColor()
            //カレンダバー
            self.calendarBar.backgroundColor = UIColor(red: 235/255, green: 208/255, blue: 185/255, alpha: 1.0)
            //ナビゲーションバー
            self.navigationItem.titleView?.tintColor = UIColor.blackColor()
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
            self.navigationController?.navigationBar.barTintColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
            //「前月」「次月」ボタン
            self.prevMonthButton.backgroundColor = UIColor(red: 112/255, green: 229/255, blue: 208/255, alpha: 1.0)
            self.nextMonthButton.backgroundColor = UIColor(red: 161/255, green: 209/255, blue: 230/255, alpha: 1.0)
            
        }
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

        if(converter.leapMonth == month){ //leapMonth→converter.leapMonth（2016/04/17）
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
        // コンソール表示
        //print("\(year)年\(month)月\(button.tag)日が選択されました！")
        day = button.tag
        performSegueWithIdentifier("toScheduleView", sender: self)
        
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

        removeCalendarButtonObject()
        setupAnotherCalendarData()
        removecalendarBaseLabel()   //曜日のラベルを全削除
        setupCalendarLabel()        //曜日のラベルを作成
        generateCalendar()
        setupCalendarTitleLabel()
    }
    
    //前月を表示するメソッド
    func prevCalendarSettings() {
        if(year > minYear){
            removeCalendarButtonObject()
            setupPrevCalendarData()
            generateCalendar()
            setupCalendarTitleLabel()
        }
    }
    
    //次月を表示するメソッド
    func nextCalendarSettings() {
        if(year < maxYear){
            removeCalendarButtonObject()
            setupNextCalendarData()
            generateCalendar()
            setupCalendarTitleLabel()
        }
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
    
    

    /**
     認証許可
     **/
    func allowAuthorization() {
        
        // 許可されていなかった場合、認証許可を求める
        if getAuthorization_status() {
            return
        } else {
            
            // ユーザーに許可を求める
            eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
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
    
    //画面遷移時に呼ばれるメソッド
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //セゲエ用にダウンキャストしたScheduleViewControllerのインスタンス
        let svc = segue.destinationViewController as! ScheduleViewController
        
        //変数を渡す
        svc.calendarMode = calendarMode
        svc.year = year
        svc.month = month
        svc.day = day
        svc.isLeapMonth = isLeapMonth
        
        //eventStoreも渡す（2016/04/13：これをシングルトンと呼ぶのか？なんか違う気がする。）
        svc.eventStore = eventStore

        //converterも渡す（2016/04/17）
        svc.converter = converter
        
    }
    
    // ステータスバーを黒くする
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // どのクラスにもあるメソッド Memory監視？
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
