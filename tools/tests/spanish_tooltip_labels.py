from audit_regressions import run
run('''
for _,file in ipairs({"TradMap.lua","Glossary.lua","GlossaryEN.lua","GlossaryES.lua","GlossaryKO.lua","GlossaryZH.lua","GlossaryJA.lua","GlossaryRU.lua","Translations.lua"}) do
 assert(loadfile(file))("WoWChatTranslator",ns)
end
ns.db.chat.langs.es=true
assert(loadfile("Chat.lua"))("WoWChatTranslator",ns)
local text="¿Buscas latinos con los que prepararte para el lanzamiento? ¡No busques mas! ¡Unite a Vae Victis!"
assert(ns.Detect(text)=="es")
local g=ns.Gloss(text,"es","ko")
print("Spanish sample:",g.plain)
assert(g.plain:find("정식 오픈을 함께 준비",1,true))
assert(g.plain:find("더 찾지 마세요",1,true))
assert(g.plain:find("Vae Victis",1,true))
assert(not g.plain:find("prepararte",1,true))
assert(not g.plain:find("lanzamiento",1,true))
assert(ns.Detect("Unite a Vae Victis")=="es")
assert(ns.Detect("bus stop near the tank")=="en")
GetNumAddOns=function()return 1 end
GetAddOnInfo=function()return "TestAddon", "|cff00ffffExample Utility|r" end
assert(loadfile("Tooltip.lua"))("WoWChatTranslator",ns)
assert(ns.IsTooltipBoundary("|cff00ffffWoW Smart Fishing|r"))
assert(ns.IsTooltipBoundary("Example Utility"))
assert(not ns.IsTooltipBoundary("Increases fishing skill by 5."))
assert(not ns.IsTooltipBoundary("Deals 50 fire damage."))
''')
print('스페인어 문장·길드명 유지·영어 오감지 방지·애드온 이름 제외 검증 통과')
