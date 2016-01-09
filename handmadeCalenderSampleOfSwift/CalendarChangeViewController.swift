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

class CalendarChangeViewController: UIViewController, UITextFieldDelegate {
    
    //@IBOutlet weak var scheduleTitle: UILabel!
//    @IBOutlet weak var eventTitle: UILabel!
//    @IBOutlet weak var startTime: UILabel!
//    @IBOutlet weak var endTime: UILabel!
//    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var detailText: UITextView!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    @IBOutlet weak var location: UITextField!

//    @IBOutlet weak var startTime: UIButton!
//    @IBOutlet weak var endTime: UIButton!
    
    //前画面から取ってきたイベント
    var myEvent: EKEvent!
    
    //イベント登録時の変数
    var myEventStore: EKEventStore!
    
    
    override func viewDidLoad() {
        eventTitle.text = myEvent.title
        startTime.setTitle("\(myEvent.startDate)", forState: .Normal)
        endTime.setTitle("\(myEvent.endDate)", forState: .Normal)
        location.text = myEvent.location
        detailText.text = myEvent.description

    }
    
    /*
    TextFieldの文字が変わった時に呼ばれるメソッド
    */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        print("textFieldが変わったよ。")
        myEvent.title = eventTitle.text!
//        myEvent.startDate = startTime.titleLabel
//        myEvent.endDate = endTime.text
        myEvent.location = location.text
//        myEvent.description = detailText.text
        
        return true
    }
    
    /*
    func FormatFromStringToDate(str:String){
        let df = NSDateFormatter()
        df.dateFormat = "yyyy/mm/dd hh:mm"
        //let mySelectDateString = df.stringFromDate(<#T##date: NSDate##NSDate#>)
        
    }

    func FormatFromDateToString(date:NSDate){
        let df = NSDateFormatter()
        df.dateFormat = "yyyy/mm/dd hh:mm"
        let mySelectDateString = df.stringFromDate(date)
        let mySelectDate = df.dateFromString(mySelectDateString)!
        //myDate = NSDate(timeInterval: 0, sinceDate: mySelectDate)
        
    }
    */

    @IBAction func updateAction(sender: UIButton){
        print("setCalendar")
        
        myEventStore = EKEventStore()
        
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
        
        //performSegueWithIdentifier("changed", sender: nil)
        
        //元の画面に戻る
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func backAction(sender: UIButton){
        print("back")
        
        //dismissViewControllerAnimated(false, completion: nil)
        navigationController?.popViewControllerAnimated(true)
    }
    
    //画面遷移時に呼ばれるメソッド
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //セゲエ用にダウンキャストしたCalendarChangeViewControllerのインスタンス
        let cdvc = segue.destinationViewController as! CalendarDetailViewController
        //変数を渡す
        //svc.myItems = eventItems;
        cdvc.myEvent = myEvent
    }
    
    /*
    認証許可
    */
    func allowAuthorization() {
        print("allowAuthorized")
        
        //ステータスを取得
        let status: EKAuthorizationStatus = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        if status != EKAuthorizationStatus.Authorized {
            //ユーザに許可を求める
            myEventStore.requestAccessToEntityType(EKEntityType.Event, completion: {(granted, error) -> Void in
                
                //許可が得られなかった場合アラート発動
                if granted {
                    return
                }
                else {
                    
                    //メインスレッド 画面制御 非同期
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        //アラート作成
                        let myAlert = UIAlertController(title: "許可されませんでした", message: "Privacy->App->Reminderで変更してください", preferredStyle: UIAlertControllerStyle.Alert)//UIAlertActionStyle→UIAlertControllerStyle.Alert
                        
                        //アラートアクション
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        
                        myAlert.addAction(okAction)
                        self.presentViewController(myAlert, animated: true, completion: nil)
                    })
                }
            })
        }
    }
    
    // どのクラスにもあるメソッド Memory監視？
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
