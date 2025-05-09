//
//  ScheduleView.swift
//  スケジュール一覧画面
//
//  Created by Morioka Naoya on H27/07/29.
//  Copyright (c) 2016 foresthill. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import EventKitUI   //EKEventEditViewController

class ScheduleViewController: UIViewController, EKEventEditViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // Tableで使用する配列を設定する
    var events: [EKEvent]!
    
    // テーブルビュー（2015/12/23）
    @IBOutlet var myTableView :UITableView!
    
    //旧暦カレンダー変換エンジン外出し（2016/04/17）
    //var converter: AncientCalendarConverter2!

    //イベント新規作成フラグ（2016/05/24）
    var addNewEventFlag = false
    
    /** CalendarManagerクラス（シングルトン）（2016/07/13）*/
    let calendarManager: CalendarManager = CalendarManager.sharedInstance
    
    //デザイナークラス（シングルトン）
    var designer: Designer!

    //表示
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var moonName: UILabel!
    @IBOutlet weak var moonAge: UILabel!
    @IBOutlet weak var moonImage: UIImageView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    //編集ボタン
    @IBOutlet weak var editEventButton: CustomButton!

    /** 初期化処理 */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("詳細画面初期化開始 - 日付情報:")
        print("初期化前 - CalendarManager状態:")
        print("現在のモード: \(calendarManager.calendarMode == 1 ? "新暦" : "旧暦")")
        print("年月日: \(calendarManager.year)年\(calendarManager.month)月\(calendarManager.day)日")
        print("旧暦日付: \(calendarManager.ancientYear ?? 0)年\(calendarManager.ancientMonth ?? 0)月\(calendarManager.ancientDay ?? 0)日")
        
        //初期化
        calendarManager.initScheduleViewController()
        
        print("初期化後 - CalendarManager状態:")
        print("現在のモード: \(calendarManager.calendarMode == 1 ? "新暦" : "旧暦")")
        print("年月日: \(calendarManager.year)年\(calendarManager.month)月\(calendarManager.day)日")
        print("旧暦日付: \(calendarManager.ancientYear ?? 0)年\(calendarManager.ancientMonth ?? 0)月\(calendarManager.ancientDay ?? 0)日")
        
        //フェッチ
        //events = calendarManager.fetchEvent(calendarManager.comps)
        events = calendarManager.fetchEvent()
        
        //デザイナークラス（シングルトン）
        designer = Designer.sharedInstance
        
        //デザインを設定
        setupCalendarDesign()
        
        //タイトルの設定
        setScheduleTitle()

        // Cell名の登録を行う
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DateSourceの設定をする
        myTableView.dataSource = self
        
        // Delegateを設定する
        myTableView.delegate = self
        
        // Cellの高さを可変にする
        myTableView.estimatedRowHeight = 80
        myTableView.rowHeight = UITableViewAutomaticDimension
        
        // Viewに追加する
        self.view.addSubview(myTableView)
        
        // タイトル
        //setTitle(year, inMonth: month, inDay: day)
        
        // 編集ボタンの配置
        //navigationItem.rightBarButtonItem = editButtonItem()
        
        // ツールバー非表示（2016/01/30）
        //self.navigationController!.toolbarHidden = true
    }
    
    /** タイトルをセットする */
    func setScheduleTitle() {
        //文言の指定
        calendarManager.setScheduleTitle()
        
        //タイトルの設定
        self.navigationItem.title = calendarManager.scheduleBarTitle
        //self.navigationItem.prompt = calendarManager.scheduleBarPrompt
        
        print("詳細画面情報 - CalendarManager状態:")
        print("現在のモード: \(calendarManager.calendarMode == 1 ? "新暦" : "旧暦")")
        print("新暦日付: \(calendarManager.year)年\(calendarManager.month)月\(calendarManager.day)日")
        print("旧暦日付: \(calendarManager.ancientYear ?? 0)年\(calendarManager.ancientMonth ?? 0)月\(calendarManager.ancientDay ?? 0)日")
        
        // 旧暦日付に基づく月齢計算と表示（伝統的な方法）
        let dayNumber: Int
        
        if calendarManager.calendarMode == 1 {
            // 新暦モード: 旧暦の日付を取得
            dayNumber = calendarManager.ancientDay ?? 15
        } else {
            // 旧暦モード: 現在の日を使用
            dayNumber = calendarManager.day
        }
        
        print("詳細画面 - 選択された日付情報:")
        print("- 旧暦日: \(dayNumber)日")
        
        // 1. 旧暦日からの伝統的な月齢計算（旧暦1日=新月、旧暦15日=満月の関係）
        let traditionalMoonAge = calendarManager.calcMoonAgeForLunarDay(lunarDay: dayNumber)
        
        // 2. 天文学的月齢計算（各計算方法で比較）
        // 計算のために一時的に日付を設定
        var tmpDate = DateComponents()
        if calendarManager.calendarMode == 1 {
            tmpDate.year = calendarManager.ancientYear
            tmpDate.month = calendarManager.ancientMonth
        } else {
            tmpDate.year = calendarManager.year
            tmpDate.month = calendarManager.month
        }
        tmpDate.day = dayNumber
        
        // 計算前の状態を保存
        let savedComps = calendarManager.comps
        calendarManager.comps = tmpDate
        
        // 3種類の計算方法による月齢を計算
        let simpleAge = calendarManager.calcMoonAgeSimple()
        let astroAge = calendarManager.calcMoonAgeAstronomical()
        let highPrecisionAge = calendarManager.calcMoonAgeHighPrecision()
        
        // 元のcompsに戻す
        calendarManager.comps = savedComps
        
        print("月齢計算比較:")
        print("- 伝統的計算（旧暦日-1）: \(traditionalMoonAge)")
        print("- 簡易計算: \(simpleAge)")
        print("- 天文学的計算: \(astroAge)")
        print("- 高精度計算: \(highPrecisionAge)")
        
        // このアプリでは伝統的な月齢表示（旧暦日に基づく）を使用
        let calculatedMoonAge = traditionalMoonAge
        
        // 表示用文言をセット
        self.dateLabel.text = calendarManager.scheduleBarTitle
        self.subDateLabel.text = calendarManager.scheduleBarPrompt
        self.moonAge.text = String(format: "%.1f", calculatedMoonAge)
        
        // 月齢の名前を表示（従来のmoonName配列を使用）
        let moonAgeIndex = min(max(Int(floor(calculatedMoonAge)), 0), 29)
        let moonPhaseName = moonAgeIndex < calendarManager.moonName.count && !calendarManager.moonName[moonAgeIndex].isEmpty 
                          ? calendarManager.moonName[moonAgeIndex] 
                          : "満月"
        
        self.moonName.text = moonPhaseName
        
        print("月相情報: 月齢=\(calculatedMoonAge), 月相名=\(moonPhaseName)")
        
        // 日付が有効な範囲内であることを確認
        let safeDay = max(min(dayNumber, 30), 1) // 1〜30の範囲内に収める
        
        print("月画像設定: 選択された日付: \(dayNumber), 安全な日付範囲: \(safeDay), 計算された月齢: \(calculatedMoonAge)")
        self.moonImage.image = UIImage(named:"moon\(safeDay)_90x90.png")
        print("月画像設定: moon\(safeDay)_90x90.png を表示")
        
    }
    
    /** デザインを設定・変更する関数（2016/05/05） #5 */
    func setupCalendarDesign(){
        //カレンダーモードに応じて色をセット
        designer.setColor(calendarManager.calendarMode)
        
        //背景
        self.view.backgroundColor = designer.backgroundColor
        
        //ナビゲーションバー
        self.navigationItem.titleView?.tintColor = designer.navigationTintColor
        self.navigationController?.navigationBar.titleTextAttributes = designer.navigationTextAttributes
        self.navigationController?.navigationBar.barTintColor = designer.navigationBarTintColor
        
        //表示系（色）
        self.dateLabel.textColor = designer.navigationTintColor
        self.subDateLabel.textColor = designer.navigationTintColor
        self.titleLabel.textColor = designer.navigationTintColor
        self.detailTextView.textColor = designer.navigationTintColor
        self.moonName.textColor = designer.navigationTintColor
        self.moonAge.textColor = designer.navigationTintColor
    }
    
    
    /** 以下、更新・削除処理を実施するメソッド **/
    
    /**
    tableViewメソッド - Cellがタップ（選択）された際に呼び出される
    **/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        //イベントを編集する
        editEvent(event: events[indexPath.row])
        
        //選択を解除する
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /**
    tableViewメソッド - Cellの総数を返す
    **/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    /**
     * スタブから作られたメソッド（ダミー）
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cellの.を取得する
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyCell")
        
        // Cellに値を設定する
        cell.textLabel?.text = events[indexPath.row].title
        cell.detailTextLabel?.text = calendarManager.tableViewDetailText(
            startDate: events[indexPath.row].startDate, endDate: events[indexPath.row].endDate)

        // 表示列数
        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.numberOfLines = 0 //2016/04/21 0にすることで制限なし表示（「…」とならない）#29
        cell.backgroundColor = UIColor.clear //背景色を透明に（ないとだめ！）
        
        // 文字色
        cell.textLabel?.textColor = designer.navigationTintColor
        cell.detailTextLabel?.textColor = designer.navigationTintColor
        
        return cell
    }
    
    /**
     tableViewメソッド - 削除可能なセルのindexPath
     */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /**
     tableViewメソッド - 実際に削除された時の処理を実装する
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 実データ削除メソッド
        removeEvent(index: indexPath.row)
        
        // 先にデータを更新する
        events.remove(at: indexPath.row)   // これがないと、絶対にエラーが出る
        
        // それからテーブルの更新
        tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: UITableView.RowAnimation.fade)
    }
    
    //Editボタンを押した時の処理
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        myTableView.isEditing = editing
        
        //編集中の時のみaddButtonをナビゲーションバーの左に表示する
        if editing {
            //編集中
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCell))
            self.navigationItem.setLeftBarButton(addButton, animated: true)
        } else {
            //通常モード
            self.navigationItem.setLeftBarButton(nil, animated: true)
        }
    }
    
    // メソッドの宣言
    @objc func addCell(_ sender: Any) {
        editEvent(event: nil)
    }
    
    //モーダルでEditEventViewControllerを呼び出す
    func editEvent(event:EKEvent?){
        let eventEditController = EKEventEditViewController.init()
        
        eventEditController.eventStore = calendarManager.eventStore
        eventEditController.editViewDelegate = self
        
        if(event != nil){
            eventEditController.event = event
            addNewEventFlag = false
        
        } else {
            let newEvent = EKEvent.init(eventStore: calendarManager.eventStore)
            if let date = calendarManager.calendar.date(from: calendarManager.comps) {
                newEvent.startDate = date
                newEvent.endDate = date
            } else {
                // コンポーネントから日付が作成できない場合は現在の日付を使用
                newEvent.startDate = Date()
                newEvent.endDate = Date()
            }
            eventEditController.event = newEvent
            addNewEventFlag = true
        }

        self.present(eventEditController, animated: true, completion: nil)
    }
    
    //EditEventViewControllerを閉じた時に呼ばれるメソッド（必須）
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction){
        self.dismiss(animated: true, completion: nil)
        
        //作成したイベントの日時に戻るように改修（2016/04/16）　※そもそもSaved以外はリロードする必要ないんじゃん。。。※Deletedがきになる
        switch action{
        case EKEventEditViewAction.saved:
            //イベントが保存された時（カレンダーで指定した開始日に戻るように）
            if let event = controller.event, let startDate = event.startDate {
                scheduleReload(startDate: startDate as NSDate)
            } else {
                // イベントがnilの場合は現在の日付を使用
                scheduleReload(startDate: Date() as NSDate)
            }
            break
        case EKEventEditViewAction.canceled:
            if(addNewEventFlag){
                do{
                    try calendarManager.eventStore.remove(controller.event!, span: EKSpan.thisEvent)
                } catch _{
                    //もし削除できなかったらゴミが溜まる。。考慮中。
                }
            }
        default:
            break
        }

        
    }
    
    /** スケジュールを再読込するメソッド */
    func scheduleReload(startDate: NSDate){
        
        // 作成したイベントの日時に戻るように改修（2016/04/16）
        calendarManager.comps = calendarManager.calendar.dateComponents([.year, .month, .day], from: startDate as Date)

        //タイトルを付け直す
        setScheduleTitle()
        
        // イベントをフェッチ
        //calendarManager.fetchEvent(calendarManager.comps)
        events = calendarManager.fetchEvent()
        
        //tableViewを更新
        self.myTableView.reloadData()
        
        print("Schedule reloaded for date: \(startDate)")
    }
    
    /** イベントをカレンダーから削除するメソッド */
    func removeEvent(index:Int){
        
        switch EKEventStore.authorizationStatus(for: EKEntityType.event){
            
        case .authorized:
            do{
                calendarManager.eventStore.event(withIdentifier: events[index].eventIdentifier)
                try calendarManager.eventStore.remove(events[index], span: EKSpan.thisEvent)
                print("Deleted.")
            } catch _{
                print("not Deleted(1).")
            }
            break
        case .denied:
            print("Access denied")
            break
        case .notDetermined:
            calendarManager.eventStore.requestAccess(to: EKEntityType.event, completion: {
                //[weak self](granted:Bool, error:NSError!) -> Void in
                granted, error in
                if granted {
                    do{
                        try self.calendarManager.eventStore.remove(self.events[index], span: EKSpan.thisEvent)
                    } catch _{
                        print("not Deleted(2).")
                    }
                    
                } else {
                    print("Access denied")
                }
            })
            break
        default:
            print("Case Default")
            break
        }
        
    }

    /** 「予定を追加」ボタンを押下されたときに呼ばれるメソッド */
    @IBAction func addEventButtonAction(_ sender: AnyObject) {
        editEvent(event: nil)
    }

    /** 「編集」ボタンを押下されたときに呼ばれるメソッド */
    @IBAction func editEventButtonAction(_ sender: AnyObject) {
        if(!self.myTableView.isEditing){
            //編集を開始する
            setEditing(true, animated: true)
            editEventButton.setTitle("完了", for: .normal)
        } else {
            setEditing(false, animated: true)
            editEventButton.setTitle("編集", for: .normal)
        }
    }
    
    /** ツールバーアクション（モード切替） */
    @IBAction func changeCalendarMode(_ sender: UIBarButtonItem) {
        print("カレンダーモード切替")
    }
    
    /** ツールバーアクション（前の日へ） */
    @IBAction func prevDayAction(_ sender: UIBarButtonItem) {
        print("前の日へ")
    }

    /** ツールバーアクション（次の日へ） */
    @IBAction func nextDayAction(_ sender: UIBarButtonItem) {
        print("次の日へ")
    }

    /** メモリ監視 */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


