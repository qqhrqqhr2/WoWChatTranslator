-- WoW Chat Translator: 툴팁 번역
-- 아이템·주문 툴팁에 남아 있는 영어 문장(포에버 신규 아이템 등)을 현지 언어로 옮겨
-- 툴팁 아래 "WoW Chat Translator" 칸에 보여준다.
-- 번역 순서: 1) 문장표(직접 만든 표 → 게임 데이터 표)  2) 비슷한 문장  3) 문장 패턴  4) 단어 사전 풀이
-- 1)·2)로 번역하지 못한 문장은 저장 파일에 모아 두었다가 문장표에 추가한다.
local ADDON, ns = ...
local L = setmetatable({}, { __index = function(_, k) return ns.L[k] end })

local COLLECT_MAX = 3000
local HEADER = "WoW Chat Translator"

------------------------------------------------------------------------
-- 안전하게 글자 읽기 (포에버 클라이언트는 보안 값을 줄 때가 있다)
------------------------------------------------------------------------
local function Readable(v)
	if type(v) ~= "string" then return false end
	if issecretvalue then
		local ok, secret = pcall(issecretvalue, v)
		if not ok or secret then return false end
	end
	return true
end

------------------------------------------------------------------------
-- 문장 정리: 소문자, 시간 단위 통일, 숫자 → #
------------------------------------------------------------------------
local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end

-- 색상(|cff..|r), 아이콘(|T..|t, |A..|a), 링크(|H..|h) 코드를 지운다
local function StripCodes(s)
	s = s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
	s = s:gsub("|T.-|t", ""):gsub("|A.-|a", ""):gsub("|H.-|h(.-)|h", "%1")
	-- 붙지 않는 공백(NBSP)·줄바꿈 문자는 보통 공백으로
	s = s:gsub("\194\160", " "):gsub("\r", ""):gsub("\n", " ")
	return s
end

-- 게임이 현지화해 끼워 넣은 시간 단위("1 시간", "1시간")와 영어 단위를 hr/min/sec 로 맞춘다
local UNIT_FIX = {
	{ "(%d+)%s*시간", "%1 hr" }, { "(%d+)%s*분", "%1 min" }, { "(%d+)%s*초", "%1 sec" },
	{ "(%d+)%s*小时", "%1 hr" }, { "(%d+)%s*小時", "%1 hr" }, { "(%d+)%s*分钟", "%1 min" }, { "(%d+)%s*分鐘", "%1 min" }, { "(%d+)%s*秒", "%1 sec" },
	{ "(%d+)%s*ч%.?", "%1 hr" }, { "(%d+)%s*мин%.?", "%1 min" }, { "(%d+)%s*сек%.?", "%1 sec" },
	{ "(%d+)%s+hours?", "%1 hr" }, { "(%d+)%s+hrs?", "%1 hr" },
	{ "(%d+)%s+minutes?", "%1 min" }, { "(%d+)%s+mins?", "%1 min" },
	{ "(%d+)%s+seconds?", "%1 sec" }, { "(%d+)%s+secs?", "%1 sec" },
}

local function Canon(s)
	s = s:lower():gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
	-- 줄바꿈·겹친 공백·붙지 않는 공백(NBSP)을 한 칸으로
	s = s:gsub("\194\160", " "):gsub("\\n", " "):gsub("%s+", " ")
	for _, u in ipairs(UNIT_FIX) do s = s:gsub(u[1], u[2]) end
	s = trim(s)
	s = trim(s:gsub('^"', ""):gsub('"$', ""))
	s = s:gsub("[%.!]+$", "")
	return s
end

-- 숫자를 꺼내고 # 로 바꾼 열쇠를 만든다
local function KeyOf(canon)
	local nums = {}
	local key = canon:gsub("%d+%.?%d*", function(n) nums[#nums + 1] = n; return "#" end)
	return key, nums
end

local function Fill(tpl, nums)
	return (tpl:gsub("{(%d)}", function(i) return nums[tonumber(i)] or "?" end))
end

------------------------------------------------------------------------
-- 비슷한 문장 찾기: 겹치는 단어 비율(Jaccard)이 높은 게임 데이터 문장
------------------------------------------------------------------------
local STOP = {}
for w in ("a an the of to and or in on by for with your you is are be it its this that from as at into"):gmatch("%S+") do STOP[w] = true end
local fuzzyIndex, fuzzySize
-- 이 단어가 한쪽에만 있으면 뜻이 달라지므로 비슷한 문장으로 치지 않는다
local KEYWORD = {}
for w in ([[attack healing heal spell spells stamina strength agility intellect spirit mana health energy rage
	fire frost nature shadow arcane holy physical damage armor critical crit hit dodge parry block speed movement
	defense resistance haste power ranged melee weapon shield bear cat moonkin travel aquatic party raid enemy
	enemies friendly target targets increases increased decreases decreased reduces reduced]]):gmatch("%S+") do KEYWORD[w] = true end

local function BuildFuzzy()
	fuzzyIndex, fuzzySize = {}, {}
	for i, e in ipairs(ns.TipDBFuzzy or {}) do
		local n = 0
		for w in e[1]:gmatch("%S+") do
			n = n + 1
			local list = fuzzyIndex[w]
			if not list then list = {}; fuzzyIndex[w] = list end
			list[#list + 1] = i
		end
		fuzzySize[i] = n
	end
end

function ns.FindSimilar(key, target)
	if not ns.TipDBFuzzy then return nil end
	if not fuzzyIndex then BuildFuzzy() end
	local words, nq = {}, 0
	for w in key:gmatch("[%a']+") do
		if #w > 1 and not STOP[w] and not words[w] then words[w] = true; nq = nq + 1 end
	end
	if nq < 4 then return nil end
	local sigParts = {}
	for pct in key:gmatch("#(%%?)") do sigParts[#sigParts + 1] = (pct == "%") and "p" or "n" end
	local sig = table.concat(sigParts, ",")
	local count = {}
	for w in pairs(words) do
		local list = fuzzyIndex[w]
		if list and #list <= 600 then
			for _, i in ipairs(list) do count[i] = (count[i] or 0) + 1 end
		end
	end
	local best, bestScore = nil, 0
	for i, c in pairs(count) do
		if c >= 4 then
			local score = c / (nq + fuzzySize[i] - c)
			local e = ns.TipDBFuzzy[i]
			if score > bestScore and e[2][target] and (e[3] or "") == sig then best, bestScore = i, score end
		end
	end
	if not best or bestScore < 0.85 then return nil end
	-- 서로 다른 단어 중에 핵심 단어가 있으면 버린다
	local cand = {}
	for w in ns.TipDBFuzzy[best][1]:gmatch("%S+") do cand[w] = true end
	for w in pairs(words) do if not cand[w] and KEYWORD[w] then return nil end end
	for w in pairs(cand) do if not words[w] and KEYWORD[w] then return nil end end
	return ns.TipDBFuzzy[best][2][target]
end

------------------------------------------------------------------------
-- 이름 번역 (아이템·주문 이름): 이름표 → 단어 사전(모든 단어를 알 때만)
------------------------------------------------------------------------
local function TranslateName(name, target)
	local n = trim(name):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
	local e = ns.TipNames and ns.TipNames[n:lower()]
	if e and e[target] then return e[target], true end
	e = ns.TipDBNames and ns.TipDBNames[n:lower()]
	if e and e[target] then return e[target], true end
	if not (ns.Gloss and n:find("%a")) then return nil end
	local function full(x)
		local g = ns.Gloss(x, "en", target)
		if g and g.found > 0 and g.cover >= 100 then
			-- 중국어 이름은 띄어쓰기 없이
			if target == "zhCN" or target == "zhTW" then return (g.plain:gsub(" ", "")) end
			return g.plain
		end
	end
	-- "X of the Bear" → 한국어 "곰의 X", 중국어 "熊之X"
	local head, tail = n:match("^(.+) of the (.+)$")
	if not head then head, tail = n:match("^(.+) of (.+)$") end
	if head then
		local h, t = full(head), full(tail)
		if h and t then
			if target == "ko" then return t .. "의 " .. h, false end
			if target == "zhCN" or target == "zhTW" then return t .. "之" .. h, false end
			return h .. " " .. t, false
		end
	end
	local g = full(n)
	if g then return g, false end
	return nil
end
ns.TranslateName = TranslateName

------------------------------------------------------------------------
-- 한 문장 번역
-- 반환: 번역문, 방식("exact"/"pattern"/"gloss"), 또는 nil
------------------------------------------------------------------------
local function TranslatePiece(piece, target)
	local canon = Canon(piece)
	if canon == "" then return nil end
	local key, nums = KeyOf(canon)

	-- 1) 문장표 (직접 만든 표 → 게임 데이터 표)
	local e = ns.TipText and ns.TipText[key]
	if e and e[target] then return Fill(e[target], nums), "exact" end
	e = ns.TipDBText and ns.TipDBText[key]
	if e and e[target] then return Fill(e[target], nums), "exact" end

	-- 2) 비슷한 문장 찾기 (게임 데이터 표, 표현이 조금 다른 경우)
	local fz = ns.FindSimilar and ns.FindSimilar(key, target)
	if fz then
		local out = Fill(fz, nums)
		if not out:find("?", 1, true) then return out, "similar" end
	end

	-- 3) 패턴
	if ns.TipPatterns then
		for _, p in ipairs(ns.TipPatterns) do
			local caps = { canon:match(p[1]) }
			if caps[1] ~= nil and p[2][target] then
				-- %=1 처럼 쓰면 잡은 부분을 번역하지 않고 원문 대소문자 그대로 둔다 (주문 이름 등)
				local low = trim(piece):lower()
				local raw = p[2][target]:gsub("%%=(%d)", function(i)
					local c = caps[tonumber(i)] or ""
					local st = low:find(c, 1, true)
					local orig = st and trim(piece):sub(st, st + #c - 1) or c
					local e = (ns.TipNames and ns.TipNames[c]) or (ns.TipDBNames and ns.TipDBNames[c])
					return (e and e[target]) or orig
				end)
				local out = raw:gsub("%%(%d)", function(i)
					local c = caps[tonumber(i)] or ""
					if c:find("%a") and ns.Gloss then
						-- 글자로 된 부분은 사전으로 다시 풀어 준다
						local g = ns.Gloss(c, "en", target)
						if g and g.found > 0 then return g.plain end
					end
					return c
				end)
				out = out:gsub("%%%%", "%%")
				return out, "pattern"
			end
		end
	end

	-- 4) 단어 사전 풀이: 아는 단어가 하나라도 있으면 보여 준다 (연한 색으로 표시)
	local words = 0
	for _ in canon:gmatch("%a+") do words = words + 1 end
	if words >= 2 and ns.Gloss then
		local g = ns.Gloss(piece, "en", target)
		if g and g.found > 0 then return g.plain, "gloss" end
	end
	return nil
end

------------------------------------------------------------------------
-- 툴팁 한 줄에 영어가 남아 있는지 (한글 등이 섞여 있어도 영어 단어가 있으면 대상)
------------------------------------------------------------------------
local function EnglishWords(text)
	-- 다른 애드온이 붙인 "Item ID 12345", "아이템ID: 123" 같은 줄은 제외
	local low = text:lower()
	if low:find("id[%s:]*%d") then return 0 end
	local n = 0
	for w in text:gmatch("%a+") do
		if #w >= 2 then n = n + 1 end
	end
	return n
end

-- 이름이 영어인지 (한글·한자가 하나도 없을 것)
local function LooksEnglishName(text)
	return not text:find("[\228-\239][\128-\191][\128-\191]") and text:find("%a%a") ~= nil
end

-- 영어 문장으로 볼 만한지 (모으기 기준): 영어 글자가 한글·한자보다 충분히 많을 것
local function LooksEnglish(piece)
	local latin = select(2, piece:gsub("%a", ""))
	local other = select(2, piece:gsub("[\228-\239][\128-\191][\128-\191]", ""))
	return latin >= 6 and latin > other * 3
end

-- 게임이 붙인 머리말("사용 효과:", "착용 효과:")은 떼고 번역한 뒤 다시 붙인다
local function SplitPrefix(text)
	local kinds = { ITEM_SPELL_TRIGGER_ONUSE = "use", ITEM_SPELL_TRIGGER_ONEQUIP = "equip", ITEM_SPELL_TRIGGER_ONPROC = "proc" }
	for g, kind in pairs(kinds) do
		local p = _G[g]
		if type(p) == "string" and p ~= "" and text:sub(1, #p) == p then
			return kind, trim(text:sub(#p + 1))
		end
	end
	local en, rest = text:match("^(%a[%a ]-:)%s*(.+)$")
	local map = { ["Use:"] = "use", ["Equip:"] = "equip", ["Chance on hit:"] = "proc" }
	if en and map[en] then return map[en], rest end
	return nil, text
end

-- 문장 단위로 나누기 (". " 기준, 소수점은 건드리지 않음)
local function Sentences(text)
	local out, buf = {}, text
	while true do
		-- 한국어 문장 뒤에 영어가 이어지는 경우도 나눈다 (소수점 1.5 는 공백이 없어서 안 나뉨)
		local s, e = buf:find("[%.!%?]%s+[^%s%d]")
		if not s then break end
		out[#out + 1] = buf:sub(1, s)
		buf = buf:sub(e)
	end
	out[#out + 1] = buf
	return out
end

------------------------------------------------------------------------
-- 미번역 문장 모으기
------------------------------------------------------------------------
local function Collect(piece)
	local db = ns.db
	if not db or not db.tooltip or not db.tooltip.collect then return end
	if not LooksEnglish(piece) then return end
	db.collected = db.collected or {}
	local key = KeyOf(Canon(piece))
	if db.collected[key] then return end
	db.collectedCount = (db.collectedCount or 0) + 1
	if db.collectedCount > COLLECT_MAX then return end
	db.collected[key] = trim(piece)
end

------------------------------------------------------------------------
-- 한 줄 번역 (결과 캐시)
------------------------------------------------------------------------
local cache, cacheTarget = {}, nil

local function TranslateLine(text, target)
	if cacheTarget ~= target then cache, cacheTarget = {}, target end
	local c = cache[text]
	if c ~= nil then return c or nil end
	local original = text
	text = trim(StripCodes(text))
	if EnglishWords(text) == 0 then cache[original] = false return nil end

	local prefix, body = SplitPrefix(text)
	local parts, full = {}, true
	local wholeKey, wholeNums = KeyOf(Canon(body))
	local whole = (ns.TipText and ns.TipText[wholeKey]) or (ns.TipDBText and ns.TipDBText[wholeKey])
	local pieces = Sentences(body)
	if whole and whole[target] then
		parts[1] = Fill(whole[target], wholeNums)
		pieces = {}
	elseif #pieces > 1 then
		-- 문단 전체가 조금 다른 경우: 비슷한 문단 찾기
		local fz = ns.FindSimilar and ns.FindSimilar(wholeKey, target)
		if fz then
			local out = Fill(fz, wholeNums)
			if not out:find("?", 1, true) then parts[1] = out; pieces = {} end
		end
	end
	-- 이어지는 문장 몇 개를 묶어야 표에 있는 경우 (게임 데이터는 문단 단위로 들어 있는 것이 많다)
	local merged, i = {}, 1
	while i <= #pieces do
		local hit
		for j = #pieces, i + 1, -1 do
			local k, nums = KeyOf(Canon(table.concat(pieces, " ", i, j)))
			local e = (ns.TipText and ns.TipText[k]) or (ns.TipDBText and ns.TipDBText[k])
			if e and e[target] then hit = { done = Fill(e[target], nums) }; i = j + 1; break end
		end
		if not hit then hit = pieces[i]; i = i + 1 end
		merged[#merged + 1] = hit
	end
	for _, piece in ipairs(merged) do
		if type(piece) == "table" then
			parts[#parts + 1] = piece.done
		elseif EnglishWords(piece) > 0 then
			local tr, how = TranslatePiece(piece, target)
			if tr then
				parts[#parts + 1] = tr
				if how == "gloss" then full = false; Collect(piece) end
			else
				full = false
				Collect(piece)
				-- 번역이 전혀 안 되는 문장은 원문 그대로 둔다
				parts[#parts + 1] = { raw = trim(piece) }
			end
		end
	end
	local any = false
	for i, p in ipairs(parts) do
		if type(p) == "table" then parts[i] = p.raw else any = true end
	end
	local result = false
	if any then
		local cjk = (target == "zhCN" or target == "zhTW")
		if #parts > 1 then
			-- 문장 사이에 마침표가 빠지지 않게
			for i = 1, #parts - 1 do
				if not parts[i]:find("[%.!%?。！？…%)]$") and not parts[i]:find("\227\128\130$") then
					parts[i] = parts[i] .. (cjk and "。" or ".")
				end
			end
		end
		local joined = table.concat(parts, cjk and "" or " ")
		if prefix then
			-- 머리말도 현지 언어로
			local localPrefix = (prefix == "use" and L.tipUse) or (prefix == "equip" and L.tipEquip) or L.tipProc
			joined = localPrefix .. " " .. joined
		end
		result = { text = joined, full = full }
	end
	cache[original] = result
	return result or nil
end
ns.TranslateTooltipLine = TranslateLine

------------------------------------------------------------------------
-- 툴팁에 붙이기
------------------------------------------------------------------------
local function Process(tooltip)
	local db = ns.db
	if not db or not db.tooltip or not db.tooltip.enabled then return end
	local target = ns.GetTarget()
	if target == "en" then return end  -- 원문이 영어라 영어 사용자는 번역할 필요 없음
	if tooltip.wctDone then return end
	-- 캐릭터·NPC(유닛) 툴팁은 번역하지 않는다
	if tooltip.GetUnit then
		local ok, _, unit = pcall(tooltip.GetUnit, tooltip)
		if ok and unit then return end
	end
	local name = tooltip.GetName and tooltip:GetName()
	if not name then return end
	local n = tooltip.NumLines and tooltip:NumLines() or 0
	local out = {}
	for i = 1, n do
		local fs = _G[name .. "TextLeft" .. i]
		local ok, text = pcall(function() return fs and fs:GetText() end)
		if ok and Readable(text) then text = trim(StripCodes(text)) end
		if i == 1 and ok and Readable(text) and text ~= "" then
			-- 첫 줄은 이름: 영어 이름이면 번역해서 "번역 (원문)" 으로
			local okc, cnt = pcall(EnglishWords, text)
			if okc and cnt > 0 and LooksEnglishName(text) then
				local okn, tr, full = pcall(TranslateName, text, target)
				if okn and tr then
					out[#out + 1] = { text = tr .. " |cff999999(" .. trim(text) .. ")|r", full = full, name = true }
				else
					pcall(Collect, text)
				end
			end
		elseif ok and Readable(text) and text ~= "" and text ~= HEADER then
			local okc, cnt = pcall(EnglishWords, text)
			if okc and cnt > 0 then
				local okt, r = pcall(TranslateLine, text, target)
				if okt and r then out[#out + 1] = r end
			end
		end
	end
	if #out == 0 then return end
	tooltip.wctDone = true
	tooltip:AddLine(" ")
	tooltip:AddLine(HEADER, 0.4, 0.8, 1)
	for _, r in ipairs(out) do
		if r.name then
			tooltip:AddLine(r.text, 1, 0.82, 0, true)
		elseif r.full then
			tooltip:AddLine(r.text, 0.6, 1, 0.6, true)
		else
			tooltip:AddLine(r.text, 0.62, 0.8, 0.62, true)
		end
	end
	tooltip:Show()
end

local hooked = {}
-- 툴팁 내용을 채우는 함수들 (TooltipDataProcessor 가 없는 클라이언트용)
local SETTERS = {
	"SetAction", "SetBagItem", "SetInventoryItem", "SetHyperlink", "SetItemByID", "SetSpellByID",
	"SetSpellBookItem", "SetShapeshift", "SetPetAction", "SetTalent", "SetUnitAura", "SetUnitBuff",
	"SetUnitDebuff", "SetTotem", "SetTrainerService", "SetCraftSpell", "SetCraftItem", "SetTradeSkillItem",
	"SetMerchantItem", "SetBuybackItem", "SetLootItem", "SetLootRollItem", "SetQuestItem", "SetQuestLogItem",
	"SetQuestRewardSpell", "SetQuestLogRewardSpell", "SetAuctionItem", "SetInboxItem", "SetSendMailItem",
	"SetTradePlayerItem", "SetTradeTargetItem", "SetMountBySpellID", "SetToyByItemID", "SetCompanionPet",
}

local function HookTooltip(tt, useSetters)
	if not tt or hooked[tt] then return end
	hooked[tt] = true
	tt:HookScript("OnTooltipCleared", function(self) self.wctDone = nil end)
	-- 마지막 안전망: 툴팁이 보일 때 한 번 더 확인
	tt:HookScript("OnShow", function(self) pcall(Process, self) end)
	if useSetters then
		pcall(tt.HookScript, tt, "OnTooltipSetItem", Process)
		pcall(tt.HookScript, tt, "OnTooltipSetSpell", Process)
		for _, fn in ipairs(SETTERS) do
			if type(tt[fn]) == "function" then
				pcall(hooksecurefunc, tt, fn, function(self) pcall(Process, self) end)
			end
		end
	end
end

local function Setup()
	local processor = TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType
	for _, tt in ipairs({ GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2,
		ItemRefShoppingTooltip1, ItemRefShoppingTooltip2, EmbeddedItemTooltip }) do
		-- 특성창 등 일부 툴팁은 데이터 처리기를 거치지 않아서 채우는 함수에도 항상 연결 (중복은 wctDone 으로 막음)
		pcall(HookTooltip, tt, true)
	end
	if processor then
		local function post(tt, data)
			-- 유닛(캐릭터·NPC 이름) 툴팁은 제외
			if data and Enum.TooltipDataType.Unit and data.type == Enum.TooltipDataType.Unit then return end
			pcall(Process, tt)
		end
		if TooltipDataProcessor.AllTypes then
			TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, post)
		else
			for name, id in pairs(Enum.TooltipDataType) do
				if name ~= "Unit" and type(id) == "number" then
					pcall(TooltipDataProcessor.AddTooltipPostCall, id, post)
				end
			end
		end
	end
end

------------------------------------------------------------------------
-- 수집 명령 (/wct 수집, /wct 수집 초기화)
------------------------------------------------------------------------
function ns.CollectCommand(arg)
	local db = ns.db
	if not db then return end
	local p = function(s) DEFAULT_CHAT_FRAME:AddMessage("|cff66ccff[WCT]|r " .. s) end
	if arg == "clear" or arg == "초기화" or arg == "reset" then
		db.collected, db.collectedCount = {}, 0
		p(L.collectCleared)
		return
	end
	local n = 0
	for _ in pairs(db.collected or {}) do n = n + 1 end
	p(L.collectCount:format(n))
	p(L.collectHow)
end

local prevLogin = ns.OnLogin
ns.OnLogin = function()
	if prevLogin then prevLogin() end
	local ok, err = pcall(Setup)
	if not ok and ns.status then ns.status.lastError = "tooltip: " .. tostring(err) end
end
