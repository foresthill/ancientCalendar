//
//  ScheduleChangeViewController.swift
//  handmadeCalenderSampleOfSwift
//
//  Created by Morioka Naoya on H27/12/10.
//  Copyright © 平成27年 just1factory. All rights reserved.
//

import Foundation
import UIKit
import EventKit

class CalendarChangeViewController: UIViewController {
    
    @IBOutlet weak var eventTitle: UILabel!
    //@IBOutlet weak var scheduleTitle: UILabel!
    
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var detailText: UITextView!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    //前画面から取ってきたイベント
    var myEvent: EKEvent!
    
    //イベント登録時の変数
    var myEventStore: EKEventStore!
    
    
    override func viewDidLoad() {
        eventTitle.text = myEvent.title
        startTime.text = "\(myEvent.startDate)"
        endTime.text = "\(myEvent.endDate)"
        location.text = myEvent.location
        detailText.text = myEvent.description
        
    }
    
    @IBAction func updateAction(sender: UIButton){
        print("setCalendar")
        
        //イベントを登録する
        myEvent.calendar = myEventStore.defaultCalendarForNewEvents
        
        //イベントを保存
        var result:Bool = true

        do {
            try myEventStore.saveEvent(myEvent, span: EKSpan.ThisEvent, commit: true)   //error:nil→commit:true
        } catch _ {
            result = false
        }
        
        if result {     //Bool? cannnot be used as a boolean; test for !=nil instead
            print("OK")
            
        } else {
            print("NG")

            let myAlert = UIAlertController(title: "カレンダーの更新に失敗しました", message: "\(eventTitle)", preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            myAlert.addAction(okAlertAction)
            
        }
        
        performSegueWithIdentifier("changed", sender: nil)
        
        
    }
    
    //画面遷移時に呼ばれるメソッド
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //セゲエ用にダウンキャストしたCalendarChangeViewControllerのインスタンス
        let cdvc = segue.destinationViewController as! CalendarDetailViewController
        //変数を渡す
        //svc.myItems = eventItems;
        cdvc.myEvent = myEvent
    }
    
    // どのクラスにもあるメソッド Memory監視？
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
