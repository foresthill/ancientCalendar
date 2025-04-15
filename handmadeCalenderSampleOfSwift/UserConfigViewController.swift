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
    var config: UserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config = UserDefaults.standard
        
        let defaultConfig = config.object(forKey: "scrollNatural")
        if(defaultConfig != nil){
            scrollNatural.isOn = defaultConfig as! Bool
        }
        
        // タイトルの設定
        self.navigationItem.title = "ユーザ設定"
        //self.navigationItem.prompt = ""
        
        
    }
    
    //「戻る」ボタン押下時に呼ばれるメソッド
    override func viewWillDisappear(_ animated: Bool) {
        
        //ユーザ設定に保存
        config.set(scrollNatural.isOn, forKey: "scrollNatural")
        
        let viewControllers = self.navigationController?.viewControllers
        let vc:ViewController = viewControllers?.first as! ViewController
        vc.scrollNatural = scrollNatural.isOn
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


