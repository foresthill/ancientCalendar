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
    
    //メンバ変数の設定（カレンダーの背景色）
    var calendarBackGroundColor: UIColor!
    
    //プロパティを指定
    @IBOutlet var calendarBar: UILabel!
    @IBOutlet var prevMonthButton: UIButton!
    @IBOutlet var nextMonthButton: UIButton!
    @IBOutlet weak var presentMode: UILabel!
    @IBOutlet weak var toolBar: UIToolbar!
    
    //その他追加機能（2015/07/21）
    var popUpWindow: UIWindow!
    private var popUpWindowButton: UIButton!
        
    //曜日ラベル削除用（2016/02/11外だし）
    var mArrayForLabel: NSMutableArray!
    
    //旧暦カレンダー変換エンジン外出し（2016/04/17）
    var converter: AncientCalendarConverter2!
    
    //ユーザ設定（スクロール方向をナチュラルにするか否か）
    var scrollNatural = false
    
    //デザイナークラス（シングルトン）
    //let designer: Designer! = Designer.sharedInstance
    var designer: Designer!
    
    //カレンダーロジック管理クラス（シングルトン）
    //let calendarManager: CalendarManager! = CalendarManager.sharedInstance
    var calendarManager: CalendarManager!
    
    //「次へ」「前へ」ボタンを押した際の判定用変数（アニメーションで使用）
    //var nextFlg = true
    
    /** 初期化時に呼ばれる関数 */
    override func viewDidLoad() {
        
        super.viewDidLoad()
                
        //旧暦カレンダー変換エンジン外出し（2016/04/17）
        converter = AncientCalendarConverter2.sharedInstance

        //デザイナークラス（シングルトン）
        designer = Designer.sharedInstance
        
        //カレンダーロジック管理クラス（シングルトン）
        calendarManager = CalendarManager.sharedInstance
        
        //画面初期化・最適化
        //screenInit()
        //余計に呼ぶと座標がおかしくなるのでコメントアウト
        //designer.screenInit()
        
        //GregorianCalendarセットアップ
        setupGregorianCalendar()
        
        //ユーザーにカレンダーの使用許可を求める（2015/08/06）
        allowAuthorization()
        
        //NavigationViewControllerのタイトル（初期表示）
        self.navigationItem.title = "旧暦カレンダー"
        //self.navigationItem.prompt = "\(year)年"   //見栄えが崩れるためコメントアウト

        //設定画面（UserConfigViewController）へ飛ぶ barButtonSystemItem: UIBarButtonSystemItem.Bookmarks
        let btn: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(ViewController.toUserConfig))
        navigationItem.rightBarButtonItem = btn
        
        //ウィンドウ（2015/07/21）
        //        popUpWindow = UIWindow()        // インスタンス化しとかないとダメ
        //        popUpWindowButton = UIButton()  // 同上
        
        //設定値を取得する
        let config = UserDefaults.standard
        let result = config.object(forKey: "scrollNatural")
        if(result != nil){
            scrollNatural = result as! Bool
        }
        
        if designer.prevMonthButtonFrame != nil && designer.nextMonthButtonFrame != nil {
            prevMonthButton.frame = designer.prevMonthButtonFrame
            nextMonthButton.frame = designer.nextMonthButtonFrame
        }
        
     }
    
    /** GregorianCalendarセットアップ */
    func setupGregorianCalendar(){
        /*
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
         */
        
        calendarManager.setupGregorianCalendar()
        
        //空の配列を作成する（カレンダーデータの格納用）
        mArray = NSMutableArray()
        
        //曜日ラベルの配列を格納する（削除用）2016/02/11
        mArrayForLabel = NSMutableArray()
        
        //曜日ラベルを動的に配置
        setupCalendarLabel()
        
        //初期表示時のカレンダーをセットアップする
        setupCurrentCalendar()
    }
    
    
    /** 曜日ラベルの動的配置関数 */
    func setupCalendarLabel() {
        
        //曜日ラベル初期定義（2016/02/11外出し）
        var monthName:[String] = calendarManager.dayOfTheWeekName()
        
        let calendarLabelCount = monthName.count
        
        let reviseX:Double =  7.0 / Double(calendarLabelCount)
        var tempCalendarLabelX = Int(ceil(Double(designer.calendarLabelX ?? 0) * reviseX))
        
        if(calendarManager.calendarMode == -1){
            tempCalendarLabelX += 1      //微調整
        }
        
        for i in 0...calendarLabelCount-1{
            
            var calendarBaseLabel:UILabel
            
            //インスタンス作成（必要？）
            calendarBaseLabel = UILabel()
            
            //X座標の値をCGFloat型へ変換して設定
            calendarBaseLabel.frame = CGRect(
                x: CGFloat((designer.calendarLabelIntervalX ?? 0) + tempCalendarLabelX * (i % calendarLabelCount)),
                y: CGFloat(designer.calendarLabelY ?? 0),
                width: CGFloat(designer.calendarLabelWidth ?? 0),
                height: CGFloat(designer.calendarLabelHeight ?? 0)
            )
            
            if(i == 0){
                //日曜、大安の場合は赤色を指定
                calendarBaseLabel.textColor = designer.baseRed
                
            }else if(i == calendarLabelCount-1){
                //土曜、仏滅の場合は青色を指定
                calendarBaseLabel.textColor = designer.baseBlue
                
            }else{
                //その他の場合は灰色を指定
                calendarBaseLabel.textColor = designer.baseNormal
                
            }
            
            //曜日ラベルの配置
            calendarBaseLabel.text = String(monthName[i] as NSString)
            calendarBaseLabel.textAlignment = .center
            calendarBaseLabel.font = UIFont(name: "System", size: CGFloat(designer.calendarLabelFontSize ?? 0))
            self.view.addSubview(calendarBaseLabel)
            
            mArrayForLabel.add(calendarBaseLabel) //削除用（2016/02/11）
        }
        

    }
    
    /**
     カレンダーを生成する関数
     - parameters: mode（アニメーションのモード）0:前の月へ 1:次の月へ 2:カレンダーモード切替
     */
    func generateCalendar(mode: Int){
        //func generateCalendar(){
        
        calendarManager.setupGenerateCalendar()
        
        //イマを刻むコンポーネント（2016/02/07）
        //let nowCalendar: NSCalendar = NSCalendar.currentCalendar()
        //let nowComps = nowCalendar.components([.Year, .Month, .Day], fromDate: NSDate())
        
        var tagNumber = 1   //タグナンバー（日数）
        
        let reviseX:Double =  7.0 / Double(calendarManager.numberOfDaysInWeek)
        var tempCalendarX = Int(ceil(Double(designer.calendarX ?? 0) * reviseX))
        
        if(calendarManager.calendarMode == -1){
            tempCalendarX += 1      //微調整
        }
        
        //numberOfDaysInWeek×6個（36個 or 42個）のボタン要素を作る
        for i in 0...calendarManager.total-1{
            
            //配置場所の定義
            let positionX   = (designer.calendarIntervalX ?? 0) + tempCalendarX * (i % calendarManager.numberOfDaysInWeek)   //Intervalは間隔ではなくて初期値でしたorz
            let positionY   = (designer.calendarIntervalY ?? 0) + (designer.calendarY ?? 0) * (i / calendarManager.numberOfDaysInWeek)
            let buttonSizeX = designer.calendarSize ?? 0;
            let buttonSizeY = designer.calendarSize ?? 0;

            //ボタンをつくる
            let button: UIButton = UIButton()
            button.frame = CGRect(
                x: CGFloat(positionX),
                y: CGFloat(positionY),
                width: CGFloat(buttonSizeX ?? 0),
                height: CGFloat(buttonSizeY ?? 0)
            )

            //ボタン配置アニメーション（2016/08/16）
            let duration:Double = 0.3
            switch mode {
                case 0:
                    //初期表示＆カレンダーモード切替はクルッと回る（2016/02/15）
                    UIView.animate(withDuration: duration, animations: { () -> Void in
                        button.transform = CGAffineTransform(scaleX: -1, y: 1)
                        },
                        completion: {(finished) -> Void in
                            UIView.animate(withDuration: duration, animations: { () -> Void in
                                button.transform = CGAffineTransform.identity
                            })
                        }
                    )
                    break
                default:
                    //前月＆後月の場合は左右にスライドする
                    let appearX: CGFloat = mode == 1 ? CGFloat(designer.screenWidth + 60) : -60.0
                    button.layer.position = CGPoint(x: appearX, y: CGFloat(positionY + (buttonSizeY ?? 0)/2))
                    UIView.animate(withDuration: duration, animations: {() -> Void in
                        //移動先の座標を指定する
                        //button.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
                        button.center = CGPoint(x: positionX + (buttonSizeX ?? 0)/2, y: positionY + (buttonSizeY ?? 0)/2)
                        }, completion: {(finished) -> Void in
                    })
                    break
            }
            

            
            //TODO:
            

            //ボタンの初期設定をする
            if(i < calendarManager.dayOfWeek - 1){
                
                //日付の入らない部分はボタンを押せなくする
                button.setTitle("", for: .normal)
                button.isEnabled = false
                
            } else if (i == calendarManager.dayOfWeek - 1 || i < calendarManager.dayOfWeek + calendarManager.maxDay - 1){
                
                //日付の入る部分はボタンのタグを設定する（日にち）
//                button.setTitle(String(tagNumber), forState: .Normal)
                
                var strBtn :String = String(tagNumber) + " "
                
                var tmpComps: DateComponents = calendarManager.calendar.dateComponents([.year, .month, .day], from: Date())
                tmpComps.year = calendarManager.year
                tmpComps.month = calendarManager.month
                tmpComps.day = tagNumber
                
                var addDate:String = ""
                
                if(calendarManager.calendarMode == -1){ //旧暦モード
                    
                    if(!calendarManager.nowLeapMonth){  //通常月
                        tmpComps = converter.convertForGregorianCalendar(dateArray: [calendarManager.year, calendarManager.month, tagNumber, 0])
                        
                    } else {    //閏月
                        tmpComps = converter.convertForGregorianCalendar(dateArray: [calendarManager.year, -calendarManager.month, tagNumber, 0])
                    }
                    
                    addDate += "\(tmpComps.month ?? 0)/\(tmpComps.day ?? 0)"
                    
                } else {
                    var array:[Int] = converter.convertForAncientCalendar(comps: tmpComps)
                    
                    if(array[3] == -1){
                        addDate += "閏"
                    }
                    
                    addDate += "\(array[1])/\(array[2])"
                }
            
                
                strBtn += addDate
                
                button.setAttributedTitle(designer.setFont(strBtn, addDate: addDate), for: .normal)
                
                /*当日については、枠線で色をつける（旧暦に対応していないため、一旦保留）
                if(nowComps.year == year && nowComps.month == month && nowComps.day == tagNumber){
                    //button.setTitleColor(UIColor.redColor(), forState: .Normal)
                    button.layer.borderColor = UIColor(
                        red: CGFloat(0.993), green: CGFloat(0.989), blue: CGFloat(0.856), alpha: CGFloat(0.9)).CGColor
                    button.layer.borderWidth = 1
                }*/
                
                button.tag = tagNumber
                
                //旧暦の場合背景画像（月）を設定
                if(calendarManager.calendarMode == -1){
                    // 旧暦日付の月齢を計算
                    // 一覧表示では旧暦日(tagNumber)から直接月齢を計算（伝統的方法）
                    let traditionalMoonAge = calendarManager.calcMoonAgeForLunarDay(lunarDay: tagNumber)
                    
                    print("一覧表示 - 選択日付情報:")
                    print("- 旧暦日: \(tagNumber)日")
                    print("- 伝統的月齢（旧暦日-1）: \(traditionalMoonAge)")
                    
                    // 詳細なデバッグのために他の計算方法も比較
                    var tmpDate = DateComponents()
                    tmpDate.year = calendarManager.year
                    tmpDate.month = calendarManager.month
                    tmpDate.day = tagNumber
                    
                    // 一時的に日付を設定して月齢計算
                    let savedComps = calendarManager.comps
                    calendarManager.comps = tmpDate
                    
                    // 複数の計算方法による結果の比較
                    let simpleAge = calendarManager.calcMoonAgeSimple()
                    let astroAge = calendarManager.calcMoonAgeAstronomical()
                    let highPrecisionAge = calendarManager.calcMoonAgeHighPrecision()
                    
                    calendarManager.comps = savedComps  // 元に戻す
                    
                    print("月齢計算比較（一覧表示）:")
                    print("- 伝統的計算（旧暦日-1）: \(traditionalMoonAge)")
                    print("- 簡易計算: \(simpleAge)")
                    print("- 天文学的計算: \(astroAge)")
                    print("- 高精度計算: \(highPrecisionAge)")
                    
                    // 一覧表示では伝統的な月齢計算を使用
                    let moonAge = traditionalMoonAge
                    
                    button.setBackgroundImage(UIImage(named:"moon\(tagNumber).png"), for: .normal)
                }
                
                tagNumber += 1
                
            } else if (i == calendarManager.dayOfWeek + calendarManager.maxDay - 1 || i < calendarManager.total){
                
                //日付の入らない部分はボタンを押せなくする
                button.setTitle("", for: .normal)
                button.isEnabled = false
                
            }
            
            //ボタンの配色の設定
            //@remark:このサンプルでは正円のボタンを作っていますが、背景画像の設定等も可能です。
            if(calendarManager.calendarMode == 1){
                //通常モード（新暦）
                if(i % calendarManager.numberOfDaysInWeek == 0){
                    //日曜、大安
                    calendarBackGroundColor = designer.baseRed
                    
                } else if (i % calendarManager.numberOfDaysInWeek == calendarManager.numberOfDaysInWeek-1){
                    //土曜、仏滅
                    calendarBackGroundColor = designer.baseBlue
                    
                } else {
                    //それ以外（通常）
                    calendarBackGroundColor = designer.baseNormal
                    
                }
            
            } else {
                //旧暦モード
                if(button.isEnabled){
                    calendarBackGroundColor = designer.baseBlack
                    
                } else {
                    calendarBackGroundColor = designer.baseDarkGray
                }

            }
            
            //ボタンの背景デザインを決定する
            button.backgroundColor = calendarBackGroundColor    //ここに置かないと色がずれちゃうよ。
                
            //フォント
            button.titleLabel!.font = UIFont(name: "System", size: CGFloat(designer.calendarFontSize ?? 0))
            
            //旧暦モードの場合は、日付を丸くする。
            if(calendarManager.calendarMode == -1){
                button.layer.cornerRadius = CGFloat(designer.buttonRadius ?? 0)
            }
            
            //配置したボタンに押した際のアクションを設定する
            button.addTarget(self, action: #selector(ViewController.buttonTapped(_:)), for: .touchUpInside)
            
            //ボタンを配置する
            self.view.addSubview(button)
            
            //ボタンが配置された時のアニメーション
            /*
            UIView.animateWithDuration(duration, animations: { () -> Void in
                button.transform = transform
                })
                {(Bool) -> Void in
                    UIView.animateWithDuration(duration, animations: { () -> Void in
                        button.transform = CGAffineTransformIdentity
                        })
                        { (Bool) -> Void in
                    }
            }*/
            mArray.add(button)
    
        }
        
        //タイトル表記を設定する
        setupCalendarTitleLabel()
        
        //ボタンを活性・非活性にする
        buttonNotActive()
        
        //アニメーション（2016/08/16）
//        let effect = UIBlurEffect(style: UIBlurEffectStyle.Light)
//        let effectView = UIVisualEffectView(effect: effect)
//        self.view.addSubview(effectView)
//        UIView.animateWithDuration(duration, animations: {() -> Void in
//            //移動先の座標を指定する
//            self.view.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
//            }, completion: {(Bool) -> Void in
//        })
        
    }
    
    /** タイトル表記を設定する関数 */
    func setupCalendarTitleLabel() {

        //self.navigationItem.title = "\(year)年"
        
        calendarManager.setupCalendarTitleLabel()
        
        /*
        var calendarTitle: String;
        var jpnMonth = ["睦月", "如月", "弥生", "卯月", "皐月", "水無月", "文月", "葉月", "長月", "神無月", "霜月", "師走"]
        calendarTitle = "\(calendarManager.month)月"

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
 */
        
        calendarBar.text = calendarManager.calendarBarTitle
        presentMode.text = calendarManager.presentMode
        
    }
    
    /** 前の月を取得する関数 */
    func setupPrevCalendarData() {
        calendarManager.setupPrevCalendarData()
    }
    
    /** 次の月を取得する関数 */
    func setupNextCalendarData() {
        calendarManager.setupNextCalendarData()
    }
    
    /** カレンダー切り替え時に呼び出される関数 */
    func setupAnotherCalendarData(){
        calendarManager.setupAnotherCalendarData()
        //カレンダーのデザインを変更
        setupCalendarDesign()
    }

    /** デザインを設定・変更する関数（2016/05/05） #5 */
    func setupCalendarDesign(){
        //カレンダーモードに応じて色をセット
        designer.setColor(calendarManager.calendarMode)
        //背景
        self.view.backgroundColor = designer.backgroundColor
        //カレンダバー
        self.calendarBar.backgroundColor = designer.calendarBarBgColor
        //ナビゲーションバー
        self.navigationItem.titleView?.tintColor = designer.navigationTintColor
        self.navigationController?.navigationBar.titleTextAttributes = designer.navigationTextAttributes
        self.navigationController?.navigationBar.barTintColor = designer.navigationBarTintColor
        //「前月」「次月」ボタン
        self.prevMonthButton.backgroundColor = designer.prevMonthButtonBgColor
        self.nextMonthButton.backgroundColor = designer.nextMonthButtonBgColor
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
    
    //表示されている曜日オブジェクトを一旦削除する関数
    func removecalendarBaseLabel(){
        
        //ビューから曜日オブジェクトを削除する
        for i in 0..<mArrayForLabel.count {
            (mArrayForLabel[i] as AnyObject).removeFromSuperview()
        }
        
        mArrayForLabel.removeAllObjects()
        
    }
    
    //現在のカレンダーをセットアップする関数
    func setupCurrentCalendar() {
        
        calendarManager.setupCurrentCalendarData()
        generateCalendar(mode: 0)
        setupCalendarTitleLabel()
    }
    
    //カレンダーボタンをタップした時のアクション
    @objc func buttonTapped(_ button: UIButton){
        // コンソール表示
        //print("\(calendarManager.year)年\(calendarManager.month)月\(button.tag)日が選択されました！")
        calendarManager.day = button.tag
        performSegue(withIdentifier: "toScheduleView", sender: self)
        
    }
    
    //前の月のボタンを押した際のアクション
    @IBAction func getPrevMonthData(_ sender: UIButton) {
        prevCalendarSettings()
    }
    
    //次の月のボタンを押した際のアクション
    @IBAction func getNextMonthData(_ sender: UIButton) {
        nextCalendarSettings()
    }
    
    //左スワイプ（ナチュラル時は右スワイプ）で前月を表示
    @IBAction func swipePrevCalendar(_ sender: UISwipeGestureRecognizer) {
        if(scrollNatural){
            nextCalendarSettings()
        } else {
            prevCalendarSettings()
        }
    }
    
    //右スワイプ（ナチュラル時は左スワイプ）で次月を表示
    @IBAction func swipeNextCalendar(_ sender: UISwipeGestureRecognizer) {
        if(scrollNatural){
            prevCalendarSettings()
        } else {
            nextCalendarSettings()
        }
    }
    
    // モードを切り替えるメソッド
    @IBAction func changeCalendarMode(_ sender: UIBarButtonItem){
        calendarManager.calendarMode = calendarManager.calendarMode * -1

        removeCalendarButtonObject()
        setupAnotherCalendarData()
        removecalendarBaseLabel()   //曜日のラベルを全削除
        setupCalendarLabel()        //曜日のラベルを作成
        generateCalendar(mode: 0)
    }
    
    //前月を表示するメソッド
    func prevCalendarSettings() {
        if(calendarManager.year > Constants.minYear){
            removeCalendarButtonObject()
            setupPrevCalendarData()
            generateCalendar(mode: -1)
        }
    }
    
    //次月を表示するメソッド
    func nextCalendarSettings() {
        if(calendarManager.year < Constants.maxYear){
            removeCalendarButtonObject()
            setupNextCalendarData()
            generateCalendar(mode: 1)
        }
    }
    
    //ボタンを活性・非活性にする（#51）
    func buttonNotActive(){
 
        if(calendarManager.year >= Constants.maxYear){
            //上限を上回る場合はこれ以上進めないようにボタンを非活性にする
            nextMonthButton.isEnabled = false
            nextMonthButton.alpha = 0.5
        } else if(calendarManager.year <= Constants.minYear){
            //下限を下回る場合はこれ以上戻れないようにボタンを非活性にする
            prevMonthButton.isEnabled = false
            prevMonthButton.alpha = 0.5
        } else {
            //必要に応じてprevMonthButtonを復活させる
            if(!prevMonthButton.isEnabled){
                prevMonthButton.isEnabled = true
                prevMonthButton.alpha = 1.0
            }
            //必要に応じてnextMonthButtonを復活させる
            if(!nextMonthButton.isEnabled){
                nextMonthButton.isEnabled = true
                nextMonthButton.alpha = 1.0
            }
        }

    }
    
    /**
     認証ステータスを取得
     **/
    func getAuthorization_status() -> Bool {
        
        // ステータスを取得
        let status: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
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
            
        @unknown default:
            print("error - unknown status")
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
            calendarManager.eventStore.requestAccess(to: EKEntityType.event, completion: {
                (granted, error) -> Void in
                
                // 許可を得られなかった場合アラート発動
                if granted {
                    return
                }
                else {
                    
                    // メインスレッド 画面制御.非同期.
                    DispatchQueue.main.async { () -> Void in
                        
                        // アラート作成
                        let myAlert = UIAlertController(title: "許可されませんでした", message: "Privacy->App->Reminderで変更してください", preferredStyle: UIAlertController.Style.alert)
                        
                        // アラートアクション
                        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                        myAlert.addAction(okAction)
                        
                    }
                }
            })
        }
    }
    
    //画面遷移時に呼ばれるメソッド
    /* 2016/07/13 CalendarManagerですべて持つためコメントアウト
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        switch (segue.identifier)! {
            case "toScheduleView":
                /*
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
                */
                break
            
            case "toUserConfigView":
                break
            
            default:
                break
        }
        
    }
     */
    
    // 設定ボタンをタップした時の処理
    @objc func toUserConfig(){
        performSegue(withIdentifier: "toUserConfigView", sender: self)
    }
    
    // ステータスバーを黒くする
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // どのクラスにもあるメソッド Memory監視？
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
