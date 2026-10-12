from audit_regressions import run
run('''
assert(loadfile("TooltipText.lua"))("WoWChatTranslator",ns)
assert(loadfile("TooltipDB.lua"))("WoWChatTranslator",ns)
local text="사용 효과: Raise the severed head of Roogug, Horrifying and Silencing all Swine within 15 yds for 5초."
local t=ns.TranslateTooltipLine(text,"ko")
assert(t and t.text:find("15미터",1,true) and t.text:find("5초",1,true))
assert(t.text:find("공포",1,true) and t.text:find("침묵",1,true))
assert(not t.text:find("Silencing",1,true))
local v=ns.TranslateTooltipLine(text:gsub("15 yds","20 yds"):gsub("5초","8초"),"ko")
assert(v.text:find("20미터",1,true) and v.text:find("8초",1,true))
assert(ns.TipNames["roogug's severed head"].ko=="루구그의 잘린 머리")
''')
print('루구그 사용 효과 문장 번역·수치 변경·아이템 이름 검증 통과')
