<p align="center">
  <img src="icon.png" alt="DualClip Icon" width="128" height="128">
</p>

<h1 align="center">DualClip</h1>

<p align="center">
  <a href="README.md">English</a> · <a href="README-ko.md">한국어</a> · <b>日本語</b> · <a href="README-zh.md">中文</a>
</p>

<p align="center">
  <b>マルチスロット・クリップボード管理</b>を提供する軽量な macOS メニューバーアプリです。<br>
  履歴ベースのクリップボードマネージャーとは異なり、DualClip はカスタマイズ可能なキーボードショートカットで専用クリップボードスロットへ即座にアクセスできます。
</p>

<p align="center">
  <a href="https://rakkunn.github.io/DualClip/"><b>🌐 ウェブサイト</b></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/RAKKUNN/DualClip/releases/latest"><b>⬇ ダウンロード</b></a>
  &nbsp;·&nbsp;
  <a href="#インストール"><b>🍺 Homebrew</b></a>
</p>

![CI](https://github.com/RAKKUNN/DualClip/actions/workflows/ci.yml/badge.svg)
![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)
![Universal](https://img.shields.io/badge/Universal-arm64%20%2B%20x86__64-black?logo=apple)
![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange)
![License: MIT](https://img.shields.io/badge/License-MIT-green)

## 主な機能

- **3 つのクリップボードスロット**: Slot A (システムデフォルト)、Slot B、Slot C
- **カスタマイズ可能なショートカット**: ハードコードされたキーの衝突なし — 自由に設定可能
- **アトミックペースト**: システムクリップボードを汚染せずに任意のスロットからシームレスに貼り付け
- **メニューバーポップオーバー**: すべてのスロットの内容をプレビュー付きで一目で確認
- **プライバシー優先**: すべてのデータは RAM のみに存在 — ディスクには保存されません
- **ネットワークアクセスゼロ**: テレメトリなし、分析なし、インターネット通信なし

## デモ

<p align="center">
  <img src="test_dualclip.gif" alt="DualClip デモ" width="600">
</p>

<p align="center">
  <img src="test_dualclip_image.gif" alt="DualClip 画像対応デモ" width="600">
</p>

## デフォルトショートカット

| 操作 | ショートカット |
|------|----------------|
| Slot B にコピー | ⌥⌘C |
| Slot B から貼り付け | ⌥⌘V |
| Slot C にコピー | ⌃⌘C |
| Slot C から貼り付け | ⌃⌘V |

すべてのショートカットは **Settings > Shortcuts** で完全にカスタマイズできます。

## 仕組み

1. **Slot A** はシステムクリップボード (⌘C / ⌘V) を自動的にミラーリングします
2. **Slot B/C** は独自のコピーショートカットを通じて独立してコンテンツを保存します
3. **アトミックペースト**はシステムクリップボードを一時的に置き換え、⌘V をシミュレートし、元のクリップボードを復元します — 通常約 200ms 以内で、**設定 > General** で調整可能

## 要件

- macOS 13.0 (Ventura) 以降
- Intel または Apple Silicon Mac — 事前ビルドされたリリースはユニバーサルバイナリ(`arm64` + `x86_64`)です
- アクセシビリティ権限 (キーストロークシミュレーションに必要)

## インストール

### Homebrew (推奨)

```bash
brew install RAKKUNN/tap/dualclip
```

### 手動ダウンロード

1. [最新リリース](https://github.com/RAKKUNN/DualClip/releases/latest)に移動
2. `DualClip-x.x.x-universal.zip` をダウンロード
3. 解凍して `DualClip.app` を `/Applications` に移動
4. 求められたらアクセシビリティ権限を付与

> **注**: v1.1.0 以降、このアプリは Apple によって署名・公証されています。起動時のセキュリティ警告は表示されません。

### ソースからビルド

```bash
# リポジトリのクローン
git clone https://github.com/RAKKUNN/DualClip.git
cd DualClip

# Xcode で開く
open Package.swift

# またはコマンドラインからビルド
swift build -c release
```

> **注**: ソースからのビルドには Xcode または Swift 5.9+ Command Line Tools が必要です。

## 依存関係

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) — グローバルキーボードショートカット管理 (MIT)

## アーキテクチャ

```
DualClipCore/                # ライブラリターゲット — 全アプリロジック (テスト対象)
├── App/                    # アプリのエントリポイントとデリゲート
├── Models/                 # データモデル (SlotIdentifier, ClipboardSlot)
├── Services/               # コアロジック
│   ├── ClipboardManager    # NSPasteboard ポーリング (0.5 秒間隔)
│   ├── AtomicPasteService  # クリップボードスワップ + CGEvent ⌘V シミュレーション
│   └── AccessibilityService # 権限管理
├── Views/                  # SwiftUI ビュー (MenuBar, Settings, Onboarding)
└── Shortcuts/              # KeyboardShortcuts 統合

DualClip/                   # 実行ターゲット — エントリポイントのみ
└── main.swift

Tests/DualClipCoreTests/    # ユニットテスト (@testable import DualClipCore)
```

## セキュリティとプライバシー

- **永続化なし**: クリップボードデータはメモリにのみ存在します
- **ネットワークなし**: 外部通信ゼロ — ソースコードで検証可能
- **オープンソース**: セキュリティに敏感なクリップボードアクセスへの完全な透明性
- **アクセシビリティのみ**: 最小限の権限フットプリント

## ロードマップ

- [x] セキュア入力フィールド検出 (パスワードフィールドでの自動無効化)
- [x] 通常終了時の RAM ゼロクリア (強制終了時は動作しません)
- [x] 画像 / リッチテキストクリップボード対応
- [x] GitHub Actions CI/CD + 公証
- [x] Homebrew Cask 配布
- [ ] Sparkle 自動更新フレームワーク
- [ ] VoiceOver アクセシビリティ対応

## スポンサー

DualClip が役に立ったら、開発を支援してください：

<a href="https://github.com/sponsors/RAKKUNN">
  <img src="https://img.shields.io/badge/Sponsor-%E2%9D%A4-ea4aaa?logo=github" alt="Sponsor RAKKUNN"/>
</a>

## 貢献

貢献を歓迎します! 変更したい内容については、まず Issue を開いて議論してください。

## ライセンス

[MIT](LICENSE)
