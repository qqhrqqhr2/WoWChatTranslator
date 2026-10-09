# WoW Chat Translator (채팅 번역기)

WoW Forever addon. Translates Korean, Chinese, Japanese, Russian and English chat into your local language (Korean, English, Simplified Chinese, Traditional Chinese, Russian) using a built-in dictionary of gamer slang, abbreviations and WoW terms — right after the message and on mouse-over.

와우 포에버용 애드온입니다. 한국어·중국어·일본어·러시아어·영어 채팅을 현지 언어로 풀어 줍니다. 게임 은어·약어·와우 용어 사전이 들어 있습니다.

## 현지 언어

| 게임 클라이언트 | 기본 현지 언어 |
|---|---|
| 한국어 (koKR) | 한국어 |
| 간체 중국어 (zhCN) | 简体中文 |
| 번체 중국어 (zhTW) | 繁體中文 |
| 러시아어 (ruRU) | Русский |
| 그 외 (enUS, deDE, frFR ...) | English |

설정창에서 현지 언어를 직접 고를 수 있고, 바꾸면 번역 결과와 화면 문구가 바로 그 언어로 바뀝니다. 현지 언어와 같은 언어의 채팅은 번역하지 않습니다.

## 기능

- **뜻 바로 붙이기**: 메시지 뒤에 대략적인 뜻이 초록색 괄호로 붙습니다.
  `[EN] LFM BRD need tank and heals (인원 구함 검은바위 나락 탱커 필요 그리고 힐러)`
- **언어 표시**: 중국어 `[中]`, 일본어 `[日]`, 러시아어 `[RU]`, 영어 `[EN]`
- **마우스 오버 풀이**: 표시나 메시지에 마우스를 올리면 원문, 대략적인 뜻, 찾은 표현 목록을 보여줍니다.
- **클릭 복사**: 클릭하면 원문 복사창이 열립니다. Ctrl+C로 복사해서 파파고 같은 번역기에 붙여 넣으세요.
- **풀이 비율 조절**: 사전으로 풀린 비율이 설정값(기본 40%)보다 낮은 문장은 뒤에 뜻을 붙이지 않습니다. (마우스 오버로는 항상 볼 수 있음)

> 와우 애드온은 인터넷에 접속할 수 없어서 번역기처럼 문장 전체를 번역할 수는 없습니다. 모집 글, 거래 글, 던전·직업·재료 이름, 게임 약어처럼 자주 쓰는 표현을 사전으로 풀어 줍니다.

> 게임 글꼴에 중국어·일본어 글자가 없으면 원문은 네모(□)로 보일 수 있습니다. 뒤에 붙는 뜻은 정상적으로 보이고, 복사창으로 복사하면 원래 글자 그대로 복사됩니다.

## 툴팁 번역

포에버 신규 아이템처럼 번역이 없는 툴팁 설명을 툴팁 아래 **WoW Chat Translator** 칸에 현지 언어로 보여 줍니다. 번역하지 못한 문장은 `/wct 수집`으로 모아 두었다가 사전에 추가합니다.

## 명령어

- `/wct`, `/번역`, `/외국어` : 설정창 열기
- `/wct 상태` : 동작 상태 확인 (문제가 있을 때 이 결과를 알려주세요)
- `/wct 수집` : 모은 미번역 툴팁 문장 개수, `/wct 수집 초기화` : 비우기
- 게임 메뉴 → 설정 → 애드온 → WoW Chat Translator 에서도 열 수 있습니다.

## 사전

약 4,200개 표현이 들어 있습니다 (영어 1,800 / 중국어 1,400 / 러시아어 820 / 일본어 190).
채팅 약어, 직업·특성, 스킬, 버프, 스탯, 장비, 소모품, 재료, 전리품 규칙, PvP 용어, 지역·던전·보스 이름을 다룹니다.
`30g`, `1.5k`, `lvl40`, `lf2m`, `8pm` 같은 숫자 표현도 풀어 줍니다.

| 파일 | 내용 |
|---|---|
| `Glossary.lua` | 기본 사전 (4개 언어) |
| `GlossaryEN.lua` | 영어 약어·와우 용어·일상 단어 |
| `GlossaryZH.lua` | 중국어 와우 은어, 간체·번체 지역/던전 이름 |
| `GlossaryRU.lua` | 러시아어 와우 은어·격변화, 일본어 추가분 |

`Glossary*.lua`에 한 줄에 하나씩 `원문=한국어=English` 형식으로 들어 있어서 직접 추가할 수 있습니다. 뜻을 비워 두면(`the==`) 풀이에서 생략합니다.

## 번역표 고치기 (개발용)

- 사전: `Glossary*.lua` (원문=한국어=English)
- 다른 현지 언어: `tools/tr_*.txt` (English|简体中文|Русский) → `python3 tools/build_translations.py` 로 `Translations.lua` 생성 (번체는 자동 변환, 누락·오타 검사)
- 새 뜻 목록 뽑기: `python3 tools/list_meanings.py`

## 라이선스

MIT (`LICENSE`)

## 링크

- GitHub: https://github.com/qqhrqqhr2/WoWChatTranslator

## 후원

https://buymeacoffee.com/qqhrqqhr2
