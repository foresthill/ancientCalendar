//
//  MyNavigationController.swift
//  AncientCalendar
//
//  Created by Morioka Naoya on H28/05/04.
//  Copyright © 平成28年 foresthill. All rights reserved.
//

import UIKit

class MyNavigationController: UINavigationController {
    // ステータスバーのスタイルを設定するためのメソッド
    override func viewDidLoad() {
        super.viewDidLoad()
        // ここでステータスバーのスタイルを設定する場合
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        // 表示中のビューコントローラのステータスバースタイルを取得
        if let visController = visibleViewController {
            return visController.preferredStatusBarStyle
        }
        return .default
    }
}
