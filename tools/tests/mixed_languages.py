from check import run
run('''
for _,name in ipairs({"TradMap","Glossary","GlossaryEN","GlossaryZH","GlossaryRU","GlossaryKO","GlossaryJA","GlossaryES","Translations"}) do
 assert(loadfile(name..".lua"))("WoWChatTranslator",ns)
end
ns.db.chat.langs={ko=true,en=true,es=true,ru=true,zh=true,ja=true}
ns.L.tag={ko="KO",en="EN",zh="ZH",ru="RU",ja="JA",es="ES"}
assert(loadfile("Chat.lua"))("WoWChatTranslator",ns)
local examples={
 {"你好 нужен танк LFM DPS",{"탱커","딜러"}},
 {"안녕하세요 파티 모집합니다 нужен танк",{"안녕하세요","탱커"}},
 {"안녕하세요 파티 모집합니다 Buscamos tanque",{"안녕하세요","탱커"}},
 {"达拉然 LFM 2 DPS SM lib",{"달라란","도서관"}},
 {"タンク募集 нужен танк",{"탱커"}},
}
for _,example in ipairs(examples) do
 local text=example[1];local lang=ns.Detect(text);local g=ns.Gloss(text,lang,"ko")
 assert(g.foreignFound>0,text)
 for _,word in ipairs(example[2]) do assert(g.plain:find(word,1,true),text.." => "..g.plain) end
end
local f=filters.CHAT_MSG_SAY
local _,out=f(nil,"CHAT_MSG_SAY","안녕하세요 파티 모집합니다 нужен танк","Other")
assert(out and out:find("탱커",1,true))
local _,localOnly=f(nil,"CHAT_MSG_SAY","안녕하세요 파티 모집합니다","Other")
assert(not localOnly)
ns.db.chat.langs.ru=false
local _,disabled=f(nil,"CHAT_MSG_SAY","안녕하세요 파티 모집합니다 нужен танк","Other")
assert(not disabled)
ns.db.chat.langs.ru=true
local g=ns.Gloss("你好 mysteriousunknown неизвестно","zh","ko")
assert(g.unknownByLanguage.en and g.unknownByLanguage.ru)
''')
print('5종 혼합 문장·한국어 원문 유지·현지 언어 전체 제외 방지·언어별 끄기·수집 언어 분리 검증 통과')
