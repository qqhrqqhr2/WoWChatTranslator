from audit_regressions import run
run('''
for _,f in ipairs({"GlossaryEN.lua","GlossaryES.lua","GlossaryZH.lua","TradMap.lua","Chat.lua","UnknownChat.lua"}) do assert(loadfile(f))("WoWChatTranslator",ns) end
for _,pair in ipairs({{"invvvvvvvvvv","초대"},{"anyyyy","아무"},{"racial hit","종족 특성 적중 보너스"},{"shunder armor","방어구 가르기"},{"信箱咋打不开了。。","우편함이 왜 안 열리죠"},{"hab das falsche teil gecraftet und nun kein gold mehr","잘못된 물건을 제작해서 이제 골드가 없어요"}}) do
 local text,expected=pair[1],pair[2]
 local g=ns.Gloss(text,ns.Detect(text),"ko")
 assert(g.plain:find(expected,1,true),text.." => "..g.plain)
end
assert(ns.MatchPattern("Mooooo","en","ko")==nil)
assert(ns.MatchPattern("invvvvv","zh","ko")==nil)
ns.db.unknownChat={words={["en:invvvvvvvvvv"]=3,["en:anyyyy"]=1,["en:ct"]=22},samples={}}
ns.ShowCopy=function(t)
 assert(not t:find("invvvvv",1,true) and not t:find("anyyyy",1,true))
 assert(t:find("en:ct",1,true))
end
GetLocale=function() return "koKR" end
ns.ShowUnknownChat()
''')
print('새 수집 표현·제한적 강조 표기·미등록 제외·불명확 약어 보존 통과')
