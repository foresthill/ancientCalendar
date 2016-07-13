//
//  Designer.swift
//  AncientCalendar
//
//  Created by Morioka Naoya on H28/07/10.
//  Copyright © 平成28年 just1factory. All rights reserved.
//

import Foundation
import UIKit

class Designer {
    
    //シングルトン
    static let sharedInstance = Designer()
    
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
    var navigationTextAttributes: [String: AnyObject]!  //ナビゲーションの文字色（２）
    var navigationBarTintColor: UIColor!    //ナビゲーションバーの色
    
    var prevMonthButtonBgColor: UIColor!    //「前へ」ボタンの背景色
    var nextMonthButtonBgColor: UIColor!    //「次へ」ボタンの背景色
    
    /** 初期化処理（インスタンス化禁止） */
    private init() {
        //色の標準化・共通化（2016/05/05） ※RGBカラーの設定は小数値をCGFloat型にしてあげる
        baseNormal = UIColor.lightGrayColor()
        baseRed = UIColor(red: CGFloat(0.831), green: CGFloat(0.349), blue: CGFloat(0.224), alpha: CGFloat(1.0))
        baseBlue = UIColor(red: CGFloat(0.400), green: CGFloat(0.471), blue: CGFloat(0.980), alpha: CGFloat(1.0))
        baseBlack = UIColor.blackColor()
        baseDarkGray = UIColor.darkGrayColor()
        
        //画面初期化・最適化
        screenInit()
        
    }
    
    /** 画面初期化・最適化 */
    func screenInit() {
        //現在起動中のデバイスを取得（スクリーンの幅・高さ）
        let screenWidth  = DeviseSize.screenWidth()
        let screenHeight = DeviseSize.screenHeight()
        
//        var prevMonthButtonFrame = CGRect()
//        var nextMonthButtonFrame = CGRect()
        
        //iPhone4s
        if(screenWidth == 320 && screenHeight == 480){
            
            calendarLabelIntervalX = 5;
            calendarLabelX         = 45;
            calendarLabelY         = 93;
            calendarLabelWidth     = 40;
            calendarLabelHeight    = 25;
            calendarLabelFontSize  = 14;
            
            buttonRadius           = 20.0;
            
            calendarIntervalX      = 5;
            calendarX              = 45;
            calendarIntervalY      = 120;
            calendarY              = 45;
            calendarSize           = 40;
            calendarFontSize       = 17;
            
            //iPhone5またはiPhone5s
        }else if (screenWidth == 320 && screenHeight == 568){
            
            calendarLabelIntervalX = 5;
            calendarLabelX         = 45;
            calendarLabelY         = 93;
            calendarLabelWidth     = 40;
            calendarLabelHeight    = 25;
            calendarLabelFontSize  = 14;
            
            buttonRadius           = 20.0;
            
            calendarIntervalX      = 5;
            calendarX              = 45;
            calendarIntervalY      = 120;
            calendarY              = 45;
            calendarSize           = 40;
            calendarFontSize       = 17;
            
            //iPhone6
        }else if (screenWidth == 375 && screenHeight == 667){
            
            calendarLabelIntervalX = 15;
            calendarLabelX         = 50;
            calendarLabelY         = 95;
            calendarLabelWidth     = 45;
            calendarLabelHeight    = 25;
            calendarLabelFontSize  = 16;
            
            buttonRadius           = 22.5;
            
            calendarIntervalX      = 15;
            calendarX              = 50;
            calendarIntervalY      = 125;
            calendarY              = 50;
            calendarSize           = 45;
            calendarFontSize       = 19;
            
//            self.prevMonthButton.frame = CGRectMake(15, 438, CGFloat(calendarSize), CGFloat(calendarSize));
//            self.nextMonthButton.frame = CGRectMake(314, 438, CGFloat(calendarSize), CGFloat(calendarSize));
            prevMonthButtonFrame = CGRectMake(15, 438, CGFloat(calendarSize), CGFloat(calendarSize));
            nextMonthButtonFrame = CGRectMake(314, 438, CGFloat(calendarSize), CGFloat(calendarSize));
            
            //iPhone6 plus
        }else if (screenWidth == 414 && screenHeight == 736){
            
            calendarLabelIntervalX = 15;
            calendarLabelX         = 55;
            calendarLabelY         = 95;
            calendarLabelWidth     = 55;
            calendarLabelHeight    = 25;
            calendarLabelFontSize  = 18;
            
            buttonRadius           = 25;
            
            calendarIntervalX      = 18;
            calendarX              = 55;
            calendarIntervalY      = 125;
            calendarY              = 55;
            calendarSize           = 50;
            calendarFontSize       = 21;
            
//            self.prevMonthButton.frame = CGRectMake(18, 468, CGFloat(calendarSize), CGFloat(calendarSize));
//            self.nextMonthButton.frame = CGRectMake(348, 468, CGFloat(calendarSize), CGFloat(calendarSize));
            prevMonthButtonFrame = CGRectMake(18, 468, CGFloat(calendarSize), CGFloat(calendarSize));
            nextMonthButtonFrame = CGRectMake(348, 468, CGFloat(calendarSize), CGFloat(calendarSize));
            
        }
        
        //ボタンを角丸にする
        //prevMonthButton.layer.cornerRadius = CGFloat(buttonRadius)
        //nextMonthButton.layer.cornerRadius = CGFloat(buttonRadius)
        
        //return (prevMonthButtonFrame, nextMonthButtonFrame)
        
    }

    /** ボタンのフォントをセット */
    func setFont(strBtn: String, addDate: String) -> NSMutableAttributedString {
        //文字のフォント・文字色などをNSMutableAttributedStringで設定
        
        //大きい日付の文字色
        let mutableAttributedString:NSMutableAttributedString = NSMutableAttributedString(
            string: strBtn,
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(11.9)])
        
        //大きい日付のフォントサイズ
        mutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location: 0, length: (strBtn.characters.count - addDate.characters.count)))
        
        //小さい日付の文字色
        mutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(
            red: CGFloat(0.989), green: CGFloat(0.919), blue: CGFloat(0.756), alpha: CGFloat(0.9)),
                                     range: NSRange(location: (strBtn.characters.count - addDate.characters.count), length: addDate.characters.count))   //0.971,0.749, 0.456
        
        //小さい日付のフォントサイズ
        mutableAttributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(7.3),
                                     range: NSRange(location: (strBtn.characters.count - addDate.characters.count), length: addDate.characters.count))   //7.6
        
        //文字に影をつける（2016/07/10）
        let shadow: NSShadow = NSShadow()
        //shadow.shadowColo
        shadow.shadowOffset = CGSizeMake(1.0, 1.0)
        mutableAttributedString.addAttribute(NSShadowAttributeName, value: shadow, range: NSRange(location: 0, length: strBtn.characters.count))
        
        return mutableAttributedString
    }
    
    /** 色をセット */
    func setColor(calendarMode: Int) {
        if(calendarMode == -1){
            //旧暦モード
            backgroundColor = UIColor(red: 15/255, green: 21/255, blue: 36/255, alpha: 1.0)
            calendarBarBgColor = UIColor(red: 8/255, green: 8/255, blue: 21/255, alpha: 1.0)
            navigationTintColor = UIColor(red: 207/255, green: 215/255, blue: 234/255, alpha: 1.0)
            navigationTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 207/255, green: 215/255, blue: 234/255, alpha: 1.0)]
            navigationBarTintColor = UIColor(red: 15/255, green: 16/255, blue: 19/255, alpha: 1.0)
            prevMonthButtonBgColor = UIColor(red: 30/255, green: 125/255, blue: 108/255, alpha: 1.0)
            nextMonthButtonBgColor = UIColor(red: 47/255, green: 103/255, blue: 127/255, alpha: 1.0)
        } else {
            //新暦モード
            backgroundColor = UIColor.whiteColor()
            calendarBarBgColor = UIColor(red: 235/255, green: 208/255, blue: 185/255, alpha: 1.0)
            navigationTintColor = UIColor.blackColor()
            navigationTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
            navigationBarTintColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
            prevMonthButtonBgColor = UIColor(red: 112/255, green: 229/255, blue: 208/255, alpha: 1.0)
            nextMonthButtonBgColor = UIColor(red: 161/255, green: 209/255, blue: 230/255, alpha: 1.0)
        }
    }
    
    /** ボタン生成時に呼び出されるメソッド */
    func generateCalendarButton(i: Int){
    
    }
    
    
}