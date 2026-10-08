"""애드온 번역 엔진을 그대로 돌려서 이미지에 쓸 실제 결과를 JSON으로 저장한다."""
import json, os, re, sys
from lupa.lua51 import LuaRuntime
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def load(client="koKR"):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute(f'''
    GetLocale=function() return "{client}" end
    CreateFrame=function() return setmetatable({{}},{{__index=function() return function() end end}}) end
    hooksecurefunc=function() end; SlashCmdList={{}}; NS={{}}
    ''')
    toc = open(os.path.join(ROOT, "WoWChatTranslator.toc"), encoding="utf-8").read()
    for f in [l.strip() for l in toc.splitlines() if l.strip().endswith(".lua")]:
        lua.eval("function(s,n) local f,e=loadstring(s,n); if not f then error(e) end; f('WoWChatTranslator',NS) end")(
            open(os.path.join(ROOT, f), encoding="utf-8").read(), f)
    return lua

lua = load()
def gloss(text, target):
    lang = lua.eval("NS.Detect")(text)
    g = lua.eval("NS.Gloss")(text, lang, target)
    terms = [(g.terms[i][1], g.terms[i][2]) for i in range(1, len(g.terms) + 1)]
    # rough: 초록(뜻)/흰색(원문) 조각으로 나누기
    segs = []
    for m in re.finditer(r"\|cff99ff99(.*?)\|r|([^|]+)", g.rough):
        if m.group(1) is not None:
            segs.append(["hit", m.group(1)])
        else:
            segs.append(["miss", m.group(2)])
    return {"lang": lang, "plain": g.plain, "cover": g.cover, "terms": terms, "rough": segs}

samples = {
    "en1": "lfg RF Quest",
    "en2": "LFM BRD need tank and heals, last spot pst",
    "en3": "WTS Arcanite Bar 30g each, CoD ok",
    "zh1": "黑上 来个奶 速度 门口集合",
    "zh2": "收人中 不限职业 欢迎新人 氛围好 有yy",
    "ru1": "Продам рунку 2з за стак, пишите в лс",
    "ko1": "검바 탱 구합니다 귓주세요",
    "ko2": "화심 공대 모집 힐러 딜러 구해요",
    "ja1": "PT募集 ストラトホルム タンク",
}
out = {}
for k, t in samples.items():
    out[k] = {"text": t}
    for target in ["ko", "en", "zhCN", "zhTW", "ru"]:
        out[k][target] = gloss(t, target)
json.dump(out, open(sys.argv[1], "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("ok", len(out))
