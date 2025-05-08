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
        
        //初期化
        calendarManager.initScheduleViewController()
        
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
        
        //月齢の計算
        //calendarManager.calcMoonAge()
        let currentMoonAge = calendarManager.calcMoonAge(calendarManager.comps)
        calendarManager.moonAge = currentMoonAge  // 計算結果をプロパティに保存
        
        //表示する文言をセット
        self.dateLabel.text = calendarManager.scheduleBarTitle
        self.subDateLabel.text = calendarManager.scheduleBarPrompt
        self.moonAge.text = String(currentMoonAge)
        
        //月の画像
        let moonAgeNumber: Int = min(max(Int(floor(currentMoonAge)), 0), 29)
        if moonAgeNumber < calendarManager.moonName.count {
            self.moonName.text = calendarManager.moonName[moonAgeNumber]
            self.moonImage.image = UIImage(named:"moon\(moonAgeNumber)_90x90.png")
            print("Setting moon image to: moon\(moonAgeNumber)_90x90.png")
        } else {
            self.moonName.text = "満月"
            self.moonImage.image = UIImage(named:"moon15_90x90.png")
            print("Using default full moon image: moon15_90x90.png")
        }
        
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


