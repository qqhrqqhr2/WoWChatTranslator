from check import run
run('''
ns.RawGlossary={zh="需要坦克=탱커 필요=need a tank"}
ns.db.chat.langs.zh=true
ns.db.chat.tag=false
ns.db.chat.skipSelf=false
ns.db.chat.minCover=0
ns.SAME_SOURCE.ko="ko"
local timers={}
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
assert(loadfile("Chat.lua"))("WoWChatTranslator",ns)
local function frame()
 return {lines={},AddMessage=function(self,text,r,g,b) self.lines[#self.lines+1]={text,r,g,b};return 42 end}
end
local visible,hidden=frame(),frame()
local f=filters.CHAT_MSG_CHANNEL
local _,shown=f(visible,"CHAT_MSG_CHANNEL","需要坦克","Other")
f(hidden,"CHAT_MSG_CHANNEL","需要坦克","Other")
assert(#visible.lines==0 and #hidden.lines==0 and #timers==0)
assert(visible:AddMessage(shown,0.7,0.2,0.4)==42)
assert(#visible.lines==2 and #hidden.lines==0)
assert(visible.lines[2][1]:find("탱커 필요",1,true))
assert(visible.lines[2][2]==0.7)
visible:AddMessage("System message")
assert(#visible.lines==3 and #hidden.lines==0)
for i=1,250 do f(hidden,"CHAT_MSG_CHANNEL","需要坦克","Other") end
assert(#hidden.wctSeparatePending.order==200)
local count=0;for _ in pairs(hidden.wctSeparatePending.values) do count=count+1 end
assert(count<=200 and #hidden.lines==0)
local _,a=f(visible,"CHAT_MSG_CHANNEL","需要坦克","First")
local _,b=f(visible,"CHAT_MSG_CHANNEL","需要坦克","Second")
visible:AddMessage(a);visible:AddMessage(b)
assert(#visible.lines==7)
''')
print('숨긴 채널 번역 차단, 원문 직후 출력, 중복 후킹 방지, 색상/반환값 유지, 대기 한도 검증 통과')
