# iOS版 AncientCalendar（参照用）

既存のSwift実装をこのディレクトリに配置してください。

## 配置方法

```bash
# シンボリックリンク推奨
ln -s ~/path/to/AncientCalendar apps/ios/AncientCalendar

# またはコピー
cp -r ~/path/to/AncientCalendar apps/ios/
```

## Web版で参照するファイル

### コアロジック

- **旧暦変換**: `AncientCalendar/Sources/Calendar/LunarConverter.swift`
  - Web版: `packages/calendar-core/src/lunar-converter.ts`

- **月齢計算**: `AncientCalendar/Sources/Moon/MoonPhase.swift`
  - Web版: `packages/calendar-core/src/moon-phase.ts`

### 月の画像アセット

- **iOS版**: `AncientCalendar/Assets.xcassets/Moon/`
- **Web版**: `apps/web/public/images/moon/`

#### 画像の抽出方法

1. Xcodeで `Assets.xcassets` を開く
2. Moonフォルダ内の画像を確認
3. 各画像を右クリック → "Show in Finder"
4. 画像ファイルをエクスポート
5. `apps/web/public/images/moon/` にコピー
6. ファイル名を `moon-00.png` ~ `moon-27.png` にリネーム

#### 期待されるファイル名

```
moon-00.png  # 新月
moon-01.png
moon-02.png
...
moon-14.png  # 満月
...
moon-27.png  # 残月
```

## 注意

- **iOS版**: CoreData使用（変更なし）
- **Web版**: Postgres使用（独立）
- **共有**: 計算ロジックと画像アセットのみ
