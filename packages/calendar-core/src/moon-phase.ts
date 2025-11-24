/**
 * 月齢計算
 *
 * iOS Swift実装参照: apps/ios/AncientCalendar/Sources/Moon/MoonPhase.swift
 * Astronomical Algorithms (Jean Meeus)
 *
 * ⭐ 重要: 28枚の月画像を使用して精密な表現を実現
 */

export type MoonPhaseName =
  | 'new'
  | 'waxing-crescent'
  | 'first-quarter'
  | 'waxing-gibbous'
  | 'full'
  | 'waning-gibbous'
  | 'last-quarter'
  | 'waning-crescent';

export interface MoonPhase {
  age: number;
  phase: MoonPhaseName;
  illumination: number;
  imageIndex: number;
  imagePath: string;
}

export class MoonPhaseCalculator {
  /**
   * 指定日の月齢情報を計算
   *
   * @param date - 対象日
   * @returns 月齢、フェーズ、照度、画像情報
   */
  static calculate(date: Date): MoonPhase {
    const age = this.getMoonAge(date);
    const phase = this.getPhaseName(age);
    const illumination = this.getIllumination(age);
    const imageIndex = this.getImageIndex(age);
    const imagePath = this.getImagePath(imageIndex);

    return { age, phase, illumination, imageIndex, imagePath };
  }

  /**
   * 月齢を計算（Astronomical Algorithms）
   *
   * @param date - 対象日
   * @returns 月齢（0-29.53日）
   */
  private static getMoonAge(date: Date): number {
    const jd = this.getJulianDay(date);
    const newMoonJD = 2451550.1;
    const synodicMonth = 29.53058867;
    const daysSinceNewMoon = jd - newMoonJD;
    const age = daysSinceNewMoon % synodicMonth;
    return age >= 0 ? age : age + synodicMonth;
  }

  /**
   * ユリウス日を計算
   *
   * @param date - 対象日
   * @returns ユリウス日
   */
  private static getJulianDay(date: Date): number {
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();

    const a = Math.floor((14 - month) / 12);
    const y = year + 4800 - a;
    const m = month + 12 * a - 3;

    const jdn =
      day +
      Math.floor((153 * m + 2) / 5) +
      365 * y +
      Math.floor(y / 4) -
      Math.floor(y / 100) +
      Math.floor(y / 400) -
      32045;

    const jd =
      jdn +
      (date.getHours() - 12) / 24 +
      date.getMinutes() / 1440 +
      date.getSeconds() / 86400;

    return jd;
  }

  /**
   * 月齢からフェーズ名を取得
   *
   * @param age - 月齢
   * @returns フェーズ名
   */
  private static getPhaseName(age: number): MoonPhaseName {
    if (age < 1.84566) return 'new';
    if (age < 7.38264) return 'waxing-crescent';
    if (age < 9.2283) return 'first-quarter';
    if (age < 14.76528) return 'waxing-gibbous';
    if (age < 16.61094) return 'full';
    if (age < 22.14792) return 'waning-gibbous';
    if (age < 24.99358) return 'last-quarter';
    return 'waning-crescent';
  }

  /**
   * 照度を計算
   *
   * @param age - 月齢
   * @returns 照度（0-100%）
   */
  private static getIllumination(age: number): number {
    const phase = (age / 29.53) * 2 * Math.PI;
    return 50 * (1 - Math.cos(phase));
  }

  /**
   * 月齢から画像インデックスを取得
   *
   * ⭐ iOS版と同じアルゴリズム
   * 28枚の画像を使用（0-27）
   *
   * @param age - 月齢（0-29.53）
   * @returns 画像インデックス（0-27）
   */
  private static getImageIndex(age: number): number {
    const index = Math.floor((age / 29.53) * 28);
    return Math.min(Math.max(index, 0), 27);
  }

  /**
   * 画像パスを取得
   *
   * @param index - 画像インデックス（0-27）
   * @returns 画像パス
   */
  private static getImagePath(index: number): string {
    return `/images/moon/moon${index}_90x90.png`;
  }

  /**
   * 今日の月齢を取得
   *
   * @returns 今日の月齢情報
   */
  static today(): MoonPhase {
    return this.calculate(new Date());
  }

  /**
   * 特定の月齢に最も近い日付を取得
   *
   * @param targetAge - 目標月齢（0-29.53）
   * @param startDate - 開始日（デフォルト: 今日）
   * @returns 最も近い日付
   */
  static findDateByAge(targetAge: number, startDate: Date = new Date()): Date {
    let bestDate = startDate;
    let minDiff = Math.abs(this.getMoonAge(startDate) - targetAge);

    for (let offset = -30; offset <= 30; offset++) {
      const date = new Date(startDate);
      date.setDate(date.getDate() + offset);

      const age = this.getMoonAge(date);
      const diff = Math.abs(age - targetAge);

      if (diff < minDiff) {
        minDiff = diff;
        bestDate = date;
      }
    }

    return bestDate;
  }
}
