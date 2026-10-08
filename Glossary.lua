-- WoW Chat Translator: 용어 사전
-- 한 줄에 하나씩 "원문=한국어=English" 형식. 뜻을 비워 두면(the== 처럼) 풀이에서 생략한다. 대소문자, 러시아어 대소문자, 전각 영문은 자동으로 맞춰서 찾는다.
-- 중국어·일본어는 붙어 있는 글자 중 가장 긴 표현부터 찾고, 영어·러시아어는 단어(최대 3단어 묶음) 단위로 찾는다.
local ADDON, ns = ...

ns.RawGlossary = {}

------------------------------------------------------------------------
-- 중국어 (간체 위주 + 자주 쓰는 번체)
------------------------------------------------------------------------
ns.RawGlossary.zh = [[
长期=장기간=long-term
活跃=활발한=active
长期活跃=장기간 활발한=long-term active
魔兽=와우=WoW
魔兽世界=월드 오브 워크래프트=World of Warcraft
社群=커뮤니티=community
社区=커뮤니티=community
大佬=고수=pro players
大佬带新=고수가 뉴비를 도와줌=veterans help newbies
带新=뉴비 도와줌=help newbies
新手=초보=newbie
萌新=초보(귀여운 말)=newbie
小白=초보=newbie
老玩家=고인물=veteran
副本=던전/인던=dungeon
地下城=던전=dungeon
团本=공격대 던전=raid
团队=공격대=raid
金团=골드팟(입찰 공대)=GDKP raid
工资=분배금=payout
分金=골드 분배=gold split
拍卖=경매=auction
成就=업적=achievement
打架=싸움(PvP)=fight
无压力=부담 없는=no pressure
休闲=캐주얼=casual
无压力休闲=부담 없는 캐주얼=chill casual
佛系=느긋한=chill
进裙=단톡방 입장=join group chat
进群=단톡방 입장=join group chat
加群=단톡방 입장=join group chat
群=단톡방=group chat
裙=단톡방=group chat
加v=위챗 친구추가=add on WeChat
加微=위챗 친구추가=add on WeChat
微信=위챗=WeChat
备用=보조/예비=backup
备用v=예비 위챗=backup WeChat
qq群=QQ 단톡방=QQ group
yy=YY(음성채팅)=YY voice
语音=음성채팅=voice chat
歪歪=YY 음성채팅=YY voice
公会=길드=guild
公會=길드=guild
工会=길드=guild
招人=인원 모집=recruiting
招募=모집=recruiting
招收=모집=recruiting
收人=인원 모집=recruiting
欢迎=환영=welcome
欢迎加入=가입 환영=welcome to join
加入=가입=join
入会=길드 가입=join guild
进会=길드 가입=join guild
组队=파티 구함=LFG
組隊=파티 구함=LFG
组=파티=group
来人=사람 구함=need people
缺=부족(구함)=need
差=부족(구함)=need
还差=아직 부족=still need
来个=한 명 와=need one
来=와요(구함)=come
速来=빨리 와=come fast
速度=빨리=quick
密我=귓말 줘=whisper me
密=귓말=whisper
私聊=귓말=whisper
m我=귓말 줘=whisper me
满了=꽉 참=full
满员=정원 마감=full
开组=파티 시작=starting group
开车=출발(파티 시작)=starting
发车=출발=leaving now
上车=탑승(합류)=join
车=파티(차)=group
车队=파티=group
老板=버스 고객=buyer
带=버스/캐리=carry
代练=대리 육성=boosting
带刷=버스 캐리=carry run
刷=반복 사냥=farm
刷本=던전 반복=dungeon farming
刷钱=골드 파밍=gold farming
刷怪=몹 사냥=grinding
升级=레벨업=leveling
练级=레벨업=leveling
满级=만렙=max level
级=레벨=level
等级=레벨=level
经验=경험치=XP
任务=퀘스트=quest
交任务=퀘스트 완료=turn in quest
做任务=퀘스트 진행=questing
装备=장비=gear
毕业=졸업(BiS 완성)=BiS done
毕业装=졸업 장비=BiS gear
武器=무기=weapon
戒指=반지=ring
项链=목걸이=necklace
饰品=장신구=trinket
披风=망토=cloak
护甲=방어구=armor
需求=필요(주사위)=need
贪婪=차비(주사위)=greed
roll=주사위=roll
掷骰=주사위=roll
分配=분배=loot
拾取=전리품=loot
队长=파티장=leader
团长=공대장=raid leader
指挥=지휘=raid lead
坦克=탱커=tank
t=탱커=tank
mt=메인 탱커=main tank
奶=힐러=healer
治疗=힐러/치유=healer
奶妈=힐러=healer
输出=딜러(DPS)=DPS
dps=딜러=DPS
近战=근접=melee
远程=원거리=ranged
战士=전사=Warrior
法师=마법사=Mage
牧师=사제=Priest
术士=흑마법사=Warlock
猎人=사냥꾼=Hunter
盗贼=도적=Rogue
德鲁伊=드루이드=Druid
小德=드루이드=Druid
圣骑士=성기사=Paladin
圣骑=성기사=Paladin
骑士=성기사=Paladin
萨满=주술사=Shaman
萨满祭司=주술사=Shaman
zs=전사=Warrior
fs=마법사=Mage
ms=사제=Priest
ss=흑마법사=Warlock
lr=사냥꾼=Hunter
dz=도적=Rogue
xd=드루이드=Druid
qs=성기사=Paladin
sm=주술사=Shaman
职业=직업=class
天赋=특성=talents
专业=전문기술=profession
炼金=연금술=Alchemy
锻造=대장기술=Blacksmithing
附魔=마법부여=Enchanting
工程=기계공학=Engineering
制皮=가죽세공=Leatherworking
裁缝=재봉술=Tailoring
采矿=채광=Mining
采药=약초채집=Herbalism
剥皮=무두질=Skinning
钓鱼=낚시=Fishing
烹饪=요리=Cooking
急救=응급치료=First Aid
收=삽니다=WTB
求购=삽니다=WTB
买=구매=buy
卖=팝니다=WTS
出=팝니다=WTS
出售=팝니다=WTS
换=교환=trade
交易=거래=trade
价格=가격=price
价钱=가격=price
便宜=싼=cheap
金=골드=gold
g=골드=gold
金币=골드=gold
银=실버=silver
多少钱=얼마예요=how much
多少=얼마/몇=how many
联盟=얼라이언스=Alliance
部落=호드=Horde
世界=월드(전체) 채널=world
世界频道=월드 채널=world channel
频道=채널=channel
大喊=외침=yell
主城=수도=capital city
暴风城=스톰윈드=Stormwind
铁炉堡=아이언포지=Ironforge
达纳苏斯=다르나서스=Darnassus
奥格瑞玛=오그리마=Orgrimmar
奥格=오그리마=Orgrimmar
雷霆崖=썬더 블러프=Thunder Bluff
幽暗城=언더시티=Undercity
藏宝海湾=무법항=Booty Bay
加基森=가젯잔=Gadgetzan
死亡矿井=죽음의 폐광=Deadmines
怒焰裂谷=성난불길 협곡=Ragefire Chasm
哀嚎洞穴=통곡의 동굴=Wailing Caverns
影牙城堡=그림자송곳니 성채=Shadowfang Keep
监狱=스톰윈드 지하감옥=Stockade
黑暗深渊=검은심연의 나락=Blackfathom Deeps
诺莫瑞根=놈리건=Gnomeregan
剃刀沼泽=가시덩굴 우리=Razorfen Kraul
剃刀高地=가시덩굴 구릉=Razorfen Downs
血色修道院=붉은십자군 수도원=Scarlet Monastery
血色=붉은십자군 수도원=Scarlet Monastery
奥达曼=울다만=Uldaman
祖尔法拉克=줄파락=Zul'Farrak
zul=줄파락=Zul'Farrak
玛拉顿=마라우돈=Maraudon
神庙=아탈학카르 신전=Sunken Temple
阿塔哈卡神庙=아탈학카르 신전=Sunken Temple
黑石深渊=검은바위 나락=Blackrock Depths
黑石塔=검은바위 첨탑=Blackrock Spire
上层=상층=upper
下层=하층=lower
斯坦索姆=스트라솔름=Stratholme
通灵学院=스칼로맨스=Scholomance
厄运之槌=혈투의 전장=Dire Maul
厄运=혈투의 전장=Dire Maul
熔火之心=화산 심장부=Molten Core
mc=화산 심장부=Molten Core
黑翼之巢=검은날개 둥지=Blackwing Lair
bwl=검은날개 둥지=Blackwing Lair
奥妮克希亚=오닉시아=Onyxia
黑龙=오닉시아=Onyxia
祖尔格拉布=줄구룹=Zul'Gurub
zg=줄구룹=Zul'Gurub
安其拉=안퀴라즈=Ahn'Qiraj
纳克萨玛斯=낙스라마스=Naxxramas
naxx=낙스라마스=Naxxramas
战场=전장=battleground
奥特兰克=알터랙 계곡=Alterac Valley
战歌=전쟁노래 협곡=Warsong Gulch
阿拉希=아라시 분지=Arathi Basin
荣誉=명예=honor
野外=필드=open world
插旗=PvP 켜기=flag PvP
杀=죽이다=kill
打=잡다/공격=fight
打不过=못 이김=can't win
救命=살려줘=help
帮忙=도와줘=help
帮=도와=help
谢谢=고마워요=thanks
多谢=고마워요=thanks
谢了=고마워=thanks
感谢=감사=thanks
不客气=천만에요=you're welcome
你好=안녕하세요=hello
大家好=모두 안녕하세요=hi all
晚上好=좋은 저녁=good evening
再见=잘 가요=bye
拜拜=바이바이=bye
好的=좋아요=okay
好=좋아=good
可以=가능/좋아=can/ok
不行=안 돼=no
不要=필요 없어=don't want
要=필요해/원해=want
有人=누구 있나요=anyone
有没有=있나요=is there any
有=있다=have
没有=없다=don't have
哪里=어디=where
在哪=어디 있어요=where is
在=~에 있다=at
什么=무엇=what
怎么=어떻게=how
为什么=왜=why
谁=누구=who
现在=지금=now
马上=곧/바로=right away
等=기다려=wait
等等=잠깐만=wait
稍等=잠시만요=one moment
一起=같이=together
去=가다=go
走=가자=let's go
走了=간다=leaving
回来=돌아와=come back
上线=접속=online
下线=접속 종료=offline
在线=접속 중=online
人=사람=people
朋友=친구=friend
兄弟=형제(친구)=bro
老铁=친구=buddy
哈哈=하하=haha
哈哈哈=ㅋㅋㅋ=lol
666=잘한다(대박)=nice
牛=대박=awesome
厉害=대단해=awesome
垃圾=쓰레기=trash
坑=트롤=troll
服务器=서버=server
卡=렉=lag
掉线=튕김=disconnected
中国=중국=China
中国人=중국인=Chinese
韩国=한국=Korea
韩国人=한국인=Korean
华人=중국계=Chinese
中文=중국어=Chinese
不懂=모르겠어요=don't understand
听不懂=못 알아들어요=don't understand
翻译=번역=translate
收人中=인원 모집 중=recruiting
招募中=모집 중=recruiting
休闲公会=캐주얼 길드=casual guild
pvp公会=PvP 길드=PvP guild
活动=이벤트/활동=event
每天=매일=every day
每周=매주=every week
晚上=저녁=evening
周末=주말=weekend
时间=시간=time
在线时间=접속 시간=play time
不限=제한 없음=no limit
不限职业=직업 무관=any class
职业不限=직업 무관=any class
不限等级=레벨 무관=any level
等级不限=레벨 무관=any level
以上=이상=or higher
以下=이하=or lower
级以上=레벨 이상=level+
人数=인원=headcount
满人=인원 마감=full
还缺=아직 부족=still need
缺人=사람 부족=need people
缺坦克=탱커 구함=need tank
缺奶=힐러 구함=need healer
缺治疗=힐러 구함=need healer
缺输出=딜러 구함=need DPS
来t=탱커 와=need tank
来奶=힐러 와=need healer
带人=버스 태움=carrying
带新人=뉴비 버스=carry newbies
免费=무료=free
免费带=무료 버스=free carry
收费=유료=paid
便宜卖=싸게 팝니다=selling cheap
大量=대량=bulk
有货=재고 있음=in stock
现货=재고 있음=in stock
价格美丽=가격 착함=good price
价格私聊=가격은 귓말=price in whisper
私聊价格=가격은 귓말=price in whisper
需要的=필요한 분=anyone who needs
需要=필요=need
需要的密=필요하면 귓말=whisper if needed
材料=재료=materials
自备材料=재료 지참=bring mats
包材料=재료 포함=mats included
制作=제작=craft
代做=대신 제작=crafting service
代工=대리 제작=crafting service
附魔师=마법부여사=enchanter
铭文=주문각인=inscription
药水=물약=potion
合剂=영약=flask
食物=음식=food
绷带=붕대=bandage
背包=가방=bag
包=가방=bag
坐骑=탈것=mount
宠物=애완동물=pet
马=탈것(말)=mount
图纸=도안=plans
配方=제조법=recipe
卷轴=두루마리=scroll
宝石=보석=gem
矿=광석=ore
皮=가죽=leather
布=천=cloth
符文布=룬매듭 천=runecloth
魔纹布=마법매듭 천=mageweave
丝绸=비단=silk
奥金锭=아케이나이트 주괴=arcanite bar
瑟银=토륨=thorium
真银=진은=truesilver
秘银=미스릴=mithril
奥术水晶=비전 수정=arcane crystal
黑莲花=검은 연꽃=black lotus
任务物品=퀘스트 아이템=quest item
精英=정예=elite
稀有=희귀=rare
紫装=영웅 장비=epic gear
紫=영웅(보라)=epic
蓝装=희귀 장비=blue gear
绿装=고급 장비=green gear
橙=전설=legendary
boss=보스=boss
老一=첫 보스=first boss
老二=두 번째 보스=second boss
尾王=막보=last boss
全通=전체 클리어=full clear
通关=클리어=clear
开荒=첫 공략=progression
速刷=빠른 반복=speed run
重置=초기화=reset
团灭=전멸=wipe
灭了=전멸했다=wiped
复活=부활=resurrect
召唤=소환=summon
拉人=소환=summon
门=차원문=portal
开门=차원문 열기=open portal
传送=순간이동=teleport
石头=귀환석=hearthstone
集合=집합=gather
集合点=집합 장소=meeting point
门口=입구=entrance
副本门口=던전 입구=dungeon entrance
在门口=입구에 있음=at the entrance
路上=가는 중=on the way
到了=도착=arrived
快到了=거의 도착=almost there
马上到=곧 도착=be right there
开始=시작=start
结束=끝=end
完成=완료=done
任务链=연계 퀘스트=quest chain
精英任务=정예 퀘스트=elite quest
一起做=같이 하자=do together
组人做=파티 모아서 진행=group up for
求组=파티 구함=LFG
求带=버스 구함=need a carry
求=구함/부탁=looking for
请问=실례지만=excuse me
请=부탁=please
麻烦=부탁/귀찮게 해서 죄송=please
大哥=형님=bro
兄弟们=여러분=guys
各位=여러분=everyone
新人=신입=newcomer
老人=고인물=veteran
欢迎新人=신입 환영=newcomers welcome
回归=복귀=returning
回归玩家=복귀 유저=returning players
上班族=직장인=workers
学生=학생=student
女玩家=여성 유저=female players
妹子=여성 유저=girls
氛围=분위기=atmosphere
氛围好=분위기 좋음=good vibe
和谐=화목한=harmonious
友好=친절한=friendly
互帮互助=서로 도움=help each other
团结=단합=united
稳定=안정적인=stable
固定团=고정 공대=static raid
固定队=고정 파티=static group
野团=공팟=pug
野队=공팟=pug
dkp=DKP=DKP
自由拾取=자유 획득=free for all
队长分配=파티장 분배=master loot
全部=전부=all
所有=모든=all
一些=약간=some
很多=많이=a lot
一点=조금=a little
好多=아주 많이=lots
太=너무=too
贵=비싼=expensive
真=정말=really
非常=매우=very
最=가장=most
最好=최고=best
更=더=more
别=하지 마=don't
没=없다/안=not
能=할 수 있다=can
会=할 줄 안다=can
想=원하다=want
知道=알다=know
不知道=모르다=don't know
看=보다=look
找=찾다=find
找人=사람 찾음=looking for people
找组=파티 찾음=LFG
找公会=길드 찾음=looking for guild
在吗=있어요?=you there?
来吗=올래요?=coming?
去吗=갈래요?=going?
有人吗=누구 있나요?=anyone?
怎么去=어떻게 가요=how to get there
在哪里=어디예요=where is it
是什么=뭐예요=what is it
多少级=몇 레벨=what level
几级=몇 레벨=what level
几个=몇 개/명=how many
几=몇=how many
一=1=one
二=2=two
两=2=two
三=3=three
四=4=four
五=5=five
个人=명=people
人了=명 됐어=people now
和=와/과=and
跟=~와 함께=with
我=나=I
你=너=you
他=그=he
我们=우리=we
你们=너희=you all
吧=~하자=let's
也=~도=also
还=아직/또=still
是=~이다=is
不=안/아니=not
都=모두=all
很=매우=very
一个=하나=one
一下=좀/한번=a bit
可以吗=돼요?=can I?
个=개/명=(counter)
]]

------------------------------------------------------------------------
-- 일본어
------------------------------------------------------------------------
ns.RawGlossary.ja = [[
募集=모집=recruiting
メンバー募集=멤버 모집=recruiting members
ギルド=길드=guild
ギルドメンバー=길드원=guild member
パーティー=파티=party
パーティ=파티=party
ダンジョン=던전=dungeon
レイド=공격대=raid
タンク=탱커=tank
ヒーラー=힐러=healer
アタッカー=딜러=DPS
初心者=초보=beginner
歓迎=환영=welcome
大歓迎=대환영=very welcome
日本人=일본인=Japanese
日本語=일본어=Japanese
韓国=한국=Korea
お願いします=부탁합니다=please
よろしくお願いします=잘 부탁합니다=nice to meet you
よろしく=잘 부탁해=nice to meet you
ありがとう=고마워요=thanks
ありがとうございます=감사합니다=thank you
すみません=죄송합니다/저기요=sorry/excuse me
こんにちは=안녕하세요=hello
こんばんは=좋은 저녁=good evening
おはよう=좋은 아침=good morning
おつかれ=수고했어요=good work
お疲れ様です=수고하셨습니다=good work
おやすみ=잘 자요=good night
誰か=누군가=anyone
一緒に=같이=together
手伝って=도와줘=help me
助けて=살려줘=help
売ります=팝니다=WTS
買います=삽니다=WTB
売る=팔다=sell
買う=사다=buy
金=골드=gold
ゴールド=골드=gold
クエスト=퀘스트=quest
レベル=레벨=level
装備=장비=gear
武器=무기=weapon
はい=네=yes
いいえ=아니요=no
大丈夫=괜찮아요=okay
了解=알겠습니다=roger
待って=기다려=wait
今=지금=now
どこ=어디=where
何=무엇=what
できます=가능합니다=can
できません=불가능합니다=can't
わかりません=모르겠습니다=don't understand
]]

------------------------------------------------------------------------
-- 영어 (게임 약어 위주)
------------------------------------------------------------------------
ns.RawGlossary.en = [[
lfg=파티 구함=looking for group
lfm=인원 구함=looking for more
lf=구함=looking for
lf1m=1명 구함=need 1 more
lf2m=2명 구함=need 2 more
lf3m=3명 구함=need 3 more
lf4m=4명 구함=need 4 more
looking for=구함=looking for
looking for group=파티 구함=looking for group
wts=팝니다=want to sell
wtb=삽니다=want to buy
wtt=교환합니다=want to trade
pst=귓말 주세요=please send tell
pm=귓말=private message
pm me=귓말 주세요=message me
w/=귓말=whisper
whisper=귓말=whisper
msg=메시지=message
inv=초대=invite
invite=초대=invite
inv pls=초대 부탁=invite please
pls=부탁해요=please
plz=부탁해요=please
please=부탁해요=please
ty=고마워=thank you
thx=고마워=thanks
tnx=고마워=thanks
thanks=고마워요=thanks
np=천만에=no problem
yw=천만에=you're welcome
gg=수고했어요=good game
gj=잘했어=good job
wp=잘했어=well played
brb=금방 올게=be right back
afk=자리 비움=away from keyboard
omw=가는 중=on my way
otw=가는 중=on the way
idk=모르겠어=I don't know
imo=내 생각엔=in my opinion
btw=그런데=by the way
lol=ㅋㅋ=laughing
lmao=ㅋㅋㅋ=laughing
wtf=뭐야=what the
nvm=신경 쓰지 마=never mind
k=ㅇㅋ=ok
kk=ㅇㅋ=ok
ok=좋아=ok
sry=미안=sorry
sorry=미안해요=sorry
gl=행운을=good luck
hf=즐겜=have fun
gz=축하해=congrats
grats=축하해=congrats
congrats=축하해=congrats
hi=안녕=hi
hello=안녕하세요=hello
bye=잘 가=bye
cya=또 봐=see you
anyone=누구 있나요=anyone
any=아무나/있나요=any
and=그리고=and
rf=성난불길 협곡=Ragefire Chasm
engineer=기계공학자=engineer
engineering=기계공학=engineering
blacksmith=대장장이=blacksmith
leatherworker=가죽세공사=leatherworker
alchemist=연금술사=alchemist
crafter=제작자=crafter
craft=제작=craft
crafting=제작=crafting
make=만들기=make
recipe=제조법=recipe
for=~용=for
with=~와 함께=with
who=누가=who
can=할 수 있는=can
help=도와줘=help
someone=누군가=someone
my=내=my
me=나=me
shotgun=샷건(총)=shotgun
gun=총=gun
bow=활=bow
quest item=퀘스트 아이템=quest item
group=파티=group
guild=길드=guild
recruiting=모집 중=recruiting
guy=사람=guy
guys=여러분=guys
everyone=모두=everyone
people=사람들=people
player=플레이어=player
players=플레이어들=players
looking for more=인원 구함=looking for more
lf tank=탱커 구함=looking for tank
lf heals=힐러 구함=looking for healer
lf healer=힐러 구함=looking for healer
lf dps=딜러 구함=looking for DPS
need tank=탱커 필요=need tank
need heals=힐러 필요=need healer
need healer=힐러 필요=need healer
need dps=딜러 필요=need DPS
all quests=퀘스트 전부=all quests
quest run=퀘스트 런=quest run
full run=풀런=full run
speed run=빠른 런=speed run
farm=파밍=farm
farming=파밍 중=farming
grind=사냥=grind
level=레벨=level
leveling=레벨업=leveling
lvling=레벨업=leveling
ding=레벨업!=level up!
mount=탈것=mount
pet=펫=pet
bag=가방=bag
bags=가방=bags
ore=광석=ore
herb=약초=herb
herbs=약초=herbs
leather=가죽=leather
cloth=천=cloth
bar=주괴=bar
bars=주괴=bars
stack=묶음(한 칸)=stack
stacks=묶음=stacks
x=개(수량)=x
cod=착불 우편=cash on delivery
mail=우편=mail
tip=팁=tip
tips=팁=tips
free=무료=free
your mats=재료 지참=your mats
my mats=내 재료=my mats
ur=너의=your
u=너=you
r=~이다(are)=are
y=왜=why
im=나는=I'm
i=나=I
you=너=you
we=우리=we
they=그들=they
is==
are==
the==
a==
an==
to=~로=to
in=~에서=in
at=~에=at
on=~에=on
of=~의=of
from=~에서=from
or=또는=or
but=하지만=but
if=만약=if
not=아니다=not
no=아니/없음=no
yes=응=yes
yeah=응=yeah
yep=응=yep
nope=아니=nope
want=원하다=want
wants=원하다=wants
go=가자=go
going=가는 중=going
come=와=come
coming=가는 중=coming
get=얻다=get
got=얻었다=got
have=가지다=have
has=가지다=has
know=알다=know
where=어디=where
what=뭐=what
how=어떻게=how
when=언제=when
why=왜=why
how much=얼마=how much
how many=몇 개=how many
much=많이=much
many=많은=many
more=더=more
last=마지막=last
first=처음=first
now=지금=now
asap=최대한 빨리=as soon as possible
soon=곧=soon
later=나중에=later
today=오늘=today
tonight=오늘 밤=tonight
tomorrow=내일=tomorrow
wait=기다려=wait
sec=잠깐=second
min=분=minute
mins=분=minutes
hour=시간=hour
pls inv=초대 부탁=please invite
inv me=초대해줘=invite me
add me=추가해줘=add me
join=합류=join
leave=나가기=leave
left=나갔다=left
kick=추방=kick
dc=튕김=disconnected
lag=렉=lag
wipe=전멸=wipe
pull=풀링=pull
loot=전리품=loot
drop=드랍=drop
drops=드랍=drops
boss=보스=boss
rare=희귀(몹)=rare
elite=정예=elite
mob=몹=mob
mobs=몹=mobs
kill=잡기=kill
killed=잡음=killed
dead=죽음=dead
die=죽다=die
corpse=시체=corpse
rez pls=부활 부탁=rez please
water=물=water
food=음식=food
mana=마나=mana
oom=마나 없음=out of mana
hp=생명력=health
heal pls=힐 부탁=heal please
good=좋아=good
bad=나쁜=bad
nice=좋네=nice
great=훌륭해=great
cool=멋져=cool
fun=재밌다=fun
easy=쉬움=easy
hard=어려움=hard
friendly=친절한=friendly
chill=느긋한=chill
casual=캐주얼=casual
active=활발한=active
social=친목=social
recruit=모집=recruit
members=멤버=members
new players=신규 유저=new players
returning=복귀=returning
welcome=환영=welcome
discord=디스코드=Discord
voice=음성 채팅=voice
need=필요=need
greed=차비=greed
roll=주사위=roll
sr=찜(소프트 예약)=soft reserve
ms=주 특성(우선)=main spec
os=보조 특성=off spec
res=예약/부활=reserve/resurrect
rez=부활=resurrect
tank=탱커=tank
heal=힐=heal
healer=힐러=healer
heals=힐러=healer
dps=딜러=DPS
mdps=근접 딜러=melee DPS
rdps=원거리 딜러=ranged DPS
mt=메인 탱커=main tank
ot=보조 탱커=off tank
war=전사=Warrior
warr=전사=Warrior
warrior=전사=Warrior
mage=마법사=Mage
priest=사제=Priest
lock=흑마법사=Warlock
warlock=흑마법사=Warlock
hunt=사냥꾼=Hunter
hunter=사냥꾼=Hunter
rog=도적=Rogue
rogue=도적=Rogue
dru=드루이드=Druid
druid=드루이드=Druid
pal=성기사=Paladin
pala=성기사=Paladin
pally=성기사=Paladin
paladin=성기사=Paladin
sham=주술사=Shaman
shaman=주술사=Shaman
summ=소환=summon
summon=소환=summon
sum=소환=summon
port=순간이동=portal
portal=차원문=portal
ports=순간이동=portals
boe=착용 시 귀속=bind on equip
ah=경매장=auction house
gdkp=골드팟=GDKP
gbid=골드팟=gold bid
bis=최고 장비(BiS)=best in slot
aoe=광역=AoE
cc=군중 제어=crowd control
cd=쿨다운=cooldown
buff=버프=buff
buffs=버프=buffs
pot=물약=potion
pots=물약=potions
flask=영약=flask
mats=재료=materials
ench=마부=enchant
enchanter=마법부여사=enchanter
lw=가죽세공=leatherworking
bs=대장기술=blacksmithing
alch=연금술=alchemy
engi=기계공학=engineering
tailor=재봉=tailoring
quest=퀘스트=quest
q=퀘스트=quest
xp=경험치=XP
exp=경험치=XP
lvl=레벨=level
dung=던전=dungeon
dungeon=던전=dungeon
raid=공격대=raid
run=판/런=run
runs=판=runs
boost=버스=boost
carry=캐리=carry
spot=자리=spot
spots=자리=spots
last spot=마지막 자리=last spot
full=꽉 참=full
hc=영웅=heroic
sm=붉은십자군 수도원=Scarlet Monastery
sm gy=붉은수도원 묘지=SM Graveyard
sm lib=붉은수도원 도서관=SM Library
sm arm=붉은수도원 무기고=SM Armory
sm cath=붉은수도원 대성당=SM Cathedral
dm=죽음의 폐광/혈투의 전장=Deadmines/Dire Maul
vc=죽음의 폐광=Deadmines
wc=통곡의 동굴=Wailing Caverns
rfc=성난불길 협곡=Ragefire Chasm
sfk=그림자송곳니 성채=Shadowfang Keep
stocks=스톰윈드 지하감옥=Stockade
bfd=검은심연의 나락=Blackfathom Deeps
gnomer=놈리건=Gnomeregan
rfk=가시덩굴 우리=Razorfen Kraul
rfd=가시덩굴 구릉=Razorfen Downs
ulda=울다만=Uldaman
zf=줄파락=Zul'Farrak
mara=마라우돈=Maraudon
st=아탈학카르 신전=Sunken Temple
brd=검은바위 나락=Blackrock Depths
lbrs=검은바위 첨탑 하층=Lower Blackrock Spire
ubrs=검은바위 첨탑 상층=Upper Blackrock Spire
strat=스트라솔름=Stratholme
scholo=스칼로맨스=Scholomance
mc=화산 심장부=Molten Core
ony=오닉시아=Onyxia
bwl=검은날개 둥지=Blackwing Lair
zg=줄구룹=Zul'Gurub
aq=안퀴라즈=Ahn'Qiraj
aq20=안퀴라즈 폐허=Ruins of Ahn'Qiraj
aq40=안퀴라즈 사원=Temple of Ahn'Qiraj
naxx=낙스라마스=Naxxramas
bg=전장=battleground
wsg=전쟁노래 협곡=Warsong Gulch
ab=아라시 분지=Arathi Basin
av=알터랙 계곡=Alterac Valley
sw=스톰윈드=Stormwind
og=오그리마=Orgrimmar
org=오그리마=Orgrimmar
uc=언더시티=Undercity
tb=썬더 블러프=Thunder Bluff
gadget=가젯잔=Gadgetzan
xr=크로스로드=Crossroads
stv=가시덤불 골짜기=Stranglethorn Vale
wpl=서부 역병지대=Western Plaguelands
epl=동부 역병지대=Eastern Plaguelands
g=골드=gold
s=실버=silver
gold=골드=gold
price=가격=price
cheap=싸게=cheap
each=개당=each
per=당=per
]]

------------------------------------------------------------------------
-- 러시아어
------------------------------------------------------------------------
ns.RawGlossary.ru = [[
привет=안녕=hi
здравствуйте=안녕하세요=hello
всем привет=모두 안녕=hi all
пока=잘 가=bye
спасибо=고마워요=thanks
спс=고마워=thx
пожалуйста=부탁해요/천만에요=please
пж=부탁해=pls
плиз=부탁해=pls
да=네=yes
нет=아니요=no
ок=ㅇㅋ=ok
ладно=알았어=alright
хорошо=좋아요=good
давай=가자/하자=let's go
го=가자=go
идём=가자=let's go
кто=누구=who
есть=있나요=is there
нужен=필요해요=need
нужна=필요해요=need
нужны=필요해요=need
нужно=필요=need
ищу=찾아요=looking for
в=~에/~로=in/to
на=~에=on/to
и=그리고=and
с=~와 함께=with
группа=파티=group
группу=파티=group
в группу=파티에=to the group
пати=파티=party
гильдия=길드=guild
гильдию=길드=guild
ги=길드=guild
набор=모집=recruiting
набираем=모집 중=recruiting
рейд=공격대=raid
данж=던전=dungeon
подземелье=던전=dungeon
танк=탱커=tank
хил=힐러=healer
хилер=힐러=healer
дд=딜러=DPS
дпс=딜러=DPS
воин=전사=Warrior
маг=마법사=Mage
жрец=사제=Priest
прист=사제=Priest
чернокнижник=흑마법사=Warlock
лок=흑마법사=Warlock
охотник=사냥꾼=Hunter
хант=사냥꾼=Hunter
разбойник=도적=Rogue
рога=도적=Rogue
друид=드루이드=Druid
дру=드루이드=Druid
паладин=성기사=Paladin
пал=성기사=Paladin
шаман=주술사=Shaman
шам=주술사=Shaman
куплю=삽니다=WTB
продам=팝니다=WTS
продаю=팝니다=WTS
обмен=교환=trade
цена=가격=price
сколько=얼마=how much
золото=골드=gold
голд=골드=gold
г=골드=gold
ах=경매장=auction house
аук=경매장=auction house
аукцион=경매장=auction house
квест=퀘스트=quest
квесты=퀘스트=quests
уровень=레벨=level
лвл=레벨=level
ур=레벨=level
шмот=장비=gear
вещи=아이템=items
пишите=귓말 주세요=whisper
пиши=귓말 줘=whisper me
в лс=귓말로=in whisper
лс=귓말=whisper
пм=귓말=PM
инвайт=초대=invite
инв=초대=invite
помогите=도와주세요=help
помочь=돕다=help
помощь=도움=help
кто поможет=누가 도와줄래요=who can help
где=어디=where
когда=언제=when
что=뭐=what
сейчас=지금=now
быстро=빨리=quickly
жду=기다려요=waiting
подожди=기다려=wait
секунду=잠깐=one sec
норм=괜찮아=fine
круто=멋져=cool
русский=러시아어/러시아인=Russian
русские=러시아인들=Russians
ру=러시아=RU
кореец=한국인=Korean
корея=한국=Korea
не=~않다=not
понимаю=이해해요=understand
не понимаю=모르겠어요=don't understand
мертвые копи=죽음의 폐광=Deadmines
мк=화산 심장부=Molten Core
огненные недра=화산 심장부=Molten Core
ониксия=오닉시아=Onyxia
стратхольм=스트라솔름=Stratholme
некроситет=스칼로맨스=Scholomance
глубины черной горы=검은바위 나락=Blackrock Depths
бг=전장=battleground
орда=호드=Horde
альянс=얼라이언스=Alliance
оргриммар=오그리마=Orgrimmar
штормград=스톰윈드=Stormwind
стальгорн=아이언포지=Ironforge
всем=모두에게=everyone
все=모두=all
я=나=I
мы=우리=we
ты=너=you
вы=당신들=you
кто-то=누군가=someone
один=한 명=one
еще=더/아직=more
хила=힐러를=healer
хилов=힐러들=healers
хилера=힐러를=healer
танка=탱커를=tank
танков=탱커들=tanks
дамагера=딜러를=DPS
мага=마법사를=mage
жреца=사제를=priest
приста=사제를=priest
лока=흑마법사를=warlock
ханта=사냥꾼을=hunter
рогу=도적을=rogue
друида=드루이드를=druid
пала=성기사를=paladin
шама=주술사를=shaman
воина=전사를=warrior
группы=파티의=group
группе=파티에=in group
гильдии=길드의=guild
пойдем=가자=let's go
пойду=갈게=I'll go
иду=가는 중=coming
куда=어디로=where to
откуда=어디서=from where
как=어떻게=how
почему=왜=why
зачем=뭐 하러=what for
можно=해도 돼요?/가능=may I
нельзя=안 돼=can't
могу=할 수 있어=I can
можешь=할 수 있어?=can you
хочу=원해요=I want
надо=해야 해=need to
знаю=알아=I know
не знаю=몰라요=don't know
кто идет=누가 가요=who's going
кто со мной=나랑 갈 사람=who's with me
со мной=나와 함께=with me
с нами=우리와 함께=with us
нас=우리를=us
мне=나에게=me
тебе=너에게=you
есть кто=누구 있어요=anyone here
кто есть=누구 있어요=anyone
человек=사람=person
людей=사람들=people
один человек=한 명=one person
последний=마지막=last
фарм=파밍=farm
фармить=파밍하다=to farm
качаться=레벨업하다=to level
кач=레벨업=leveling
прокачка=레벨업=leveling
пройти=클리어하다=to clear
пройти данж=던전 돌기=run dungeon
вход=입구=entrance
у входа=입구에서=at the entrance
саммон=소환=summon
призыв=소환=summon
портал=차원문=portal
вайп=전멸=wipe
лут=전리품=loot
дроп=드랍=drop
босс=보스=boss
рар=희귀몹=rare
элитка=정예몹=elite
моб=몹=mob
мобы=몹들=mobs
убить=잡다=kill
умер=죽었다=died
ресни=부활시켜 줘=rez me
вода=물=water
еда=음식=food
мана=마나=mana
зелье=물약=potion
зелья=물약=potions
сумка=가방=bag
маунт=탈것=mount
руда=광석=ore
трава=약초=herb
кожа=가죽=leather
ткань=천=cloth
рецепт=제조법=recipe
крафт=제작=craft
скрафтить=제작하다=to craft
мат=재료=mats
маты=재료=mats
свои маты=재료 지참=your mats
дешево=싸게=cheap
дорого=비싸게=expensive
бесплатно=무료=free
за=~에(가격)/~를 위해=for
по=~씩=each
шт=개=pcs
штук=개=pcs
голды=골드=gold
серебро=실버=silver
медь=코퍼=copper
квестов=퀘스트=quests
задание=퀘스트=quest
делать=하다=do
делаем=하는 중=doing
сделать=해내다=make
вместе=같이=together
спасибо большое=정말 고마워요=thank you very much
благодарю=감사합니다=thank you
извините=죄송합니다=sorry
извини=미안=sorry
прости=미안=sorry
удачи=행운을=good luck
гг=수고했어요=gg
лол=ㅋㅋ=lol
ахах=ㅋㅋ=haha
хаха=ㅋㅋ=haha
афк=자리 비움=afk
бб=잘 가=bye
дс=디스코드=Discord
дискорд=디스코드=Discord
войс=음성 채팅=voice
адекватные=정상적인(매너 있는)=decent
адекватных=매너 있는 분=decent people
дружная=화목한=friendly
активная=활발한=active
приглашаем=초대합니다=we invite
приглашает=초대합니다=invites
вступить=가입하다=to join
]]
