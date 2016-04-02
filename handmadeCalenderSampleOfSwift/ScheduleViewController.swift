//
//  ScheduleView.swift
//  handmadeCalenderSampleOfSwift
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
    var myItems: NSArray = []
    var myEvents: [EKEvent]!
    
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
    
    //外出し（2016/04/02）
    var eventStore: EKEventStore!
//    var eventEditViewDelegate: EKEventEditViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Viewのタイトルを設定
        self.title = "Calendar Events"
        
        // Status Barの高さを取得する
        let barHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        
        // Viewの高さと幅を取得する
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        // TableViewの生成する（status barの高さ分ずらして表示）
        //let myTableView: UITableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight)) //2015/12/23
        
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
        self.navigationItem.title = "\(year)年\(month)月\(day)日の予定"
        
        //編集ボタンの配置
        //navigationItem.leftBarButtonItem = editButtonItem()
        navigationItem.rightBarButtonItem = editButtonItem()
        
        //ツールバー非表示（2016/01/30）
        self.navigationController!.toolbarHidden = true
        
        //EKEventStoreを最初で宣言（2016/04/02）
        eventStore = EKEventStore.init()
   
    }

    
    //画面遷移時に呼ばれるメソッド
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //セゲエ用にダウンキャストしたScheduleViewControllerのインスタンス
        if(segue.identifier == "toAddNewEvent"){
            let ccvc = segue.destinationViewController as! CalendarChangeViewController
            
            //let eventStore:EKEventStore = EKEventStore() //外だし
            
            var newEvent = EKEvent(eventStore: eventStore)
            
            let df:NSDateFormatter = NSDateFormatter()
            //df.dateFormat = "yyyy/MM/dd"
            df.dateFormat = "yyyy年MM月dd日hh:mm"
            
            newEvent.startDate = df.dateFromString("\(year)年\(month)月\(day)日 01:00")!
            newEvent.endDate = df.dateFromString("\(year)年\(month)月\(day)日 02:00")!
            
            ccvc.myEvent = newEvent
            
        } else {
            let cdvc = segue.destinationViewController as! CalendarDetailViewController
        //変数を渡す
        cdvc.myEvent = myEvents[calNum]
        }
    }
    
    /** 以下、tableview系メソッド **/
    
    /**
    Cellがタップ（選択）された際に呼び出される
    **/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        print("Num: \(indexPath.row)")
        print("Value: \(myEvents[indexPath.row])")
        calNum = indexPath.row
        
        //一旦コメントアウト（2016/04/02）
//        performSegueWithIdentifier("toCalendarDetailView", sender: self)
        
        //EKEventEditViewController（2016/04/02）
        
        //editEvent(indexPath.row)
        editEvent(myEvents[indexPath.row])
        
    }
    
    /**
    Cellの総数を返す
    **/
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return myItems.count
        return myEvents.count
    }
    
    /**
    Cellの内容を指定する
    **/
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Cellの.を取得する
        //let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) //これだとdetailが取れない？
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyCell")
        
        // Cellに値を設定する
        cell.textLabel?.text = myEvents[indexPath.row].title

        let df:NSDateFormatter = NSDateFormatter()
        let df2:NSDateFormatter = NSDateFormatter()
        //df.dateFormat = "yyyy/MM/dd"
        df.dateFormat = "yyyy年MM月dd日 hh:mm"
        df2.dateFormat = "hh:mm"

        let detailText = "\(df2.stringFromDate(myEvents[indexPath.row].startDate))" + "\n - " + "\(df.stringFromDate(myEvents[indexPath.row].endDate))"
//        print("tmpは\(tmp)")
        
        cell.detailTextLabel?.text = detailText
        
//        print(myEvents[indexPath.row].startDate)
//        print(cell.detailTextLabel?.text)

        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.numberOfLines = 2
        
        return cell
    }

    //Editボタンを押した時の処理
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        myTableView.editing = editing
        
        //編集中の時のみaddButtonをナビゲーションバーの左に表示する
        if editing {
            print("編集中")
            let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addCell:")
            self.navigationItem.setLeftBarButtonItem(addButton, animated: true)
        } else {
            print("通常モード")
            self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        }
    }
    
    /*
    addButtonが押された時に呼び出される
    */
    func addCell(sender: AnyObject) {
        print("追加")
        
        //EditEventViewController（2016/04/02）
        //performSegueWithIdentifier("toAddNewEvent", sender: self)
        //let event:EKEvent = EKEvent()
        editEvent(nil)
        
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
        myEvents.removeAtIndex(indexPath.row)   //これがないと、絶対にエラーが出る

        //それからテーブルの更新
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    //イベントをカレンダーから削除するメソッド
    func removeEvent(index:Int){
        
//        let eventStore:EKEventStore = EKEventStore.init() //2016/04/02外だし
        
        
        print(myEvents[index].eventIdentifier)
        
        switch EKEventStore.authorizationStatusForEntityType(EKEntityType.Event){
        
        case .Authorized:
//            print(myEvents)
            print(myEvents[index])
            do{
                eventStore.eventWithIdentifier(myEvents[index].eventIdentifier)
                try eventStore.removeEvent(myEvents[index], span: EKSpan.ThisEvent)
                print("削除完了！")
            } catch _{
                print("イベント削除されていない。（１）")
            }
        case .Denied:
            print("Access denied")
        case .NotDetermined:
            eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
                //[weak self](granted:Bool, error:NSError!) -> Void in
                granted, error in
                if granted {
                    do{
                        try self.eventStore.removeEvent(self.myEvents[index], span: EKSpan.ThisEvent)
                    } catch _{
                        print("イベント削除されていない。（２）")
                    }

                } else {
                    print("Access denied")
                }
            })
        default:
            print("Case Default")
        }

    }
    
        
    /**
    reloadする

    func reloadTableView(){
        
    }
*/
    
    /**
    Cellの高さを指定する

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath)
        
        return
    }
    **/
     
     //モーダルでEditEventViewControllerを呼び出す
//    func editEvent(eventNum:Int){
    func editEvent(event:EKEvent?){
        var eventEditController = EKEventEditViewController.init()
        
        if(self.eventStore == nil){
            self.eventStore = EKEventStore.init()
        }
        
        eventEditController.eventStore = eventStore
        //        eventEditController.editViewDelegate = eventEditViewDelegate
        eventEditController.editViewDelegate = self
        
        
        
        if(event != nil){
//            eventEditController.event = myEvents[eventNum]
//            print("myEvent[\(eventNum)]=\(myEvents[eventNum])")
            eventEditController.event = event
//            eventEditController.eventStore = eventStore
        }
        
        print("eventEditController.event=\(eventEditController.event)")
        
        self.presentViewController(eventEditController, animated: true, completion: nil)
    }
    
    //EditEventViewControllerを消すためのメソッド
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction){
        self.dismissViewControllerAnimated(true, completion: nil)
        scheduleReload()
        self.myTableView.reloadData()
        
    }
    
    func scheduleReload(){
        // NSCalendarを生成
        let myCalendar: NSCalendar = NSCalendar.currentCalendar()
        
        // ユーザのカレンダーを取得
        var myEventCalendars = eventStore.calendarsForEntityType(EKEntityType.Event)
        
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
        
        predicate = eventStore.predicateForEventsWithStartDate(SelectedDay, endDate: oneDayFromSelectedDay, calendars: nil)
        
        print("predicate=\(predicate)")
        
        // 選択された一日分をフェッチ
        myEvents = eventStore.eventsMatchingPredicate(predicate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


