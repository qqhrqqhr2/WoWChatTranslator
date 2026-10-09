-- WoW Chat Translator: 채팅 번역
-- 한국어·중국어·일본어·러시아어·영어 메시지를 감지해 [中] 같은 표시를 붙이고,
-- 내장 사전으로 현지 언어(설정)로 풀어서 메시지 뒤와 마우스 오버로 보여준다.
-- (와우 애드온은 인터넷에 접속할 수 없어서 문장 전체 자동 번역은 불가능하다.)
local ADDON, ns = ...
-- 화면 문구는 현지 언어 설정에 따라 바뀌므로 항상 ns.L 을 거쳐서 읽는다
local L = setmetatable({}, { __index = function(_, k) return ns.L[k] end })

------------------------------------------------------------------------
-- UTF-8 처리
------------------------------------------------------------------------
local byte, char, floor = string.byte, string.char, math.floor

local function decode(s, i)
	local c = byte(s, i)
	if not c then return nil, i end
	if c < 0x80 then return c, i + 1 end
	local c2, c3, c4 = byte(s, i + 1) or 128, byte(s, i + 2) or 128, byte(s, i + 3) or 128
	if c < 0xE0 then return (c % 32) * 64 + c2 % 64, i + 2 end
	if c < 0xF0 then return (c % 16) * 4096 + (c2 % 64) * 64 + c3 % 64, i + 3 end
	return (c % 8) * 262144 + (c2 % 64) * 4096 + (c3 % 64) * 64 + c4 % 64, i + 4
end

local function encode(cp)
	if cp < 0x80 then return char(cp) end
	if cp < 0x800 then return char(0xC0 + floor(cp / 64), 0x80 + cp % 64) end
	if cp < 0x10000 then
		return char(0xE0 + floor(cp / 4096), 0x80 + floor(cp / 64) % 64, 0x80 + cp % 64)
	end
	return char(0xF0 + floor(cp / 262144), 0x80 + floor(cp / 4096) % 64, 0x80 + floor(cp / 64) % 64, 0x80 + cp % 64)
end

-- 찾기용 정규화: 영문·러시아어 소문자, 전각 영문/기호 → 반각, ё → е
local function norm(cp)
	if cp >= 0xFF01 and cp <= 0xFF5E then cp = cp - 0xFEE0 end
	if cp >= 65 and cp <= 90 then return cp + 32 end
	if cp >= 0x0410 and cp <= 0x042F then return cp + 32 end
	if cp == 0x0401 or cp == 0x0451 then return 0x0435 end
	if cp == 0x3001 then return 44 end  -- 、
	if cp == 0x3002 then return 46 end  -- 。
	if cp == 0x2019 or cp == 0x2018 or cp == 0x02BC or cp == 0x60 then return 39 end  -- ’ ‘ ` → '
	-- 번체 → 간체 (嗎 → 吗): 번체 채팅도 간체 사전으로 찾는다
	local t2s = ns.T2S and ns.T2S[cp]
	if t2s then return t2s end
	return cp
end

local function isHan(cp)
	return (cp >= 0x3400 and cp <= 0x4DBF) or (cp >= 0x4E00 and cp <= 0x9FFF)
		or (cp >= 0xF900 and cp <= 0xFAFF) or (cp >= 0x20000 and cp <= 0x2FFFF)
end
local function isKana(cp)
	return (cp >= 0x3040 and cp <= 0x30FF) or (cp >= 0x31F0 and cp <= 0x31FF) or (cp >= 0xFF66 and cp <= 0xFF9F)
end
local function isHangul(cp)
	return (cp >= 0xAC00 and cp <= 0xD7AF) or (cp >= 0x1100 and cp <= 0x11FF) or (cp >= 0x3130 and cp <= 0x318F)
end
local function isCyr(cp) return cp >= 0x0400 and cp <= 0x04FF end
local function isLatin(cp) return (cp >= 97 and cp <= 122) or (cp >= 0xC0 and cp <= 0x24F) end
local function isDigit(cp) return cp >= 48 and cp <= 57 end

------------------------------------------------------------------------
-- 토큰 나누기
-- kind: "cjk"(한자·가나·한글 한 글자), "word"(영문·러시아어·숫자 단어), "space", "other"
------------------------------------------------------------------------
local function Tokenize(text)
	local tokens, i, n = {}, 1, #text
	local cps = {}
	while i <= n do
		local cp, j = decode(text, i)
		if not cp then break end
		cps[#cps + 1] = { cp = cp, n = norm(cp), s = text:sub(i, j - 1) }
		i = j
	end
	local k = 1
	while k <= #cps do
		local c = cps[k]
		local nc = c.n
		if isHan(nc) or isKana(nc) or isHangul(nc) then
			tokens[#tokens + 1] = { kind = "cjk", text = c.s, key = encode(nc) }
			k = k + 1
		elseif isLatin(nc) or isCyr(nc) or isDigit(nc) then
			local raw, key = {}, {}
			while k <= #cps do
				local d = cps[k]
				local dn = d.n
				local inWord = isLatin(dn) or isCyr(dn) or isDigit(dn)
				-- 단어 사이 하이픈(кто-нибудь), w/ 같은 슬래시는 단어에 포함
				if not inWord and #raw > 0 then
					local nx = cps[k + 1]
					local prevN = cps[k - 1] and cps[k - 1].n
					if dn == 47 then
						inWord = true
					elseif dn == 45 or dn == 39 then
						-- 하이픈·아포스트로피는 글자 사이에 있을 때만 (кто-нибудь, don't, zul'farrak)
						inWord = nx and (isLatin(nx.n) or isCyr(nx.n)) or false
					elseif dn == 46 then
						-- 소수점은 숫자 사이에 있을 때만 (1.5k, t2.5)
						inWord = (prevN and isDigit(prevN) and nx and isDigit(nx.n)) or false
					end
				end
				if not inWord then break end
				raw[#raw + 1] = d.s
				key[#key + 1] = encode(dn)
				k = k + 1
			end
			tokens[#tokens + 1] = { kind = "word", text = table.concat(raw), key = table.concat(key) }
		elseif nc == 32 or nc == 9 or nc == 0x3000 then
			tokens[#tokens + 1] = { kind = "space", text = " ", key = " " }
			k = k + 1
		else
			tokens[#tokens + 1] = { kind = "other", text = (nc < 128) and char(nc) or c.s, key = encode(nc) }
			k = k + 1
		end
	end
	return tokens
end

------------------------------------------------------------------------
-- 사전 만들기
------------------------------------------------------------------------
local Dict = {}   -- Dict[lang][key] = { 한국어 뜻, 영어 뜻, 원문 }
local MaxLen = {} -- 중국어·일본어: 최대 글자(토큰) 수
local function NormKey(term)
	local parts = {}
	for _, t in ipairs(Tokenize(term)) do
		if t.kind == "space" then
			if #parts > 0 and parts[#parts] ~= " " then parts[#parts + 1] = " " end
		else
			parts[#parts + 1] = t.key
		end
	end
	while parts[#parts] == " " do parts[#parts] = nil end
	return table.concat(parts), #parts
end

local function BuildDict()
	for lang, raw in pairs(ns.RawGlossary) do
		local d, maxLen = {}, 1
		for line in raw:gmatch("[^\r\n]+") do
			local term, ko, en = line:match("^%s*(.-)%s*=%s*(.-)%s*=%s*(.-)%s*$")
			if term and term ~= "" then
				local key, len = NormKey(term)
				d[key] = { ko, en, term }
				if len > maxLen then maxLen = len end
			end
		end
		Dict[lang], MaxLen[lang] = d, maxLen
	end
end
BuildDict()
ns.Dict = Dict

-- 사전 항목의 뜻을 현지 언어로 (번역표에 없으면 영어 뜻)
local function Meaning(e, target)
	local ko, en = e[1], e[2]
	if en == "" and ko == "" then return "" end
	if target == "ko" then return ko ~= "" and ko or en end
	if target == "en" or en == "" then return en ~= "" and en or ko end
	local tr = ns.TR and ns.TR[target]
	local lower = en:lower()
	local v = tr and tr[lower]
	if not v and target == "zhTW" and ns.TR and ns.TR.zhCN then v = ns.TR.zhCN[lower] end
	return v or en
end
ns.Meaning = Meaning

------------------------------------------------------------------------
-- 언어 감지
------------------------------------------------------------------------
local function Detect(text)
	local han, kana, hangul, cyr, lat = 0, 0, 0, 0, 0
	local i, n = 1, #text
	while i <= n do
		local cp, j = decode(text, i)
		if not cp then break end
		cp = norm(cp)
		if isHangul(cp) then hangul = hangul + 1
		elseif isKana(cp) then kana = kana + 1
		elseif isHan(cp) then han = han + 1
		elseif isCyr(cp) then cyr = cyr + 1
		elseif isLatin(cp) then lat = lat + 1 end
		i = j
	end
	if hangul > 0 and hangul >= han + kana + cyr then return "ko" end
	if kana > 0 then return "ja" end
	if han > 0 then return "zh" end
	if cyr > 0 then return "ru" end
	if lat >= 2 and hangul == 0 then return "en" end
	return nil
end
ns.Detect = Detect

------------------------------------------------------------------------
-- 용어 풀이
------------------------------------------------------------------------
-- 숫자가 붙은 표현 (30g, 1.5k, lvl40, lf2m, x5, 9pm ...)
-- { 패턴, { 현지 언어별 결과 }, 원문 언어 제한(없으면 전부) }
local function P(pat, ko, en, zhCN, zhTW, ru, src)
	return { pat, { ko = ko, en = en, zhCN = zhCN, zhTW = zhTW, ru = ru }, src }
end
local PATTERNS = {
	P("^(%d[%d%.]*)g$", "%1골드", "%1 gold", "%1金", "%1金", "%1 золотых"),
	P("^(%d[%d%.]*)gold$", "%1골드", "%1 gold", "%1金", "%1金", "%1 золотых"),
	P("^(%d[%d%.]*)s$", "%1실버", "%1 silver", "%1银", "%1銀", "%1 серебра"),
	P("^(%d[%d%.]*)c$", "%1코퍼", "%1 copper", "%1铜", "%1銅", "%1 меди"),
	P("^(%d[%d%.]*)k$", "%1천", "%1k", "%1千", "%1千", "%1 тыс."),
	P("^(%d[%d%.]*)kg$", "%1천 골드", "%1k gold", "%1千金", "%1千金", "%1 тыс. золотых"),
	P("^(%d[%d%.]*)w$", "%1만", "%1 x10k", "%1万", "%1萬", "%1 x10 тыс.", "zh"),
	P("^x(%d+)$", "%1개", "x%1", "%1个", "%1個", "%1 шт."),
	P("^(%d+)x$", "%1개", "x%1", "%1个", "%1個", "%1 шт."),
	P("^lvl(%d+)$", "레벨 %1", "level %1", "%1级", "%1級", "%1 ур."),
	P("^lv(%d+)$", "레벨 %1", "level %1", "%1级", "%1級", "%1 ур."),
	P("^level(%d+)$", "레벨 %1", "level %1", "%1级", "%1級", "%1 ур."),
	P("^lf(%d+)m$", "%1명 구함", "need %1 more", "缺%1人", "缺%1人", "нужно ещё %1"),
	P("^need(%d+)$", "%1명 필요", "need %1", "需要%1人", "需要%1人", "нужно %1"),
	P("^(%d+)m$", "%1명", "%1-man", "%1人", "%1人", "%1 чел."),
	P("^(%d+)man$", "%1인", "%1-man", "%1人", "%1人", "на %1"),
	P("^(%d+)min$", "%1분", "%1 min", "%1分钟", "%1分鐘", "%1 мин"),
	P("^(%d+)mins$", "%1분", "%1 min", "%1分钟", "%1分鐘", "%1 мин"),
	P("^(%d+)sec$", "%1초", "%1 sec", "%1秒", "%1秒", "%1 сек"),
	P("^(%d+)ish$", "%1쯤", "around %1", "%1左右", "%1左右", "около %1"),
	P("^(%d+)pm$", "오후 %1시", "%1 PM", "下午%1点", "下午%1點", "%1 вечера"),
	P("^(%d+)am$", "오전 %1시", "%1 AM", "上午%1点", "上午%1點", "%1 утра"),
	P("^(%d+)st$", "%1번째", "%1st", "第%1", "第%1", "%1-й"),
	P("^(%d+)nd$", "%1번째", "%1nd", "第%1", "第%1", "%1-й"),
	P("^(%d+)rd$", "%1번째", "%1rd", "第%1", "第%1", "%1-й"),
	P("^(%d+)th$", "%1번째", "%1th", "第%1", "第%1", "%1-й"),
	P("^r(%d+)$", "%1계급", "rank %1", "%1级军衔", "%1級軍銜", "ранг %1"),
	P("^(%d[%d%.]*)г$", "%1골드", "%1 gold", "%1金", "%1金", "%1 золотых", "ru"),
	P("^(%d[%d%.]*)з$", "%1골드", "%1 gold", "%1金", "%1金", "%1 золотых", "ru"),
	P("^(%d[%d%.]*)с$", "%1실버", "%1 silver", "%1银", "%1銀", "%1 серебра", "ru"),
	P("^(%d[%d%.]*)к$", "%1천", "%1k", "%1千", "%1千", "%1 тыс.", "ru"),
	P("^(%d+)лвл$", "레벨 %1", "level %1", "%1级", "%1級", "%1 ур.", "ru"),
	P("^(%d+)ур$", "레벨 %1", "level %1", "%1级", "%1級", "%1 ур.", "ru"),
}

local function MatchPattern(key, lang, target)
	target = target or ns.GetTarget()
	for _, p in ipairs(PATTERNS) do
		if not p[3] or p[3] == lang then
			local out, n = key:gsub(p[1], p[2][target] or p[2].en)
			if n > 0 then return out end
		end
	end
end
ns.MatchPattern = MatchPattern

local function lookup(dicts, key)
	for _, d in ipairs(dicts) do
		local e = d and d[key]
		if e then return e end
	end
end

-- 반환: { rough = "대략적인 뜻(색 코드 포함)", terms = { {원문, 뜻}, ... }, found = 찾은 개수 }
-- 한국어 반복 자모 줄이기 (ㅋㅋㅋㅋ → ㅋㅋ)
local REPEAT_JAMO = { "ㅋ", "ㅎ", "ㅠ", "ㅜ", "ㄷ", "ㅡ" }
local function CollapseKo(text)
	for _, j in ipairs(REPEAT_JAMO) do
		local three = j .. j .. j
		while text:find(three, 1, true) do
			text = text:gsub(three, j .. j)
		end
	end
	return text
end

local function Gloss(text, lang, target)
	target = target or ns.GetTarget()
	if lang == "ko" then text = CollapseKo(text) end
	local tokens = Tokenize(text)
	local cjkMode = (lang == "zh" or lang == "ja" or lang == "ko")
	local cjkOut = (target == "zhCN" or target == "zhTW")
	local mainDicts
	if lang == "ja" then mainDicts = { Dict.ja, Dict.zh }
	elseif lang == "zh" then mainDicts = { Dict.zh }
	else mainDicts = { Dict[lang] } end
	local wordDicts = { Dict[lang], Dict.en }
	local maxLen = 1
	for _, l in ipairs(cjkMode and { "zh", "ja", "ko" } or { lang }) do
		if (MaxLen[l] or 1) > maxLen then maxLen = MaxLen[l] end
	end

	local pieces, terms, seen, found = {}, {}, {}, 0
	local coverHit, coverMiss = 0, 0
	local function isNumber(tok) return tok.kind == "word" and tok.key:find("^[%d%p]+$") ~= nil end
	local function emit(kind, s) pieces[#pieces + 1] = { kind = kind, s = s } end
	local function addTerm(term, meaning, len)
		found = found + 1
		if meaning ~= "" and not seen[term] and #terms < 14 and len > 0 and meaning:lower() ~= term:lower() then
			seen[term] = true
			terms[#terms + 1] = { term, meaning }
		end
	end

	local i, n = 1, #tokens
	while i <= n do
		local t = tokens[i]
		local matched = false
		if t.kind == "cjk" or t.kind == "word" then
			-- 가장 긴 표현부터 찾기
			local keys, last = {}, nil
			local j, used = i, 0
			local best, bestJ = nil, nil
			while j <= n and used < maxLen do
				local tj = tokens[j]
				if tj.kind == "space" then
					if cjkMode then break end
					-- 영어·러시아어: 단어 사이 공백 하나는 구절로 이어 붙임
					local nx = tokens[j + 1]
					if not nx or nx.kind ~= "word" then break end
					keys[#keys + 1] = " "
				elseif tj.kind == "cjk" or tj.kind == "word" then
					if cjkMode and tj.kind == "word" and last == "word" then break end
					keys[#keys + 1] = tj.key
					used = used + 1
					last = tj.kind
					local key = table.concat(keys)
					local e = lookup(mainDicts, key)
					if not e and used == 1 and tj.kind == "word" then e = lookup(wordDicts, key) end
					if e then best, bestJ = e, j end
				else
					break
				end
				if not cjkMode and tj.kind == "cjk" then break end
				j = j + 1
			end
			if best then
				local orig = {}
				for x = i, bestJ do orig[#orig + 1] = tokens[x].text end
				local term = table.concat(orig)
				for x = i, bestJ do
					if tokens[x].kind ~= "space" and not isNumber(tokens[x]) then coverHit = coverHit + 1 end
				end
				local meaning = Meaning(best, target)
				if meaning ~= "" then emit("hit", meaning) end
				-- 한 글자짜리 영문·러시아어(в, и, g 등)는 목록에서는 뺀다
				local short = (t.kind == "word" and i == bestJ and #t.key <= 2 and not cjkMode)
				addTerm(term, meaning, short and 0 or 1)
				i = bestJ + 1
				matched = true
			end
		end
		if not matched and t.kind == "word" then
			local p = MatchPattern(t.key, lang, target)
			if p then
				emit("hit", p)
				found = found + 1
				coverHit = coverHit + 1
				i = i + 1
				matched = true
			end
		end
		if not matched then
			if t.kind == "space" then emit("space", " ")
			elseif t.kind == "other" then emit("other", t.text)
			else
				emit("miss", t.text)
				if not isNumber(t) then coverMiss = coverMiss + 1 end
			end
			i = i + 1
		end
	end

	-- 조각 이어 붙이기: 뜻끼리는 띄어 쓰고, 모르는 한자는 붙여서 원문 그대로
	local out, plain, prev, prevS = {}, {}, nil, nil
	for _, p in ipairs(pieces) do
		if p.kind == "space" then
			if prev and prev ~= "space" then out[#out + 1] = " "; plain[#plain + 1] = " " end
		else
			if prev and prev ~= "space" and prev ~= "other" and p.kind ~= "other"
				and (p.kind == "hit" or prev == "hit")
				and not (cjkOut and p.kind == "hit" and prev == "hit") then
				out[#out + 1] = " "; plain[#plain + 1] = " "
			elseif prev == "other" and p.kind ~= "other" and prevS and prevS:find("^[,%.!%?:;]$") then
				out[#out + 1] = " "; plain[#plain + 1] = " "
			end
			plain[#plain + 1] = p.s
			if p.kind == "hit" then
				out[#out + 1] = "|cff99ff99" .. p.s .. "|r"
			else
				out[#out + 1] = p.s
			end
		end
		prev, prevS = p.kind, p.s
	end
	-- 한자·가나를 뺀 풀이 (한 줄에 한자와 한글이 섞이면 게임 글꼴에서 한글이 깨지므로)
	local alt, prevAlt = {}, nil
	for _, p in ipairs(pieces) do
		local s2, k = p.s, p.kind
		if k == "miss" and s2:find("[\227-\233]") then s2, k = "…", "hit" end
		if k == "space" then
			if prevAlt and prevAlt ~= "space" then alt[#alt + 1] = " " end
		elseif not (s2 == "…" and alt[#alt] == "…") and not (s2 == "…" and alt[#alt] == " " and alt[#alt - 1] == "…") then
			if prevAlt and prevAlt ~= "space" and prevAlt ~= "other" and k ~= "other" and not (cjkOut and k == "hit" and prevAlt == "hit") then
				alt[#alt + 1] = " "
			end
			alt[#alt + 1] = s2
		end
		prevAlt = k
	end
	local total = coverHit + coverMiss
	return {
		plainNoCJK = table.concat(alt),
		rough = table.concat(out),
		plain = table.concat(plain),
		terms = terms,
		found = found,
		cover = total > 0 and floor(coverHit * 100 / total) or 0,
	}
end
ns.Gloss = Gloss

------------------------------------------------------------------------
-- 메시지 저장소
------------------------------------------------------------------------
local KEEP = 600
local entries, nextId = {}, 0
local lineCache, lineOrder = {}, {}

local function StripCodes(msg)
	msg = msg:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
	msg = msg:gsub("|T.-|t", ""):gsub("|A.-|a", "")
	return msg
end

local function PlainText(msg)
	return (StripCodes(msg):gsub("|H.-|h(.-)|h", "%1"):gsub("||", "|"))
end

local function DetectText(msg)
	-- 아이템·퀘스트 링크 이름은 내 클라이언트 언어로 보이므로 감지에서 뺀다
	return (StripCodes(msg):gsub("|H.-|h.-|h", ""))
end

local function NewEntry(text, lang, author)
	nextId = nextId + 1
	entries[nextId] = { text = text, lang = lang, author = author }
	entries[nextId - KEEP] = nil
	return nextId
end

local function CacheLine(lineID, value)
	if not lineID then return end
	if lineCache[lineID] == nil then
		lineOrder[#lineOrder + 1] = lineID
		if #lineOrder > KEEP then
			lineCache[table.remove(lineOrder, 1)] = nil
		end
	end
	lineCache[lineID] = value
end

local TAG_COLOR = { ko = "a0e8a0", zh = "ffcc66", ja = "ff99cc", ru = "99ccff", en = "cccccc" }
local myName

-- 상태 확인용 (/wct 상태)
ns.status = { method = "none", seen = 0, tagged = 0, lastError = nil, filterEvents = 0 }

-- 메시지 본문 하나를 처리해서 바뀐 본문을 돌려준다 (안 바꿀 땐 nil)
local function Process(msg, author)
	local db = ns.db
	if not db or not db.chat.enabled or type(msg) ~= "string" or msg == "" then return nil end
	if msg:find("|Hwct:", 1, true) then return nil end
	ns.status.seen = ns.status.seen + 1
	if db.chat.skipSelf and type(author) == "string" and author ~= "" then
		myName = myName or UnitName("player")
		if author:match("^[^%-]+") == myName then return nil end
	end
	local lang = Detect(DetectText(msg))
	if not lang or not db.chat.langs[lang] then return nil end
	local target = ns.GetTarget()
	if ns.SAME_SOURCE[target] == lang then return nil end

	local plainText = PlainText(msg)
	local id = NewEntry(plainText, lang, author)
	-- 아이템·퀘스트 링크 이름은 게임이 알아서 내 언어로 보여주므로 번역에서 뺀다
	local g = Gloss(DetectText(msg):gsub("||", "|"), lang, target)
	entries[id].gloss = g
	local body, wrapped = msg, false
	if db.chat.hoverAll and not msg:find("|", 1, true) then
		body = ("|Hwct:%d|h%s|h"):format(id, msg)
		wrapped = true
	end
	local tag = ""
	if db.chat.tag or not wrapped then
		tag = ("|cff%s|Hwct:%d|h[%s]|h|r "):format(TAG_COLOR[lang], id, L.tag[lang])
	end
	local suffix, separate = "", nil
	if db.chat.inline and g.found > 0 and g.cover >= (db.chat.minCover or 40) then
		-- 원문이 한자·가나인데 뜻이 한글(또는 그 반대)이면 한 줄에 섞지 않고 다음 줄에 따로 보여 준다
		local hanSource = (lang == "zh" or lang == "ja")
		local conflict = (hanSource and target == "ko") or (lang == "ko" and (target == "zhCN" or target == "zhTW"))
		if conflict then
			local meaning = (hanSource and g.plainNoCJK or g.plain):gsub("|", "||")
			separate = ("    |cff88dd88↳ %s|r"):format(meaning)
		else
			local meaning = g.plain:gsub("|", "||")
			suffix = (" |cff88dd88(%s)|r"):format(meaning)
		end
	end
	ns.status.tagged = ns.status.tagged + 1
	return tag .. body .. suffix, separate
end

local function NoteError(err)
	ns.status.lastError = tostring(err)
end

-- 방법 1: 채팅 메시지 필터 (권장)
local function Filter(self, event, msg, author, ...)
	local lineID = select(9, ...)
	local out, separate
	if lineID and lineCache[lineID] ~= nil then
		local cached = lineCache[lineID]
		if not cached then return false end
		out, separate = cached[1], cached[2]
	else
		local ok, o, sep = pcall(Process, msg, author)
		if not ok then NoteError(o) o, sep = nil, nil end
		out, separate = o, sep
		CacheLine(lineID, out and { out, separate } or false)
	end
	if not out then return false end
	if separate and self and self.AddMessage and C_Timer then
		-- 원래 메시지가 채팅창에 찍힌 바로 뒤에 같은 색으로 한 줄 더
		local info = ChatTypeInfo and ChatTypeInfo[(event or ""):sub(10)]
		C_Timer.After(0, function()
			pcall(self.AddMessage, self, separate, info and info.r, info and info.g, info and info.b)
		end)
	end
	return false, out, author, ...
end

local EVENTS = {
	"CHAT_MSG_CHANNEL", "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_EMOTE",
	"CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_WHISPER", "CHAT_MSG_BN_WHISPER",
}

local function GetAddFilter()
	if type(ChatFrame_AddMessageEventFilter) == "function" then
		return ChatFrame_AddMessageEventFilter
	end
	if type(ChatFrameUtil) == "table" and type(ChatFrameUtil.AddMessageEventFilter) == "function" then
		return function(ev, fn) return ChatFrameUtil.AddMessageEventFilter(ev, fn) end
	end
end

local function RegisterFilters()
	if ns.status.method == "filter" then return true end
	local add = GetAddFilter()
	if not add then return false end
	local count = 0
	for _, ev in ipairs(EVENTS) do
		local ok, err = pcall(add, ev, Filter)
		if ok then count = count + 1 else NoteError(err) end
	end
	ns.status.filterEvents = count
	if count > 0 then ns.status.method = "filter" return true end
	return false
end
-- 필터는 로그인 전에도 등록할 수 있으므로 파일을 읽을 때 바로 등록
pcall(RegisterFilters)

-- 방법 2: 필터 함수가 없는 클라이언트용 - 채팅창에 줄이 추가될 때 본문만 골라 처리
local function ProcessLine(text)
	local _, e = text:find("|Hplayer:.-|h.-|h")
	if not e then return nil end
	local rest = text:sub(e + 1)
	local sep, body = rest:match("^(.-:%s*)(.+)$")
	if not sep or #sep > 40 then return nil end
	local out, separate = Process(body, nil)
	if not out then return nil end
	return text:sub(1, e) .. sep .. out, separate
end

local function HookAddMessage(frame)
	if not frame or frame.wctOrigAddMessage or type(frame.AddMessage) ~= "function" then return end
	local orig = frame.AddMessage
	frame.wctOrigAddMessage = orig
	frame.AddMessage = function(self, text, ...)
		if type(text) == "string" and text:find("|Hplayer:", 1, true) then
			local ok, out, separate = pcall(ProcessLine, text)
			if ok and out then
				text = out
				if separate then
					local r = orig(self, text, ...)
					orig(self, separate, ...)
					return r
				end
			elseif not ok then NoteError(out) end
		end
		return orig(self, text, ...)
	end
end

local function HookAllAddMessage()
	for i = 1, (NUM_CHAT_WINDOWS or 10) do HookAddMessage(_G["ChatFrame" .. i]) end
	if CHAT_FRAMES then
		for _, name in ipairs(CHAT_FRAMES) do HookAddMessage(_G[name]) end
	end
end

------------------------------------------------------------------------
-- 툴팁
------------------------------------------------------------------------
local function ShowGloss(owner, id)
	local e = entries[id]
	if not e then return end
	e.gloss = e.gloss or Gloss(e.text, e.lang)
	local g = e.gloss
	GameTooltip:SetOwner(owner, "ANCHOR_CURSOR")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L.glossTitle:format(L.langName[e.lang]), 0.4, 0.8, 1)
	GameTooltip:AddLine(e.text, 1, 1, 1, true)
	if g.found > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.rough, 1, 0.82, 0)
		GameTooltip:AddLine(g.rough, 1, 1, 1, true)
		if #g.terms > 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L.terms, 1, 0.82, 0)
			for _, t in ipairs(g.terms) do
				GameTooltip:AddDoubleLine(t[1], t[2], 0.9, 0.9, 0.9, 0.6, 1, 0.6)
			end
		end
	else
		GameTooltip:AddLine(L.noTerms, 0.6, 0.6, 0.6)
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L.clickHint, 0.5, 0.5, 0.5)
	GameTooltip:Show()
end

local hooked = {}
local function HookFrame(frame)
	if not frame or hooked[frame] then return end
	hooked[frame] = true
	frame:HookScript("OnHyperlinkEnter", function(self, link)
		local id = type(link) == "string" and link:match("^wct:(%d+)")
		if id then ShowGloss(self, tonumber(id)) end
	end)
	frame:HookScript("OnHyperlinkLeave", function(self)
		if GameTooltip:GetOwner() == self then GameTooltip:Hide() end
	end)
end

local function HookAllFrames()
	for i = 1, (NUM_CHAT_WINDOWS or 10) do HookFrame(_G["ChatFrame" .. i]) end
	if CHAT_FRAMES then
		for _, name in ipairs(CHAT_FRAMES) do HookFrame(_G[name]) end
	end
end

------------------------------------------------------------------------
-- 복사창
------------------------------------------------------------------------
local copy
function ns.ShowCopy(text, title)
	if not copy then
		copy = CreateFrame("Frame", "WoWChatTranslatorCopy", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
		copy:SetSize(540, 96)
		copy:SetPoint("CENTER", 0, 120)
		copy:SetFrameStrata("DIALOG")
		copy:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true, tileSize = 32, edgeSize = 32,
			insets = { left = 11, right = 12, top = 12, bottom = 11 },
		})
		copy:EnableMouse(true)
		copy:SetMovable(true)
		copy:RegisterForDrag("LeftButton")
		copy:SetScript("OnDragStart", copy.StartMoving)
		copy:SetScript("OnDragStop", copy.StopMovingOrSizing)

		copy.title = copy:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		copy.title:SetPoint("TOP", 0, -18)

		local eb = CreateFrame("EditBox", nil, copy, "InputBoxTemplate")
		eb:SetSize(480, 24)
		eb:SetPoint("TOP", 0, -44)
		eb:SetAutoFocus(false)
		eb:SetMaxLetters(0)
		eb:SetScript("OnEscapePressed", function() copy:Hide() end)
		eb:SetScript("OnEnterPressed", function() copy:Hide() end)
		-- 읽기 전용처럼: 글자를 바꾸면 원래대로 되돌림
		eb:SetScript("OnTextChanged", function(self, userInput)
			if userInput and self:GetText() ~= copy.text then
				self:SetText(copy.text)
				self:HighlightText()
			end
		end)
		eb:SetScript("OnKeyUp", function(self, key)
			if key == "C" and IsControlKeyDown() then
				C_Timer.After(0.15, function() copy:Hide() end)
			end
		end)
		copy.eb = eb

		local close = CreateFrame("Button", nil, copy, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", -4, -4)

		tinsert(UISpecialFrames, "WoWChatTranslatorCopy")
	end
	copy.text = text
	copy.title:SetText(title or L.copyTitle)
	copy:Show()
	copy.eb:SetText(text)
	copy.eb:SetFocus()
	copy.eb:HighlightText()
	copy.eb:SetCursorPosition(0)
	copy.eb:HighlightText()
end

------------------------------------------------------------------------
-- 링크 클릭 처리 (wct: 링크만 가로채고 나머지는 원래대로)
------------------------------------------------------------------------
local function HookItemRef()
	local orig = SetItemRef
	SetItemRef = function(link, text, button, chatFrame, ...)
		if type(link) == "string" and link:sub(1, 4) == "wct:" then
			local e = entries[tonumber(link:match("^wct:(%d+)"))]
			if e then ns.ShowCopy(e.text) end
			return
		end
		return orig(link, text, button, chatFrame, ...)
	end
end

------------------------------------------------------------------------
-- 시작
------------------------------------------------------------------------
local prevLogin = ns.OnLogin
ns.OnLogin = function()
	if prevLogin then pcall(prevLogin) end
	if not RegisterFilters() then
		ns.status.method = "addmessage"
		HookAllAddMessage()
	end
	local ok, err = pcall(HookItemRef)
	if not ok then NoteError(err) end
	HookAllFrames()
	if FCF_OpenTemporaryWindow then
		hooksecurefunc("FCF_OpenTemporaryWindow", function()
			HookAllFrames()
			if ns.status.method == "addmessage" then HookAllAddMessage() end
		end)
	end
end

-- 상태 출력 (/wct 상태)
function ns.PrintStatus()
	local st = ns.status
	local p = function(s) DEFAULT_CHAT_FRAME:AddMessage("|cff66ccff[WCT]|r " .. s) end
	p("db=" .. tostring(ns.db ~= nil) .. "  enabled=" .. tostring(ns.db and ns.db.chat.enabled)
		.. "  method=" .. st.method .. "  filterEvents=" .. st.filterEvents)
	p("seen=" .. st.seen .. "  tagged=" .. st.tagged .. "  target=" .. tostring(ns.GetTarget())
		.. " (setting=" .. tostring(ns.db and ns.db.target) .. ", client=" .. tostring(GetLocale()) .. ")")
	p("ChatFrame_AddMessageEventFilter=" .. type(ChatFrame_AddMessageEventFilter)
		.. "  ChatFrameUtil=" .. type(ChatFrameUtil) .. "  SetItemRef=" .. type(SetItemRef))
	local sample = "lfg RF Quest"
	p("test: \"" .. sample .. "\" -> " .. tostring(Detect(sample)))
	if st.lastError then p("|cffff6666error:|r " .. st.lastError) end
end
