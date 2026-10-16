from audit_regressions import run
run('''
assert(loadfile("TooltipText.lua"))("WoWChatTranslator",ns)
local skills={Alchemy="연금술",Blacksmithing="대장기술",Enchanting="마법부여",Engineering="기계공학",Herbalism="약초채집",Leatherworking="가죽세공",Mining="채광",Skinning="무두질",Tailoring="재봉술",Cooking="요리",["First Aid"]="응급치료",Fishing="낚시"}
for en,ko in pairs(skills) do
 for _,template in ipairs({"Requires %s (225)","Increases your %s skill by 15.","Used in %s.","Created by %s.","Obtained from %s with a skill of 150 or higher."}) do
  local s=template:format(en)
  local r=ns.TranslateTooltipLine(s,"ko")
  assert(r and r.full and r.text:find(ko,1,true) and not r.text:find("%a"),s.." => "..tostring(r and r.text))
 end
 local r=ns.TranslateTooltipLine("Increases your "..en.." skill by 25 for 10 min.","ko")
 assert(r.full and r.text:find("25",1,true) and r.text:find("10분",1,true))
end
for _,s in ipairs({"Teaches you how to make Unknown Widget.","Teaches you how to cook Unknown Fish.","Teaches you how to smelt Unknown Ore."}) do
 local r=ns.TranslateTooltipLine(s,"ko")
 assert(r.full and r.text:find("Unknown",1,true) and not r.text:find("Teaches",1,true),r.text)
end
for _,s in ipairs({"Obtained from mining Copper Vein.","Obtained from skinning Unknown Beast.","Obtained from fishing in Unknown Lake.","Obtained from gathering Unknown Herb."}) do
 local r=ns.TranslateTooltipLine(s,"ko")
 assert(r.full and r.text:find("획득",1,true),r.text)
end
local r=ns.TranslateTooltipLine("Requires Engineering (300)","ko")
assert(r.full and r.text=="기계공학 숙련도 300 필요",r.text)
local added,hooks={},{}
ITEM_REQ_SKILL="Requires %s (%d)"
ns.OnLogin=nil
GameTooltip={GetName=function() return "ProfessionTip" end, GetUnit=function() end,
 NumLines=function() return 3 end, HookScript=function(_,ev,fn) hooks[ev]=fn end,
 AddLine=function(_,t) added[#added+1]=t end, Show=function() end}
ProfessionTipTextLeft1={GetText=function() return "시험 아이템" end}
ProfessionTipTextLeft2={GetText=function() return "Requires Engineering (225)" end}
ProfessionTipTextLeft3={GetText=function() return "Added With Patch" end}
assert(loadfile("Tooltip.lua"))("WoWChatTranslator",ns)
ns.OnLogin();hooks.OnShow(GameTooltip)
assert(table.concat(added," "):find("기계공학 숙련도 225 필요",1,true))
assert(not table.concat(added," "):find("Patch",1,true))
''')
print('12개 전문기술 공통 안내·숙련도·지속시간·제작법·미등록 이름 보존 검증 통과')
