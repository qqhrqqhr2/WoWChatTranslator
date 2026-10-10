-- WoW Chat Translator: 툴팁 문장 자동 수집
-- 마우스를 올리지 않아도 주문책, 특성, 가방 아이템의 툴팁을 숨은 툴팁으로 읽어서
-- 번역하지 못한 영어 문장을 모아 둔다 (/wct 수집 으로 개수 확인).
local ADDON, ns = ...

local scanTip
local queue, running = {}, false
local PER_TICK = 8
local function Enabled()
	return ns.db and ns.db.tooltip and ns.db.tooltip.collect
end

local function Readable(v)
	if type(v) ~= "string" then return false end
	if issecretvalue then
		local ok, secret = pcall(issecretvalue, v)
		if not ok or secret then return false end
	end
	return true
end

local function GetScanTip()
	if not scanTip then
		scanTip = CreateFrame("GameTooltip", "WoWChatTranslatorScanTip", nil, "GameTooltipTemplate")
		scanTip:SetOwner(WorldFrame or UIParent, "ANCHOR_NONE")
	end
	return scanTip
end

-- 숨은 툴팁에 내용을 채운 뒤 줄마다 번역을 시도한다 (번역 못 한 문장은 Tooltip.lua 가 모은다)
local function ReadTip(setter)
	local tt = GetScanTip()
	tt:SetOwner(WorldFrame or UIParent, "ANCHOR_NONE")
	tt:ClearLines()
	if not pcall(setter, tt) then return end
	local target = ns.GetTarget()
	if target == "en" then target = "ko" end -- 영어 사용자도 수집은 한국어 기준으로
	for i = 1, tt:NumLines() do
		local fs = _G["WoWChatTranslatorScanTipTextLeft" .. i]
		local ok, text = pcall(function() return fs and fs:GetText() end)
		if ok and ns.IsTooltipBoundary and ns.IsTooltipBoundary(text) then break end
		if ok and Readable(text) and text ~= "" and ns.TranslateTooltipLine then
			pcall(ns.TranslateTooltipLine, text, target)
		end
	end
end

local function Pump()
	if not Enabled() then queue, running = {}, false; return end
	if #queue == 0 then running = false return end
	for _ = 1, PER_TICK do
		local job = table.remove(queue, 1)
		if not job then break end
		ReadTip(job)
	end
	C_Timer.After(0.05, Pump)
end

local function Enqueue(job)
	if not Enabled() then return end
	queue[#queue + 1] = job
	if not running and C_Timer then
		running = true
		C_Timer.After(0.5, Pump)
	end
end

------------------------------------------------------------------------
-- 주문책
------------------------------------------------------------------------
local function ScanSpellbook()
	if not Enabled() then return end
	local seen = {}
	local function addSpell(id)
		if type(id) == "number" and id > 0 and not seen[id] then
			seen[id] = true
			Enqueue(function(tt) tt:SetSpellByID(id) end)
		end
	end
	if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines and C_SpellBook.GetSpellBookItemInfo then
		for line = 1, C_SpellBook.GetNumSpellBookSkillLines() or 0 do
			local info = C_SpellBook.GetSpellBookSkillLineInfo(line)
			if info then
				for i = info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems do
					local ok, item = pcall(C_SpellBook.GetSpellBookItemInfo, i, Enum.SpellBookSpellBank.Player)
					if ok and item then addSpell(item.spellID or item.actionID) end
				end
			end
		end
	elseif GetNumSpellTabs and GetSpellTabInfo then
		for tab = 1, GetNumSpellTabs() do
			local _, _, offset, num = GetSpellTabInfo(tab)
			for i = (offset or 0) + 1, (offset or 0) + (num or 0) do
				local ok, _, id = pcall(GetSpellBookItemInfo, i, BOOKTYPE_SPELL or "spell")
				if ok then addSpell(id) end
			end
		end
	end
end

------------------------------------------------------------------------
-- 특성
------------------------------------------------------------------------
local function ScanTalents()
	if not Enabled() then return end
	if not (GetNumTalentTabs and GetNumTalents) then return end
	for tab = 1, GetNumTalentTabs() or 0 do
		for i = 1, GetNumTalents(tab) or 0 do
			Enqueue(function(tt) tt:SetTalent(tab, i) end)
		end
	end
end

------------------------------------------------------------------------
-- 가방 아이템
------------------------------------------------------------------------
local scannedItems = {}
local function ScanBags()
	if not Enabled() then return end
	local numSlots = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
	local itemID = (C_Container and C_Container.GetContainerItemID) or GetContainerItemID
	if not (numSlots and itemID) then return end
	for bag = 0, (NUM_BAG_SLOTS or 4) do
		for slot = 1, numSlots(bag) or 0 do
			local ok, id = pcall(itemID, bag, slot)
			if ok and type(id) == "number" and not scannedItems[id] then
				scannedItems[id] = true
				Enqueue(function(tt) tt:SetBagItem(bag, slot) end)
			end
		end
	end
end

------------------------------------------------------------------------
-- 이벤트
------------------------------------------------------------------------
local pendingBags, pendingSpells = false, false
function ns.ResetScan()
	queue = {}
	scannedItems = {}
end
local ev = CreateFrame("Frame")
ev:SetScript("OnEvent", function(self, event)
	if not Enabled() then return end
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		C_Timer.After(5, function() pcall(ScanSpellbook); pcall(ScanTalents); pcall(ScanBags) end)
	elseif event == "SPELLS_CHANGED" or event == "LEARNED_SPELL_IN_TAB" then
		if not pendingSpells then
			pendingSpells = true
			C_Timer.After(2, function() pendingSpells = false; pcall(ScanSpellbook) end)
		end
	elseif event == "BAG_UPDATE_DELAYED" or event == "BAG_UPDATE" then
		if not pendingBags then
			pendingBags = true
			C_Timer.After(3, function() pendingBags = false; pcall(ScanBags) end)
		end
	end
end)

local prevLogin = ns.OnLogin
ns.OnLogin = function()
	if prevLogin then prevLogin() end
	if not C_Timer then return end
	for _, e in ipairs({ "PLAYER_ENTERING_WORLD", "SPELLS_CHANGED", "LEARNED_SPELL_IN_TAB", "BAG_UPDATE_DELAYED" }) do
		pcall(ev.RegisterEvent, ev, e)
	end
end
