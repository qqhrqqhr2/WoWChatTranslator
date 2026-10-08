"""사전의 고유 영어 뜻 목록을 뽑는다 (번역표 작성용).
사용: python3 tools/list_meanings.py > tools/meanings.txt"""
import re, os, sys, collections
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
toc = open(os.path.join(root, "WoWChatTranslator.toc"), encoding="utf-8").read()
files = [l.strip() for l in toc.splitlines() if l.strip().startswith("Glossary")]
seen = collections.OrderedDict()
for f in files:
    s = open(os.path.join(root, f), encoding="utf-8").read()
    for m in re.finditer(r'ns\.RawGlossary\.(\w+) = (?:\(ns\.RawGlossary\.\w+ or ""\) \.\. )?\[\[\n(.*?)\]\]', s, re.S):
        for line in m.group(2).splitlines():
            if "=" not in line or line.startswith("--"):
                continue
            term, ko, en = [x.strip() for x in line.split("=")]
            if en and en.lower() not in seen:
                seen[en.lower()] = (en, ko)
for k, (en, ko) in seen.items():
    print(f"{en}\t{ko}")
