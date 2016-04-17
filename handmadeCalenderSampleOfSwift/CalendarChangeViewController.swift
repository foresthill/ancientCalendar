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
    
    @IBOutlet weak var detailText: UITextView!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    @IBOutlet weak var location: UITextField!
    
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
    
    //フォーマッター外だし
    var dateFormatter: NSDateFormatter! //letにしてると（あるいは!つけないと）no initializerといって怒られる。
    
    //前画面（二画面前）に戻すためのイベント一覧
    var events: [EKEvent]!

    //どの画面から来たか？（新規or編集モード）
    var mode: NSString!
    
    override func viewDidLoad() {
        
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 hh:mm"
        
        eventTitle.text = myEvent.title
        startTime.text = dateFormatter.stringFromDate(myEvent.startDate)
        endTime.text = dateFormatter.stringFromDate(myEvent.endDate)
        location.text = myEvent.location
        detailText.text = myEvent.notes
        
        //textFieldの初期処理
        textFieldInit()
        
        //DatePickerを非表示にする
        hideDatePicker()
        
        datePicker.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.title = "\(myEvent.title) 予定詳細"

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
            
            UIView.animateWithDuration(0.25, animations:{ () -> Void in self.datePicker.alpha = 0}, completion: {(Bool) -> Void in self.datePicker.hidden = true
            })
        }
    }
    
    
    func dfDateFromString(str:String) -> NSDate{
        let df = NSDateFormatter()
        //df.dateFormat = "yyyy/mm/dd hh:mm"
        df.dateFormat = "yyyy年MM月dd日 hh:mm"
        //let mySelectDateString = df.stringFromDate(<#T##date: NSDate##NSDate#>)
        return df.dateFromString(str)!
    }

    
    func dfStringFromDate(date:NSDate) -> String{
        let df = NSDateFormatter()
        //df.dateFormat = "yyyy/mm/dd hh:mm"
        df.dateFormat = "yyyy年MM月dd日 hh:mm"
        //let mySelectDateString = df.stringFromDate(date)
        //let mySelectDate = df.dateFromString(mySelectDateString)!
        //myDate = NSDate(timeInterval: 0, sinceDate: mySelectDate)
        return df.stringFromDate(date)
    }
    
    
    @IBAction func decideDatePicker(sender: UIButton){
        print("decideDate")
        
        /*
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        //dpdf.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateFormat = "yyyy年MM月dd日 hh:mm"
*/
        
        switch textfieldTag{
        case 1:
//            startTime.text = dateFormatter.stringFromDate(datePicker.date)
            startTime.text = dfStringFromDate(datePicker.date)
            break
        case 2:
            //endTime.text = dateFormatter.stringFromDate(datePicker.date)
            endTime.text = dfStringFromDate(datePicker.date)
            break
        default:
            //hideDatePicker()
            break
        }
        
        
        
        hideDatePicker()

        
    }
    
    
    @IBAction func datePickerBg(sender: UIButton){
        print("datePickerBg")
        
        hideDatePicker()
    }

    @IBAction func updateAction(sender: UIButton){
        print("setCalendar")
        
        let eventStore:EKEventStore = EKEventStore()
        
        //イベントを登録する
        //myEvent.calendar = myEventStore.defaultCalendarForNewEvents
        
        //今のイベントを登録したい
        
        //イベントを追加
        switch EKEventStore.authorizationStatusForEntityType(EKEntityType.Event){
        case .Authorized:
            insertEvent(eventStore)
        case .Denied:
            print("Access denied")
        case .NotDetermined:
            eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
                //[weak self](granted:Bool, error:NSError!) -> Void in
                granted, error in
                if granted {
                    self.insertEvent(eventStore)
                } else {
                    print("Access denied")
                }
            })
        default:
            print("Case Default")
        }
        
    }
    
    func insertEvent(store: EKEventStore){
        print("insertEvent")
        
        let calendars = store.calendarsForEntityType(EKEntityType.Event)
        
        var entrySuccess:Bool = false
        
//        let dateFormatter: NSDateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "yyyy年MM月dd日 hh:mm"
        
        for calendar in calendars {
            
                //Create Event
                var newEvent = EKEvent(eventStore: store)

                newEvent.calendar = calendar                   //必要
            
                newEvent.title = eventTitle.text!
                newEvent.startDate = dfDateFromString(startTime.text!)
//                newEvent.endDate = dateFormatter.dateFromString(endTime.text!)!
                newEvent.endDate = dfDateFromString(endTime.text!)
                newEvent.location = location.text
                newEvent.notes = detailText.text
                newEvent.timeZone = myEvent.timeZone
                

                do {
                    print("event = \(newEvent)")
                    print("myEvent = \(self.myEvent)")
                    print("try Save Event")
                    
                    try store.saveEvent(newEvent, span: EKSpan.ThisEvent)
                    
                    print("complete Save Event")
                    
                    entrySuccess = true
                    
                    //遷移前の画面を更新する
                    updatePreviousScreen()

                    //イベントを削除
                    /*if(myEvent != nil){
                        store.delete(myEvent)                   //これはうまくいかない
                    }*/
                    
                    store.eventWithIdentifier(myEvent.eventIdentifier)  //これを入れました。（2016/1/31）でもダメ。なんで？
                    try store.removeEvent(myEvent, span: EKSpan.ThisEvent)
                    
                    print("complete Delete Event")
                    
                    
                } catch _{
                    print("not Save (or Delete) Event")

            }
        }
        
        if(!entrySuccess){
            let myAlert = UIAlertController(title: "カレンダーの更新に失敗しました", message: "\(eventTitle)", preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            myAlert.addAction(okAlertAction)
            
            self.presentViewController(myAlert, animated: true, completion: nil)  //これを実行するとなぜか戻れなくなる→まぁいいか
        }
    
    
    }
    
    func editEvent(store: EKEventStore){
        print("editEvent")
        
        let calendars = store.calendarsForEntityType(EKEntityType.Event)
        
        var entrySuccess:Bool = false
        
        //        let dateFormatter: NSDateFormatter = NSDateFormatter()
        //        dateFormatter.dateFormat = "yyyy年MM月dd日 hh:mm"
        
        for calendar in calendars {
            
            myEvent.calendar = calendar                   //必要
            
            myEvent.title = eventTitle.text!
            myEvent.startDate = dfDateFromString(startTime.text!)
            //                myEvent.endDate = dateFormatter.dateFromString(endTime.text!)!
            myEvent.endDate = dfDateFromString(endTime.text!)
            myEvent.location = location.text
            myEvent.notes = detailText.text
            myEvent.timeZone = myEvent.timeZone
            
            
            do {
                print("event = \(myEvent)")
                print("myEvent = \(self.myEvent)")
                print("try Save Event")
                
                try store.saveEvent(myEvent, span: EKSpan.ThisEvent)
                
                print("complete Save Event")
                
                entrySuccess = true
                
                //遷移前の画面を更新する
                updatePreviousScreen()
                
                //イベントを削除
                /*if(myEvent != nil){
                store.delete(myEvent)                   //これはうまくいかない
                }*/
                
                store.eventWithIdentifier(myEvent.eventIdentifier)  //これを入れました。（2016/1/31）
                try store.removeEvent(myEvent, span: EKSpan.ThisEvent)
                
                print("complete Delete Event")
                
                
            } catch _{
                print("not Save (or Delete) Event")
                
            }
        }
        
        if(!entrySuccess){
            let myAlert = UIAlertController(title: "カレンダーの更新に失敗しました", message: "\(eventTitle)", preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            myAlert.addAction(okAlertAction)
            
            self.presentViewController(myAlert, animated: true, completion: nil)  //これを実行するとなぜか戻れなくなる→まぁいいか
        }
        
        
    }

    
    
    
    //前画面を更新する
    func updatePreviousScreen(){
        
        var array:NSArray = (navigationController?.viewControllers)!
        
        var svc:ScheduleViewController = array.objectAtIndex(1) as! ScheduleViewController
        
        svc.events = getCalendar()
        
        print(svc.events)
        
        
        //svc.viewDidLoad()
        
        //svc.reloadInputViews()
        svc.myTableView.reloadData()
        
        navigationController?.viewControllers.removeAtIndex(1)
        navigationController?.viewControllers.insert(svc, atIndex: 1)
        
        print("return to svc")
        
        
        navigationController?.popToViewController(svc, animated: true)
        
        
        

    }
    
    func getCalendar() -> [EKEvent]{
        // NSCalendarを生成
        let myCalendar: NSCalendar = NSCalendar.currentCalendar()
        let myEventStore:EKEventStore = EKEventStore()
        
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 hh:mm"
        var date:NSDate = dateFormatter.dateFromString(startTime.text!)!
        
        let comps:NSDateComponents = myCalendar.components([.Year, .Month, .Day], fromDate: date)
        
        print("comps=\(comps)")
        
        let SelectedDay: NSDate = myCalendar.dateFromComponents(comps)!
 
        comps.day += 1
        
        
        let oneDayFromSelectedDay: NSDate = myCalendar.dateFromComponents(comps)!
        
        print("oneDayFromSelcetedDay=\(oneDayFromSelectedDay)")
        
        
        // イベントストアのインスタントメソッドで述語を生成
        var predicate = NSPredicate()
        

        
        predicate = myEventStore.predicateForEventsWithStartDate(SelectedDay, endDate: oneDayFromSelectedDay, calendars: nil)
        
        print("predicate=\(predicate)")
        
        // 述語にマッチする全てのイベントをフェッチ
        events = myEventStore.eventsMatchingPredicate(predicate)
        
        return events
        
    }


    @IBAction func backAction(sender: UIButton){
        print("back")
        
        //dismissViewControllerAnimated(false, completion: nil)
        navigationController?.popViewControllerAnimated(true)
    }
    
    //画面遷移時に呼ばれるメソッド
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        /*
        //セゲエ用にダウンキャストしたCalendarChangeViewControllerのインスタンス
        let cdvc = segue.destinationViewController as! CalendarDetailViewController
        //変数を渡す
        //svc.myItems = eventItems;
        cdvc.myEvent = myEvent
        */
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

    // どのクラスにもあるメソッド Memory監視？
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
