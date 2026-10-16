-- WoW Chat Translator: 내 메시지를 외국어로 (/wct en 문장), 나만의 단어 (/wct add 단어=뜻), 도구 창
local ADDON, ns = ...
local L = setmetatable({}, { __index = function(_, k) return ns.L[k] end })

local function Print(s) DEFAULT_CHAT_FRAME:AddMessage("|cff66ccff[WCT]|r " .. s) end
local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end

------------------------------------------------------------------------
-- 글자 종류로 원문 언어 고르기 (짧은 단어는 감지가 안 될 수 있어서)
------------------------------------------------------------------------
local function ScriptLang(text)
	if text:find("\234[\176-\191]") or text:find("\235") or text:find("\236") or text:find("\237[\128-\158]") or text:find("\227\132[\177-\191]") or text:find("\227\133") or text:find("\227\134[\128-\142]") then
		return "ko"
	end
	if text:find("\227\129") or text:find("\227\130") or text:find("\227\131") then return "ja" end
	if text:find("[\228-\233][\128-\191][\128-\191]") then return "zh" end
	if text:find("\208") or text:find("\209") then return "ru" end
	if text:find("%a") then return "en" end
end

------------------------------------------------------------------------
-- 나만의 단어
------------------------------------------------------------------------
local backup = {}   -- 덮어쓴 기본 사전 항목 (삭제하면 되돌림)
ns.customVersion = 0

local function LangsFor(term)
	local lang = ScriptLang(term)
	if lang == "en" then return { "en", "es" } end   -- 라틴 글자는 영어·스페인어 사전 모두에
	if lang then return { lang } end
	return {}
end

local function Put(lang, key, len, term, meaning)
	local dict = ns.Dict[lang]
	if not dict then dict = {}; ns.Dict[lang] = dict end
	local id = lang .. "\1" .. key
	if backup[id] == nil then backup[id] = dict[key] or false end
	dict[key] = { "", "", term, custom = meaning }
	if ns.DictMaxLen and (ns.DictMaxLen[lang] or 1) < len then ns.DictMaxLen[lang] = len end
end

local function Remove(lang, key)
	local dict = ns.Dict[lang]
	local id = lang .. "\1" .. key
	if dict then dict[key] = backup[id] or nil end
	backup[id] = nil
end

local RefreshCustomIndex

function ns.ApplyCustom()
	local db = ns.db
	if not db or not ns.Dict or not ns.NormKey then return end
	db.custom = db.custom or {}
	for lang, words in pairs(db.custom) do
		for key, w in pairs(words) do
			local _, len = ns.NormKey(w[1])
			Put(lang, key, len, w[1], w[2])
		end
	end
	RefreshCustomIndex()
	ns.customVersion = (ns.customVersion or 0) + 1
end

-- Explicit custom phrases may span script boundaries. Rebuild only on edits/login.
RefreshCustomIndex = function()
	local entries, prefixes, maxLen = {}, {}, 0
	for _, words in pairs(ns.db.custom or {}) do
		for key, w in pairs(words) do
			local _, len = ns.NormKey(w[1])
			entries[key] = { "", "", w[1], custom = w[2] }
			maxLen = math.max(maxLen, len)
			for i = 1, #key do prefixes[key:sub(1, i)] = true end
		end
	end
	ns.CustomEntries, ns.CustomPrefixes, ns.CustomMaxLen = entries, prefixes, maxLen
end

local function AddWord(arg)
	local term, meaning = arg:match("^(.-)%s*=%s*(.+)$")
	term = term and trim(term)
	if not term or term == "" or not meaning or trim(meaning) == "" then Print(L.addUsage) return end
	meaning = trim(meaning)
	local key, len = ns.NormKey(term)
	local langs = LangsFor(term)
	if key == "" or #langs == 0 then Print(L.addUsage) return end
	ns.db.custom = ns.db.custom or {}
	for _, lang in ipairs(langs) do
		ns.db.custom[lang] = ns.db.custom[lang] or {}
		ns.db.custom[lang][key] = { term, meaning }
		Put(lang, key, len, term, meaning)
	end
	RefreshCustomIndex()
	ns.customVersion = (ns.customVersion or 0) + 1
	Print(L.addDone:format(term, meaning))
end

local function DelWord(arg)
	local term = trim(arg or "")
	if term == "" then Print(L.addUsage) return end
	local key = ns.NormKey(term)
	local found = false
	for lang, words in pairs(ns.db.custom or {}) do
		if words[key] then
			words[key] = nil
			Remove(lang, key)
			found = true
		end
	end
	RefreshCustomIndex()
	ns.customVersion = (ns.customVersion or 0) + 1
	Print((found and L.delDone or L.delNone):format(term))
end

local function ListWords()
	local seen, lines = {}, {}
	for _, words in pairs(ns.db.custom or {}) do
		for key, w in pairs(words) do
			if not seen[key] then
				seen[key] = true
				lines[#lines + 1] = w[1] .. " = " .. w[2]
			end
		end
	end
	if #lines == 0 then Print(L.listEmpty) return end
	table.sort(lines)
	ns.ShowCopy(table.concat(lines, "\n"), L.listTitle:format(#lines))
end

------------------------------------------------------------------------
-- 내 메시지를 외국어로
------------------------------------------------------------------------
local OUT_CODES = {
	en = "en", eng = "en", ["영어"] = "en",
	zh = "zhCN", cn = "zhCN", ["중국어"] = "zhCN",
	tw = "zhTW",
	ru = "ru", ["러시아어"] = "ru",
	ja = "ja", jp = "ja", ["일본어"] = "ja",
	es = "es", ["스페인어"] = "es",
	ko = "ko", kr = "ko", ["한국어"] = "ko",
}
ns.OUT_CODES = OUT_CODES

-- 결과 문장 다듬기: 한자·가나 사이 공백 제거, 겹친 공백 정리
local function Tidy(s, target)
	s = s:gsub("%s+", " ")
	if target == "zhCN" or target == "zhTW" or target == "ja" then
		local prev
		repeat
			prev = s
			s = s:gsub("([\227-\233][\128-\191][\128-\191]) ([\227-\233][\128-\191][\128-\191])", "%1%2")
		until s == prev
	end
	return trim(s)
end

-- 엔진만 따로 (시험용으로도 씀): 결과 문장, 풀이 비율, 못 푼 부분
function ns.TranslateOutgoing(text, target)
	text = trim(text or "")
	if text == "" then return nil end
	local src = (ns.Detect and ns.Detect(text)) or ScriptLang(text) or ns.SAME_SOURCE[ns.CLIENT_TARGET]
	local g = ns.Gloss(text, src, target, { outgoing = true })
	if g and g.coverageTotal == 0 then return Tidy(g.plain, target), 100, {} end
	if not g or g.found == 0 then return nil, 0, {} end
	return Tidy(g.plain, target), g.cover or 0, g.unknown or {}
end

local function OpenChatWith(text)
	local function go()
		if ChatFrame_OpenChat then
			ChatFrame_OpenChat(text)
		elseif ChatEdit_GetActiveWindow and ChatEdit_GetActiveWindow() then
			ChatEdit_GetActiveWindow():Insert(text)
		end
	end
	-- 지금 입력창은 /wct 명령을 처리하는 중이라 한 박자 뒤에 연다
	if C_Timer and C_Timer.After then C_Timer.After(0, go) else go() end
end

local function Outgoing(target, text)
	if not text or trim(text) == "" then Print(L.outUsage) return end
	local out, cover, unknown = ns.TranslateOutgoing(text, target)
	if not out then Print(L.outNone) return end
	Print(L.outDone:format(ns.TARGET_NAME[target] or target, cover))
	if unknown and #unknown > 0 then Print(L.outLeft:format(table.concat(unknown, ", "))) end
	OpenChatWith(out)
end

------------------------------------------------------------------------
-- 도구 창 (설정창 버튼에서도 씀)
------------------------------------------------------------------------
function ns.ShowCollected()
	local lines = {}
	for _, v in pairs((ns.db and ns.db.collected) or {}) do lines[#lines + 1] = v end
	if #lines == 0 then Print(L.collectedEmpty) return end
	table.sort(lines)
	ns.ShowCopy(table.concat(lines, "\n"), L.collectedTitle:format(#lines))
end

function ns.ShowHelp()
	ns.ShowCopy(L.help, L.helpTitle)
end

-- 슬래시 명령 처리 (Options.lua 에서 부름). 처리했으면 true
function ns.ExtraCommand(raw)
	local cmd, rest = raw:match("^(%S+)%s*(.-)$")
	if not cmd then return false end
	local lc = cmd:lower()
	if lc == "add" or lc == "추가" then AddWord(rest) return true end
	if lc == "del" or lc == "delete" or lc == "삭제" then DelWord(rest) return true end
	if lc == "list" or lc == "목록" then ListWords() return true end
	if lc == "help" or lc == "도움말" or lc == "명령어" then ns.ShowHelp() return true end
	if lc == "collected" then ns.ShowCollected() return true end
	local target = OUT_CODES[lc]
	if target then Outgoing(target, rest) return true end
	return false
end

local prevLogin = ns.OnLogin
ns.OnLogin = function()
	if prevLogin then prevLogin() end
	pcall(ns.ApplyCustom)
end
