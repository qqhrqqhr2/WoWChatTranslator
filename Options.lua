-- WoW Chat Translator: 설정창 (/wct)
-- 왼쪽: 현지 언어·채팅 번역 / 오른쪽: 번역할 언어·채널·툴팁·기타 / 아래: 도구 버튼
-- 현지 언어를 바꾸면 화면 문구도 바로 그 언어로 바뀐다.
local ADDON, ns = ...
local L = setmetatable({}, { __index = function(_, k) return ns.L[k] end })

local frame
local ICON = "Interface\\AddOns\\" .. ADDON .. "\\Media\\icon"

local FRAME_W = 840
local LEFT, RIGHT = 22, 432      -- 두 칸의 시작 x
local COL_W = 390                -- 한 칸 너비
local HALF = 195                 -- 칸 안의 두 줄 배치 간격
local ROW = 24

local texts = {}      -- { 글자 오브젝트, 문구를 만드는 함수 }
local checks = {}     -- 체크박스·라디오 (창이 열릴 때 값 다시 읽기)
local langChecks = {}

local function Track(obj, fn)
	texts[#texts + 1] = { obj, fn }
	obj:SetText(fn())
	return obj
end

-- 체크박스 (radio=true 이면 동그란 라디오 버튼)
local function Check(parent, labelFn, x, y, get, set, maxW, radio)
	local cb
	if radio then
		local ok, r = pcall(CreateFrame, "CheckButton", nil, parent, "UIRadioButtonTemplate")
		if ok and r then cb = r; cb:SetSize(20, 20) end
	end
	if not cb then
		cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
		cb:SetSize(26, 26)
	end
	cb:SetPoint("TOPLEFT", radio and x + 3 or x, radio and y - 3 or y)
	if type(cb.text) == "table" and cb.text.SetText then cb.text:SetText("") end
	if type(cb.Text) == "table" and cb.Text.SetText then cb.Text:SetText("") end
	local fs = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	fs:SetPoint("LEFT", cb, "RIGHT", radio and 5 or 2, 1)
	fs:SetJustifyH("LEFT")
	if maxW then
		fs:SetWidth(maxW)
		if fs.SetWordWrap then fs:SetWordWrap(false) end
	end
	Track(fs, labelFn)
	cb.label = fs
	cb.get = get
	cb:SetScript("OnClick", function(self) set(self:GetChecked() and true or false) end)
	checks[#checks + 1] = cb
	return cb
end

local function Header(parent, key, x, y)
	local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	fs:SetPoint("TOPLEFT", x - 4, y)
	fs:SetWidth(COL_W)
	fs:SetJustifyH("LEFT")
	if fs.SetWordWrap then fs:SetWordWrap(false) end
	return Track(fs, function() return L[key] end)
end

local function Note(parent, key, x, y)
	local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	fs:SetPoint("TOPLEFT", x, y)
	fs:SetWidth(COL_W - 20)
	fs:SetJustifyH("LEFT")
	fs:SetJustifyV("TOP")
	return Track(fs, function() return L[key] end)
end

local function Button(parent, key, w)
	local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	b:SetSize(w or 140, 24)
	Track(b, function() return L[key] end)
	return b
end

local RefreshAll

-- 번역할 언어: 현지 언어와 같은 언어는 끄고 흐리게 (저장된 값은 그대로 둔다)
local function LayoutLangs()
	local same = ns.SAME_SOURCE[ns.GetTarget()]
	for _, lc in ipairs(langChecks) do
		if lc.lang == same then
			lc:SetChecked(false)
			if lc.Disable then lc:Disable() end
			lc.label:SetTextColor(0.45, 0.45, 0.45)
		else
			if lc.Enable then lc:Enable() end
			lc:SetChecked(ns.db.chat.langs[lc.lang] and true or false)
			lc.label:SetTextColor(1, 1, 1)
		end
	end
end

local function SetTarget(value)
	ns.db.target = value
	ns.ApplyTarget()
	RefreshAll()
end

local function Build()
	frame = CreateFrame("Frame", "WoWChatTranslatorOptions", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	frame:SetSize(FRAME_W, 600)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 },
	})
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	tinsert(UISpecialFrames, "WoWChatTranslatorOptions")

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", 14, -18)
	Track(title, function() return L.title end)
	local icon = frame:CreateTexture(nil, "ARTWORK")
	icon:SetTexture(ICON)
	icon:SetSize(28, 28)
	icon:SetPoint("RIGHT", title, "LEFT", -6, 0)

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)

	-- 두 칸 사이 세로 구분선
	local line = frame:CreateTexture(nil, "ARTWORK")
	line:SetColorTexture(1, 1, 1, 0.12)
	line:SetSize(1, 420)
	line:SetPoint("TOPLEFT", RIGHT - 16, -54)

	local db = ns.db
	local LW = COL_W - 40           -- 한 줄짜리 체크박스 글자 너비
	local HW = HALF - 36            -- 두 줄 배치 체크박스 글자 너비

	-- 왼쪽 칸 ==============================================================
	local y = -52
	Header(frame, "secTarget", LEFT, y); y = y - 26
	local function radio(value, x, yy, w)
		local labelFn
		if value == "auto" then
			labelFn = function() return L.auto:format(ns.TARGET_NAME[ns.CLIENT_TARGET]) end
		else
			labelFn = function() return ns.TARGET_NAME[value] end
		end
		Check(frame, labelFn, x, yy,
			function() return (db.target or "auto") == value end,
			function() SetTarget(value) end, w, true)
	end
	radio("auto", LEFT, y, LW); y = y - ROW
	local order = { "ko", "en", "zhCN", "zhTW", "ja", "ru", "es" }
	for i, t in ipairs(order) do
		radio(t, LEFT + ((i - 1) % 2) * HALF, y - math.floor((i - 1) / 2) * ROW, HW)
	end
	y = y - 4 * ROW - 4
	Note(frame, "targetNote", LEFT + 4, y); y = y - 40

	Header(frame, "secChat", LEFT, y); y = y - 26
	Check(frame, function() return L.optEnabled end, LEFT, y, function() return db.chat.enabled end, function(v) db.chat.enabled = v end, LW); y = y - ROW
	Check(frame, function() return L.optInline end, LEFT, y, function() return db.chat.inline end, function(v) db.chat.inline = v end, LW); y = y - ROW - 2

	-- 최소 풀이 비율 (- / + 버튼)
	local minus = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	minus:SetSize(24, 22); minus:SetText("-")
	minus:SetPoint("TOPLEFT", LEFT + 28, y)
	minus:SetScript("OnClick", function()
		db.chat.minCover = math.max(0, (db.chat.minCover or 40) - 10); RefreshAll()
	end)
	local plus = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	plus:SetSize(24, 22); plus:SetText("+")
	plus:SetPoint("LEFT", minus, "RIGHT", 4, 0)
	plus:SetScript("OnClick", function()
		db.chat.minCover = math.min(100, (db.chat.minCover or 40) + 10); RefreshAll()
	end)
	local cover = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	cover:SetPoint("LEFT", plus, "RIGHT", 8, 0)
	cover:SetWidth(COL_W - 100)
	cover:SetJustifyH("LEFT")
	if cover.SetWordWrap then cover:SetWordWrap(false) end
	Track(cover, function() return L.optCover:format(db.chat.minCover or 40) end)
	y = y - ROW - 4

	Check(frame, function() return L.optTag end, LEFT, y, function() return db.chat.tag end, function(v) db.chat.tag = v end, LW); y = y - ROW
	Check(frame, function() return L.optHover end, LEFT, y, function() return db.chat.hoverAll end, function(v) db.chat.hoverAll = v end, LW); y = y - ROW
	Check(frame, function() return L.optSelf end, LEFT, y, function() return db.chat.skipSelf end, function(v) db.chat.skipSelf = v end, LW); y = y - ROW
	Check(frame, function() return L.optPlayerTip end, LEFT, y, function() return db.chat.playerTip ~= false end, function(v) db.chat.playerTip = v end, LW); y = y - ROW - 4
	Note(frame, "chatNote", LEFT + 4, y); y = y - 30
	local leftBottom = y

	-- 오른쪽 칸 ============================================================
	y = -52
	Header(frame, "secLangs", RIGHT, y); y = y - 26
	for i, lang in ipairs({ "ko", "zh", "ja", "ru", "en", "es" }) do
		local cb = Check(frame, function() return L.langName[lang] end,
			RIGHT + ((i - 1) % 2) * HALF, y - math.floor((i - 1) / 2) * ROW,
			function() return db.chat.langs[lang] end,
			function(v) db.chat.langs[lang] = v end, HW)
		cb.lang = lang
		langChecks[#langChecks + 1] = cb
	end
	y = y - 3 * ROW - 8

	Header(frame, "secChannels", RIGHT, y); y = y - 26
	for _, kind in ipairs({ "public", "say", "guild", "group", "whisper" }) do
		local key = "ch" .. kind:sub(1, 1):upper() .. kind:sub(2)
		Check(frame, function() return L[key] end, RIGHT, y,
			function() return db.chat.channels[kind] ~= false end,
			function(v) db.chat.channels[kind] = v end, LW)
		y = y - ROW
	end
	y = y - 8

	Header(frame, "secTooltip", RIGHT, y); y = y - 26
	Check(frame, function() return L.optTooltip end, RIGHT, y, function() return db.tooltip.enabled end, function(v) db.tooltip.enabled = v end, LW); y = y - ROW
	Check(frame, function() return L.optCollect end, RIGHT, y, function() return db.tooltip.collect end, function(v)
		db.tooltip.collect = v
		if ns.ResetScan then ns.ResetScan() end
	end, LW); y = y - ROW - 4
	Note(frame, "tooltipNote", RIGHT + 4, y); y = y - 40

	Header(frame, "secMisc", RIGHT, y); y = y - 26
	Check(frame, function() return L.optMinimap end, RIGHT, y, function() return db.minimap.show ~= false end, function(v)
		db.minimap.show = v
		if ns.UpdateMinimapButton then ns.UpdateMinimapButton() end
	end, LW); y = y - ROW - 6

	local bottom = math.min(leftBottom, y)
	line:SetHeight(-bottom - 54)

	-- 도구 버튼 줄 =========================================================
	bottom = bottom - 10
	local tools = {
		{ "btnUnknown", function() if ns.ShowUnknownChat then ns.ShowUnknownChat() end end },
		{ "btnCollected", function() if ns.ShowCollected then ns.ShowCollected() end end },
		{ "btnStatus", function() if ns.PrintStatus then ns.PrintStatus() end end },
		{ "btnHelp", function() if ns.ShowHelp then ns.ShowHelp() end end },
	}
	local bw = 140
	for i, t in ipairs(tools) do
		local b = Button(frame, t[1], bw)
		b:SetPoint("TOPLEFT", LEFT + (i - 1) * (bw + 8), bottom)
		b:SetScript("OnClick", t[2])
	end
	bottom = bottom - 24

	-- 창 높이를 내용에 맞춤 (아래 버튼 자리 포함)
	frame:SetHeight(-bottom + 62)

	local donate = Button(frame, "donate", 120)
	donate:SetPoint("BOTTOMLEFT", 22, 20)
	donate:SetScript("OnClick", function() ns.ShowCopy(ns.DONATE_URL, L.copyDonate) end)

	local ok = Button(frame, "close", 100)
	ok:SetPoint("BOTTOMRIGHT", -22, 20)
	ok:SetScript("OnClick", function() frame:Hide() end)

	frame:SetScript("OnShow", function() RefreshAll() end)
	frame:Hide()
end

RefreshAll = function()
	if not frame then return end
	for _, t in ipairs(texts) do t[1]:SetText(t[2]()) end
	for _, cb in ipairs(checks) do cb:SetChecked(cb.get() and true or false) end
	LayoutLangs()
end

function ns.ToggleOptions()
	if not ns.db then return end
	if not frame then Build() end
	if frame:IsShown() then frame:Hide() else frame:Show() end
end

SLASH_WOWCHATTRANSLATOR1 = "/wct"
SLASH_WOWCHATTRANSLATOR2 = "/번역"
SLASH_WOWCHATTRANSLATOR3 = "/외국어"
SlashCmdList.WOWCHATTRANSLATOR = function(raw)
	raw = (raw or ""):gsub("^%s+", ""):gsub("%s+$", "")
	local msg = raw:lower()
	if msg == "status" or msg == "상태" or msg == "debug" then
		if ns.PrintStatus then ns.PrintStatus() end
		return
	end
	if msg == "미등록" or msg == "unknown" then
		if ns.ShowUnknownChat then ns.ShowUnknownChat() end
		return
	end
	local cmd, rest = msg:match("^(%S+)%s*(.-)$")
	if cmd == "test" or cmd == "테스트" then
		if ns.TestChat and rest ~= "" then ns.TestChat(raw:match("^%S+%s*(.-)$")) end
		return
	end
	if cmd == "collect" or cmd == "수집" then
		if rest == "" or rest == "clear" or rest == "초기화" or rest == "reset" then
			if ns.CollectCommand then ns.CollectCommand(rest) end
			return
		end
	end
	-- 내 메시지 번역·나만의 단어·도움말 (뜻·문장은 대소문자를 그대로 둔다)
	if ns.ExtraCommand and raw ~= "" and ns.ExtraCommand(raw) then return end
	ns.ToggleOptions()
end

------------------------------------------------------------------------
-- 게임 설정(ESC → 설정 → 애드온)에도 바로가기 등록
------------------------------------------------------------------------
local function RegisterPanel()
	local panel = CreateFrame("Frame")
	panel.name = "WoW Chat Translator"
	local ic = panel:CreateTexture(nil, "ARTWORK")
	ic:SetTexture(ICON)
	ic:SetSize(32, 32)
	ic:SetPoint("TOPLEFT", 16, -12)
	local t = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	t:SetPoint("LEFT", ic, "RIGHT", 8, 0)
	t:SetText(L.title)
	local b = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	b:SetSize(180, 26)
	b:SetPoint("TOPLEFT", 16, -50)
	b:SetText("/wct")
	b:SetScript("OnClick", function()
		if SettingsPanel and SettingsPanel:IsShown() then HideUIPanel(SettingsPanel) end
		if InterfaceOptionsFrame and InterfaceOptionsFrame:IsShown() then HideUIPanel(InterfaceOptionsFrame) end
		ns.ToggleOptions()
	end)
	if Settings and Settings.RegisterCanvasLayoutCategory then
		local cat = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
		Settings.RegisterAddOnCategory(cat)
	elseif InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(panel)
	end
end

local prevLogin = ns.OnLogin
ns.OnLogin = function()
	if prevLogin then prevLogin() end
	pcall(RegisterPanel)
end
