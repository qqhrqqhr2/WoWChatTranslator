from audit_regressions import run
run('''
assert(loadfile("TradMap.lua"))("WoWChatTranslator",ns)
assert(loadfile("GlossaryZH.lua"))("WoWChatTranslator",ns)
assert(loadfile("Chat.lua"))("WoWChatTranslator",ns)
for _,text in ipairs({"有FM大师吗","有 FM 大师 吗","有fm大师吗?","有FM大师嗎"}) do
 local g=ns.Gloss(text,ns.Detect(text),"ko")
 assert(g.plain:find("마법부여 장인 계신가요?",1,true),text.." => "..g.plain)
 assert(#g.unknown==0)
end
for _,pair in ipairs({{"求FM","마법부여사 구함"},{"找 FM","마법부여사 찾음"},{"有T吗","탱커 계신가요?"},{"缺 N","힐러 필요"},{"来DPS","딜러 구함"},{"FM大师","마법부여 장인"}}) do
 local g=ns.Gloss(pair[1],ns.Detect(pair[1]),"ko")
 assert(g.plain==pair[2],pair[1].." => "..g.plain)
end
for _,pair in ipairs({{"有FS吗","마법사 계신가요?"},{"求 MS","사제 구함"},{"来XD","드루이드 구함"},{"缺SS","흑마법사 구함"},{"找 DZ","도적 구함"}}) do
 local g=ns.Gloss(pair[1],ns.Detect(pair[1]),"ko")
 assert(g.plain==pair[2],pair[1].." => "..g.plain)
end
assert(not ns.Gloss("FM radio","en","ko").plain:find("마법부여",1,true))
ns.db.chat.langs.zh=false
assert(not ns.Gloss("有FM大师吗","zh","ko").plain:find("마법부여",1,true))
''')
print('중국어 혼합 약어·공백·대소문자·모집 조합·영어 문맥 보존 검증 통과')
