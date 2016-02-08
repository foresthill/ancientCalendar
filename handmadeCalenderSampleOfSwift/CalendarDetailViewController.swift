//
//  CalendarDetailViewController.swift
//  handmadeCalenderSampleOfSwift
//
//  Created by Morioka Naoya on H27/12/10.
//  Copyright © 平成27年 just1factory. All rights reserved.
//

import Foundation
import UIKit
import EventKit

class CalendarDetailViewController: UIViewController {
    
    //渡されたイベントを格納
    var myEvent: EKEvent!

    @IBOutlet weak var scheduleTitle: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var detailText: UITextView!
    @IBOutlet weak var changeButton: UIButton!
    
    override func viewDidLoad() {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 hh:mm"
        
        //デバッグコード、なぜdetailTextがでん？（2016/01/30）
        print(navigationController?.viewControllers)
        
        scheduleTitle.text = myEvent.title
        startTime.text = dateFormatter.stringFromDate(myEvent.startDate)
        endTime.text = dateFormatter.stringFromDate(myEvent.endDate)
        place.text = myEvent.location
        detailText.text = myEvent.notes

        print(myEvent.notes)    //なぜか、更新後表示されない（初期画面に戻ると表示される）
        
        self.navigationItem.title = "\(myEvent.title) 予定詳細"
        
    }
    
    //画面遷移時に呼ばれるメソッド
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //セゲエ用にダウンキャストしたCalendarChangeViewControllerのインスタンス
        let ccvc = segue.destinationViewController as! CalendarChangeViewController
        //変数を渡す
        ccvc.myEvent = myEvent
    }
    
    // どのクラスにもあるメソッド Memory監視？
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
