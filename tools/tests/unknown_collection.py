from check import run
run('''
ns.RawGlossary={zh="坦克=탱커=tank",en="dal=달라란=Dalaran"}
assert(loadfile("Chat.lua"))("WoWChatTranslator",ns)
local g=ns.Gloss("陌陌坦克隐隐","zh","ko")
assert(#g.unknown==2 and g.unknown[1]=="陌陌" and g.unknown[2]=="隐隐")
assert(loadfile("UnknownChat.lua"))("WoWChatTranslator",ns)
ns.db.unknownChat={words={["en:dal"]=5,["zh:备"]=7,["zh:gezi130323"]=9},samples={}}
ns.RecordUnknownChat("sample","zh",{unknown={"gezi130323","备","坦克","陌陌"},cover=90})
assert(ns.db.unknownChat.words["zh:陌陌"]==1)
assert(ns.db.unknownChat.words["en:dal"]==nil)
assert(ns.db.unknownChat.words["zh:备"]==nil)
assert(ns.db.unknownChat.words["zh:gezi130323"]==nil)
assert(ns.db.unknownChat.words["zh:坦克"]==nil)
ns.ShowCopy=function(text) assert(text:find("陌陌",1,true));assert(not text:find("gezi130323",1,true)) end
GetLocale=function()return "koKR" end
ns.ShowUnknownChat()
''')
print('중국어 연속 구절 수집 및 등록 표현/한 글자/연락처 제거 검증 통과')
