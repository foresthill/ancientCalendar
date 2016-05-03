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
    
    // segueで渡す時の変数
    var calNum: Int!
    
    // テーブルビュー（2015/12/23）
    @IBOutlet var myTableView :UITableView!
    
    //引き渡された日時（2016/01/29）
    var year: Int!
    var month: Int!
    var day: Int!
    
    //遷移先の画面（メニューフラグ）
    var menuFlg: Int!
    
    //EKEventStore外出し（2016/04/02）
    var eventStore: EKEventStore!
    
    //旧暦時間を受け取るコンポーネント
    var ancientYear: Int!
    var ancientMonth: Int!
    var ancientDay: Int!
    
    //カレンダーモード（通常：1 旧暦：-1）
    var calendarMode: Int!
    
    //閏月かどうか
    var isLeapMonth:Int! //閏月の場合は-1（2016/02/06）
    
    //旧暦カレンダー変換エンジン外出し（2016/04/17）
    var converter: AncientCalendarConverter2!
    
    //カレンダー外出し
    var calendar: NSCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var comps: NSDateComponents = NSDateComponents()

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
        fetchEvent(comps)
        
        //タイトル
        setScheduleTitle(comps)

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
        
        //タイトル
        //setTitle(year, inMonth: month, inDay: day)
        
        //編集ボタンの配置
        navigationItem.rightBarButtonItem = editButtonItem()
        
        //ツールバー非表示（2016/01/30）
        self.navigationController!.toolbarHidden = true
        
        //カレンダー初期化
        calendar = NSCalendar.currentCalendar()
   
    }
    
    //本日1日分のイベントをフェッチするメソッド
    func fetchEvent(inComps: NSDateComponents){
        //イベントをフェッチする（メソッドとして外出し？）
        // NSCalendarを生成
        let calendar: NSCalendar = NSCalendar.currentCalendar() //新たにインスタンス化しないとダメ
        
        // 終了日（一日後）コンポーネントの作成（2016/04/15：year→svc.yearに修正）
//        let inComps: NSDateComponents = NSDateComponents()
//        inComps.year = year
//        inComps.month = month
//        inComps.day = day
        
        let SelectedDay: NSDate = calendar.dateFromComponents(inComps)!
        
        inComps.day += 1
        
        let oneDayFromSelectedDay: NSDate = calendar.dateFromComponents(inComps)!
        
        // イベントストアのインスタントメソッドで述語を生成
        var predicate = NSPredicate()
        
        predicate = eventStore.predicateForEventsWithStartDate(SelectedDay, endDate: oneDayFromSelectedDay, calendars: nil)
        
        // 選択された一日分をフェッチ
        events = eventStore.eventsMatchingPredicate(predicate)
        
        inComps.day -= 1    //かっこ悪りぃ。。inCompsはメソッド内だけでないの？ポインタ渡してるのか。。
    }
    
    //タイトルを設定して表示するメソッド
//    func setTitle(inYear:Int, inMonth:Int, inDay:Int){
    func setScheduleTitle(inComps: NSDateComponents){
        
        var ancientDate:[Int] = converter.convertForAncientCalendar(inComps)
        ancientYear = ancientDate[0]
        ancientMonth = ancientDate[1]
        ancientDay = ancientDate[2]
        isLeapMonth = ancientDate[3]
    
        var ancientMonthStr:String = String(ancientMonth)

        if(isLeapMonth < 0){
            ancientMonthStr = "閏\(ancientMonth)"
        }
        
        if(calendarMode == 1){
            //新暦モード
            self.navigationItem.title = "\(inComps.year)年\(inComps.month)月\(inComps.day)日"
            self.navigationItem.prompt = "（旧暦：\(ancientYear)年\(ancientMonthStr)月\(ancientDay)日）"
        } else {
            //旧暦モード
            self.navigationItem.title = "\(ancientYear)年\(ancientMonthStr)月\(ancientDay)日"
            self.navigationItem.prompt = "（新暦：\(inComps.year)年\(inComps.month)月\(inComps.day)日）"
        }
        
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

        let df:NSDateFormatter = NSDateFormatter()
        let df2:NSDateFormatter = NSDateFormatter()
        //df.dateFormat = "yyyy/MM/dd hh:mm"
        df.dateFormat = "hh:mm(yyyy/MM/dd)"
        df2.dateFormat = "hh:mm"

//        let startDateComps:NSDateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: events[indexPath.row].startDate)
//        let endDateComps:NSDateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: events[indexPath.row].endDate)
        
//        let calendar = NSCalendar.init(identifier: "a")
        let startDate = events[indexPath.row].startDate
        let endDate = events[indexPath.row].endDate
        
        var detailText:String
        
        if(calendar!.isDate(startDate, inSameDayAsDate: endDate)){
            //同日の場合は時間のみ表示
            detailText = "\(df2.stringFromDate(events[indexPath.row].startDate)) - \(df2.stringFromDate(events[indexPath.row].endDate))"
        } else {
            //別日の場合は日付も表示
            detailText = "\(df2.stringFromDate(events[indexPath.row].startDate)) - \(df.stringFromDate(events[indexPath.row].endDate))"
        }
        
        cell.detailTextLabel?.text = detailText

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
        var eventEditController = EKEventEditViewController.init()
        
        eventEditController.eventStore = eventStore
        eventEditController.editViewDelegate = self
        
        if(event != nil){
            eventEditController.event = event
        }

        self.presentViewController(eventEditController, animated: true, completion: nil)
    }
    
    //EditEventViewControllerを閉じた時に呼ばれるメソッド（必須）
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction){
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //作成したイベントの日時に戻るように改修（2016/04/16）　※そもそもSaved以外はリロードする必要ないんじゃん。。。※Deletedがきになる
        if(action == EKEventEditViewAction.Saved){
            scheduleReload(controller.event!.startDate)
            self.myTableView.reloadData()
        }
    }
    
    func scheduleReload(startDate:NSDate){
        // NSCalendarを生成
        //let calendar: NSCalendar = NSCalendar.currentCalendar()
        
        // ユーザのカレンダーを取得
        //var myEventCalendars = eventStore.calendarsForEntityType(EKEntityType.Event)  //不要？（2016/04/02）
        
        var comps: NSDateComponents = NSDateComponents()

        // 作成したイベントの日時に戻るように改修（2016/04/16）
        comps = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: startDate)
        //setTitle(comps.year, inMonth: comps.month, inDay: comps.day)
        setScheduleTitle(comps)
        
        // イベントをフェッチ
        fetchEvent(comps)
        
        /*
        
        let SelectedDay: NSDate = myCalendar.dateFromComponents(comps)!
        
        comps.day += 1
        
        
        let oneDayFromSelectedDay: NSDate = myCalendar.dateFromComponents(comps)!
        
        // イベントストアのインスタントメソッドで述語を生成
        var predicate = NSPredicate()
        
        predicate = eventStore.predicateForEventsWithStartDate(SelectedDay, endDate: oneDayFromSelectedDay, calendars: nil)
        
        // 選択された一日分をフェッチ
        events = eventStore.eventsMatchingPredicate(predicate)
 */
        
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
                eventStore.eventWithIdentifier(events[index].eventIdentifier)
                try eventStore.removeEvent(events[index], span: EKSpan.ThisEvent)
                print("Deleted.")
            } catch _{
                print("not Deleted(1).")
            }
        case .Denied:
            print("Access denied")
        case .NotDetermined:
            eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
                //[weak self](granted:Bool, error:NSError!) -> Void in
                granted, error in
                if granted {
                    do{
                        try self.eventStore.removeEvent(self.events[index], span: EKSpan.ThisEvent)
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


