//
//  FirstViewController.swift
//  handmadeCalenderSampleOfSwift
//
//  Created by Morioka Naoya on H27/07/29.
//  Copyright (c) 平成27年 just1factory. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をGreenに設定する
        self.view.backgroundColor = UIColor.green
        
        // ボタンを生成する
        let nextButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
        nextButton.backgroundColor = UIColor.red
        nextButton.layer.masksToBounds = true
        nextButton.setTitle("Next", for: [])
        nextButton.layer.cornerRadius = 20.0
        nextButton.layer.position = CGPoint(x:self.view.bounds.width/2, y:self.view.bounds.height-50)
        nextButton.addTarget(self, action: #selector(onClickMyButton), for: .touchUpInside)
        
        // ボタンを追加する
        self.view.addSubview(nextButton)
    }
    
    /*
    ボタンイベント
    */
    @objc internal func onClickMyButton(sender: UIButton){
        
        // 遷移するViewを定義する
        let mySecondViewController: UIViewController = SecondViewController()
        
        // アニメーションを定義する
        mySecondViewController.modalTransitionStyle = UIModalTransitionStyle.partialCurl
        
        // Viewの移動する
        self.present(mySecondViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
