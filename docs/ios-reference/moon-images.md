# 月画像の実装

## 概要

iOS版では28枚の月画像を使用して、精密な月の満ち欠けを表現しています。
Web版でも同じアプローチを採用します。

## 画像仕様

### ファイル構成

- **枚数**: 28枚
- **命名**: moon-00.png ~ moon-27.png
- **フォーマット**: PNG（WebP推奨）
- **サイズ**: 128x128px（@2x: 256x256px）

### インデックスと月齢の対応

| インデックス | 月齢（日） | フェーズ |
|------------|-----------|---------|
| 0 | 0.0 | 新月 |
| 3 | 3.2 | 三日月 |
| 7 | 7.4 | 上弦の月 |
| 10 | 10.6 | 十日夜の月 |
| 14 | 14.8 | 満月 |
| 18 | 19.0 | 寝待月 |
| 21 | 22.1 | 下弦の月 |
| 25 | 26.4 | 有明の月 |
| 27 | 28.5 | 残月 |

### 計算アルゴリズム

```typescript
// 月齢（0-29.53）を画像インデックス（0-27）にマッピング
const imageIndex = Math.floor((moonAge / 29.53) * 28);
const clampedIndex = Math.min(Math.max(imageIndex, 0), 27);
```

## Web版での使用

### Next.js Image最適化

```typescript
<Image
  src="/images/moon/moon-14.png"
  alt="満月"
  width={128}
  height={128}
  priority={false}  // カレンダーグリッドでは遅延読み込み
/>
```

### レスポンシブ対応

```typescript
sizes="(max-width: 768px) 64px, 128px"
```

## iOS版からの移行

1. iOS版のAssets.xcassetsから画像をエクスポート
2. Web版の`public/images/moon/`に配置
3. ファイル名をmoon-XX.png形式にリネーム
4. WebPフォーマットへの変換（オプション）
