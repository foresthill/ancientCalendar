//
//  ScheduleView.swift
//  handmadeCalenderSampleOfSwift
//
//  Created by Morioka Naoya on H27/07/29.
//  Copyright (c) 平成27年 just1factory. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Tableで使用する配列を設定する
    var myItems: NSArray = []                     //読み専配列
    //var myItems: NSMutableArray = []          //読み書きどちらもOK配列
    //var myItems: AnyObject[] = ["追加"]         //http://zutto-megane.com/swift/post-573/とおんない
    //var myItems: Array = []                   //Swiftで用意されている配列
  
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
        let myTableView: UITableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        
        // Cell名の登録を行う
        myTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DateSourceの設定をする
        myTableView.dataSource = self
        
        // Delegateを設定する
        myTableView.delegate = self
        
        //myItems.addObject("追加")               //や〜めた。myItem渡す前のメソッドで追加しよう。
        
        // Viewに追加する
        self.view.addSubview(myTableView)
        
        for x in myItems {
            println(x)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /** 以下、tableview系メソッド **/
    
    /**
    Cellが選択された際に呼び出されるデリゲートメソッド
    **/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        println("Num: \(indexPath.row)")
        println("Value: \(myItems[indexPath.row])")
    }
    
    /**
    Cellの総数を返すデータソースメソッド（実装必須）
    **/
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }
    
    /**
    Cellに値を設定するデータソースメソッド（実装必須）
    **/
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Cellの.を取得する
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as! UITableViewCell
        
        // Cellに値を設定する
        cell.textLabel!.text = "\(myItems[indexPath.row])"
        cell.textLabel!.font = UIFont.systemFontOfSize(13)
        
        return cell
    }

}


