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

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
        
        //ツールバーを表示
        self.navigationController!.toolbarHidden = false
        let delButton :UIBarButtonItem! = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "onClickDelButton")
        let addButton :UIBarButtonItem! = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "onClickAddButton")

        //追加するのはこれじゃない
        self.navigationController!.toolbarItems = [delButton, addButton]
//        self.navigationController!.toolbarItem = append(addButton)
        
//        self.navigationItem.leftBarButtonItem = delButton
//        self.navigationItem.rightBarButtonItem = addButton
//        
        
        //ツールバーのスタイルを黒色に指定
//        self.navigationController?.toolbar.barStyle = UIBarStyle.Black
        
        for x in myItems {
            print(x)
        }
    }

    
    //画面遷移時に呼ばれるメソッド
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //セゲエ用にダウンキャストしたScheduleViewControllerのインスタンス
        if(segue.identifier == "toAddNewEvent"){
            let ccvc = segue.destinationViewController as! CalendarChangeViewController
//            ccvc.myEvent = EKEvent()  //You must use [EKEvent eventWithEventStore:] to create an event'
            //ccvc.myEvent = EKEvent.eventWithEventStore(EKEvent(eventStore))) //EKEvent.eventWithEventStore()
            let eventStore:EKEventStore = EKEventStore()
            
            var newEvent = EKEvent(eventStore: eventStore)
            
            let df:NSDateFormatter = NSDateFormatter()
            //df.dateFormat = "yyyy/MM/dd"
            df.dateFormat = "yyyy/MM/dd hh:mm"
            
            newEvent.startDate = df.dateFromString("\(year)/\(month)/\(day) 01:00")!
            newEvent.endDate = df.dateFromString("\(year)/\(month)/\(day) 02:00")!
            
            ccvc.myEvent = newEvent
            
        } else {
            let cdvc = segue.destinationViewController as! CalendarDetailViewController
        //変数を渡す
        //svc.myItems = eventItems;
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
        
        performSegueWithIdentifier("toCalendarDetailView", sender: self)
        
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
        //cell.textLabel!.text = "\(myItems[indexPath.row])"
        //cell.textLabel!.font = UIFont.systemFontOfSize(13)
        
        cell.textLabel?.text = myEvents[indexPath.row].title
//        cell.detailTextLabel?.text = "\(myEvents[indexPath.row].startDate)" + " - " + "\(myEvents[indexPath.row].endDate)"
//        cell.detailTextLabel?.text = "\(myEvents[indexPath.row].startDate)"// + " - " + "\(myEvents[indexPath.row].endDate)"
        
        let df:NSDateFormatter = NSDateFormatter()
        let df2:NSDateFormatter = NSDateFormatter()
        //df.dateFormat = "yyyy/MM/dd"
        df.dateFormat = "yyyy/MM/dd hh:mm"
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
        
        performSegueWithIdentifier("toAddNewEvent", sender: self)
    }
    
    //削除可能なセルのindexPath
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //実際に削除された時の処理を実装する
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        /*
        
        let eventStore:EKEventStore = EKEventStore()
//        let sharedEventKitSotre:
        let delEvent = myEvents[indexPath.row]
//        eventStore.delete(delEvent)
        
        do {
            try eventStore.removeEvent(delEvent, span: EKSpan.ThisEvent)
//            try eventStore.removeEvent(delEvent, span: EKSpan.ThisEvent, commit: true)
        } catch _{
            print("イベント削除できていない。")
        }
//
        */
        
        //先にデータを更新する
        removeEvent(indexPath.row)
        myEvents.removeAtIndex(indexPath.row)   //これがないと、絶対にエラーが出る
        
        
        //それからテーブルの更新
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    //イベントをカレンダーから削除するメソッド
    func removeEvent(index:Int){
        
        let eventStore:EKEventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatusForEntityType(EKEntityType.Event){
        
        case .Authorized:
//            print(myEvents)
            print(myEvents[index])
            do{
                try eventStore.removeEvent(myEvents[index], span: EKSpan.ThisEvent)
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
                        try eventStore.removeEvent(self.myEvents[index], span: EKSpan.ThisEvent)
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
    Cellの高さを指定する

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath)
        
        return
    }
    **/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


