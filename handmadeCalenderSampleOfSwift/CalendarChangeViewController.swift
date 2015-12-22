//
//  ScheduleChangeViewController.swift
//  handmadeCalenderSampleOfSwift
//
//  Created by Morioka Naoya on H27/12/10.
//  Copyright © 平成27年 just1factory. All rights reserved.
//

import Foundation
import UIKit

class CalendarChangeViewController: UIViewController {
    
    override func viewDidLoad() {
        
    }
    
    //テーブルビューのセルがタップされた時の処理
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        //セルのインデックスパス番号を出力
        print("タップされたセルのインデックスパス：\(indexPath.row)")
    }
    
    // どのクラスにもあるメソッド Memory監視？
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
