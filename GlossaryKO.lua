-- WoW Chat Translator: 한국어 원문 사전 (한국어 채팅 → 다른 현지 언어)
-- 형식: 원문=한국어 표준형=English  (영어 뜻을 기준으로 중국어·러시아어로 바뀐다)
-- 한국어는 띄어쓰기 없이 붙여 쓰는 일이 많아서 글자 단위로 가장 긴 표현부터 찾는다.
local ADDON, ns = ...

ns.RawGlossary.ko = [[
-- 초성·감탄 ------------------------------------------------------------
ㅋㅋ=ㅋㅋ=lol
ㅋ=ㅋ=lol
ㅎㅎ=ㅎㅎ=haha
ㅎ=ㅎ=heh
ㅠㅠ=ㅠㅠ=sad
ㅜㅜ=ㅜㅜ=sad
ㅠ=ㅠ=sad
ㄷㄷ=ㄷㄷ=wow
ㄱㄱ=가자=let's go
ㄱ=가자=go
ㅇㅇ=응=yes
ㅇㅋ=오케이=ok
ㅇㅋㅇㅋ=오케이=ok
ㄴㄴ=아니=no
ㄴ=아니=no
ㅈㅅ=죄송=sorry
ㅈㅅㅈㅅ=죄송=sorry
ㄳ=감사=thanks
ㄱㅅ=감사=thanks
ㄱㅅㄱㅅ=감사=thanks
ㄱㅅㅇ=감사요=thanks
ㅅㄱ=수고=good work
ㅅㄱㅇ=수고요=good work
ㅊㅋ=축하=congrats
ㅊㅋㅊㅋ=축하=congrats
ㅂㅂ=바이=bye
ㅂㅇ=바이=bye
ㅎㅇ=하이=hi
ㅎㅇㅎㅇ=하이=hi
ㅁㄹ=몰라=don't know
ㅇㄷ=어디=where
ㄹㅇ=진짜=really
ㅇㅈ=인정=agreed
ㅈㄱ=조금만=just a bit
ㅁㅊ=미쳤다=crazy
ㄴㅇㅅ=나이스=nice
ㄷㄱ=대기=wait
ㅃㄹ=빨리=hurry
ㅊㅊ=추천=recommend
ㅇㄱㄹㅇ=진짜=for real
ㅠㅠㅠ=ㅠㅠ=sad
-- 인사·대화 ------------------------------------------------------------
와우=와우=WoW
물건=물건=item
피곤해요=피곤해요=tired
양손=양손=two-hand
한손=한손=one-hand
분들=분들=people
여러분=여러분=everyone
다들=다들=everyone
안녕하세요=안녕하세요=hello
안녕=안녕=hi
하이=하이=hi
반가워요=반가워요=nice to meet you
반갑습니다=반갑습니다=nice to meet you
잘가요=잘 가요=bye
잘자요=잘 자요=good night
감사합니다=감사합니다=thank you
감사해요=감사해요=thank you
감사=감사=thanks
고맙습니다=고맙습니다=thank you
고마워요=고마워요=thanks
고마워=고마워=thanks
땡큐=땡큐=thank you
수고하셨습니다=수고하셨습니다=good work
수고하셨어요=수고하셨어요=good work
수고했어요=수고했어요=good work
수고요=수고요=good work
수고=수고=good work
고생하셨습니다=고생하셨습니다=good work
죄송합니다=죄송합니다=sorry
죄송해요=죄송해요=sorry
미안해요=미안해요=sorry
미안=미안=sorry
괜찮아요=괜찮아요=it's okay
괜찮습니다=괜찮습니다=it's okay
네=네=yes
넵=넵=yes
넹=넹=yes
예=예=yes
응=응=yes
아니요=아니요=no
아뇨=아뇨=no
아니=아니=no
좋아요=좋아요=good
좋습니다=좋습니다=good
좋아=좋아=good
오케이=오케이=okay
알겠습니다=알겠습니다=got it
알겠어요=알겠어요=got it
몰라요=몰라요=don't know
모르겠어요=모르겠어요=don't know
잠시만요=잠시만요=one moment
잠깐만요=잠깐만요=wait a moment
잠깐만=잠깐만=wait a sec
잠시=잠시=a moment
기다려주세요=기다려 주세요=please wait
기다려=기다려=wait
대기=대기=wait
축하해요=축하해요=congrats
축하드립니다=축하드립니다=congratulations
축하=축하=congrats
화이팅=화이팅=good luck
대박=대박=awesome
진짜=진짜=really
정말=정말=really
헐=헐=whoa
와=와=wow
어디=어디=where
어디에요=어디예요=where is it
어디예요=어디예요=where is it
어디있어요=어디 있어요=where is it
뭐예요=뭐예요=what is it
뭐=뭐=what
누구=누구=who
언제=언제=when
왜=왜=why
어떻게=어떻게=how
얼마=얼마=how much
얼마에요=얼마예요=how much
얼마예요=얼마예요=how much
몇=몇=how many
지금=지금=now
바로=바로=right away
곧=곧=soon
빨리=빨리=quickly
천천히=천천히=slowly
같이=같이=together
혹시=혹시=by any chance
제발=제발=please
부탁드립니다=부탁드립니다=please
부탁드려요=부탁드려요=please
부탁해요=부탁해요=please
부탁=부탁=please
주세요=주세요=please give
해주세요=해 주세요=please do
도와주세요=도와주세요=please help
도와줘=도와줘=help me
도움=도움=help
제가=제가=I
우리=우리=we
님==
요==
사람=사람=people
한국인=한국인=Korean
한국=한국=Korea
중국인=중국인=Chinese
외국인=외국인=foreigner
한국어=한국어=Korean
영어=영어=English
번역=번역=translate
-- 모집·파티 -----------------------------------------------------------
구합니다=구합니다=looking for
구해요=구해요=looking for
구해용=구해요=looking for
구함=구함=looking for
구하고있어요=구하고 있어요=looking for
구인=구인=recruiting
모집합니다=모집합니다=recruiting
모집중=모집 중=recruiting
모집=모집=recruiting
파티=파티=group
파티원=파티원=party member
파티장=파티장=party leader
파장=파티장=party leader
공대=공격대=raid
공격대=공격대=raid
공대장=공대장=raid leader
공팟=공팟=pug
고정팟=고정팟=static group
고정=고정=static
길드=길드=guild
길드원=길드원=guildies
길원=길드원=guildies
길마=길드장=guild master
길드장=길드장=guild master
신입=신입=newcomer
뉴비=뉴비=newbie
초보=초보=newbie
복귀=복귀=returning
고수=고수=pro
가실분=가실 분=anyone going
가실분구해요=가실 분 구해요=anyone want to go
하실분=하실 분=anyone want to
오실분=오실 분=anyone coming
같이하실분=같이 하실 분=anyone join
갈사람=갈 사람=who's going
할사람=할 사람=anyone want to
오세요=오세요=come
와주세요=와 주세요=please come
와요=와요=coming
가요=가요=let's go
가자=가자=let's go
출발=출발=let's go
출발합니다=출발합니다=leaving now
시작=시작=start
마감=마감=closed
풀파티=풀파티=full party
풀=풀=full
남았어요=남았어요=left
남음=남음=left
자리=자리=spot
한자리=한 자리=one spot
한명=한 명=one more
두명=두 명=two more
세명=세 명=three more
한분=한 분=one more
두분=두 분=two more
명=명=people
초대=초대=invite
초대해주세요=초대해 주세요=please invite
초대부탁=초대 부탁=invite please
초대좀=초대 좀=invite please
초대요=초대요=invite please
초대해드릴게요=초대해 드릴게요=I'll invite you
귓=귓말=whisper
귓말=귓말=whisper
귓주세요=귓말 주세요=whisper me
귓말주세요=귓말 주세요=whisper me
귓해주세요=귓말 주세요=whisper me
귓ㄱ=귓말 줘=whisper me
쪽지=쪽지=mail
우편=우편=mail
-- 역할·직업·특성 -------------------------------------------------------
탱=탱커=tank
탱커=탱커=tank
메인탱=메인 탱커=main tank
보조탱=보조 탱커=off tank
힐=힐러=healer
힐러=힐러=healer
딜=딜러=DPS
딜러=딜러=DPS
근딜=근접 딜러=melee DPS
원딜=원거리 딜러=ranged DPS
전사=전사=Warrior
전탱=전사 탱커=warrior tank
방전=방어 전사=protection warrior
분전=분노 전사=fury warrior
무전=무기 전사=arms warrior
마법사=마법사=Mage
법사=마법사=Mage
냉법=냉기 마법사=frost mage
화법=화염 마법사=fire mage
비법=비전 마법사=arcane mage
사제=사제=Priest
신사=신성 사제=holy priest
암사=암흑 사제=shadow priest
수사=수양 사제=discipline priest
흑마법사=흑마법사=Warlock
흑마=흑마법사=Warlock
고흑=고통 흑마법사=affliction warlock
악흑=악마 흑마법사=demonology warlock
파흑=파괴 흑마법사=destruction warlock
사냥꾼=사냥꾼=Hunter
냥꾼=사냥꾼=Hunter
야냥=야수 사냥꾼=BM hunter
격냥=사격 사냥꾼=MM hunter
생냥=생존 사냥꾼=survival hunter
도적=도적=Rogue
드루이드=드루이드=Druid
드루=드루이드=Druid
회드=회복 드루이드=resto druid
야드=야성 드루이드=feral druid
곰드=곰 드루이드=bear druid
곰탱=곰 탱커=bear tank
조드=조화 드루이드=balance druid
성기사=성기사=Paladin
기사=성기사=Paladin
신기=신성 성기사=holy paladin
징기=징벌 성기사=retribution paladin
주술사=주술사=Shaman
술사=주술사=Shaman
정술=정기 주술사=elemental shaman
고술=고양 주술사=enhancement shaman
복술=복원 주술사=resto shaman
특성=특성=talents
특초=특성 초기화=respec
직업=직업=class
-- 전투·스킬 -----------------------------------------------------------
풀링=풀링=pull
풀링해주세요=풀링해 주세요=please pull
어그로=어그로=aggro
어글=어그로=aggro
광역=광역=AoE
광역사냥=광역 사냥=AoE farming
쫄=잡몹=trash mobs
쫄몹=잡몹=trash mobs
잡몹=잡몹=trash mobs
네임드=네임드=named mob
보스=보스=boss
막보=마지막 보스=last boss
첫넴=첫 보스=first boss
전멸=전멸=wipe
누웠어요=죽었어요=died
죽었어요=죽었어요=died
죽음=죽음=dead
부활=부활=resurrect
부활해주세요=부활해 주세요=rez please
부활좀=부활 좀=rez please
영혼석=영혼석=soulstone
생명석=생명석=healthstone
소환=소환=summon
소환해주세요=소환해 주세요=summon please
소환부탁=소환 부탁=summon please
소환석=집결의 돌=meeting stone
돌소환=돌 소환=stone summon
귀환=귀환=hearth
귀환석=귀환석=hearthstone
포탈=차원문=portal
차원문=차원문=portal
물=물=water
물좀=물 좀=water please
물주세요=물 주세요=water please
빵=빵=food
마나=마나=mana
마나없어요=마나 없어요=out of mana
엠없=마나 없음=oom
피=생명력=health
버프=버프=buff
버프주세요=버프 주세요=buff please
버프좀=버프 좀=buff please
디버프=디버프=debuff
해제=해제=dispel
해독=해독=cure poison
도발=도발=taunt
차단=차단=interrupt
양=변이=sheep
변이=변이=polymorph
혼절=혼절=sap
공포=공포=fear
기절=기절=stun
-- 장비·전리품 ---------------------------------------------------------
장비=장비=gear
템=아이템=item
득템=득템=got loot
드랍=드랍=drop
드롭=드랍=drop
떴어요=나왔어요=dropped
나왔어요=나왔어요=dropped
안나와요=안 나와요=no drop
영웅템=영웅 템=epic
보라템=영웅 템=epic
희귀템=희귀 템=blue
파란템=희귀 템=blue
초록템=고급 템=green
전설=전설=legendary
세트=세트=set
무기=무기=weapon
방패=방패=shield
반지=반지=ring
목걸이=목걸이=necklace
장신구=장신구=trinket
망토=망토=cloak
귀속=귀속=bound
착귀=착용 시 귀속=BoE
획귀=획득 시 귀속=BoP
주사위=주사위=roll
입찰=입찰=need
차비=차비=greed
포기=포기=pass
주사위굴려주세요=주사위 굴려 주세요=please roll
분배=분배=loot
자유분배=자유 획득=free for all
골팟=골드팟=GDKP
골드팟=골드팟=GDKP
분배금=분배금=payout
버스=버스=boost
버스기사=버스 기사=booster
손님=손님=boostee
찜=찜=soft reserve
예약=예약=reserved
-- 거래·돈 -------------------------------------------------------------
팝니다=팝니다=selling
판매=판매=selling
판매합니다=판매합니다=selling
팜=판매=selling
삽니다=삽니다=buying
구매=구매=buying
구매합니다=구매합니다=buying
매입=매입=buying
교환=교환=trade
거래=거래=trade
거래요청=거래 요청=trade request
골드=골드=gold
골=골드=gold
실버=실버=silver
코퍼=코퍼=copper
경매장=경매장=auction house
경매=경매=auction
시세=시세=price
가격=가격=price
싸게=싸게=cheap
비싸게=비싸게=expensive
개당=개당=each
묶음=묶음=stack
무료=무료=free
팁=팁=tip
재료=재료=materials
재료지참=재료 지참=bring mats
사기=사기=scam
사기꾼=사기꾼=scammer
-- 전문기술·재료 --------------------------------------------------------
마부=마법부여=enchant
마법부여=마법부여=enchanting
연금=연금술=alchemy
연금술=연금술=alchemy
대장=대장기술=blacksmithing
대장기술=대장기술=blacksmithing
가세=가죽세공=leatherworking
가죽세공=가죽세공=leatherworking
재봉=재봉술=tailoring
재봉술=재봉술=tailoring
기공=기계공학=engineering
기계공학=기계공학=engineering
채광=채광=mining
약초=약초=herb
약초채집=약초채집=herbalism
무두=무두질=skinning
무두질=무두질=skinning
낚시=낚시=fishing
요리=요리=cooking
응급치료=응급치료=first aid
붕대=붕대=bandage
물약=물약=potion
영약=영약=flask
비약=비약=elixir
룬천=룬매듭 천=runecloth
룬매듭=룬매듭 천=runecloth
마매천=마법매듭 천=mageweave
비단=비단=silk cloth
아케=아케이나이트=arcanite
아케이나이트=아케이나이트=arcanite
토륨=토륨=thorium
진은=진은=truesilver
미스릴=미스릴=mithril
검은연꽃=검은 연꽃=black lotus
연꽃=검은 연꽃=black lotus
-- 퀘스트·레벨·기타 ------------------------------------------------------
퀘=퀘스트=quest
퀘스트=퀘스트=quest
퀘공=퀘스트 공유=share quest
공유=공유=share
공유해주세요=공유해 주세요=share please
퀘템=퀘스트 아이템=quest item
연계퀘=연계 퀘스트=quest chain
레벨=레벨=level
렙=레벨=level
만렙=만렙=max level
렙업=레벨업=leveling
경험치=경험치=XP
경치=경험치=XP
입구=입구=entrance
입구에서=입구에서=at the entrance
앞=앞=front
집합=집합=gather
모여주세요=모여 주세요=gather up
던전=던전=dungeon
인던=던전=dungeon
레이드=공격대=raid
돌=판/런=run
뺑이=반복=farm runs
파밍=파밍=farming
작업장=작업장=gold farmer
봇=봇=bot
렉=렉=lag
튕겼어요=튕겼어요=disconnected
튕김=튕김=disconnected
잠수=자리 비움=afk
자리비움=자리 비움=afk
화장실=화장실=bathroom
밥=밥=food
전장=전장=battleground
명예=명예=honor
결투=결투=duel
쟁=PvP=PvP
필드쟁=필드 PvP=world PvP
학살=학살=gank
-- 던전·공격대 약칭 -----------------------------------------------------
성불=성난불길 협곡=Ragefire Chasm
성난불길=성난불길 협곡=Ragefire Chasm
죽폐=죽음의 폐광=Deadmines
죽음의폐광=죽음의 폐광=Deadmines
통곡=통곡의 동굴=Wailing Caverns
통곡의동굴=통곡의 동굴=Wailing Caverns
그송=그림자송곳니 성채=Shadowfang Keep
그림자송곳니=그림자송곳니 성채=Shadowfang Keep
감옥=스톰윈드 지하감옥=Stockade
지하감옥=스톰윈드 지하감옥=Stockade
검심=검은심연의 나락=Blackfathom Deeps
놈리건=놈리건=Gnomeregan
가우=가시덩굴 우리=Razorfen Kraul
가시덩굴우리=가시덩굴 우리=Razorfen Kraul
가구=가시덩굴 구릉=Razorfen Downs
가시덩굴구릉=가시덩굴 구릉=Razorfen Downs
붉수=붉은십자군 수도원=Scarlet Monastery
붉십=붉은십자군 수도원=Scarlet Monastery
수도원=붉은십자군 수도원=Scarlet Monastery
묘지=묘지=Graveyard
도서관=도서관=Library
무기고=무기고=Armory
성당=대성당=Cathedral
대성당=대성당=Cathedral
울다만=울다만=Uldaman
줄파락=줄파락=Zul'Farrak
마라우돈=마라우돈=Maraudon
마라=마라우돈=Maraudon
아탈=아탈학카르 신전=Sunken Temple
아탈학카르=아탈학카르 신전=Sunken Temple
신전=신전=temple
검바=검은바위 나락=Blackrock Depths
나락=검은바위 나락=Blackrock Depths
검은바위나락=검은바위 나락=Blackrock Depths
검첨=검은바위 첨탑=Blackrock Spire
상층=상층=upper
하층=하층=lower
검첨상층=검은바위 첨탑 상층=Upper Blackrock Spire
검첨하층=검은바위 첨탑 하층=Lower Blackrock Spire
혈전=혈투의 전장=Dire Maul
혈투=혈투의 전장=Dire Maul
혈투의전장=혈투의 전장=Dire Maul
동쪽=동쪽=east
서쪽=서쪽=west
북쪽=북쪽=north
공물=공물 런=tribute run
스트라=스트라솔름=Stratholme
스트라솔름=스트라솔름=Stratholme
남작=리븐데어 남작=Baron Rivendare
남작런=남작 런=Baron run
스칼로=스칼로맨스=Scholomance
스칼로맨스=스칼로맨스=Scholomance
화심=화산 심장부=Molten Core
화산심장부=화산 심장부=Molten Core
오닉=오닉시아=Onyxia
오닉시아=오닉시아=Onyxia
검둥=검은날개 둥지=Blackwing Lair
검은날개둥지=검은날개 둥지=Blackwing Lair
줄구룹=줄구룹=Zul'Gurub
안퀴=안퀴라즈=Ahn'Qiraj
안퀴라즈=안퀴라즈=Ahn'Qiraj
낙스=낙스라마스=Naxxramas
낙스라마스=낙스라마스=Naxxramas
라그=라그나로스=Ragnaros
라그나로스=라그나로스=Ragnaros
네파=네파리안=Nefarian
네파리안=네파리안=Nefarian
학카르=학카르=Hakkar
-- 지역·도시 -----------------------------------------------------------
스톰윈드=스톰윈드=Stormwind
스윈=스톰윈드=Stormwind
아이언포지=아이언포지=Ironforge
아포=아이언포지=Ironforge
다르나서스=다르나서스=Darnassus
오그리마=오그리마=Orgrimmar
오그=오그리마=Orgrimmar
썬더블러프=썬더 블러프=Thunder Bluff
썬블=썬더 블러프=Thunder Bluff
언더시티=언더시티=Undercity
언더=언더시티=Undercity
무법항=무법항=Booty Bay
가젯잔=가젯잔=Gadgetzan
톱니항=톱니항=Ratchet
크로스로드=크로스로드=Crossroads
불모=불모의 땅=The Barrens
불모의땅=불모의 땅=The Barrens
가시덤불=가시덤불 골짜기=Stranglethorn Vale
가덤=가시덤불 골짜기=Stranglethorn Vale
골짜기=골짜기=valley
잿빛=잿빛 골짜기=Ashenvale
잿빛골짜기=잿빛 골짜기=Ashenvale
타나리스=타나리스=Tanaris
운고로=운고로 분화구=Un'Goro Crater
악령의숲=악령의 숲=Felwood
여명의설원=여명의 설원=Winterspring
설원=여명의 설원=Winterspring
실리더스=실리더스=Silithus
역병지대=역병지대=Plaguelands
동역=동부 역병지대=Eastern Plaguelands
서역=서부 역병지대=Western Plaguelands
저습지=저습지=Wetlands
아라시=아라시 고원=Arathi Highlands
알터랙=알터랙=Alterac
전쟁노래=전쟁노래 협곡=Warsong Gulch
노래협곡=전쟁노래 협곡=Warsong Gulch
아라시분지=아라시 분지=Arathi Basin
알터랙계곡=알터랙 계곡=Alterac Valley
알방=알터랙 계곡=Alterac Valley
]]
