"""tools/tooltip_text.txt + tools/tooltip_patterns.txt -> TooltipText.lua
문장 열쇠는 Tooltip.lua 의 Canon/KeyOf 와 같은 방식으로 만든다.
사용: python3 tools/build_tooltip.py   (필요: opencc-python-reimplemented)"""
import os, re, sys
from opencc import OpenCC

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
cc = OpenCC("s2twp")

def canon(s):
    s = s.lower()
    s = re.sub(r"\s+", " ", s)
    for pat, rep in [(r"(\d+)\s+hours?", r"\1 hr"), (r"(\d+)\s+hrs?", r"\1 hr"), (r"(\d+)\s+minutes?", r"\1 min"),
                     (r"(\d+)\s+mins?", r"\1 min"), (r"(\d+)\s+seconds?", r"\1 sec"), (r"(\d+)\s+secs?", r"\1 sec")]:
        s = re.sub(pat, rep, s)
    s = s.strip()
    s = re.sub(r"[.!]+$", "", s)
    return re.sub(r"\d+\.?\d*", "#", s)

def lua(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'

def localized(ko, zh, ru):
    pairs = [("ko", ko), ("zhCN", zh), ("zhTW", cc.convert(zh)), ("ru", ru)]
    return "{ " + ", ".join(k + " = " + lua(v) for k, v in pairs if v) + " }"

def rows(name):
    for n, line in enumerate(open(os.path.join(HERE, name), encoding="utf-8"), 1):
        line = line.rstrip("\n")
        if not line.strip() or line.startswith("#"):
            continue
        parts = line.split("|")
        if len(parts) != 4:
            print(f"형식 오류 {name}:{n}: {line}", file=sys.stderr)
            continue
        yield [p.strip() for p in parts]

out = ["-- WoW Chat Translator: 툴팁 문장표·패턴 (자동 생성 - tools/build_tooltip.py)",
       "local ADDON, ns = ...", "ns.TipText = {"]
seen = set()
for en, ko, zh, ru in rows("tooltip_text.txt"):
    k = canon(en)
    if k in seen:
        print("중복:", en, file=sys.stderr)
    seen.add(k)
    out.append(f"\t[{lua(k)}] = {localized(ko, zh, ru)},")
out.append("}")
out.append("ns.TipNames = {")
nnames = 0
for en, ko, zh, ru in rows("tooltip_names.txt"):
    out.append(f"\t[{lua(en.lower())}] = {localized(ko, zh, ru)},")
    nnames += 1
out.append("}")
out.append("ns.TipPatterns = {")
npat = 0
for pat, ko, zh, ru in rows("tooltip_patterns.txt"):
    out.append(f"\t{{ {lua(pat)}, {localized(ko, zh, ru)} }},")
    npat += 1
out.append("}")
open(os.path.join(ROOT, "TooltipText.lua"), "w", encoding="utf-8").write("\n".join(out) + "\n")
print(f"문장 {len(seen)}개, 이름 {nnames}개, 패턴 {npat}개 -> TooltipText.lua")
