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
run('''assert(ns.Gloss("will   tip","en","ko").plain=="팁 드릴게")
assert(ns.Gloss("will\\t tip","en","ko").plain=="팁 드릴게")
assert(ns.Gloss("will"..string.char(194,160).."tip","en","ko").plain=="팁 드릴게")
local f=filters.CHAT_MSG_SAY
local function message(text,id) local _,out=f(nil,"CHAT_MSG_SAY",text,"Other",nil,nil,nil,nil,nil,nil,nil,nil,id);return out end
assert(message("lfg",0):find("파티 찾음",1,true))
assert(message("wts",0):find("판매",1,true))
assert(message("lfg",12):find("파티 찾음",1,true))
assert(message("wts",12):find("판매",1,true))
local first=message("wts",12);assert(message("wts",12)==first)
local link="|Hitem:123|h[물건]|h"
local out=message("lfg"..link.."wts",13)
assert(out:find(link,1,true));assert(out:find("파티 찾음 판매",1,true))
''')
print('전체 Lua 파일 문법 검사 및 회귀 검증 8개 통과 (Lua 5.4, 게임 API 모의 환경)')
