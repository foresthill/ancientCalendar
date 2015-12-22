//
//  ScheduleView.swift
//  handmadeCalenderSampleOfSwift
//
//  Created by Morioka Naoya on H27/07/29.
//  Copyright (c) 平成27年 just1factory. All rights reserved.
//

import Foundation
import UIKit

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Tableで使用する配列を設定する
    var myItems: NSArray = []
    
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
        
        // Viewに追加する
        self.view.addSubview(myTableView)
        
        for x in myItems {
            print(x)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /** 以下、tableview系メソッド **/
    
    /**
    Cellがタップ（選択）された際に呼び出される
    **/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        print("Num: \(indexPath.row)")
        print("Value: \(myItems[indexPath.row])")
    }
    
    /**
    Cellの総数を返す
    **/
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }
    
    /**
    Cellに値を設定する
    **/
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Cellの.を取得する
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) 
        
        // Cellに値を設定する
        cell.textLabel!.text = "\(myItems[indexPath.row])"
        cell.textLabel!.font = UIFont.systemFontOfSize(13)
        
        return cell
    }

}


