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
