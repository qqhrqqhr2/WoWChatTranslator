from check import run
# 채널별 끄기, Shift+클릭(입력 중이면 원래 동작), 나만의 단어, 내 메시지 번역
run('''
ns.RawGlossary={en="lfg=파티 찾음=looking for group", ko="탱커=탱커=tank\\n구함=구함=looking for", zh="来t=탱커 구함=looking for a tank"}
ns.db.chat.langs.en=true; ns.db.chat.langs.zh=true
ns.db.chat.tag=false; ns.db.chat.skipSelf=false; ns.db.chat.minCover=0
ns.db.chat.channels={public=true,say=true,guild=false,group=true,whisper=true}
ns.db.chat.playerTip=true
ns.SAME_SOURCE.ko="ko"; ns.SAME_SOURCE.en="en"; ns.CLIENT_TARGET="ko"
ns.TARGET_NAME={ko="한국어",en="English"}
ns.L.outDone="%s %d"; ns.L.outLeft="%s"; ns.L.outUsage="u"; ns.L.outNone="n"
ns.L.addDone="%s %s"; ns.L.addUsage="u"; ns.L.delDone="%s"; ns.L.delNone="%s"
DEFAULT_CHAT_FRAME={AddMessage=function() end}
C_Timer={After=function(_,fn) fn() end}
assert(loadfile("Chat.lua"))("WoWChatTranslator",ns)
assert(loadfile("Outgoing.lua"))("WoWChatTranslator",ns)
local f=filters.CHAT_MSG_GUILD
local _,out=f({},"CHAT_MSG_GUILD","lfg","Other")
assert(out==nil, "길드 채널은 꺼져 있어야 함")
local _,out2=filters.CHAT_MSG_SAY({},"CHAT_MSG_SAY","lfg","Other")
assert(out2 and out2:find("파티 찾음",1,true))
-- 번역하지 않는 메시지도 클릭 복사 (copyAll)
ns.db.chat.copyAll=true
local _,g2=f({},"CHAT_MSG_GUILD","lfg","Other")
assert(g2 and g2:find("|Hwctcopy:",1,true) and not g2:find("파티 찾음",1,true), "꺼진 채널은 복사 링크만")
local _,k=filters.CHAT_MSG_SAY({},"CHAT_MSG_SAY","안녕하세요 반가워요","Other")
assert(k and k:find("|Hwctcopy:%d+|h안녕하세요 반가워요|h"), tostring(k))
local _,lk=filters.CHAT_MSG_SAY({},"CHAT_MSG_SAY","안녕 |Hitem:1|h[물건]|h 팔아요","Other")
assert(lk:find("|Hitem:1|h[물건]|h",1,true) and select(2, lk:gsub("|Hwctcopy:",""))==2)
ns.db.chat.copyAll=false
local _,k2=filters.CHAT_MSG_SAY({},"CHAT_MSG_SAY","또 안녕하세요","Other")
assert(k2==nil)
-- 한자 뒤에 붙은 영문
assert(ns.Gloss("来T","zh","ko").plain:find("탱커 구함",1,true))
-- 나만의 단어
ns.db.custom={}
assert(ns.ExtraCommand("add zqword=테스트 뜻"))
assert(ns.Gloss("zqword","en","ko").plain=="테스트 뜻")
assert(ns.ExtraCommand("del zqword"))
assert(ns.Gloss("zqword","en","ko").plain~="테스트 뜻")
-- 내 메시지 번역: 입력창에 결과를 넣는다
local opened
ChatFrame_OpenChat=function(t) opened=t end
assert(ns.ExtraCommand("en 탱커 구함"))
assert(opened=="tank looking for", tostring(opened))
-- Shift+클릭: 입력 중이면 원래 SetItemRef 로 넘김
local passed, requested = 0, 0
SetItemRef=function() passed=passed+1 end
ns.RequestPlayerInfo=function() requested=requested+1 return true end
IsShiftKeyDown=function() return true end
ns.OnLogin()
ChatEdit_GetActiveWindow=function() return {} end
SetItemRef("player:Someone","[Someone]","LeftButton")
assert(passed==1 and requested==0)
ChatEdit_GetActiveWindow=function() return nil end
SetItemRef("player:Someone","[Someone]","LeftButton")
assert(passed==1 and requested==1)
ns.db.chat.playerTip=false
SetItemRef("player:Someone","[Someone]","LeftButton")
assert(passed==2 and requested==1)
''')
print("채널별 끄기·한자+영문·나만의 단어·내 메시지 번역·Shift+클릭 입력창 보존 검증 통과")
run('''
assert(ns.Gloss("黑上 4=1","zh","ko").plain:find("4명 있음, 1명 구함",1,true))
assert(not ns.Gloss("score 2=3","en","ko").plain:find("명 있음",1,true))
''')
print("파티 인원 표기(4=1) 검증 통과")
run('''
ns.RawGlossary.en = (ns.RawGlossary.en or "") .. "\\nk=ㅇㅋ=ok"
ns.db.chat.copyAll=false; ns.db.chat.langs.ko=true; ns.db.chat.langs.en=true; ns.db.chat.channels.guild=true
assert(loadfile("Chat.lua"))("WoWChatTranslator",ns)
local _,o=filters.CHAT_MSG_GUILD({},"CHAT_MSG_GUILD","k 누르고 전문기술 탭에 경험치 게이지 오른쪽 끝에","Other")
assert(o==nil, "현지 언어 문장 속 한 글자 약어만으로는 번역 표시 안 함: "..tostring(o))
local _,o2=filters.CHAT_MSG_GUILD({},"CHAT_MSG_GUILD","lfg 하실분 있나요","Other")
assert(o2 and o2:find("파티 찾음",1,true), "세 글자 이상 외국어 표현은 풀이: "..tostring(o2))
''')
print("현지 언어 문장 속 한 글자 약어 무시 검증 통과")
