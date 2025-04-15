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
    var datePickerValue: Date!
    
    //編集中のtagを格納する変数
    var textfieldTag: Int!
    
    //前画面から取ってきたイベント
    var myEvent: EKEvent!
    
    //イベント登録時の変数
    var myEventStore: EKEventStore!
    
    //フォーマッター外だし
    var dateFormatter: DateFormatter! //letにしてると（あるいは!つけないと）no initializerといって怒られる。
    
    //前画面（二画面前）に戻すためのイベント一覧
    var events: [EKEvent]!

    //どの画面から来たか？（新規or編集モード）
    var mode: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 hh:mm"
        
        eventTitle.text = myEvent.title
        startTime.text = dateFormatter.string(from: myEvent.startDate)
        endTime.text = dateFormatter.string(from: myEvent.endDate)
        location.text = myEvent.location
        detailText.text = myEvent.notes
        
        //textFieldの初期処理
        textFieldInit()
        
        //DatePickerを非表示にする
        hideDatePicker()
        
        datePicker.backgroundColor = UIColor.white
        
        self.navigationItem.title = "\(myEvent.title) 予定詳細"
    }
    
    func textFieldInit() {
        print(startTime.tag)
        print(endTime.tag)
        
        //これは必要
        eventTitle.delegate = self
        startTime.delegate = self
        endTime.delegate = self
        location.delegate = self
    }
    
    // TextFieldの文字が変わった時に呼ばれるメソッド
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("textFieldが変わったよ。")
        myEvent.title = eventTitle.text!
        myEvent.location = location.text
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField.tag {
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1:
            textField.resignFirstResponder()
            break
        case 2:
            textField.resignFirstResponder()
            break
        default: 
            break
        }
        return true
    }
    
    func showDatePicker() {
        if(datePickerIsHidden) {
            //フラグ更新
            datePickerIsHidden = false
            
            datePicker.isHidden = false
            
            dateDecideButton.isHidden = false
            
            datePickerBg.isHidden = false
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in 
                self.datePicker.alpha = 1.0
            })
        }
    }
    
    func hideDatePicker() {
        //フラグ更新
        if(!datePickerIsHidden) {
            datePickerIsHidden = true
            
            dateDecideButton.isHidden = true
            datePickerBg.isHidden = true
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in 
                self.datePicker.alpha = 0
            }, completion: { (finished) -> Void in 
                self.datePicker.isHidden = true
            })
        }
    }
    
    func dfDateFromString(str: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy年MM月dd日 hh:mm"
        return df.date(from: str)!
    }
    
    func dfStringFromDate(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy年MM月dd日 hh:mm"
        return df.string(from: date)
    }
    
    @IBAction func decideDatePicker(sender: UIButton) {
        print("decideDate")
        
        switch textfieldTag {
        case 1:
            startTime.text = dfStringFromDate(date: datePicker.date)
            break
        case 2:
            endTime.text = dfStringFromDate(date: datePicker.date)
            break
        default:
            break
        }
        
        hideDatePicker()
    }
    
    @IBAction func datePickerBg(sender: UIButton) {
        print("datePickerBg")
        
        hideDatePicker()
    }

    @IBAction func updateAction(sender: UIButton) {
        print("setCalendar")
        
        let eventStore: EKEventStore = EKEventStore()
        
        //イベントを追加
        switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
        case .authorized:
            insertEvent(store: eventStore)
        case .denied:
            print("Access denied")
        case .notDetermined:
            eventStore.requestAccess(to: EKEntityType.event, completion: { (granted, error) in
                if granted {
                    self.insertEvent(store: eventStore)
                } else {
                    print("Access denied")
                }
            })
        default:
            print("Case Default")
        }
    }
    
    func insertEvent(store: EKEventStore) {
        print("insertEvent")
        
        let calendars = store.calendars(for: EKEntityType.event)
        
        var entrySuccess: Bool = false
        
        for calendar in calendars {
            //Create Event
            let newEvent = EKEvent(eventStore: store)
            
            newEvent.calendar = calendar
            
            newEvent.title = eventTitle.text!
            newEvent.startDate = dfDateFromString(str: startTime.text!)
            newEvent.endDate = dfDateFromString(str: endTime.text!)
            newEvent.location = location.text
            newEvent.notes = detailText.text
            newEvent.timeZone = myEvent.timeZone
            
            do {
                print("event = \(newEvent)")
                print("myEvent = \(self.myEvent)")
                print("try Save Event")
                
                try store.save(newEvent, span: EKSpan.thisEvent)
                
                print("complete Save Event")
                
                entrySuccess = true
                
                //遷移前の画面を更新する
                updatePreviousScreen()
                
                //イベントを削除
                store.event(withIdentifier: myEvent.eventIdentifier)
                try store.remove(myEvent, span: EKSpan.thisEvent)
                
                print("complete Delete Event")
            } catch {
                print("not Save (or Delete) Event")
            }
        }
        
        if(!entrySuccess) {
            let myAlert = UIAlertController(title: "カレンダーの更新に失敗しました", message: "\(eventTitle.text!)", preferredStyle: .alert)
            
            let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            myAlert.addAction(okAlertAction)
            
            self.present(myAlert, animated: true, completion: nil)
        }
    }
    
    func editEvent(store: EKEventStore) {
        print("editEvent")
        
        let calendars = store.calendars(for: EKEntityType.event)
        
        var entrySuccess: Bool = false
        
        for calendar in calendars {
            myEvent.calendar = calendar
            
            myEvent.title = eventTitle.text!
            myEvent.startDate = dfDateFromString(str: startTime.text!)
            myEvent.endDate = dfDateFromString(str: endTime.text!)
            myEvent.location = location.text
            myEvent.notes = detailText.text
            myEvent.timeZone = myEvent.timeZone
            
            do {
                print("event = \(myEvent)")
                print("myEvent = \(self.myEvent)")
                print("try Save Event")
                
                try store.save(myEvent, span: EKSpan.thisEvent)
                
                print("complete Save Event")
                
                entrySuccess = true
                
                //遷移前の画面を更新する
                updatePreviousScreen()
                
                store.event(withIdentifier: myEvent.eventIdentifier)
                try store.remove(myEvent, span: EKSpan.thisEvent)
                
                print("complete Delete Event")
            } catch {
                print("not Save (or Delete) Event")
            }
        }
        
        if(!entrySuccess) {
            let myAlert = UIAlertController(title: "カレンダーの更新に失敗しました", message: "\(eventTitle.text!)", preferredStyle: .alert)
            
            let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            myAlert.addAction(okAlertAction)
            
            self.present(myAlert, animated: true, completion: nil)
        }
    }
    
    //前画面を更新する
    func updatePreviousScreen() {
        guard let viewControllers = navigationController?.viewControllers else { return }
        
        guard viewControllers.count > 1 else { return }
        
        if let svc = viewControllers[1] as? ScheduleViewController {
            svc.events = getCalendar()
            
            print(svc.events ?? [])
            
            svc.myTableView.reloadData()
            
            var updatedViewControllers = viewControllers
            updatedViewControllers.remove(at: 1)
            updatedViewControllers.insert(svc, at: 1)
            
            navigationController?.viewControllers = updatedViewControllers
            
            print("return to svc")
            
            navigationController?.popToViewController(svc, animated: true)
        }
    }
    
    func getCalendar() -> [EKEvent] {
        // Calendarを生成
        let calendar = Calendar.current
        let myEventStore = EKEventStore()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 hh:mm"
        
        guard let startDate = dateFormatter.date(from: startTime.text!) else {
            return []
        }
        
        var components = calendar.dateComponents([.year, .month, .day], from: startDate)
        
        print("components=\(components)")
        
        guard let selectedDay = calendar.date(from: components) else {
            return []
        }
        
        components.day! += 1
        
        guard let oneDayFromSelectedDay = calendar.date(from: components) else {
            return []
        }
        
        print("oneDayFromSelectedDay=\(oneDayFromSelectedDay)")
        
        // イベントストアのインスタントメソッドで述語を生成
        let predicate = myEventStore.predicateForEvents(withStart: selectedDay, end: oneDayFromSelectedDay, calendars: nil)
        
        print("predicate=\(predicate)")
        
        // 述語にマッチする全てのイベントをフェッチ
        let events = myEventStore.events(matching: predicate)
        
        return events
    }

    @IBAction func backAction(sender: UIButton) {
        print("back")
        
        navigationController?.popViewController(animated: true)
    }
    
    //画面遷移時に呼ばれるメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 必要があれば実装する
    }
    
    // 認証許可
    func allowAuthorization() {
        print("allowAuthorized")
        
        //ステータスを取得
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        if status != .authorized {
            //ユーザに許可を求める
            myEventStore.requestAccess(to: EKEntityType.event, completion: { (granted, error) in
                //許可が得られなかった場合アラート発動
                if granted {
                    return
                }
                else {
                    //メインスレッド 画面制御 非同期
                    DispatchQueue.main.async {
                        //アラート作成
                        let myAlert = UIAlertController(title: "許可されませんでした", message: "Privacy->App->Reminderで変更してください", preferredStyle: .alert)
                        
                        //アラートアクション
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        
                        myAlert.addAction(okAction)
                        self.present(myAlert, animated: true, completion: nil)
                    }
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
