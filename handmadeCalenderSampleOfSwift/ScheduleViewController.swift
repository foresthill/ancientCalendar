//
//  ScheduleView.swift
//  handmadeCalenderSampleOfSwift
//
//  Created by Morioka Naoya on H27/07/29.
//  Copyright (c) 平成27年 just1factory. All rights reserved.
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
        
        
        for x in myItems {
            print(x)
        }
    }

    
    //画面遷移時に呼ばれるメソッド
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //セゲエ用にダウンキャストしたScheduleViewControllerのインスタンス
        let cdvc = segue.destinationViewController as! CalendarDetailViewController
        //変数を渡す
        //svc.myItems = eventItems;
        cdvc.myEvent = myEvents[calNum]
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
        //df.dateFormat = "yyyy/MM/dd"
        df.dateFormat = "yyyy/MM/dd hh:mm"
        
        let detailText = "\(df.stringFromDate(myEvents[indexPath.row].startDate))" + "\n - " + "\(df.stringFromDate(myEvents[indexPath.row].endDate))"
//        print("tmpは\(tmp)")
        
        cell.detailTextLabel?.text = detailText
        
//        print(myEvents[indexPath.row].startDate)
//        print(cell.detailTextLabel?.text)

        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.numberOfLines = 2
        
        return cell
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


