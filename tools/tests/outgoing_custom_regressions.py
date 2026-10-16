from features_v147 import run

run('''
-- Receiving preferences must not disable explicit outgoing requests.
ns.db.chat.langs.ko=false
local out,cover=ns.TranslateOutgoing("탱커 구함","en")
assert(out=="tank looking for" and cover==100,tostring(out))
assert(ns.db.chat.langs.ko==false,"outgoing must not mutate receive preferences")
assert(ns.Gloss("탱커 구함","ko","en").plain=="탱커 구함")
ns.db.chat.langs.ko=true
local mixed=ns.TranslateOutgoing("탱커 lfg","ko")
assert(mixed=="탱커 파티 찾음", tostring(mixed))
local same,c=ns.TranslateOutgoing("안녕하세요","ko")
assert(same=="안녕하세요" and c==100)
local partial,pct,unknown=ns.TranslateOutgoing("탱커 lfg zzzzz","ko")
assert(pct==50 and #unknown==1 and unknown[1]=="zzzzz",tostring(pct))
local none,nc=ns.TranslateOutgoing("zzzzz","ko")
assert(none==nil and nc==0)
-- Mixed-script phrases, punctuation, longest match, delete, and saved reload.
ns.db.chat.langs.ru=true
ns.ExtraCommand("add hello привет=혼합 인사")
assert(ns.Gloss("hello привет","en","ko").plain=="혼합 인사")
ns.ExtraCommand("add hello привет friend=긴 혼합 인사")
assert(ns.Gloss("hello привет friend","en","ko").plain=="긴 혼합 인사")
ns.ExtraCommand("add 탱커 hello=혼합 모집")
assert(ns.Gloss("탱커 hello","ko","ko").plain=="혼합 모집")
ns.ExtraCommand("add hello, привет=문장부호 인사")
assert(ns.Gloss("hello, привет","en","ko").plain=="문장부호 인사")
ns.db.chat.langs.ru=false
assert(ns.Gloss("hello привет","en","ko").plain~="혼합 인사")
assert(ns.TranslateOutgoing("hello привет","ko")=="혼합 인사")
ns.db.chat.langs.ru=true
ns.CustomEntries=nil
ns.ApplyCustom()
assert(ns.Gloss("hello привет","en","ko").plain=="혼합 인사")
ns.ExtraCommand("del hello привет")
assert(ns.Gloss("hello привет","en","ko").plain~="혼합 인사")
ns.ExtraCommand("add lfg=임시 뜻")
assert(ns.Gloss("lfg","en","ko").plain=="임시 뜻")
ns.ExtraCommand("del lfg")
assert(ns.Gloss("lfg","en","ko").plain=="파티 찾음")
-- A shared line ID must honor settings changes in both directions.
ns.db.chat.copyAll=false
local events={public="CHAT_MSG_CHANNEL",say="CHAT_MSG_SAY",guild="CHAT_MSG_GUILD",group="CHAT_MSG_PARTY",whisper="CHAT_MSG_WHISPER"}
local id=9200
for channel,event in pairs(events) do
  id=id+1
  local function message()
    return select(2,filters[event]({},event,"lfg","Other",nil,nil,nil,nil,nil,nil,nil,nil,id))
  end
  ns.db.chat.channels[channel]=true
  assert(message():find("파티 찾음",1,true))
  ns.db.chat.channels[channel]=false
  assert(message()==nil,channel)
  ns.db.chat.channels[channel]=true
  assert(message():find("파티 찾음",1,true))
end
''')
print('발신 언어 설정·혼합 문장·풀이 비율·사용자 사전·5개 채널 캐시 회귀 검증 통과')
