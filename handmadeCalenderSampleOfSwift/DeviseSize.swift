//
//  DeviseSize.swift
//  handmadeCalenderSampleOfSwift
//
//  Created by 酒井文也 on 2015/01/09.
//  Copyright (c) 2015年 just1factory. All rights reserved.
//

/**
 * 本コードは下記のURLのものを使用しています。
 * http://swift-salaryman.com/uiscreenutil.php
 *
 */

import UIKit

struct DeviseSize {
    
    //CGRectを取得
    static func bounds()->CGRect{
        return UIScreen.main.bounds;
    }
    
    //画面の横サイズを取得
    static func screenWidth()->Int{
        return Int(UIScreen.main.bounds.size.width);
    }
    
    //画面の縦サイズを取得
    static func screenHeight()->Int{
        return Int(UIScreen.main.bounds.size.height);
    }
    
    // 現代的なiPhoneの場合は別の設定を使用
    static func isModernIPhone() -> Bool {
        // iPhone X以降の特徴的な特性（ノッチあり）の場合はtrue
        // iPhone X以降はすべて横幅が375以上
        return screenWidth() >= 375 && UIScreen.main.nativeBounds.height >= 2436
    }
}