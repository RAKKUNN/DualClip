# DualClip 사용 가이드

DualClip은 macOS 메뉴바에서 동작하는 멀티 슬롯 클립보드 매니저입니다. 기존 클립보드(⌘C/⌘V)를 그대로 유지하면서, 2개의 추가 슬롯(B, C)을 단축키로 즉시 사용할 수 있습니다.

---

## 목차

1. [설치](#1-설치)
2. [최초 실행 및 권한 설정](#2-최초-실행-및-권한-설정)
3. [기본 개념: 3개의 슬롯](#3-기본-개념-3개의-슬롯)
4. [단축키 사용법](#4-단축키-사용법)
5. [메뉴바 팝오버](#5-메뉴바-팝오버)
6. [단축키 커스터마이즈](#6-단축키-커스터마이즈)
7. [Atomic Paste 동작 원리](#7-atomic-paste-동작-원리)
8. [보안 및 프라이버시](#8-보안-및-프라이버시)
9. [문제 해결 (Troubleshooting)](#9-문제-해결-troubleshooting)
10. [빌드 방법](#10-빌드-방법)

---

## 1. 설치

### Xcode를 통한 빌드 설치 (권장)

```bash
# 1. 소스 클론
git clone https://github.com/dualclip/dualclip.git
cd dualclip

# 2. Xcode에서 열기
open Package.swift

# 3. Xcode 상단 툴바에서:
#    - Scheme: DualClip 선택
#    - Destination: My Mac 선택
#    - ⌘R 으로 빌드 & 실행
```

### Command Line Tools만으로 빌드

Xcode를 설치하지 않고도 빌드할 수 있습니다 (Command Line Tools 필요):

```bash
swift build -c release
# 바이너리 위치: .build/release/DualClip
```

> **참고**: CLI 빌드는 `.app` 번들이 아닌 실행 파일입니다. Dock 아이콘이 일시적으로 보일 수 있습니다.

---

## 2. 최초 실행 및 권한 설정

DualClip을 처음 실행하면 **Onboarding 화면**이 나타납니다.

### Step 1: Accessibility 권한 부여

DualClip이 슬롯 B/C의 붙여넣기를 수행하려면 **Accessibility 권한**이 필요합니다. 이 권한은 ⌘V 키 입력을 시뮬레이션하는 데 사용됩니다.

1. Onboarding 화면에서 **"Grant Access"** 버튼 클릭
2. macOS 시스템 설정이 자동으로 열립니다
3. **시스템 설정 > 개인 정보 보호 및 보안 > 손쉬운 사용(Accessibility)** 으로 이동
4. 목록에서 **DualClip**을 찾아 **토글을 켜기(ON)**

> 💡 권한이 승인되면 Onboarding 화면의 상태 표시등이 🔴 빨간색에서 🟢 초록색으로 바뀝니다.

### Step 2: 단축키 확인

"Next"를 누르면 기본 단축키 안내가 표시됩니다:

| 슬롯 | 복사 | 붙여넣기 |
|------|------|----------|
| Slot A (시스템) | ⌘C | ⌘V |
| Slot B | ⌥⌘C | ⌥⌘V |
| Slot C | ⌃⌘C | ⌃⌘V |

**"Get Started"** 를 클릭하면 메인 화면으로 이동합니다.

---

## 3. 기본 개념: 3개의 슬롯

DualClip은 3개의 독립적인 클립보드 슬롯을 제공합니다:

### Slot A — 시스템 클립보드

- macOS 기본 클립보드와 **자동 동기화**됩니다
- ⌘C로 복사한 내용이 실시간으로 반영됩니다
- 직접 제어하지 않아도 됩니다 — 기존 사용 습관 그대로 유지

### Slot B — 보조 슬롯 1

- 독립적인 저장 공간
- ⌥⌘C로 복사, ⌥⌘V로 붙여넣기
- 예: 자주 사용하는 이메일 주소, 코드 스니펫 등을 임시 저장

### Slot C — 보조 슬롯 2

- 두 번째 독립 저장 공간
- ⌃⌘C로 복사, ⌃⌘V로 붙여넣기
- 예: 번역 작업 시 원문과 번역문을 각각 다른 슬롯에 저장

### 사용 시나리오 예시

**코드 리팩토링:**
1. 변수명 `oldName`을 선택 → **⌥⌘C** (Slot B에 저장)
2. 새 변수명 `newName`을 선택 → **⌃⌘C** (Slot C에 저장)
3. 다른 파일에서 **⌥⌘V**로 옛 이름 붙여넣기, **⌃⌘V**로 새 이름 붙여넣기
4. 이 과정에서 **⌘C/⌘V (Slot A)는 그대로** 독립적으로 사용 가능

**번역 작업:**
1. 영어 원문 선택 → **⌥⌘C** (Slot B에 저장)
2. 번역기에서 번역 결과 선택 → **⌃⌘C** (Slot C에 저장)
3. 문서에서 필요한 위치에 **⌥⌘V** 또는 **⌃⌘V**로 각각 붙여넣기

---

## 4. 단축키 사용법

### 슬롯에 복사하기

1. 복사하고 싶은 텍스트를 **마우스로 선택** (드래그)
2. 해당 슬롯의 **복사 단축키** 입력:
   - Slot B: **⌥⌘C** (Option + Command + C)
   - Slot C: **⌃⌘C** (Control + Command + C)
3. 메뉴바 팝오버에서 슬롯에 텍스트가 저장된 것을 확인 가능

> 📌 복사 동작은 내부적으로 ⌘C를 시뮬레이션한 후 클립보드 내용을 해당 슬롯에 저장합니다.

### 슬롯에서 붙여넣기

1. 텍스트를 넣고 싶은 위치에 **커서를 놓기**
2. 해당 슬롯의 **붙여넣기 단축키** 입력:
   - Slot B: **⌥⌘V** (Option + Command + V)
   - Slot C: **⌃⌘V** (Control + Command + V)
3. 슬롯에 저장된 텍스트가 붙여넣어집니다

> 📌 붙여넣기 후에도 시스템 클립보드(Slot A)의 내용은 **변경되지 않습니다** (Atomic Paste).

### 기호 참고

| 기호 | 키 | 키보드 위치 |
|------|-----|-----------|
| ⌘ | Command | 스페이스바 양옆 |
| ⌥ | Option (Alt) | Command 바로 옆 |
| ⌃ | Control | 키보드 좌측 하단 |

---

## 5. 메뉴바 팝오버

화면 상단 메뉴바의 📋 아이콘을 클릭하면 **팝오버 창**이 열립니다.

### 팝오버 구성

```
┌──────────────────────────────┐
│  DualClip          Clear All │  ← 헤더 (B, C 슬롯 일괄 비우기)
├──────────────────────────────┤
│  [A] System clipboard        │  ← Slot A: 현재 시스템 클립보드
│      "복사된 텍스트 미리보기…"  │
│      3 seconds ago            │
│                               │
│  [B] Slot B              [✕] │  ← Slot B: 저장된 내용 + 삭제 버튼
│      "저장된 텍스트 미리보기…"  │
│      1 minute ago             │
│                               │
│  [C] Slot C              [✕] │  ← Slot C
│      (empty)                  │
├──────────────────────────────┤
│  ⚙ Settings    🟢    Quit   │  ← 푸터 (설정, 권한 상태, 종료)
└──────────────────────────────┘
```

### 각 요소 설명

- **슬롯 뱃지(A/B/C)**: 색상으로 구분 (A=파랑, B=주황, C=보라)
- **미리보기**: 저장된 텍스트의 처음 40자를 한 줄로 표시
- **타임스탬프**: 복사된 시간을 상대적으로 표시 (예: "3 seconds ago")
- **✕ 버튼**: 해당 슬롯의 내용을 삭제 (Slot B, C만 가능)
- **Clear All**: Slot B와 C를 동시에 비움 (Slot A는 시스템 클립보드이므로 영향 없음)
- **🟢/🔴 점**: Accessibility 권한 상태 표시. 🔴이면 클릭하여 설정으로 이동 가능
- **Settings**: 단축키 커스터마이즈 설정 창 열기
- **Quit**: 앱 종료

---

## 6. 단축키 커스터마이즈

기본 단축키가 다른 앱과 충돌하거나 불편한 경우, 자유롭게 변경할 수 있습니다.

### 설정 방법

1. 메뉴바 팝오버에서 **⚙ Settings** 클릭
2. **Shortcuts** 탭 선택
3. 변경하려는 항목의 입력 필드를 클릭
4. 원하는 **키 조합을 직접 누르기** (예: ⌃⇧C)
5. 자동으로 저장됨

### 설정 화면 구성

```
Shortcuts 탭:
┌─────────────────────────────────┐
│  Slot B                         │
│  Copy to Slot B:    [⌥⌘C     ] │  ← 클릭 후 새 키 조합 입력
│  Paste from Slot B: [⌥⌘V     ] │
│                                 │
│  Slot C                         │
│  Copy to Slot C:    [⌃⌘C     ] │
│  Paste from Slot C: [⌃⌘V     ] │
│                                 │
│  [Reset to Defaults]            │  ← 기본값으로 초기화
└─────────────────────────────────┘
```

### 단축키 선택 팁

- **다른 앱과 충돌하지 않는 조합**을 선택하세요
- 일반적으로 안전한 수식키 조합:
  - `⌃⇧` (Control + Shift) + 알파벳
  - `⌃⌥` (Control + Option) + 알파벳
  - `⌃⌥⌘` (Control + Option + Command) + 알파벳
- 피해야 할 조합:
  - `⌘⇧V` — 대부분 앱에서 "서식 없이 붙여넣기"로 사용
  - `⌘⇧C` — Chrome DevTools, VS Code 등에서 사용

---

## 7. Atomic Paste 동작 원리

DualClip의 핵심 기술인 **Atomic Paste**는 슬롯 B/C에서 붙여넣기할 때 시스템 클립보드를 보존합니다.

### 동작 과정 (⌥⌘V 입력 시)

```
[1] 시스템 클립보드 백업
    현재 ⌘C로 복사해둔 내용을 임시 저장

[2] 슬롯 데이터로 교체
    시스템 클립보드를 Slot B 내용으로 덮어쓰기

[3] ⌘V 시뮬레이션
    대상 앱에 붙여넣기 명령 전달

[4] 150ms 대기
    대상 앱이 클립보드를 읽을 시간 확보

[5] 시스템 클립보드 복원
    [1]에서 백업한 원래 내용으로 되돌리기
```

### 왜 이렇게 동작하나요?

macOS의 붙여넣기(⌘V)는 항상 **시스템 클립보드(`NSPasteboard.general`)**에서 데이터를 가져옵니다. 따라서 슬롯 B의 내용을 붙여넣으려면 일시적으로 시스템 클립보드를 교체해야 합니다. Atomic Paste는 이 과정을 **150ms 이내에 완료**하고 원래 클립보드를 복원하므로, 사용자는 시스템 클립보드가 변경되었음을 인지하지 못합니다.

---

## 8. 보안 및 프라이버시

DualClip은 보안을 최우선으로 설계되었습니다.

### 데이터 저장

| 항목 | 정책 |
|------|------|
| 클립보드 데이터 | **RAM에만 존재** — 디스크에 절대 저장하지 않음 |
| 앱 종료 시 | 모든 슬롯 데이터 즉시 파기 |
| 설정 데이터 | 단축키 설정과 온보딩 완료 여부만 `UserDefaults`에 저장 |

### 네트워크

- **네트워크 통신 코드가 존재하지 않습니다**
- 텔레메트리, 분석, 자동 업데이트 서버 연결 없음
- 소스 코드가 공개되어 있으므로 직접 검증 가능

### 권한

| 권한 | 용도 | 필수 여부 |
|------|------|-----------|
| Accessibility | ⌘V/⌘C 키 입력 시뮬레이션 | **필수** — 없으면 Slot B/C 붙여넣기 불가 |
| 그 외 | 없음 | — |

### 오픈소스

- MIT 라이선스로 공개
- 모든 소스 코드를 GitHub에서 확인 가능
- 클립보드 접근 앱은 민감한 데이터를 다루므로, 투명성이 핵심입니다

---

## 9. 문제 해결 (Troubleshooting)

### ⌥⌘V를 눌러도 아무 반응이 없어요

**원인**: Accessibility 권한이 부여되지 않았을 가능성이 높습니다.

**해결**:
1. 메뉴바 팝오버 하단의 상태 점이 🔴인지 확인
2. 🔴이면 클릭하여 시스템 설정으로 이동
3. **시스템 설정 > 개인 정보 보호 및 보안 > 손쉬운 사용**
4. DualClip 토글을 끄고 다시 켜기
5. 앱 재시작

### 단축키가 다른 앱과 충돌해요

**해결**:
1. 메뉴바 팝오버 > **Settings** > **Shortcuts** 탭
2. 충돌하는 단축키를 클릭
3. 새로운 키 조합 입력
4. "Reset to Defaults"로 기본값 복원 가능

### 붙여넣기 시 이전 클립보드 내용이 사라져요

**원인**: 대상 앱이 클립보드를 읽는 데 150ms보다 오래 걸릴 수 있습니다.

**해결**: 현재 버전에서는 복원 지연 시간을 변경할 수 없습니다. 이 문제가 자주 발생하면 GitHub Issue로 제보해주세요.

### 메뉴바에 아이콘이 안 보여요

**해결**:
1. 메뉴바 아이콘이 너무 많으면 macOS가 일부를 숨길 수 있습니다
2. ⌘ 키를 누른 채로 메뉴바 아이콘을 드래그하여 재배치
3. 앱이 실행 중인지 Activity Monitor에서 "DualClip" 검색

### Slot A에 내용이 표시되지 않아요

**원인**: 이미지나 파일 등 텍스트가 아닌 데이터를 복사한 경우

**설명**: 현재 버전은 **텍스트(String)만 지원**합니다. 이미지, 리치 텍스트, 파일 등은 감지되지 않습니다.

---

## 10. 빌드 방법

### 요구 사항

- macOS 13.0 (Ventura) 이상
- Xcode 15+ 또는 Swift 5.9+ Command Line Tools

### Xcode 빌드

```bash
git clone https://github.com/dualclip/dualclip.git
cd dualclip
open Package.swift
# Xcode에서 ⌘R로 빌드 & 실행
```

### CLI 빌드

```bash
git clone https://github.com/dualclip/dualclip.git
cd dualclip
swift build -c release
# 실행
.build/release/DualClip
```

### 프로젝트 구조

```
DualClip/
├── App/
│   ├── DualClipApp.swift        # 앱 진입점 (MenuBarExtra)
│   └── AppDelegate.swift        # 권한 체크, 라이프사이클
├── Models/
│   ├── ClipboardSlot.swift      # 슬롯 데이터 모델
│   └── SlotIdentifier.swift     # A/B/C 열거형
├── Services/
│   ├── ClipboardManager.swift   # 클립보드 폴링 (0.5초)
│   ├── AtomicPasteService.swift # Atomic Paste 구현
│   └── AccessibilityService.swift # 권한 관리
├── Views/
│   ├── MenuBarView.swift        # 메뉴바 팝오버
│   ├── SlotRowView.swift        # 개별 슬롯 행
│   ├── SettingsView.swift       # 단축키 설정
│   └── OnboardingView.swift     # 최초 실행 가이드
└── Shortcuts/
    ├── ShortcutNames.swift      # 단축키 이름 정의
    └── ShortcutHandler.swift    # 단축키 → 액션 연결
```

---

> **DualClip**은 MIT 라이선스로 배포되는 오픈소스 프로젝트입니다. 기여, 버그 제보, 기능 제안은 [GitHub Issues](https://github.com/dualclip/dualclip/issues)를 이용해주세요.
