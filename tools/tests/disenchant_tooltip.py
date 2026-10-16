from audit_regressions import run
run('''
assert(loadfile("TooltipText.lua"))("WoWChatTranslator",ns)
local samples={
 "Obtained from disenchanting uncommon (green) quality garments, amulets, rings, shields and off-hand frills within the ilvl bracket 10-25.",
 "Obtained from disenchanting uncommon (green) quality weapons within the ilvl bracket 16-30, except shields and off-hand frills."
}
for _,s in ipairs(samples) do
 local r=ns.TranslateTooltipLine(s,"ko")
 assert(r and r.full and not r.text:find("%a"),r and r.text or s)
 assert(r.text:find("마력 추출",1,true))
end
local r=ns.TranslateTooltipLine(samples[2],"ko")
assert(r.text:find("16~30",1,true) and r.text:find("제외",1,true))
for _,quality in ipairs({"uncommon (green)","rare (blue)","epic (purple)"}) do
 for _,kind in ipairs({"weapons","armor","armour","garments, amulets, rings, shields and off-hand frills"}) do
  local s="Obtained from disenchanting "..quality.." quality "..kind.." within the item level bracket 31-45."
  local r=ns.TranslateTooltipLine(s,"ko")
  assert(r.full and r.text:find("31~45",1,true) and not r.text:find("%a"),r.text)
 end
end
local wrapped=ns.TranslateTooltipLine("|cff00ff00"..samples[1]:gsub(" quality ","\\n quality ").."|r","ko")
assert(wrapped.full and wrapped.text:find("10~25",1,true))
assert(ns.IsTooltipBoundary("Added With Patch"))
assert(ns.IsTooltipBoundary("Item ID 10940"))
''')
print('마력 추출 획득처: 실제 예문·품질·분류·가변 레벨·제외 조건·줄바꿈 검증 통과')
