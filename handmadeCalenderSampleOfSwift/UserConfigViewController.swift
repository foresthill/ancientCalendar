//
//  UserConfigViewController.swift
//  ユーザ設定画面
//
//  Created by Morioka Naoya on H28/05/24.
//  Copyright (c) 2016 foresthill. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import EventKitUI   //EKEventEditViewController

class UserConfigViewController: UIViewController {
    
    @IBOutlet weak var scrollNatural: UISwitch!
    
    //ユーザ設定保存用変数
    var config: NSUserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config = NSUserDefaults.standardUserDefaults()
        
        let defaultConfig = config.objectForKey("scrollNatural")
        if(defaultConfig != nil){
            scrollNatural.on = defaultConfig as! Bool
        }
        
        // タイトルの設定
        self.navigationItem.title = "ユーザ設定"
        //self.navigationItem.prompt = ""
        
        
    }
    
    //「戻る」ボタン押下時に呼ばれるメソッド
    override func viewWillDisappear(animated: Bool) {
        
        //ユーザ設定に保存
        config.setObject(scrollNatural.on, forKey: "scrollNatural")
        
        let viewControllers = self.navigationController?.viewControllers
        let vc:ViewController = viewControllers?.first as! ViewController
        vc.scrollNatural = scrollNatural.on
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


