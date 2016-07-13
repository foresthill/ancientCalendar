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
    var converter: AncientCalendarConverter2!

    //イベント新規作成フラグ（2016/05/24）
    var addNewEventFlag = false
    
    /** CalendarManagerクラス（シングルトン）（2016/07/13）*/
    let calendarManager: CalendarManager = CalendarManager.sharedInstance

    /** 初期化処理 */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初期化
        calendarManager.initScheduleViewController()
        
        //フェッチ
        events = calendarManager.fetchEvent(calendarManager.comps)
        
        //タイトルの設定
        setScheduleTitle()

        // Cell名の登録を行う
        myTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
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
        navigationItem.rightBarButtonItem = editButtonItem()
        
        // ツールバー非表示（2016/01/30）
        self.navigationController!.toolbarHidden = true
    }
    
    /** タイトルをセットする */
    func setScheduleTitle() {
        //文言の指定
        calendarManager.setScheduleTitle()
        
        //タイトルの設定
        self.navigationItem.title = calendarManager.scheduleBarTitle
        self.navigationItem.prompt = calendarManager.scheduleBarPrompt
    }
    
    //画面遷移時に呼ばれるメソッド
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //EKEventEditViewController導入に伴うクラス削除により、メソッド処理なし
    }
    
    /** 以下、更新・削除処理を実施するメソッド **/
    
    /**
    Cellがタップ（選択）された際に呼び出される
    **/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        editEvent(events[indexPath.row])
    }
    
    /**
    Cellの総数を返す
    **/
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    /**
    Cellの内容を指定する
    **/
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Cellの.を取得する
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyCell")
        
        // Cellに値を設定する
        cell.textLabel?.text = events[indexPath.row].title
        cell.detailTextLabel?.text = calendarManager.tableViewDetailText(
            events[indexPath.row].startDate, endDate: events[indexPath.row].endDate)

        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.numberOfLines = 0 //2016/04/21 0にすることで制限なし表示（「…」とならない）#29
        
        return cell
    }

    //Editボタンを押した時の処理
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        myTableView.editing = editing
        
        //編集中の時のみaddButtonをナビゲーションバーの左に表示する
        if editing {
            //編集中
            let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addCell:")
            self.navigationItem.setLeftBarButtonItem(addButton, animated: true)
        } else {
            //通常モード
            self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        }
    }
    
    /*
    addButtonが押された時に呼び出される
    */
    func addCell(sender: AnyObject) {
        editEvent(nil)
        
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
            newEvent.startDate = calendarManager.calendar.dateFromComponents(calendarManager.comps)!
            newEvent.endDate = calendarManager.calendar.dateFromComponents(calendarManager.comps)!
            eventEditController.event = newEvent
            addNewEventFlag = true
        }

        self.presentViewController(eventEditController, animated: true, completion: nil)
    }
    
    //EditEventViewControllerを閉じた時に呼ばれるメソッド（必須）
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction){
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //作成したイベントの日時に戻るように改修（2016/04/16）　※そもそもSaved以外はリロードする必要ないんじゃん。。。※Deletedがきになる
        switch action{
        case EKEventEditViewAction.Saved:
            //イベントが保存された時
            scheduleReload(controller.event!.startDate)
            self.myTableView.reloadData()
            break
        case EKEventEditViewAction.Canceled:
            if(addNewEventFlag){
                do{
                    try calendarManager.eventStore.removeEvent(controller.event!, span: EKSpan.ThisEvent)
                } catch _{
                    //もし削除できなかったらゴミが溜まる。。考慮中。
                }
            }
        default:
            break
        }

        
    }
    
    /** スケジュールを再読込するメソッド */
    func scheduleReload(startDate:NSDate){
        
        // 作成したイベントの日時に戻るように改修（2016/04/16）
        calendarManager.comps = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: startDate)
        
        //タイトルを付け直す
        setScheduleTitle()
        
        // イベントをフェッチ
        calendarManager.fetchEvent(calendarManager.comps)
        
    }
    
    //削除可能なセルのindexPath
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //実際に削除された時の処理を実装する
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //実データ削除メソッド
        removeEvent(indexPath.row)
        
        //先にデータを更新する
        events.removeAtIndex(indexPath.row)   //これがないと、絶対にエラーが出る
        
        //それからテーブルの更新
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    //イベントをカレンダーから削除するメソッド
    func removeEvent(index:Int){
        
        switch EKEventStore.authorizationStatusForEntityType(EKEntityType.Event){
            
        case .Authorized:
            do{
                calendarManager.eventStore.eventWithIdentifier(events[index].eventIdentifier)
                try calendarManager.eventStore.removeEvent(events[index], span: EKSpan.ThisEvent)
                print("Deleted.")
            } catch _{
                print("not Deleted(1).")
            }
        case .Denied:
            print("Access denied")
        case .NotDetermined:
            calendarManager.eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
                //[weak self](granted:Bool, error:NSError!) -> Void in
                granted, error in
                if granted {
                    do{
                        try self.calendarManager.eventStore.removeEvent(self.events[index], span: EKSpan.ThisEvent)
                    } catch _{
                        print("not Deleted(2).")
                    }
                    
                } else {
                    print("Access denied")
                }
            })
        default:
            print("Case Default")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


