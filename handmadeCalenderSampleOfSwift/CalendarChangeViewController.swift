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
    
    //フォーマッター外だし
    let dateFormatter: NSDateFormatter = NSDateFormatter()
    
    //前画面（二画面前）に戻すためのイベント一覧
    var events: [EKEvent]!

    //どの画面から来たか？
    var previousScreen: NSString!
    
    override func viewDidLoad() {
        
        dateFormatter.dateFormat = "yyyy年MM月dd日 hh:mm"
        
        eventTitle.text = myEvent.title
        startTime.text = dateFormatter.stringFromDate(myEvent.startDate)
        endTime.text = dateFormatter.stringFromDate(myEvent.endDate)
//        startTime.setTitle("\(myEvent.startDate)", forState: .Normal)
//        endTime.setTitle("\(myEvent.endDate)", forState: .Normal)
        location.text = myEvent.location
//        detailText.text = myEvent.description
        detailText.text = myEvent.notes
        
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
        
        /*
        //イベントを保存
        var result:Bool = true
        
        myEventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
            granted, error in
            if(granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(error)")
                
                //var event:EKEvent = EKEvent(eventStore: myEventStore)
                self.myEvent.notes = "This is a note"
                self.myEvent.calendar = myEventStore.defaultCalendarForNewEvents
                
                do {
                    print(self.myEvent)
                    try myEventStore.saveEvent(self.myEvent, span: EKSpan.ThisEvent)
                    print("Save Event")
                    
                } catch _{
                    result = false
                    print("not Save Event")

                }
                
            }
        })

        

//        do {
//            try myEventStore.saveEvent(myEvent, span: EKSpan.ThisEvent, commit: true)   //error:nil→commit:true
//        } catch _ {
//            result = false
//        }
        
        if result {     //Bool? cannnot be used as a boolean; test for !=nil instead
            print("OK")
            
        } else {
            print("NG")

            let myAlert = UIAlertController(title: "カレンダーの更新に失敗しました", message: "\(eventTitle)", preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            myAlert.addAction(okAlertAction)
            
            self.presentViewController(myAlert, animated: true, completion: nil)  //これを実行するとなぜか戻れなくなる→まぁいいか
            
        }
*/
        
        //performSegueWithIdentifier("changed", sender: nil)
        

        
        
        //元の画面に戻る
        //dismissViewControllerAnimated(true, completion: nil)
        
        
        //navigationController?.popViewControllerAnimated(true)

        //二画面前に戻る
        
        
    }
    
    func insertEvent(store: EKEventStore){
        print("insertEvent")
        
        let calendars = store.calendarsForEntityType(EKEntityType.Event)
        
        var entrySuccess:Bool = false
        
        dateFormatter.dateFormat = "yyyy年MM月dd日 hh:mm"
        
        for calendar in calendars {
                print(calendar)
//            if calendar.title == "ioscreator" {
                //let startDate = NSDate()
                //let endDate = startDate.dateByAddingTimeInterval(2*60*60)
                
               //var event = myEvent.copy() as! EKEvent    //unrecognized selector sent to instance 0x7f9362b9d0a0
            
                //Create Event
                var newEvent = EKEvent(eventStore: store)

                newEvent.calendar = calendar                   //必要
            
                newEvent.title = eventTitle.text!
                newEvent.startDate = dateFormatter.dateFromString(startTime.text!)!
                newEvent.endDate = dateFormatter.dateFromString(endTime.text!)!
                newEvent.location = location.text
                newEvent.notes = detailText.text
                newEvent.timeZone = myEvent.timeZone
            
                //myEvent.calendar = calendar          //2016/01/20add
                //myEvent.recurrenceRules = nil
                //myEvent.timeZone = event.timeZone
                
                /*
                var error: NSError?
                let result = store.saveEvent(event, span: EKSpan.ThisEvent)
                
                if (result == false) {
                    if let theError = error {
                        print("An error occured \(theError)")
                    }
                }
                */
                
                do {
                    print("event = \(newEvent)")
                    print("myEvent = \(self.myEvent)")
                    print("try Save Event")
                    
                    try store.saveEvent(newEvent, span: EKSpan.ThisEvent)
                    //try store.saveEvent(myEvent, span: EKSpan.ThisEvent)
                    
                    print("complete Save Event")
                    
                    entrySuccess = true
                    
                    //遷移前の画面を更新する
                    updatePreviousScreen()

                    //イベントを削除
                    /*if(myEvent != nil){
                        store.delete(myEvent)                   //これはうまくいかない
                    }*/
                    try store.removeEvent(myEvent, span: EKSpan.ThisEvent)
                    
                    print("complete Delete Event")
                    
                    
                } catch _{
                    print("not Save (or Delete) Event")
                    

//            }
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
        
        //var arrayCount = array.count
        
//        let svc:ScheduleViewController = 0
        
//        navigationController?.viewControllers.indexOf(svc)
        
        
        //戻る画面（二画面前の場合はarrya.count - 3）
        
        //let previousScreen = array.count - 3
        
        //一画面戻る
        /*var cdvc:CalendarDetailViewController = array.objectAtIndex(arrayCount - 2) as! CalendarDetailViewController
        cdvc.myEvent = newEvent
        
        cdvc.scheduleTitle.text = eventTitle.text!
        cdvc.startTime.text = startTime.text
        cdvc.endTime.text = endTime.text
        cdvc.place.text = location.text
        cdvc.detailText = detailText
        
        //                    navigationController?.viewControllers.popLast()
        //                    navigationController?.viewControllers.

        
        navigationController?.viewControllers.removeAtIndex(arrayCount-2)
        navigationController?.viewControllers.insert(cdvc, atIndex: arrayCount-2)
        */
        
        //var svc:ScheduleViewController = array.objectAtIndex(previousScreen) as! ScheduleViewController
        
//        var svc:ScheduleViewController = array.objectAtIndex(previousScreen) as! ScheduleViewController
        var svc:ScheduleViewController = array.objectAtIndex(1) as! ScheduleViewController
        
        svc.myEvents = getCalendar()
        
//        navigationController?.viewControllers.removeAtIndex(previousScreen)
//        navigationController?.viewControllers.insert(svc, atIndex: previousScreen)
        
        navigationController?.viewControllers.removeAtIndex(1)
        navigationController?.viewControllers.insert(svc, atIndex: 1)

        
  /*      for i in 2...3{
            
        }
*/
        //navigationController?.popViewControllerAnimated(true)
        
        svc.viewDidLoad()
        
        print("return to svc")
        print(svc.myEvents)
        
        navigationController?.popToViewController(svc, animated: true)
        
        
        

    }
    
    func getCalendar() -> [EKEvent]{
        // NSCalendarを生成
        let myCalendar: NSCalendar = NSCalendar.currentCalendar()
        
        // EventStoreを作成する（2016/01/27）
        myEventStore = EKEventStore()
        
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
