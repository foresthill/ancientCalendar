import Foundation

// MoonAgeCalculatorクラスの実装をインポート
// 注: このスクリプトを実行する際は、このファイルと同じディレクトリに
// MoonAgeCalculator.swiftがあることを確認してください
#if canImport(SwiftCompilerPlugin)
import MoonAgeCalculator
#else
// ファイルを直接ソースとして取り込む（SwiftPMを使わない場合）
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
#include("MoonAgeCalculator.swift")
#else
// Linux等で実行する場合は別途対応が必要
print("エラー: サポートされていないプラットフォームです")
exit(1)
#endif
#endif

// 2025年における各月の新月と満月の正確な日付（NASA/JPLデータに基づく）
// 参考: https://svs.gsfc.nasa.gov/5048/
let moonPhases2025 = [
    // 新月日
    ("新月", 2025, 1, 7),
    ("新月", 2025, 2, 6),
    ("新月", 2025, 3, 7),
    ("新月", 2025, 4, 6),
    ("新月", 2025, 5, 5),
    ("新月", 2025, 6, 4),
    ("新月", 2025, 7, 3),
    ("新月", 2025, 8, 1),
    ("新月", 2025, 8, 31),
    ("新月", 2025, 9, 29),
    ("新月", 2025, 10, 29),
    ("新月", 2025, 11, 27),
    ("新月", 2025, 12, 27),
    
    // 満月日
    ("満月", 2025, 1, 22),
    ("満月", 2025, 2, 20),
    ("満月", 2025, 3, 22),
    ("満月", 2025, 4, 21),
    ("満月", 2025, 5, 20),
    ("満月", 2025, 6, 19),
    ("満月", 2025, 7, 18),
    ("満月", 2025, 8, 17),
    ("満月", 2025, 9, 15),
    ("満月", 2025, 10, 15),
    ("満月", 2025, 11, 13),
    ("満月", 2025, 12, 13)
]

// 任意の日付で月齢計算をテスト
func testSpecificDates() {
    let testDates = [
        (2025, 5, 9),   // 今日（仮）
        (2025, 5, 16),  // 一週間後
        (2025, 4, 16),  // 前月の中旬
        (2025, 6, 16),  // 来月の中旬
        (2000, 1, 6),   // 基準日
        (2023, 1, 1),   // 年始
        (2023, 12, 31), // 年末
        (2026, 1, 1),   // 将来の日付
        (1995, 7, 16)   // 過去の日付
    ]
    
    print("特定の日付における月齢計算テスト:\n")
    print("日付 | 簡易計算 | 天文学的計算 | 高精度計算 | 差分(高精度-簡易)")
    print("----|----------|------------|----------|---------------")
    
    for date in testDates {
        let year = date.0
        let month = date.1
        let day = date.2
        
        let results = MoonAgeCalculator.calculateAllMethods(year: year, month: month, day: day)
        let diff = abs(results.high - results.simple)
        
        print("\(year)/\(month)/\(day) | \(results.simple) | \(results.astro) | \(results.high) | \(diff)")
    }
}

// 新月・満月の日に計算精度をテスト
func testMoonPhases() {
    print("\n\n2025年の新月と満月における月齢計算精度テスト:\n")
    print("日付 | 期待値 | 簡易計算(誤差) | 天文学的計算(誤差) | 高精度計算(誤差)")
    print("----|-------|--------------|-----------------|---------------")
    
    for phase in moonPhases2025 {
        let phaseName = phase.0
        let year = phase.1
        let month = phase.2
        let day = phase.3
        
        let results = MoonAgeCalculator.calculateAllMethods(year: year, month: month, day: day)
        let expectedAge = phaseName == "新月" ? 0.0 : 15.0
        
        let simpleError = abs(results.simple - expectedAge)
        let astroError = abs(results.astro - expectedAge)
        let highError = abs(results.high - expectedAge)
        
        print("\(phaseName) \(year)/\(month)/\(day) | \(expectedAge) | \(results.simple) (\(simpleError)) | \(results.astro) (\(astroError)) | \(results.high) (\(highError))")
    }
}

// 月齢範囲ごとの月相名テスト
func testMoonPhaseNames() {
    print("\n\n月齢範囲ごとの月相名テスト:\n")
    print("月齢 | 月相名")
    print("----|------")
    
    let testAges = [0.0, 0.5, 3.5, 7.0, 7.5, 11.0, 15.0, 15.5, 18.0, 22.0, 22.5, 25.0, 29.0, 29.5]
    
    for age in testAges {
        let phase = MoonAgeCalculator.getPhase(moonAge: age)
        print("\(age) | \(phase.rawValue)")
    }
}

// 一連のテストを実行
print("=============== 高精度月齢計算テスト ===============\n")
testSpecificDates()
testMoonPhases()
testMoonPhaseNames()
print("\n=============== テスト完了 ===============")