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
    
    //DatePicker（開始時間・終了時間を決定）
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //DatePickerの表示・非表示フラグ
    var datePickerIsHidden: Bool = false
    
    //DatePickerを確定するボタン
    @IBOutlet weak var dateDecideButton: UIButton!
    
    //DatePickerの背景
    @IBOutlet weak var datePickerBg: UIButton!
    
    //DatePickerの値を一時的に格納する変数
    var datePickerValue: NSDate!
    
    
    //編集中のtagを格納する変数
    var textfieldTag: Int!
    
    //前画面から取ってきたイベント
    var myEvent: EKEvent!
    
    //イベント登録時の変数
    var myEventStore: EKEventStore!
    
    
    override func viewDidLoad() {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 hh:mm"
        
        eventTitle.text = myEvent.title
        startTime.text = dateFormatter.stringFromDate(myEvent.startDate)
        endTime.text = dateFormatter.stringFromDate(myEvent.endDate)
//        startTime.setTitle("\(myEvent.startDate)", forState: .Normal)
//        endTime.setTitle("\(myEvent.endDate)", forState: .Normal)
        location.text = myEvent.location
        detailText.text = myEvent.description
        
        //textFieldの初期処理
        textFieldInit()
        
        //DatePickerを非表示にする
        hideDatePicker()
        
        datePicker.backgroundColor = UIColor.whiteColor()
        
        //self.datePicker = UIDatePicker()
        
        //アクション追加
        //datePicker.addTarget(self, action: "onDatePickerValueChanged", forControlEvents: UIControlEvents.ValueChanged)

    }
    
    /*
    datePickerの値変更時に呼ばれる→不要
    */
    func onDatePickerValueChanged(sendar: AnyObject) {
        
        //一時的に値を格納する？する必要あんのか？
        //datePickerValue = datePicker.date

        /*
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle

        switch textfieldTag{
        case 1:
            startTime.text = dateFormatter.stringFromDate((sendar as! UIDatePicker).date)    //あずあず
            break
        case 2:
            endTime.text = dateFormatter.stringFromDate((sendar as! UIDatePicker).date)    //あずあず
            break
        default:
            hideDatePicker()
            
        }
        */
        
        
    }
    
    func textFieldInit(){
        print(startTime.tag)
        print(endTime.tag)
        
        //これは必要
        eventTitle.delegate = self
        startTime.delegate = self
        endTime.delegate = self
        location.delegate = self
        
        /* storyboardで指定したため不要
        eventTitle.tag = 0
        startTime.tag = 1
        endTime.tag = 2
        location.tag = 3
        */
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
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        switch textField.tag{
        case 1:
            textfieldTag = 1
            showDatePicker()
            break
        case 2:
            textfieldTag = 2
            showDatePicker()
            break
        default:
            textfieldTag = 0
            hideDatePicker()
            break
        }
        
        return true
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField.tag{
        case 1:
            textField.resignFirstResponder()
            break
        case 2:
            textField.resignFirstResponder()
            break
        default: break
            
        }
        return true
    }
    
    /*
    UIDatePickerの表示・非表示を切り替える
    */
    /*
    func dspDatePicker() {
        //フラグを見て切り替える
        if(datePickerIsHidden){
            showDatePicker()
        } else {
            hideDatePicker()
        }
    }
    */
    
    func showDatePicker(){
        
        if(datePickerIsHidden){
            //フラグ更新
            datePickerIsHidden = false
            
            datePicker.hidden = false
            //datePicker.alpha = 0
            
            dateDecideButton.hidden = false
            
            datePickerBg.hidden = false
            
    //        UIView.animateKeyframesWithDuration(0.25,animations: { () -> Void in datePicker.alpha = 1.0}, delay:, option:nil, completion: {(Bool) -> Void in })
            
            UIView.animateWithDuration(0.25, animations:{ () -> Void in self.datePicker.alpha = 1.0}
            )
        }
        
    }
    
    func hideDatePicker() {
        //フラグ更新
        
        if(!datePickerIsHidden){
            datePickerIsHidden = true
            
            dateDecideButton.hidden = true
            datePickerBg.hidden = true
            
            //datePicker.hidden = true
            //datePicker.alpha = 0
            //        UIView.animateKeyframesWithDuration(0.25,animations: { () -> Void in datePicker.alpha = 1.0}, delay:, option:nil, completion: {(Bool) -> Void in })
            
            UIView.animateWithDuration(0.25, animations:{ () -> Void in self.datePicker.alpha = 0}, completion: {(Bool) -> Void in self.datePicker.hidden = true
            })
        }
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
    
    @IBAction func decideDatePicker(sender: UIButton){
        print("decideDate")
        
        let dpdf: NSDateFormatter = NSDateFormatter()
        //dpdf.dateStyle = NSDateFormatterStyle.ShortStyle
        dpdf.dateFormat = "yyyy年MM月dd日 hh:mm"

        switch textfieldTag{
        case 1:
            startTime.text = dpdf.stringFromDate(datePicker.date)
            break
        case 2:
            endTime.text = dpdf.stringFromDate(datePicker.date)
            break
        default:
            hideDatePicker()
        }
        
        
        
        hideDatePicker()

        
    }
    
    
    @IBAction func datePickerBg(sender: UIButton){
        print("datePickerBg")
        
        hideDatePicker()
    }

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
            myEventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
                (granted, error) -> Void in
                
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
    
    
    /**
     認証ステータスを取得→不要？

    func getAuthorization_status() -> Bool {
        
        // ステータスを取得
        let status: EKAuthorizationStatus = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        // ステータスを表示 許可されている場合のみtrueを返す
        switch status {
        case EKAuthorizationStatus.NotDetermined:
            print("NotDetermined")
            return false
            
        case EKAuthorizationStatus.Denied:
            print("Denied")
            return false
            
        case EKAuthorizationStatus.Authorized:
            print("Authorized")
            return true
            
        case EKAuthorizationStatus.Restricted:
            print("Restricted")
            return false
            
        default:
            print("error")
            return false
            
        }
    }
**/

    
    // どのクラスにもあるメソッド Memory監視？
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
