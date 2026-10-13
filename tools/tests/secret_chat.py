from check import run
# 보호된 채팅 문자열: 필터는 그대로 통과, 뜻 줄 덧붙이기는 AddMessage 를 바꿔 끼우지 않는 후크로
run('''
ns.RawGlossary={zh="需要坦克=탱커 필요=need a tank"}
ns.db.chat.langs.zh=true; ns.db.chat.tag=false; ns.db.chat.skipSelf=false; ns.db.chat.minCover=0
ns.SAME_SOURCE.ko="ko"
local SECRET="需要坦克 (secret)"
issecretvalue=function(v) return rawequal(v, SECRET) end
hooksecurefunc=function(t, name, fn)
  local orig=t[name]
  t[name]=function(...) local r=orig(...); fn(...); return r end
end
assert(loadfile("Chat.lua"))("WoWChatTranslator",ns)
local f=filters.CHAT_MSG_CHANNEL
local frame={lines={},AddMessage=function(self,text) self.lines[#self.lines+1]=text end}
assert(f(frame,"CHAT_MSG_CHANNEL",SECRET,"Other")==false)
local _,shown=f(frame,"CHAT_MSG_CHANNEL","需要坦克","Other")
frame:AddMessage(SECRET)          -- 보호된 줄이 와도 오류 없이 지나감
frame:AddMessage(shown)
assert(#frame.lines==3, #frame.lines)
assert(frame.lines[3]:find("탱커 필요",1,true))
frame:AddMessage(shown)           -- 같은 줄을 다시 출력해도 뜻 줄은 한 번만
assert(#frame.lines==4)
issecretvalue=nil
''')
print("보호된 채팅 문자열 통과·후크 방식 뜻 줄 출력 검증 통과")
