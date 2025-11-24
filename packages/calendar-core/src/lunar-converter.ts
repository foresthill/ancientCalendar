/**
 * 旧暦変換
 *
 * iOS Swift実装参照: apps/ios/AncientCalendar/Sources/Calendar/LunarConverter.swift
 * lunar-javascriptライブラリを使用
 */

import { Solar, Lunar } from 'lunar-javascript';

export interface CalendarDate {
  gregorian: {
    year: number;
    month: number;
    day: number;
    weekday: string;
  };
  lunar: {
    year: number;
    month: number;
    day: number;
    isLeapMonth: boolean;
    monthName: string;
    dayName: string;
    zodiac: string;
    ganzhiYear: string;
    ganzhiMonth: string;
    ganzhiDay: string;
    solarTerm?: string;
  };
}

export class LunarConverter {
  /**
   * 新暦から旧暦へ変換
   *
   * @param year - 西暦年
   * @param month - 月（1-12）
   * @param day - 日（1-31）
   * @returns 新暦と旧暦の情報を含むオブジェクト
   */
  static gregorianToLunar(
    year: number,
    month: number,
    day: number
  ): CalendarDate {
    const solar = Solar.fromYmd(year, month, day);
    const lunar = solar.getLunar();

    return {
      gregorian: {
        year: solar.getYear(),
        month: solar.getMonth(),
        day: solar.getDay(),
        weekday: typeof solar.getWeekInChinese === 'function' ? solar.getWeekInChinese() : ''
      },
      lunar: {
        year: lunar.getYear(),
        month: lunar.getMonth(),
        day: lunar.getDay(),
        isLeapMonth: typeof lunar.isLeap === 'function' ? lunar.isLeap() : false,
        monthName: typeof lunar.getMonthInChinese === 'function' ? lunar.getMonthInChinese() : String(lunar.getMonth()),
        dayName: typeof lunar.getDayInChinese === 'function' ? lunar.getDayInChinese() : String(lunar.getDay()),
        zodiac: typeof lunar.getYearShengXiao === 'function' ? lunar.getYearShengXiao() : '',
        ganzhiYear: typeof lunar.getYearInGanZhi === 'function' ? lunar.getYearInGanZhi() : '',
        ganzhiMonth: typeof lunar.getMonthInGanZhi === 'function' ? lunar.getMonthInGanZhi() : '',
        ganzhiDay: typeof lunar.getDayInGanZhi === 'function' ? lunar.getDayInGanZhi() : '',
        solarTerm: typeof lunar.getJieQi === 'function' ? lunar.getJieQi() : undefined
      }
    };
  }

  /**
   * 旧暦から新暦へ変換
   *
   * @param year - 旧暦年
   * @param month - 旧暦月（1-13、閏月含む）
   * @param day - 旧暦日（1-30）
   * @param isLeapMonth - 閏月かどうか
   * @returns 新暦のDateオブジェクト
   */
  static lunarToGregorian(
    year: number,
    month: number,
    day: number,
    isLeapMonth: boolean = false
  ): Date {
    const lunar = Lunar.fromYmd(year, month, day, isLeapMonth);
    const solar = lunar.getSolar();
    return new Date(solar.getYear(), solar.getMonth() - 1, solar.getDay());
  }

  /**
   * 今日の旧暦日付を取得
   */
  static today(): CalendarDate {
    const now = new Date();
    return this.gregorianToLunar(
      now.getFullYear(),
      now.getMonth() + 1,
      now.getDate()
    );
  }

  /**
   * 指定月の全日付を取得
   *
   * @param year - 年
   * @param month - 月
   * @returns その月の全日付の新暦・旧暦情報
   */
  static getMonthDates(year: number, month: number): CalendarDate[] {
    const daysInMonth = new Date(year, month, 0).getDate();
    const dates: CalendarDate[] = [];

    for (let day = 1; day <= daysInMonth; day++) {
      dates.push(this.gregorianToLunar(year, month, day));
    }

    return dates;
  }
}
