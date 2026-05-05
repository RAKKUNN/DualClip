<p align="center">
  <img src="icon.png" alt="DualClip Icon" width="128" height="128">
</p>

<h1 align="center">DualClip</h1>

<p align="center">
  <a href="README.md">English</a> · <b>한국어</b> · <a href="README-ja.md">日本語</a> · <a href="README-zh.md">中文</a>
</p>

<p align="center">
  <b>다중 슬롯 클립보드 관리</b>를 제공하는 가벼운 macOS 메뉴 바 앱입니다.<br>
  히스토리 기반 클립보드 관리자와 달리, DualClip은 사용자 지정 키보드 단축키로 전용 클립보드 슬롯에 즉시 접근할 수 있게 해줍니다.
</p>

<p align="center">
  <a href="https://rakkunn.github.io/DualClip/"><b>🌐 웹사이트</b></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/RAKKUNN/DualClip/releases/latest"><b>⬇ 다운로드</b></a>
  &nbsp;·&nbsp;
  <a href="#설치"><b>🍺 Homebrew</b></a>
</p>

![CI](https://github.com/RAKKUNN/DualClip/actions/workflows/ci.yml/badge.svg)
![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)
![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-required-black?logo=apple)
![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange)
![License: MIT](https://img.shields.io/badge/License-MIT-green)

## 주요 기능

- **3개의 클립보드 슬롯**: Slot A (시스템 기본), Slot B, Slot C
- **사용자 지정 단축키**: 하드코딩된 키 충돌 없음 — 원하는 단축키로 자유롭게 설정
- **Atomic Paste**: 시스템 클립보드를 망가뜨리지 않고 어떤 슬롯이든 끊김 없이 붙여넣기
- **메뉴 바 팝오버**: 모든 슬롯 내용을 미리보기와 함께 한눈에 확인
- **프라이버시 우선**: 모든 데이터는 RAM에만 존재 — 디스크에 저장되지 않음
- **네트워크 접근 0**: 텔레메트리 없음, 분석 없음, 인터넷 통신 없음

## 데모

<p align="center">
  <img src="test_dualclip.gif" alt="DualClip 데모" width="600">
</p>

<p align="center">
  <img src="test_dualclip_image.gif" alt="DualClip 이미지 지원 데모" width="600">
</p>

## 기본 단축키

| 동작 | 단축키 |
|------|--------|
| Slot B로 복사 | ⌥⌘C |
| Slot B에서 붙여넣기 | ⌥⌘V |
| Slot C로 복사 | ⌃⌘C |
| Slot C에서 붙여넣기 | ⌃⌘V |

모든 단축키는 **Settings > Shortcuts**에서 자유롭게 변경할 수 있습니다.

## 작동 방식

1. **Slot A**는 시스템 클립보드(⌘C / ⌘V)를 자동으로 미러링합니다
2. **Slot B/C**는 자체 복사 단축키를 통해 독립적으로 콘텐츠를 저장합니다
3. **Atomic Paste**는 시스템 클립보드를 잠시 교체하고, ⌘V를 시뮬레이션한 뒤, 원래 클립보드를 복원합니다 — 모두 약 150ms 이내

## 요구 사항

- macOS 13.0 (Ventura) 이상
- **Apple Silicon Mac (M1/M2/M3/M4)** — 사전 빌드된 릴리스는 `arm64` 전용이며 Intel Mac에서는 실행되지 않습니다
- 손쉬운 사용 권한 (키 입력 시뮬레이션에 필요)

## 설치

### Homebrew (권장)

```bash
brew install RAKKUNN/tap/dualclip
```

### 수동 다운로드

1. [최신 릴리스](https://github.com/RAKKUNN/DualClip/releases/latest)로 이동
2. `DualClip-x.x.x-arm64.zip` 다운로드
3. 압축을 풀고 `DualClip.app`을 `/Applications`로 이동
4. 안내가 표시되면 손쉬운 사용 권한 부여

> **참고**: v1.1.0부터 Apple에 의해 서명 및 공증되었습니다. 실행 시 보안 경고가 표시되지 않습니다.

### 소스에서 빌드

```bash
# 저장소 클론
git clone https://github.com/RAKKUNN/DualClip.git
cd DualClip

# Xcode로 열기
open Package.swift

# 또는 커맨드 라인에서 빌드
swift build -c release
```

> **참고**: 소스에서 빌드하려면 Xcode 또는 Swift 5.9+ Command Line Tools가 필요합니다.

## 의존성

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) — 전역 키보드 단축키 관리 (MIT)

## 아키텍처

```
DualClip/
├── App/                    # 앱 엔트리 포인트와 델리게이트
├── Models/                 # 데이터 모델 (SlotIdentifier, ClipboardSlot)
├── Services/               # 핵심 로직
│   ├── ClipboardManager    # NSPasteboard 폴링 (0.5초 간격)
│   ├── AtomicPasteService  # 클립보드 스왑 + CGEvent ⌘V 시뮬레이션
│   └── AccessibilityService # 권한 관리
├── Views/                  # SwiftUI 뷰 (MenuBar, Settings, Onboarding)
└── Shortcuts/              # KeyboardShortcuts 통합
```

## 보안 및 프라이버시

- **영속성 없음**: 클립보드 데이터는 메모리에만 존재합니다
- **네트워크 없음**: 외부 통신 0 — 소스 코드에서 검증 가능
- **오픈 소스**: 보안에 민감한 클립보드 접근에 대한 완전한 투명성
- **손쉬운 사용 권한만**: 최소한의 권한 사용

## 로드맵

- [x] 보안 입력 필드 감지 (비밀번호 필드에서 자동 비활성화)
- [x] 앱 종료 시 RAM 0으로 채우기
- [x] 이미지/리치 텍스트 클립보드 지원
- [x] GitHub Actions CI/CD + 공증
- [x] Homebrew Cask 배포
- [ ] Sparkle 자동 업데이트 프레임워크
- [ ] VoiceOver 접근성 지원

## 후원

DualClip이 유용하셨다면 개발을 후원해 주세요:

<a href="https://github.com/sponsors/RAKKUNN">
  <img src="https://img.shields.io/badge/Sponsor-%E2%9D%A4-ea4aaa?logo=github" alt="Sponsor RAKKUNN"/>
</a>

## 기여하기

기여를 환영합니다! 변경하고 싶은 내용을 먼저 이슈로 열어 논의해 주세요.

## 라이선스

[MIT](LICENSE)
