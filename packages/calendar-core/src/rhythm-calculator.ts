/**
 * 月のリズム計算
 *
 * 月のフェーズに基づく推奨活動やエネルギーレベルを提供
 */

import { MoonPhaseName } from './moon-phase';

export type EnergyLevel = 'low' | 'rising' | 'high' | 'waning';

export interface MoonRhythm {
  phase: MoonPhaseName;
  energy: EnergyLevel;
  recommendations: {
    health: string[];
    mindfulness: string[];
    activities: string[];
  };
  description: string;
}

export class RhythmCalculator {
  /**
   * 月のフェーズからリズム情報を取得
   *
   * @param phase - 月のフェーズ名
   * @returns リズム情報
   */
  static getRecommendations(phase: MoonPhaseName): MoonRhythm {
    const rhythms: Record<MoonPhaseName, MoonRhythm> = {
      new: {
        phase: 'new',
        energy: 'low',
        recommendations: {
          health: [
            '新しい健康習慣を始める',
            '断食・デトックス',
            '休息を取る'
          ],
          mindfulness: [
            '瞑想',
            '意図設定',
            '新月の願い事',
            'ジャーナリング'
          ],
          activities: [
            '計画立案',
            '目標設定',
            'リフレクション',
            '新しいプロジェクトの開始'
          ]
        },
        description:
          'リセットと新しい始まりの時期。内省し、新しい意図を設定しましょう。'
      },
      'waxing-crescent': {
        phase: 'waxing-crescent',
        energy: 'rising',
        recommendations: {
          health: [
            '運動開始',
            '栄養摂取の強化',
            '新しいフィットネスルーティン'
          ],
          mindfulness: ['ポジティブアファメーション', 'ビジュアライゼーション'],
          activities: [
            '行動開始',
            'プロジェクト推進',
            '学習開始',
            'ネットワーキング'
          ]
        },
        description:
          'エネルギーが高まる時期。行動を起こし、目標に向かって進みましょう。'
      },
      'first-quarter': {
        phase: 'first-quarter',
        energy: 'rising',
        recommendations: {
          health: ['アクティブな運動', 'チャレンジングなワークアウト'],
          mindfulness: ['決断を下す', '障害を乗り越える'],
          activities: ['困難な決断', '問題解決', '調整と修正']
        },
        description:
          '行動と決断の時期。障害に立ち向かい、調整を行いましょう。'
      },
      'waxing-gibbous': {
        phase: 'waxing-gibbous',
        energy: 'high',
        recommendations: {
          health: ['持久力トレーニング', 'エネルギーレベルを活用'],
          mindfulness: ['詳細の洗練', '完璧を目指す'],
          activities: ['プロジェクトの仕上げ', '細部の調整', '準備を整える']
        },
        description:
          '完成に向けた最終段階。細部を整え、準備を完了させましょう。'
      },
      full: {
        phase: 'full',
        energy: 'high',
        recommendations: {
          health: [
            'エネルギーが高い時期',
            '積極的な運動',
            '社交的な活動'
          ],
          mindfulness: ['感謝の実践', '手放しの儀式', '満月の瞑想'],
          activities: [
            '完了・達成を祝う',
            '成果を共有',
            'パフォーマンス',
            'プレゼンテーション'
          ]
        },
        description:
          '達成と祝福の時期。成果を認識し、不要なものを手放しましょう。'
      },
      'waning-gibbous': {
        phase: 'waning-gibbous',
        energy: 'waning',
        recommendations: {
          health: ['軽い運動', 'ストレッチ', 'ヨガ'],
          mindfulness: ['感謝', '他者と共有', '教える'],
          activities: [
            '知識の共有',
            'メンタリング',
            '振り返り',
            'フィードバック'
          ]
        },
        description:
          '分かち合いの時期。学んだことを共有し、他者をサポートしましょう。'
      },
      'last-quarter': {
        phase: 'last-quarter',
        energy: 'waning',
        recommendations: {
          health: ['穏やかな運動', '休息重視', 'セルフケア'],
          mindfulness: ['許し', '手放し', '浄化'],
          activities: ['不要なものを捨てる', '整理整頓', 'クロージング']
        },
        description:
          '手放しの時期。不要なものを手放し、次のサイクルに備えましょう。'
      },
      'waning-crescent': {
        phase: 'waning-crescent',
        energy: 'low',
        recommendations: {
          health: ['休息', '睡眠を優先', '回復に集中'],
          mindfulness: ['深い瞑想', '内省', '夢日記'],
          activities: [
            '休息',
            '充電',
            '静かな時間',
            '次のサイクルの準備'
          ]
        },
        description:
          '休息と回復の時期。内なる声に耳を傾け、エネルギーを蓄えましょう。'
      }
    };

    return rhythms[phase];
  }

  /**
   * エネルギーレベルを数値化（0-100）
   *
   * @param energy - エネルギーレベル
   * @returns 数値（0-100）
   */
  static getEnergyValue(energy: EnergyLevel): number {
    const values: Record<EnergyLevel, number> = {
      low: 25,
      rising: 60,
      high: 90,
      waning: 50
    };
    return values[energy];
  }
}
