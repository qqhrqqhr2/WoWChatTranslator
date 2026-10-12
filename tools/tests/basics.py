from check import run
run('''
for _,name in ipairs({"Glossary","GlossaryEN","GlossaryZH","GlossaryRU","GlossaryKO","GlossaryJA","GlossaryES","Translations"}) do
 assert(loadfile(name..".lua"))("WoWChatTranslator",ns)
end
assert(loadfile("Chat.lua"))("WoWChatTranslator",ns)
for _,text in ipairs({"heals/tank","healer/dps","chat/inv","tank/healer/dps","shami","delay","shammy"}) do
 local g=ns.Gloss(text,"en","ko");assert(g.found>0 and #g.unknown==0,text)
end
assert(ns.Gloss("healer/dps","en","ko").plain:find("/",1,true))
assert(not ns.SlashMeaning("https://example.com","en","ko"))
assert(not ns.SlashMeaning("tank/UnknownPlayer","en","ko"))
assert(not ns.SlashMeaning("/w","en","ko"))
assert(not ns.SlashMeaning("w/","en","ko"))
assert(loadfile("UnknownChat.lua"))("WoWChatTranslator",ns)
ns.db.unknownChat={words={["en:healer/dps"]=5},samples={}}
for i=1,100 do ns.db.unknownChat.samples[i]="en: old "..i end
ns.RecordUnknownChat("newest","en",{unknown={"unlistedword"},cover=0})
assert(#ns.db.unknownChat.samples==100)
assert(ns.db.unknownChat.samples[1]=="en: old 2")
assert(ns.db.unknownChat.samples[100]=="en: newest")
assert(ns.db.unknownChat.words["en:healer/dps"]==nil)
ns.RecordUnknownChat("old 50","en",{unknown={"unlistedword"},cover=0})
assert(#ns.db.unknownChat.samples==100 and ns.db.unknownChat.samples[100]=="en: old 50")
''')
print('기본 별칭·슬래시 조합·URL/명령어 보존·최신 문장 교체 검증 통과')
