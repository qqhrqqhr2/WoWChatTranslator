"""fetch_db.py 로 모은 데이터 -> TooltipDB.lua (툴팁 번역표)
- 영어 문단·문장과 현지어(한국어/간체/번체) 문단·문장을 짝지어 정확히 맞는 번역표를 만든다.
- 숫자는 # 로 바꿔 열쇠를 만들고, 번역문의 숫자는 영어 숫자 순서에 맞춰 {1} {2} 로 바꾼다.
- 게임 문장과 표현이 조금 다른 경우를 위해 단어 집합(비슷한 문장 찾기용)도 함께 넣는다.
- 아이템·주문·특성 이름표도 만든다.
사용: python3 tools/build_db.py <fetch_db 출력 폴더>
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SRC = sys.argv[1]
TARGETS = {"ko": "ko", "zh": "zhCN", "tw": "zhTW"}

UNITS = [(r"(\d+)\s+hours?", r"\1 hr"), (r"(\d+)\s+hrs?", r"\1 hr"), (r"(\d+)\s+minutes?", r"\1 min"),
         (r"(\d+)\s+mins?", r"\1 min"), (r"(\d+)\s+seconds?", r"\1 sec"), (r"(\d+)\s+secs?", r"\1 sec")]
NUM = re.compile(r"\d+\.?\d*")
STOP = set("a an the of to and or in on by for with your you is are be it its this that from as at into".split())


def canon(s):
    """Tooltip.lua 의 Canon + KeyOf 와 같게"""
    s = re.sub(r"\|c[0-9a-fA-F]{8}|\|r", "", s).lower()
    s = re.sub(r"\s+", " ", s)
    for p, r in UNITS:
        s = re.sub(p, r, s)
    s = s.strip().strip('"').strip()
    s = re.sub(r"[.!]+$", "", s)
    return s


def key_and_nums(s):
    c = canon(s)
    nums = NUM.findall(c)
    return NUM.sub("#", c), nums


def numsig(key):
    """숫자 자리 모양: "#%" 와 "#" 의 순서 (비슷한 문장이라도 숫자 모양이 다르면 쓰지 않음)"""
    return ",".join("p" if m.group(1) else "n" for m in re.finditer(r"#(%)?", key))


def placeholder(tgt, en_nums):
    """번역문의 숫자를 영어 숫자 위치 {i} 로 바꾼다 (같은 값끼리 짝)"""
    used = set()

    def rep(m):
        v = m.group(0)
        for i, e in enumerate(en_nums):
            if i not in used and e == v:
                used.add(i)
                return "{%d}" % (i + 1)
        return v
    return NUM.sub(rep, tgt)


def en_sentences(t):
    return [x for x in re.split(r"(?<=[.!?])\s+(?=[^\s\d])", t.strip()) if x.strip()]


def tgt_sentences(t, lang):
    if lang in ("zh", "tw"):
        parts = re.split(r"(?<=[。！？])", t.strip())
    else:
        parts = re.split(r"(?<=[.!?])\s+", t.strip())
    return [x for x in parts if x.strip()]


def paragraphs(t):
    return [x.strip() for x in (t or "").replace("\r", "").split("\n") if x.strip()]


exact = {}      # key -> {target: text}
fuzzy = {}      # key -> (words, {target: text})
names = {}      # en lower -> {target: name}


def add_pair(en, tgt, lang):
    if not en or not tgt or len(en) < 4:
        return
    if not re.search(r"[A-Za-z]{2}", en):
        return
    # 현지어 쪽이 아직 번역 안 된(영어 그대로인) 항목은 버린다
    script = r"[\uac00-\ud7af]" if lang == "ko" else r"[\u4e00-\u9fff]"
    if not re.search(script, tgt) or tgt.strip().lower() == en.strip().lower():
        return
    key, nums = key_and_nums(en)
    if len(key) < 6:
        return
    t = placeholder(tgt.strip(), nums)
    e = exact.setdefault(key, {})
    e.setdefault(TARGETS[lang], t)
    words = sorted(set(w for w in re.findall(r"[a-z']+", key) if w not in STOP and len(w) > 1))
    if len(words) >= 4:
        sig = numsig(key)
        f = fuzzy.setdefault(key, (" ".join(words), {}, sig))
        f[1].setdefault(TARGETS[lang], t)


def add_text(en_text, tgt_text, lang):
    """문단 → 문장 순서로 짝을 맞춘다"""
    ep, tp = paragraphs(en_text), paragraphs(tgt_text)
    if not ep or not tp:
        return
    if len(ep) != len(tp):
        add_pair(" ".join(ep), " ".join(tp), lang)
        return
    for a, b in zip(ep, tp):
        add_pair(a, b, lang)
        es, ts = en_sentences(a), tgt_sentences(b, lang)
        if len(es) > 1 and len(es) == len(ts):
            for x, y in zip(es, ts):
                add_pair(x, y, lang)


def add_name(en, tgt, lang):
    script = r"[\uac00-\ud7af]" if lang == "ko" else r"[\u4e00-\u9fff]"
    if en and tgt and re.search(r"[A-Za-z]", en) and re.search(script, tgt):
        names.setdefault(en.strip().lower(), {}).setdefault(TARGETS[lang], tgt.strip())


# 주문책·특성
for kind in ("spellbook", "talents"):
    path = os.path.join(SRC, f"{kind}.json")
    if not os.path.exists(path):
        continue
    d = json.load(open(path, encoding="utf-8"))
    en = d.get("en", {})
    for lang in TARGETS:
        for cls, spells in d.get(lang, {}).items():
            for sid, s in spells.items():
                e = en.get(cls, {}).get(sid)
                if not e:
                    continue
                add_name(e.get("name") or s.get("nameEn"), s.get("name"), lang)
                for a, b in zip(e.get("ranks") or [], s.get("ranks") or []):
                    add_text(a, b, lang)

# 아이템
path = os.path.join(SRC, "items.json")
if os.path.exists(path):
    d = json.load(open(path, encoding="utf-8"))
    en = d.get("en", {})
    for lang in TARGETS:
        for iid, it in d.get(lang, {}).items():
            e = en.get(iid)
            if not e:
                continue
            add_name(e.get("name"), it.get("name"), lang)
            for a, b in zip(e.get("effects") or [], it.get("effects") or []):
                add_text((a or {}).get("text"), (b or {}).get("text"), lang)
            if e.get("flavor") and it.get("flavor"):
                add_text(e["flavor"], it["flavor"], lang)


def lua(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n") + '"'


def tbl(t):
    return "{ " + ", ".join(f"{k} = {lua(v)}" for k, v in sorted(t.items())) + " }"


out = ["-- WoW Chat Translator: 게임 데이터 툴팁 번역표 (자동 생성 - tools/build_db.py)",
       "-- 주문·특성·아이템의 영어 문장 → 한국어/간체/번체. 직접 만든 표(TooltipText.lua)가 우선한다.",
       "local ADDON, ns = ...", "ns.TipDBText = {"]
for k in sorted(exact):
    out.append(f"\t[{lua(k)}] = {tbl(exact[k])},")
out.append("}")
out.append("ns.TipDBNames = {")
for k in sorted(names):
    out.append(f"\t[{lua(k)}] = {tbl(names[k])},")
out.append("}")
out.append("-- 비슷한 문장 찾기용: { 단어들, 번역, 숫자 모양 }")
out.append("ns.TipDBFuzzy = {")
for k in sorted(fuzzy):
    w, t, sig = fuzzy[k]
    out.append(f"\t{{ {lua(w)}, {tbl(t)}, {lua(sig)} }},")
out.append("}")
open(os.path.join(ROOT, "TooltipDB.lua"), "w", encoding="utf-8").write("\n".join(out) + "\n")
print(f"문장 {len(exact)}개, 이름 {len(names)}개, 비슷한 문장용 {len(fuzzy)}개 -> TooltipDB.lua")
