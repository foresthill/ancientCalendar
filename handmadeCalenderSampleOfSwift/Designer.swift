//
//  Designer.swift
//  AncientCalendar
//
//  Created by Morioka Naoya on H28/07/10.
//  Copyright © 2016-2025 just1factory. All rights reserved.
//

import Foundation
import UIKit

class Designer {
    
    //シングルトン
    static let sharedInstance = Designer()
    
    //スクリーンの幅・高さ
    var screenWidth: Int!
    var screenHeight: Int!
    
    //カレンダーの位置決め用メンバ変数
    var calendarLabelIntervalX: Int!
    var calendarLabelX: Int!
    var calendarLabelY: Int!
    var calendarLabelWidth: Int!
    var calendarLabelHeight: Int!
    var calendarLabelFontSize: Int!
    var calendarIntervalX: Int!
    var calendarX: Int!
    var calendarIntervalY: Int!
    var calendarY: Int!
    var calendarSize: Int!
    var calendarFontSize: Int!
    
    //ボタンを丸めるかどうか
    var buttonRadius: Float!
    
    //「前へ」「次へ」のFrameを設定
    var prevMonthButtonFrame: CGRect!
    var nextMonthButtonFrame: CGRect!
    
    //色の標準化・共通化（2016/05/05）
    var baseNormal: UIColor!    //標準のラベルカラー
    var baseRed: UIColor!       //日曜、大安で使用
    var baseBlue: UIColor!      //土曜、仏滅で使用
    var baseBlack: UIColor!     //旧暦表示の背景に表示（2016.05.17追加）
    var baseDarkGray: UIColor!  //旧暦表示の背景に表示（2016.05.24追加）
    
    //色
    var backgroundColor: UIColor!           //背景色
    var calendarBarBgColor: UIColor!        //バーの背景色
    
    var navigationTintColor: UIColor!       //ナビゲーションの文字色
    var navigationTextAttributes: [NSAttributedString.Key: Any]?  //ナビゲーションの文字色（２）
    var navigationBarTintColor: UIColor!    //ナビゲーションバーの色
    
    var prevMonthButtonBgColor: UIColor!    //「前へ」ボタンの背景色
    var nextMonthButtonBgColor: UIColor!    //「次へ」ボタンの背景色
    
    /** 初期化処理（インスタンス化禁止） */
    private init() {
        //色の標準化・共通化（2016/05/05） ※RGBカラーの設定は小数値をCGFloat型にしてあげる
        baseNormal = UIColor.lightGray
        baseRed = UIColor(red: CGFloat(0.831), green: CGFloat(0.349), blue: CGFloat(0.224), alpha: CGFloat(1.0))
        baseBlue = UIColor(red: CGFloat(0.400), green: CGFloat(0.471), blue: CGFloat(0.980), alpha: CGFloat(1.0))
        baseBlack = UIColor.black
        baseDarkGray = UIColor.darkGray
        
        //画面初期化・最適化
        //カレンダー設定を初期化
        screenInit()
        
    }
    
    /** 画面初期化・最適化 */
    func screenInit() {
        
//        var prevMonthButtonFrame = CGRect()
//        var nextMonthButtonFrame = CGRect()
        
        //現在起動中のデバイスを取得（スクリーンの幅・高さ）
        screenWidth  = DeviseSize.screenWidth()
        screenHeight = DeviseSize.screenHeight()
        
        // 現代的なiPhone（iPhone X以降）なら特別な処理を行う
        let isModern = DeviseSize.isModernIPhone()

        //iPhone4s
        if(screenWidth == 320 && screenHeight == 480){
            
            calendarLabelIntervalX = 5;
            calendarLabelX         = 45;
            calendarLabelY         = 120;
            calendarLabelWidth     = 40;
            calendarLabelHeight    = 25;
            calendarLabelFontSize  = 14;
            
            buttonRadius           = 20.0;
            
            calendarIntervalX      = 5;
            calendarX              = 45;
            calendarIntervalY      = 150;
            calendarY              = 45;
            calendarSize           = 40;
            calendarFontSize       = 17;
            
        //iPhone5またはiPhone5s
        } else if (screenWidth == 320 && screenHeight == 568){
            
            calendarLabelIntervalX = 5;
            calendarLabelX         = 45;
            calendarLabelY         = 120;
            calendarLabelWidth     = 40;
            calendarLabelHeight    = 25;
            calendarLabelFontSize  = 14;
            
            buttonRadius           = 20.0;
            
            calendarIntervalX      = 5;
            calendarX              = 45;
            calendarIntervalY      = 150;
            calendarY              = 45;
            calendarSize           = 40;
            calendarFontSize       = 17;
            
        //iPhone6
        } else if (screenWidth == 375 && screenHeight == 667){
            
            calendarLabelIntervalX = 15;
            calendarLabelX         = 50;
            calendarLabelY         = 120;
            calendarLabelWidth     = 45;
            calendarLabelHeight    = 25;
            calendarLabelFontSize  = 16;
            
            buttonRadius           = 22.5;
            
            calendarIntervalX      = 15;
            calendarX              = 50;
            calendarIntervalY      = 150;
            calendarY              = 50;
            calendarSize           = 45;
            calendarFontSize       = 19;
            
//            self.prevMonthButton.frame = CGRectMake(15, 438, CGFloat(calendarSize), CGFloat(calendarSize));
//            self.nextMonthButton.frame = CGRectMake(314, 438, CGFloat(calendarSize), CGFloat(calendarSize));
            prevMonthButtonFrame = CGRect(x: 15, y: 438, width: CGFloat(calendarSize), height: CGFloat(calendarSize));
            nextMonthButtonFrame = CGRect(x: 314, y: 438, width: CGFloat(calendarSize), height: CGFloat(calendarSize));
            
        //iPhone6 plus
        } else if (screenWidth == 414 && screenHeight == 736){
            
            calendarLabelIntervalX = 15;
            calendarLabelX         = 55;
            calendarLabelY         = 120;
            calendarLabelWidth     = 55;
            calendarLabelHeight    = 25;
            calendarLabelFontSize  = 18;
            
            buttonRadius           = 25;
            
            calendarIntervalX      = 18;
            calendarX              = 55;
            calendarIntervalY      = 150;
            calendarY              = 55;
            calendarSize           = 50;
            calendarFontSize       = 21;
            
            prevMonthButtonFrame = CGRect(x: 18, y: 468, width: CGFloat(calendarSize), height: CGFloat(calendarSize));
            nextMonthButtonFrame = CGRect(x: 348, y: 468, width: CGFloat(calendarSize), height: CGFloat(calendarSize));
            
        // 現代的なiPhoneやその他の未定義のスクリーン
        } else {
            // 適応型レイアウト - iPhoneの幅に合わせて計算
            let widthRatio = Double(screenWidth ?? 375) / 375.0 // iPhone 6/7/8を基準に倍率を計算
            
            calendarLabelIntervalX = Int(15 * widthRatio);
            calendarLabelX         = Int(50 * widthRatio);
            calendarLabelY         = Int(120 * widthRatio);
            calendarLabelWidth     = Int(45 * widthRatio);
            calendarLabelHeight    = Int(25 * widthRatio);
            calendarLabelFontSize  = Int(16 * widthRatio);
            
            buttonRadius           = Float(25 * widthRatio);
            
            calendarIntervalX      = Int(15 * widthRatio);
            calendarX              = Int(50 * widthRatio);
            calendarIntervalY      = Int(150 * widthRatio);
            calendarY              = Int(50 * widthRatio);
            calendarSize           = Int(45 * widthRatio);
            calendarFontSize       = Int(19 * widthRatio);
            
            // 「前へ」「次へ」ボタンの位置
            let buttonY = screenHeight - 150 // 画面下部から固定位置
            let leftX = Int(20 * widthRatio)
            let rightX = screenWidth - Int(70 * widthRatio)
            
            prevMonthButtonFrame = CGRect(x: CGFloat(leftX), y: CGFloat(buttonY), width: CGFloat(calendarSize), height: CGFloat(calendarSize));
            nextMonthButtonFrame = CGRect(x: CGFloat(rightX), y: CGFloat(buttonY), width: CGFloat(calendarSize), height: CGFloat(calendarSize));
            
        }
        
        //ボタンを角丸にする
        //prevMonthButton.layer.cornerRadius = CGFloat(buttonRadius)
        //nextMonthButton.layer.cornerRadius = CGFloat(buttonRadius)
        
        //return (prevMonthButtonFrame, nextMonthButtonFrame)
        
    }

    /** ボタンのフォントをセット */
    func setFont(_ strBtn: String, addDate: String) -> NSMutableAttributedString {
        //文字のフォント・文字色などをNSMutableAttributedStringで設定
        
        //大きい日付の文字色
        let mutableAttributedString:NSMutableAttributedString = NSMutableAttributedString(
            string: strBtn,
            attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 11.9)])
        
        //大きい日付のフォントサイズ
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: (strBtn.count - addDate.count)))
        
        //小さい日付の文字色
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(
            red: CGFloat(0.989), green: CGFloat(0.919), blue: CGFloat(0.756), alpha: CGFloat(0.9)),
                                     range: NSRange(location: (strBtn.count - addDate.count), length: addDate.count))   //0.971,0.749, 0.456
        
        //小さい日付のフォントサイズ
        mutableAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 7.3),
                                     range: NSRange(location: (strBtn.count - addDate.count), length: addDate.count))   //7.6
        
        //文字に影をつける（2016/07/10）
        let shadow: NSShadow = NSShadow()
        //shadow.shadowColo
        shadow.shadowOffset = CGSize(width: 1.0, height: 1.0)
        mutableAttributedString.addAttribute(NSAttributedString.Key.shadow, value: shadow, range: NSRange(location: 0, length: strBtn.count))
        
        return mutableAttributedString
    }
    
    /** 色をセット */
    func setColor(_ calendarMode: Int) {
        if(calendarMode == -1){
            //旧暦モード
            backgroundColor = UIColor(red: 15/255, green: 21/255, blue: 36/255, alpha: 1.0)
            calendarBarBgColor = UIColor(red: 8/255, green: 8/255, blue: 21/255, alpha: 1.0)
            navigationTintColor = UIColor(red: 207/255, green: 215/255, blue: 234/255, alpha: 1.0)
            navigationTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 207/255, green: 215/255, blue: 234/255, alpha: 1.0)]
            navigationBarTintColor = UIColor(red: 15/255, green: 16/255, blue: 19/255, alpha: 1.0)
            prevMonthButtonBgColor = UIColor(red: 30/255, green: 125/255, blue: 108/255, alpha: 1.0)
            nextMonthButtonBgColor = UIColor(red: 47/255, green: 103/255, blue: 127/255, alpha: 1.0)
        } else {
            //新暦モード
            backgroundColor = UIColor.white
            calendarBarBgColor = UIColor(red: 235/255, green: 208/255, blue: 185/255, alpha: 1.0)
            navigationTintColor = UIColor.black
            navigationTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black as AnyObject]
            navigationBarTintColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
            prevMonthButtonBgColor = UIColor(red: 112/255, green: 229/255, blue: 208/255, alpha: 1.0)
            nextMonthButtonBgColor = UIColor(red: 161/255, green: 209/255, blue: 230/255, alpha: 1.0)
        }
    }
    
    /** ボタン生成時に呼び出されるメソッド */
    func generateCalendarButton(i: Int){
    
    }
    
    
}
