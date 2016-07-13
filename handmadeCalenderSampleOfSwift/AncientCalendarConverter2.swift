//
//  AncientCalendarConverter2.swift
//  swift2版 旧暦変換クラス（シングルトン）
//
//  Created by Morioka Naoya on H28/04/12.
//  Copyright © 平成28年 foresthill. All rights reserved.
//

/**
 * 本プログラムは下記URLの「新暦・旧暦変換スクリプト」を基に作成しています。
 * http://koyomi8.com/
 *
 */

import Foundation
import EventKit
import EventKitUI

final class AncientCalendarConverter2
{

    //唯一のインスタンスをstaticとして用意
    static let sharedInstance = AncientCalendarConverter2()
    
    /** 旧暦・新暦変換テーブル（秘伝のタレ）*/
    let o2ntbl:[[Int]] = [[611,2350],[468,3222]	,[316,7317]	,[559,3402]	,[416,3493]
    ,[288,2901]	,[520,1388]	,[384,5467]	,[637,605]	,[494,2349]	,[343,6443]
    ,[585,2709]	,[442,2890]	,[302,5962]	,[533,2901]	,[412,2741]	,[650,1210]
    ,[507,2651]	,[369,2647]	,[611,1323]	,[468,2709]	,[329,5781]	,[559,1706]
    ,[416,2773]	,[288,2741]	,[533,1206]	,[383,5294]	,[624,2647]	,[494,1319]
    ,[356,3366]	,[572,3475]	,[442,1450]];
    
    var ancientTbl: [[Int]] //計算用テーブル
    var isLeapMonth:Int! //閏月の場合は-1（2016/02/06）
//    var minYear:Int!    //表示できる最小（最も過去）の年数
    var leapMonth: Int! //閏月
    var ommax:Int! //月数（その年に閏月があるかないかを判定する）
    
    //CalendarManagerクラス（シングルトン）
    //var calendarManager: CalendarManager!
    
    //イニシャライザをprivateに
    private init(){
        ancientTbl = Array(count: 14, repeatedValue:[0, 0])
        isLeapMonth = 0
        leapMonth = 0
        ommax = 12
        
        //calendarManager = CalendarManager.sharedInstance
    }
    
    //旧暦変換（2016/02/06）
    func convertForAncientCalendar(comps:NSDateComponents) -> [Int]{

        var yearByAncient:Int = comps.year
        var monthByAncient:Int = comps.month
        var dayByAncient:Int = comps.day

        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        var dayOfYear = calendar.ordinalityOfUnit(.Day, inUnit:.Year, forDate: calendar.dateFromComponents(comps)!)
        
        //旧暦テーブルを作成する
        tblExpand(yearByAncient)
        
        
        if(dayOfYear < ancientTbl[0][0]){   //旧暦で表すと、１年前になる場合
            yearByAncient -= 1;
            dayOfYear += (365 + isLeapYear(yearByAncient))
            tblExpand(yearByAncient)
        }
                
        //どの月の、何日目かをancientTblから引き出す
        for(var i=12; i>=0; i -= 1){
            if(ancientTbl[i][1] != 0){
                if(ancientTbl[i][0] <= dayOfYear){
                    monthByAncient = ancientTbl[i][1]
                    dayByAncient = dayOfYear - ancientTbl[i][0] + 1
                    break
                }
            }
        }
        
        //閏月判定
        if (monthByAncient < 0){
            isLeapMonth = -1;
            monthByAncient = -monthByAncient
        } else {
            isLeapMonth = 0
        }

        return [yearByAncient,monthByAncient,dayByAncient,isLeapMonth]
        
    }
    
    
    //旧暦→新暦変換
    func convertForGregorianCalendar(dateArray:[Int]) -> NSDateComponents{
        
        //イマを刻むコンポーネント（2016/02/07）
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        
        let compsByGregorian = calendar.components([.Year, .Month, .Day], fromDate: NSDate())    //とりあえずイマを返す
        
        var yearByGregorian = dateArray[0]
        let monthByGregorian = dateArray[1]
        var dayByGregorian = dateArray[2]
        //var templeapMonth = dateArray[3]
        
        tblExpand(yearByGregorian)
        
        var dayOfYear:Int!
        
        dayOfYear = -1
        
        for i in 0 ... 13{
            if(ancientTbl[i][1] == monthByGregorian){
                dayOfYear = ancientTbl[i][0] + dayByGregorian - 1
                break
            }
        }
        
        if(dayOfYear < 0){
            //該当日なし
            return compsByGregorian
        }
        
        var tmp:Int = 365 + isLeapYear(yearByGregorian)
        
        if(dayOfYear > tmp){
            dayOfYear = dayOfYear - tmp;
            yearByGregorian += 1
        }
        
        dayByGregorian = -1
        
        compsByGregorian.year = yearByGregorian  //2016.3.20 毎年2/29が存在する件 修正
        compsByGregorian.day = 1
        
        for(var i=12; i>=1; i -= 1){
            compsByGregorian.month = i
            tmp = calendar.ordinalityOfUnit(.Day, inUnit:.Year, forDate:calendar.dateFromComponents(compsByGregorian)!)
            if(dayOfYear >= tmp){
                dayByGregorian = dayOfYear - tmp + 1
                break
            }
        }
        
        if(dayByGregorian < 0){
            return compsByGregorian   //とりあえずイマを返す
            
        }
        
        compsByGregorian.year = yearByGregorian
        //compsByGregorian.month = monthByGregorian
        compsByGregorian.day = dayByGregorian
        
        return compsByGregorian
        
    }
    
    
    //閏年判定（trueなら1、falseなら0を返す）→逆になっているのは、閏年の場合convertForAncientCalendar内で365に1追加したいため
    func isLeapYear(inYear: Int) -> Int{
        var isLeap = 0
        if(inYear % 400 == 0 || (inYear % 4 == 0 && inYear % 100 != 0)){
            isLeap = 1
        }
        return isLeap
    }
    
    //旧暦・新暦テーブル生成（ancientTbl）
    func tblExpand(inYear: Int){
        var days:Double = Double(o2ntbl[inYear - Constants.minYear][0])
        var bits:Int = o2ntbl[inYear - Constants.minYear][1]    //bit？
        leapMonth = Int(days) % 13          //閏月
        
        days = floor((Double(days) / 13.0) + 0.001) //旧暦年初の新暦年初からの日数
        
        ancientTbl[0] = [Int(days), 1]  //旧暦正月の通日と、月数
        
        if(leapMonth == 0){
            bits *= 2   //閏無しなら、１２ヶ月
            ommax = 12
        } else {
            ommax = 13
        }
        
        for i in 1...ommax {
            ancientTbl[i] = [ancientTbl[i-1][0]+29, i+1]    //[旧暦の日数, 月]をループで入れる
            if(bits >= 4096) {
                ancientTbl[i][0] += 1    //大の月（30日ある月）
            }
            bits = (bits % 4096) * 2;
            
        }
        ancientTbl[ommax][1] = 0    //テーブルの終わり＆旧暦の翌年年初
        
        if (ommax > 12){    //閏月のある年
            for i in leapMonth+1 ... 12{
                ancientTbl[i][1] = i    //月を再計算
            }
            ancientTbl[leapMonth][1] = -leapMonth;   //識別のため閏月はマイナスで記録
        } else {
            ancientTbl[13] = [0, 0] //使ってないけどエラー防止で。
        }
        
    }
    
};