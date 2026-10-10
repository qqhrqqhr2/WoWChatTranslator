import ctypes
from pathlib import Path
lib=ctypes.CDLL('liblua5.4.so.0')
lib.luaL_newstate.restype=ctypes.c_void_p
lib.luaL_openlibs.argtypes=[ctypes.c_void_p]
lib.luaL_loadbufferx.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_size_t,ctypes.c_char_p,ctypes.c_char_p]
lib.lua_pcallk.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_longlong,ctypes.c_void_p]
lib.lua_tolstring.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p];lib.lua_tolstring.restype=ctypes.c_char_p
lib.lua_settop.argtypes=[ctypes.c_void_p,ctypes.c_int]
state=lib.luaL_newstate();lib.luaL_openlibs(state)
def run(s,name='test'):
    b=s.encode();code=lib.luaL_loadbufferx(state,b,len(b),name.encode(),None)
    if not code:code=lib.lua_pcallk(state,0,0,0,0,None)
    if code:raise RuntimeError(lib.lua_tolstring(state,-1,None).decode())
for p in Path('.').glob('*.lua'):
    b=p.read_bytes();assert lib.luaL_loadbufferx(state,b,len(b),str(p).encode(),None)==0,p
    lib.lua_settop(state,0)
run('''ns={RawGlossary={en="will tip=팁 드릴게=will tip\\nlfg=파티 찾음=looking for group\\nwts=판매=selling"}, L={tag={en="EN"}}, SAME_SOURCE={ko="ko"}, GetTarget=function() return "ko" end}
ns.db={chat={enabled=true,skipSelf=false,langs={en=true},tag=true,hoverAll=true,inline=true,minCover=0}}
filters={}; ChatFrame_AddMessageEventFilter=function(event,fn) filters[event]=fn end
''')
run('assert(loadfile("Chat.lua"))("WoWChatTranslator",ns)')

run("""
CreateFrame=function() return {RegisterEvent=function() end,SetScript=function() end} end
ITEM_SPELL_TRIGGER_ONUSE="사용 효과:"
ITEM_SPELL_TRIGGER_ONEQUIP="착용 효과:"
ITEM_SPELL_TRIGGER_ONPROC="적중 시 발동:"
DEFAULT_CHAT_FRAME={AddMessage=function() end}
ns.L.tipUse="사용 효과:";ns.L.tipEquip="착용 효과:";ns.L.tipProc="적중 시 발동:"
ns.L.collectCleared="초기화"
ns.db.tooltip={enabled=true,collect=true}
ns.TipText={["restores # mana"]={ko="마나 {1} 회복"}}
assert(loadfile("Tooltip.lua"))("WoWChatTranslator",ns)
local t=ns.TranslateTooltipLine("사용 효과: Restores 20 mana.","ko")
print("현지화 머리말 처리 결과:", t and t.text or "번역 없음")
local x="Uncatalogued mysterious phrase alpha"
ns.TranslateTooltipLine(x,"ko")
assert(ns.db.collectedCount==1)
ns.CollectCommand("clear")
ns.TranslateTooltipLine(x,"ko")
assert(ns.db.collectedCount==1)
print("수집 초기화 후 같은 문장 재수집 정상: 통과")
ns.db.tooltip.collect=false
local y="Uncatalogued mysterious phrase beta"
ns.TranslateTooltipLine(y,"ko")
ns.db.tooltip.collect=true
ns.TranslateTooltipLine(y,"ko")
assert(ns.db.collectedCount==2)
print("수집 끔→켬 후 이미 본 문장 수집 정상: 통과")
ns.db.collectedCount=3000
ns.TranslateTooltipLine("Uncatalogued mysterious phrase gamma","ko")
assert(ns.db.collectedCount==3000)
print("수집 제한 초과 후 내부 개수 유지: 통과")
""")
run('''
-- 실제 사전을 로드해 화면의 러시아어 사례와 글자 사이 공백 사례 비교
for _,name in ipairs({"Glossary","GlossaryEN","GlossaryZH","GlossaryRU","GlossaryKO"}) do
 assert(loadfile(""..name..".lua"))("WoWChatTranslator",ns)
end
assert(loadfile("Chat.lua"))("WoWChatTranslator",ns)
for _,s in ipairs({"Инчантеры есть?","И н ч а н т е р ы есть?"}) do
 local g=ns.Gloss(s,"ru","ko");assert(g.cover==100);assert(g.plain=="마법부여사들 있나요?");print("러시아어 사례:",s,"=>",g.plain,"인식률",g.cover)
end
local c=filters.CHAT_MSG_SAY
local function msg(text,id) local _,out=c(nil,"CHAT_MSG_SAY",text,"Other",nil,nil,nil,nil,nil,nil,nil,nil,id);return out end
ns.db.chat.tag=false;ns.db.chat.hoverAll=true
local v=msg("|cfffffffflfg|r",98)
assert(not v:find("[EN]",1,true));print("언어 표시 끔 + 색상 포함 메시지에 표시 없음: 통과")
ns.db.chat.skipSelf=true;UnitName=function() return "Me" end
ChatFrame1={AddMessage=function(self,text) self.last=text end, HookScript=function() end}
NUM_CHAT_WINDOWS=1
SetItemRef=function() end
ChatFrame_AddMessageEventFilter=nil
-- 파일을 다시 읽으면 필터 없는 클라이언트 대체 경로 사용
assert(loadfile("Chat.lua"))("WoWChatTranslator",ns)
ns.OnLogin()
ChatFrame1:AddMessage("|Hplayer:Me|h[Me]|h: lfg")
assert(not ChatFrame1.last:find("|Hwct:",1,true));print("대체 처리 경로에서 본인 메시지 제외 정상: 통과")
''')
run('''
-- 기존 채팅 항목의 툴팁은 언어를 바꾸면 풀이를 다시 계산한다.
local target="ko";ns.GetTarget=function() return target end
ns.L.glossTitle="%s 번역";ns.L.langName={en="영어"};ns.L.rough="뜻";ns.L.terms="표현";ns.L.clickHint="복사"
GameTooltip={lines={},SetOwner=function() end,ClearLines=function(self) self.lines={} end,
 AddLine=function(self,text) self.lines[#self.lines+1]=text end,AddDoubleLine=function() end,Show=function() end}
local hooks={}
ChatFrame1={AddMessage=function() end,HookScript=function(self,event,fn) hooks[event]=fn end}
ChatFrame_AddMessageEventFilter=function(event,fn) filters[event]=fn end
ns.db.chat.tag=true
ns.db.chat.skipSelf=false
assert(loadfile("Chat.lua"))("WoWChatTranslator",ns)
ns.OnLogin()
local _,out=filters.CHAT_MSG_SAY(nil,"CHAT_MSG_SAY","lfg","Other")
local link=out:match("|H(wct:%d+)|h")
target="en"
hooks.OnHyperlinkEnter(ChatFrame1,link)
assert(GameTooltip.lines[5]==ns.Gloss("lfg","en","en").rough)
print("언어 변경 후 기존 채팅 툴팁 재계산: 통과")

-- 지연 스캔 취소 및 주문책 이벤트 예약 중복 억제
ns.OnLogin=nil
local timers,frames,spellReads={}, {}, 0
C_Timer={After=function(delay,fn) timers[#timers+1]=fn end}
CreateFrame=function(kind)
 local f={RegisterEvent=function() end,UnregisterEvent=function() end,SetScript=function(self,event,fn) self[event]=fn end}
 frames[#frames+1]=f;return f
end
GetNumSpellTabs=function() spellReads=spellReads+1;return 0 end
ns.db.tooltip.collect=true
assert(loadfile("Scan.lua"))("WoWChatTranslator",ns)
local ev=frames[#frames]
ev.OnEvent(ev,"SPELLS_CHANGED");ev.OnEvent(ev,"SPELLS_CHANGED")
assert(#timers==1)
ns.db.tooltip.collect=false
timers[1]();assert(spellReads==0)
print("중복 주문책 이벤트 예약 억제 및 수집 끈 뒤 지연 스캔 중단: 통과")
ns.db.tooltip.collect=true;timers={}
GetNumSpellTabs=function() return 1 end
GetSpellTabInfo=function() return nil,nil,0,1 end
GetSpellBookItemInfo=function() return "SPELL",123 end
local scanCreated=false
local oldCreate=CreateFrame
CreateFrame=function(kind,...) if kind=="GameTooltip" then scanCreated=true end;return oldCreate(kind,...) end
ev.OnEvent(ev,"SPELLS_CHANGED");timers[1]()
assert(#timers==2)
ns.db.tooltip.collect=false;timers[2]()
assert(not scanCreated)
print("작업 대기 중 수집 끄기: 숨은 툴팁 작업 중단 통과")
''')
run('''
assert(ns.Gloss("please /w if you need anything","en","ko").plain=="귓속말 주세요 필요한 것이 있으면")
local sample="225 enchanter is at your service. Need enchant is available now. Please /w if you need anything thanks you"
local g=ns.Gloss(sample,"en","ko")
assert(g.cover==100)
assert(not g.plain:find("your service",1,true));assert(not g.plain:find("available",1,true))
print("화면의 마법부여 광고 인식률:",g.cover,"풀이:",g.plain)
assert(ns.Gloss("please /w zebra","en","ko").plain:find("zebra",1,true))
print("미등록 단어 원문 보존 및 /w 구절 처리: 통과")
local target="ko";ns.GetTarget=function() return target end
ChatFrame_AddMessageEventFilter=function(event,fn) filters[event]=fn end
assert(loadfile("Chat.lua"))("WoWChatTranslator",ns)
local function get() local _,out=filters.CHAT_MSG_SAY(nil,"CHAT_MSG_SAY","lfg","Other",nil,nil,nil,nil,nil,nil,nil,nil,77);return out end
ns.db.chat.inline=false;local a=get()
ns.db.chat.inline=true;local b=get();assert(a~=b)
print("같은 메시지 ID에서 설정 변경 후 캐시 갱신: 통과")
local lines={};DEFAULT_CHAT_FRAME.AddMessage=function(self,s) lines[#lines+1]=s end
ns.TestChat("please /w if you need anything")
assert(lines[1]:find("100%",1,true));assert(lines[2]:find("귓속말 주세요",1,true))
print("테스트 명령 진단 출력: 통과")
''')
run('''
ns.OnLogin=nil;ns.GetTarget=function() return "ko" end
ns.db.tooltip={enabled=true,collect=true};ns.db.collected={};ns.db.collectedCount=0
ns.TipText={["restores # mana"]={ko="마나 {1} 회복"}}
local rows, hooks, added={}, {}, {}
GameTooltip={GetName=function() return "AuditTip" end,GetUnit=function() end,
 NumLines=function() return #rows end,HookScript=function(self,event,fn) hooks[event]=fn end,
 AddLine=function(self,text) added[#added+1]=text end,Show=function() end}
TooltipDataProcessor=nil
assert(loadfile("Tooltip.lua"))("WoWChatTranslator",ns)
ns.OnLogin()
local function check(lines)
 rows=lines;added={};GameTooltip.wctDone=nil
 for i=1,#rows do local k=i;_G["AuditTipTextLeft"..i]={GetText=function() return rows[k] end} end
 hooks.OnShow(GameTooltip)
 return #added
end
assert(check({"지옥의 벼룩걸이","체력 +4","착용 효과: 한글 설명입니다.","최소 요구 레벨 29","판매 가격: 31", "ATT > D&R > 가시덤굴 우리", "Added With Patch", "Best Gear Finder"})==0)
assert(ns.db.collectedCount==0)
assert(check({"지옥의 벼룩걸이","Restores 20 mana.","최소 요구 레벨 29","ATT > D&R", "Added With Patch"})>0)
for _,line in ipairs(added) do assert(not line:find("ATT",1,true));assert(not line:find("Patch",1,true)) end
assert(ns.db.collectedCount==0)
assert(check({"한글 아이템","Sell Price: 30", "Restores 20 mana."})==0)
assert(check({"한글 아이템","ATT > D&R", "Restores 20 mana."})==0)
assert(check({"한글 아이템","Best Gear Finder", "Restores 20 mana."})==0)
ITEM_MIN_LEVEL="Stufe benötigt %d"
assert(ns.IsTooltipBoundary("Stufe benötigt 29"))
assert(not ns.IsTooltipBoundary("Restores 20 mana."))
print("툴팁 경계: 한글만 있을 때 숨김, 경계 위 영어 번역, 가격/레벨/ATT/BGF 이후 제외 및 수집 제외 통과")
''')
run('''
assert(loadfile("TooltipText.lua"))("WoWChatTranslator",ns)
ns.GetTarget=function() return "ko" end
local samples={
 {"사용 효과: Unpacks a first aid kit that allows you and others sitting nearby to gain 2 increased Stamina, mutually exclusive with Power Word: Fortitude.","체력이 2만큼","신의 권능: 인내"},
 {"사용 효과: Ignites an incense candle that allows you and others sitting nearby to gain 2 increased Intellect, mutually exclusive with Arcane Intellect.","지능이 2만큼","신비한 지능"},
 {"Requires a Campfire nearby. All camping features share a cooldown of 1시간.","모닥불","1시간"}}
for _,s in ipairs(samples) do
 local t=ns.TranslateTooltipLine(s[1],"ko")
 assert(t and t.full);assert(t.text:find(s[2],1,true));assert(t.text:find(s[3],1,true))
 assert(not t.text:find("%a"));print("캠핑 효과 문장 번역:",t.text)
end
local t=ns.TranslateTooltipLine("Unpacks a first aid kit that allows you and others sitting nearby to gain 7 increased Stamina, mutually exclusive with Power Word: Fortitude.","ko")
assert(t and t.text:find("체력이 7만큼",1,true))
assert(ns.IsTooltipBoundary("요구 사항: 응급치료 (20)"))
assert(ns.IsTooltipBoundary("Item ID"));assert(ns.IsTooltipBoundary("IconID"))
print("다른 효과 수치 대입 및 요구 사항/아이템 부가 정보 경계 통과")
''')
run('''
assert(ns.TranslateName("First Aid Kit","ko")=="응급치료 도구")
assert(ns.TranslateName("Incense Candle","ko")=="향기 나는 양초")
assert(ns.TranslateName("Arcane Intellect","ko")=="신비한 지능")
assert(ns.TranslateName("Power Word: Fortitude","ko")=="신의 권능: 인내")
print("출처 대조 한국어 아이템/주문 이름 우선 적용 통과")
''')
