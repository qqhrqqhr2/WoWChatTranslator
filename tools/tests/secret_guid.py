from check import run
run('''
local scripts={}
CreateFrame=function()return {RegisterEvent=function()end,SetScript=function(_,event,fn)scripts[event]=fn end}end
hooksecurefunc=nil
local protected={}
issecretvalue=function(value)return rawequal(value,protected)end
local calls=0
GetPlayerInfoByGUID=function(guid)calls=calls+1;return "드루이드","DRUID","나이트 엘프" end
assert(loadfile("PlayerTooltip.lua"))("WoWChatTranslator",ns)
local function send(name,guid)
 scripts.OnEvent(nil,"CHAT_MSG_CHANNEL","message",name,nil,nil,nil,nil,nil,nil,nil,nil,nil,guid)
end
send("Player",protected);assert(calls==0)
send(protected,"Player-1");assert(calls==0)
send("Player","");assert(calls==0)
send("Player","Player-1");assert(calls==1)
GetPlayerInfoByGUID=function()calls=calls+1;return protected,nil,protected end
send("Player","Player-1");assert(calls==2)
issecretvalue=nil
GetPlayerInfoByGUID=function()calls=calls+1;return "드루이드","DRUID","나이트 엘프" end
send("Player","Player-1");assert(calls==3)
''')
print('보호 GUID/이름/반환값 건너뛰기 및 기존 클라이언트 호환 검증 통과')
