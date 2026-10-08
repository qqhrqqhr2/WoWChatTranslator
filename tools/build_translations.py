"""번역표(tools/tr_*.txt)를 모아 Translations.lua 를 만든다.

tr_*.txt 형식: 영어 뜻|간체 중국어|러시아어  (한 줄에 하나)
- 번체 중국어는 간체에서 OpenCC(s2twp)로 자동 변환한다.
- 사전에 있는 뜻 중 번역이 빠진 것과, 사전에 없는 번역(오타)을 알려준다.

사용: python3 tools/build_translations.py
필요: pip install opencc-python-reimplemented
"""
import glob
import os
import re
import sys

from opencc import OpenCC

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)


def dictionary_meanings():
    toc = open(os.path.join(ROOT, "WoWChatTranslator.toc"), encoding="utf-8").read()
    files = [l.strip() for l in toc.splitlines() if l.strip().startswith("Glossary")]
    out = {}
    for f in files:
        s = open(os.path.join(ROOT, f), encoding="utf-8").read()
        for m in re.finditer(r'ns\.RawGlossary\.(\w+) = (?:\(ns\.RawGlossary\.\w+ or ""\) \.\. )?\[\[\n(.*?)\]\]', s, re.S):
            for line in m.group(2).splitlines():
                if "=" not in line or line.startswith("--"):
                    continue
                en = line.split("=")[2].strip()
                if en:
                    out.setdefault(en.lower(), en)
    return out


def lua_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def main():
    cc = OpenCC("s2twp")
    zh, ru = {}, {}
    for path in sorted(glob.glob(os.path.join(HERE, "tr_*.txt"))):
        for n, line in enumerate(open(path, encoding="utf-8"), 1):
            line = line.rstrip("\n")
            if not line.strip() or line.startswith("#"):
                continue
            parts = line.split("|")
            if len(parts) != 3:
                print(f"형식 오류 {os.path.basename(path)}:{n}: {line}", file=sys.stderr)
                continue
            en, z, r = (p.strip() for p in parts)
            key = en.lower()
            if z:
                zh[key] = z
            if r:
                ru[key] = r

    meanings = dictionary_meanings()
    missing_zh = [v for k, v in meanings.items() if k not in zh]
    missing_ru = [v for k, v in meanings.items() if k not in ru]
    unused = sorted(k for k in set(zh) | set(ru) if k not in meanings)
    print(f"사전 뜻 {len(meanings)}개 / 중국어 {len(meanings) - len(missing_zh)}개 / 러시아어 {len(meanings) - len(missing_ru)}개")
    if missing_zh:
        print("중국어 번역 없음:", missing_zh[:50])
    if missing_ru:
        print("러시아어 번역 없음:", missing_ru[:50])
    if unused:
        print("사전에 없는 번역(오타?):", unused[:50])

    keys = sorted(k for k in meanings if k in zh or k in ru)
    lines = [
        "-- WoW Chat Translator: 사전 뜻 번역표 (자동 생성 - tools/build_translations.py)",
        "-- 영어 뜻(소문자) → 현지 언어. 번체 중국어는 간체에서 자동 변환.",
        "local ADDON, ns = ...",
        "ns.TR = ns.TR or {}",
    ]
    for target, table in (("zhCN", zh), ("zhTW", {k: cc.convert(v) for k, v in zh.items()}), ("ru", ru)):
        lines.append(f"ns.TR.{target} = {{")
        for k in keys:
            if k in table:
                lines.append(f"\t[{lua_str(k)}] = {lua_str(table[k])},")
        lines.append("}")
    open(os.path.join(ROOT, "Translations.lua"), "w", encoding="utf-8").write("\n".join(lines) + "\n")
    print("Translations.lua 작성 완료")


if __name__ == "__main__":
    main()
