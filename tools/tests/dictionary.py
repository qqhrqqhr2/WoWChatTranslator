import ctypes,json,zipfile
from pathlib import Path
lib=ctypes.CDLL('liblua5.4.so.0')
lib.luaL_newstate.restype=ctypes.c_void_p
lib.luaL_openlibs.argtypes=[ctypes.c_void_p]
lib.luaL_loadstring.argtypes=[ctypes.c_void_p,ctypes.c_char_p]
lib.lua_pcallk.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_longlong,ctypes.c_void_p]
lib.lua_tolstring.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.POINTER(ctypes.c_size_t)];lib.lua_tolstring.restype=ctypes.c_char_p
state=lib.luaL_newstate();lib.luaL_openlibs(state)
root=Path('.')
code='local ns = {}\n'
for fn in root.glob('*.lua'):
    code+='assert(loadfile('+json.dumps(str(fn))+'))\n'
for fn in (root/'WoWChatTranslator.toc').read_text().splitlines():
    if not (fn.startswith(('Glossary', 'Translations', 'TradMap')) and fn.endswith('.lua')): continue
    code+='assert(loadfile('+json.dumps(str(root/fn))+'))("WoWChatTranslator", ns)\n'
chat=(root/'Chat.lua').read_text().split('ns.Dict = Dict')[0]+'ns.Dict = Dict\n'
code+='assert(load('+json.dumps(chat,ensure_ascii=False)+'))("WoWChatTranslator", ns)\n'
code+='''
local count = 0
for lang,dict in pairs(ns.Dict) do
  for key,entry in pairs(dict) do
    assert(type(key) == "string" and type(entry[1]) == "string")
    count = count + 1
  end
end
assert(ns.Dict.en["sm lib"][1] == "붉은십자군 수도원 도서관")
assert(ns.Dict.en["lf2m dps"][1] == "딜러 2명 구함")
assert(ns.Dict.en["2dps"][1] == "딜러 2명 구함")
assert(ns.Dict.en["dm"][1]:find("문맥 확인",1,true))
assert(ns.Dict.es["armar grupo"][1] == "파티를 구성하다")
assert(ns.Dict.ru["нужен танк"][1] == "탱커 필요")
assert(ns.Dict.zh["别开怪"][1] == "풀링하지 마세요")
assert(ns.Dict.ja["ヘイト"][1] == "위협 수준")
assert(ns.TR.ja["crowd control"] == "行動妨害")
assert(ns.TR.es["looking for a tank"] == "buscamos tanque")
for lang,raw in pairs(ns.RawGlossary) do
  local rows,unique = 0,0
  for line in raw:gmatch("[^\\r\\n]+") do if line:match("^%s*(.-)%s*=%s*(.-)%s*=%s*(.-)%s*$") then rows=rows+1 end end
  for _ in pairs(ns.Dict[lang]) do unique=unique+1 end
  assert(rows==unique, lang..": duplicate normalized source keys")
end
assert(count >= 21702)
print("Lua 문법 및 기존 BuildDict 로딩 검증 성공. 정규화 후 고유항목: "..count)
'''
result=lib.luaL_loadstring(state,code.encode())
if result==0:result=lib.lua_pcallk(state,0,0,0,0,None)
if result:raise RuntimeError(lib.lua_tolstring(state,-1,None).decode())
