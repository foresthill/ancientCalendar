//
//  SecondViewContoller.swift
//  handmadeCalenderSampleOfSwift
//
//  Created by Morioka Naoya on H27/07/29.
//  Copyright (c) 平成27年 just1factory. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景色を設定
        self.view.backgroundColor = UIColor.blue
        
        // ボタンを作成
        let backButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
        backButton.backgroundColor = UIColor.red
        backButton.layer.masksToBounds = true
        backButton.setTitle("Back", for: [])
        backButton.layer.cornerRadius = 20.0
        backButton.layer.position = CGPoint(x:self.view.bounds.width/2, y:self.view.bounds.height-50)
        backButton.addTarget(self, action: #selector(onClickMyButton), for: .touchUpInside)
        
        self.view.addSubview(backButton)
    }
    
    /*
    ボタンイベント
    */
    @objc internal func onClickMyButton(sender: UIButton){
        
        // 遷移するViewを定義
        let myViewController: UIViewController = FirstViewController()
        
        // アニメーションを設定
        myViewController.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        // Viewの移動
        self.present(myViewController, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
