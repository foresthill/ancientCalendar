# AncientCalendar

新暦・旧暦統合カレンダー

## 機能

- **新暦⇄旧暦 瞬時切り替え**: ワンタップでスムーズに切り替え
- **月のフェーズ表示**: 28枚の画像で精密な月の満ち欠けを表現
- **月のリズムガイド**: フェーズに基づく推奨活動
- **イベント管理**: 新暦・旧暦両対応のイベントシステム
- **干支・二十四節気**: 伝統的な暦情報の表示

## 月の表現

絵文字ではなく、**28枚の専用画像**を使用して月の満ち欠けを精密に表現しています。

## 構成

- `apps/web` - Web版（Next.js）
- `apps/ios` - iOS版（Swift、参照用）
- `packages/calendar-core` - 共通ロジック（旧暦変換、月齢計算）
- `packages/shared-types` - 共通型定義

## セットアップ

```bash
# 依存関係のインストール
pnpm install

# 開発サーバー起動
pnpm dev
```

## iOS版の画像アセット

iOS版から月の画像（28枚）を移行してください：

```bash
# iOS版の画像を確認
ls apps/ios/AncientCalendar/Assets.xcassets/Moon/

# Web版にコピー
mkdir -p apps/web/public/images/moon/
# 画像をmoon-00.png ~ moon-27.png にリネームしてコピー
```

詳細は `apps/ios/README.md` を参照してください。

## アクセス

http://localhost:3000

## 技術スタック

- Next.js 15.5
- React 19
- TypeScript 5.7
- Tailwind CSS v4
- shadcn/ui
- Prisma + Postgres
- lunar-javascript
