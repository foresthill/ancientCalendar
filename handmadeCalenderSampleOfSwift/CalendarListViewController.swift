//
//  TableViewController.swift
//  handmadeCalenderSampleOfSwift
//
//  Created by Morioka Naoya on H27/12/10.
//  Copyright © 平成27年 just1factory. All rights reserved.
//

import Foundation
import UIKit
import EventKit

/*
class CalendarListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
*/
class CalendarListViewController: UIViewController{


    //テーブルビュー
    @IBOutlet var table: UITableView!
 
    /*
    
    // カレンダーを呼び出すための認証情報（前画面から）
    var myEventStore: EKEventStore!
    var myEvents: NSArray!
    var myTargetCalendar: EKCalendar!
    var event: EKEvent!
    
    // 発見したイベントを格納する配列を生成
    var eventItems = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //Table ViewのDataSource参照先
        table.dataSource = self
        //Table Viewのタップ時のdelegate先を指定
        table.delegate = self
        // NSCalendarを生成
        let myCalendar: NSCalendar = NSCalendar.currentCalendar()
        
        // ユーザのカレンダーを取得
        var myEventCalendars = myEventStore.calendarsForEntityType(EKEntityType.Event)
        
        // 開始日（昨日）コンポーネントの生成
        let oneDayAgoComponents: NSDateComponents = NSDateComponents()
        oneDayAgoComponents.day = -1
        
        // 昨日から今日までのNSDateを生成
        let oneDayAgo: NSDate = myCalendar.dateByAddingComponents(oneDayAgoComponents,
            toDate: NSDate(),
            options: NSCalendarOptions())!
        
        // 終了日（一年後）コンポーネントの生成
        let oneYearFromNowComponents: NSDateComponents = NSDateComponents()
        oneYearFromNowComponents.year = 1
        
        // 今日から一年後までのNSDateを生成
        let oneYearFromNow: NSDate = myCalendar.dateByAddingComponents(oneYearFromNowComponents,
            toDate: NSDate(),
            options: NSCalendarOptions())!
        
        // イベントストアのインスタントメソッドで述語を生成
        var predicate = NSPredicate()
        
        // ユーザーの全てのカレンダーからフェッチせよ
        predicate = myEventStore.predicateForEventsWithStartDate(oneDayAgo,
            endDate: oneYearFromNow, calendars: nil)
        
        // 述語にマッチする全てのイベントをフェッチ
        let events = myEventStore.eventsMatchingPredicate(predicate)
        
        // イベントが見つかった
        if !events.isEmpty {
            for i in events{
                print(i.title)
                print(i.startDate)
                print(i.endDate)
                
                // 配列に格納
                eventItems += ["\(i.title): \(i.startDate)"]    //これ自体がディクショナリー（2015/12/23）
                
            }
        }

        
        //カレンダー情報を取得したらテーブルビューに表示
        self.table.reloadData()
    }
    
    //テーブルビューのセルの数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventItems.count
    }
    
    //テーブルビューのセルに表示する内容
    func tableview(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        //StoryBoardで取得したCell
        let cell = UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        //カレンダー情報を取得（配列の"indexPath.row"番目の要素を取得）
        //var eventDic = event[indexPath.row] as NSDictionary
        
        
        /*
        var eventDic = eventItems[indexPath.row] as NSDictionary
        cell.textLabel?.text = eventDic["title"] as NSString
        cell.textLabel?.numberOfLines = 3
        cell.detailTextLabel?.text = eventDic["startDate"] as NSString
        
        event.
        */
        
        var eventDic = eventItems[indexPath.row]
        cell.textLabel?.text = eventDic["title"]
        cell.textLabel?.numberOfLines = 3
        cell.detailTextLabel?.text = eventDic
        
        return cell

    }
    
    //テーブルビューのセルがタップされた時の処理
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        //セルのインデックスパス番号を出力
        print("タップされたセルのインデックスパス：\(indexPath.row)")
    }
    
    
    */
    
    
    
    // どのクラスにもあるメソッド Memory監視？
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
