//
//  ViewController.swift
//  handmadeCalenderSampleOfSwift
//
//  Created by 酒井文也 on 2014/11/29.
//  Copyright (c) 2014年 just1factory. All rights reserved.
//

import UIKit
import EventKit

//CALayerクラスのインポート
import QuartzCore

class ViewController: UIViewController {

    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        

     }
    
    
    
 /*
    // Windowを開くアクション
    internal func openWindow(button: UIButton){
        
        popUpWindow.backgroundColor = UIColor.whiteColor()
        popUpWindow.frame = CGRectMake(0, 0, 200, 250)
        popUpWindow.layer.position = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
        popUpWindow.alpha = 0.8
        popUpWindow.layer.cornerRadius = 10
        
        // popUpWindowsをkeyWindowsにする.
        popUpWindow.makeKeyWindow()
        
        // windowsを表示する
        self.popUpWindow.makeKeyAndVisible()
        
        // ボタンを作成する
        popUpWindowButton.frame = CGRectMake(0, 0, 100, 60)
        popUpWindowButton.backgroundColor = UIColor.orangeColor()
        popUpWindowButton.setTitle("Close", forState: .Normal)
        popUpWindowButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        popUpWindowButton.layer.masksToBounds = true
        popUpWindowButton.layer.cornerRadius = 10.0
        popUpWindowButton.layer.position = CGPointMake(self.popUpWindow.frame.width/2, self.popUpWindow.frame.height-50)
        popUpWindowButton.addTarget(self, action: "onClickCloseButton:", forControlEvents: .TouchUpInside)

        self.popUpWindow.addSubview(popUpWindowButton)
        
        // TextViewを作成する
        let windowTextView: UITextView = UITextView(frame: CGRectMake(10, 10, self.popUpWindow.frame.width - 20, 150))
        windowTextView.backgroundColor = UIColor.clearColor()
        windowTextView.text = "ボタンを押しましたね。あなたは今日から“大納言”です。ウソです。"
        windowTextView.text = "\(year)年\(month)月\(button.tag)日が選択されました！ by 大納言小豆"
        windowTextView.font = UIFont.systemFontOfSize(CGFloat(15))
        windowTextView.textColor = UIColor.blackColor()
        windowTextView.textAlignment = NSTextAlignment.Left
        windowTextView.editable = false
        
        self.popUpWindow.addSubview(windowTextView)
        
    }
    
    // Windowを閉じるイベント
    internal func onClickCloseButton(sendar: UIButton){
    
        objc_setAssociatedObject(UIApplication.sharedApplication(), &popUpWindow, nil, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        popUpWindow = nil
        
        // メインウインドウをキーウインドウにする。
        UIApplication.sharedApplication().windows.first?.makeKeyAndVisible()
    }
    
    //カレンダーボタンをタップした時のアクション
    func buttonTapped(button: UIButton){
        
        // @todo:画面遷移等の処理を書くことができます。
        
        // コンソール表示
        println("\(year)年\(month)月\(button.tag)日が選択されました！")
        
        // Windowを開く
        //openWindow(button)
        
        // 画面遷移１
        //toSchedule(button)
        
        day = button.tag
        
        // 画面遷移２
        toScheduleView()
    }
    
    
    
    // どのクラスにもあるメソッド Memory監視？
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
*/

}
