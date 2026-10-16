from audit_regressions import run
run('''
assert(loadfile("TooltipText.lua"))("WoWChatTranslator",ns)
local mana="Chance on damaging spell to allow 15% of your Mana regeneration to continue while casting for 15 sec. Mana regen amount is doubled in Strongholds and Cities."
local summon="Chance on damaging spell to summon an Arcane elemental to aid you in combat."
for _,label in ipairs({"(4) 세트 효과: ","(4) Set: "}) do
 local r=ns.TranslateTooltipLine(label..mana,"ko")
 assert(r and r.full and r.text:find("(4) 세트 효과:",1,true))
 assert(r.text:find("15초",1,true) and r.text:find("15%",1,true))
 assert(r.text:find("두 배",1,true) and not r.text:find("%a"),r.text)
end
local changed=ns.TranslateTooltipLine("(6) Set: "..mana:gsub("15%%","20%%"):gsub("15 sec","8 sec"),"ko")
assert(changed.full and changed.text:find("(6)",1,true) and changed.text:find("20%",1,true) and changed.text:find("8초",1,true),changed.text)
local r=ns.TranslateTooltipLine("(5) 세트 효과: "..summon,"ko")
assert(r.full and r.text:find("비전 정령",1,true) and not r.text:find("%a"),r.text)
local wrapped=ns.TranslateTooltipLine("|cff808080(4) 세트 효과: "..mana:gsub(" to ","\\n to ").."|r","ko")
assert(wrapped.full and not wrapped.text:find("%a"),wrapped.text)
for _,target in ipairs({"zhCN","zhTW","ru"}) do
 assert(ns.TranslateTooltipLine("(5) Set: "..summon,target).full)
end
''')
print('세트 효과 문장·한영 머리말·수치 변경·줄바꿈·색상 코드 검증 통과')
