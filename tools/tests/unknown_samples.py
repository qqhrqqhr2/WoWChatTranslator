from unknown_collection import run
run('''
ns.db.unknownChat={words={},samples={"en: dal","en: [달라란의 고서]","en: zzzzz"}}
ns.ShowCopy=function(t)
 assert(not t:find("en: dal",1,true))
 assert(not t:find("달라란의 고서",1,true))
 assert(t:find("en: zzzzz",1,true))
end
ns.ShowUnknownChat()
assert(#ns.db.unknownChat.samples==1)
ns.RecordUnknownChat("Vae Victis","en",{unknown={"vae","victis"},cover=0})
assert(#ns.db.unknownChat.samples==1)
ns.RecordUnknownChat("zzzzz newunknown","en",{unknown={"zzzzz","newunknown"},cover=0})
assert(#ns.db.unknownChat.samples==2)
''')
print('과거 예문 재검사·링크 전용 예문 제거·유효 미등록 예문 보존 통과')
