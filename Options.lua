-- WoW Chat Translator: 설정창 (/wct)
-- 현지 언어를 바꾸면 화면 문구도 바로 그 언어로 바뀐다.
local ADDON, ns = ...
local L = setmetatable({}, { __index = function(_, k) return ns.L[k] end })

local frame
local ICON = "Interface\\AddOns\\" .. ADDON .. "\\Media\\icon"

-- 창 너비와 3칸 격자 위치 (긴 러시아어 문구도 넘치지 않게)
local FRAME_W = 520
local COL = { 22, 186, 350 }
local COL_W = 150
local texts = {}      -- { 글자 오브젝트, 문구를 만드는 함수 }
local checks = {}     -- 체크박스 (창이 열릴 때 값 다시 읽기)
local targetRadios = {}
local langChecks = {}

local function Track(obj, fn)
	texts[#texts + 1] = { obj, fn }
	obj:SetText(fn())
	return obj
end

local function Check(parent, labelFn, x, y, get, set, maxW)
	local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	cb:SetSize(26, 26)
	cb:SetPoint("TOPLEFT", x, y)
	if cb.text then cb.text:SetText("") end
	if cb.Text then cb.Text:SetText("") end
	local fs = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	fs:SetPoint("LEFT", cb, "RIGHT", 2, 1)
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

local function Header(parent, key, y)
	local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	fs:SetPoint("TOPLEFT", 18, y)
	return Track(fs, function() return L[key] end)
end

local function Note(parent, key, y)
	local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	fs:SetPoint("TOPLEFT", 22, y)
	fs:SetWidth(FRAME_W - 50)
	fs:SetJustifyH("LEFT")
	return Track(fs, function() return L[key] end)
end

local function Button(parent, key, w)
	local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	b:SetSize(w or 140, 24)
	Track(b, function() return L[key] end)
	return b
end

local RefreshAll


-- 번역할 언어 체크박스: 현지 언어와 같은 언어는 흐리게 (배치는 3칸 격자로 고정)
local function LayoutLangs()
	local same = ns.SAME_SOURCE[ns.GetTarget()]
	for _, lc in ipairs(langChecks) do
		if lc.lang == same then
			lc.label:SetTextColor(0.5, 0.5, 0.5)
		else
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

	local db = ns.db
	local y = -50

	-- 현지 언어 ----------------------------------------------------------
	Header(frame, "secTarget", y); y = y - 26
	local options = { { "auto" } }
	for _, t in ipairs(ns.TARGETS) do options[#options + 1] = { t } end
	local function radio(value, x, yy, maxW)
		local labelFn
		if value == "auto" then
			labelFn = function() return L.auto:format(ns.TARGET_NAME[ns.CLIENT_TARGET]) end
		else
			labelFn = function() return ns.TARGET_NAME[value] end
		end
		local cb = Check(frame, labelFn, x, yy,
			function() return (db.target or "auto") == value end,
			function() SetTarget(value) end, maxW)
		targetRadios[#targetRadios + 1] = cb
		return cb
	end
	radio("auto", COL[1], y, FRAME_W - 80); y = y - 26
	radio("ko", COL[1], y, COL_W - 30); radio("en", COL[2], y, COL_W - 30); radio("zhCN", COL[3], y, COL_W - 30); y = y - 26
	radio("zhTW", COL[1], y, COL_W - 30); radio("ru", COL[2], y, COL_W - 30); y = y - 30
	Note(frame, "targetNote", y); y = y - 38

	-- 채팅 번역 ----------------------------------------------------------
	Header(frame, "secChat", y); y = y - 26
	Check(frame, function() return L.optEnabled end, 22, y, function() return db.chat.enabled end, function(v) db.chat.enabled = v end, FRAME_W - 80); y = y - 26
	Check(frame, function() return L.optInline end, 22, y, function() return db.chat.inline end, function(v) db.chat.inline = v end, FRAME_W - 80); y = y - 28

	-- 최소 풀이 비율 (- / + 버튼)
	local minus = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	minus:SetSize(24, 24); minus:SetText("-")
	minus:SetPoint("TOPLEFT", 50, y)
	minus:SetScript("OnClick", function()
		db.chat.minCover = math.max(0, (db.chat.minCover or 40) - 10); RefreshAll()
	end)
	local plus = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	plus:SetSize(24, 24); plus:SetText("+")
	plus:SetPoint("LEFT", minus, "RIGHT", 4, 0)
	plus:SetScript("OnClick", function()
		db.chat.minCover = math.min(100, (db.chat.minCover or 40) + 10); RefreshAll()
	end)
	local cover = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	cover:SetPoint("LEFT", plus, "RIGHT", 8, 0)
	cover:SetWidth(FRAME_W - 150)
	cover:SetJustifyH("LEFT")
	Track(cover, function() return L.optCover:format(db.chat.minCover or 40) end)
	y = y - 30

	Check(frame, function() return L.optTag end, 22, y, function() return db.chat.tag end, function(v) db.chat.tag = v end, FRAME_W - 80); y = y - 26
	Check(frame, function() return L.optHover end, 22, y, function() return db.chat.hoverAll end, function(v) db.chat.hoverAll = v end, FRAME_W - 80); y = y - 26
	Check(frame, function() return L.optSelf end, 22, y, function() return db.chat.skipSelf end, function(v) db.chat.skipSelf = v end, FRAME_W - 80); y = y - 30

	local lt = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	lt:SetPoint("TOPLEFT", 26, y)
	Track(lt, function() return L.langs end)
	y = y - 22
	for i, lang in ipairs({ "ko", "zh", "ja", "ru", "en" }) do
		local col = (i - 1) % 3 + 1
		local row = math.floor((i - 1) / 3)
		local cb = Check(frame, function() return L.langName[lang] end, COL[col], y - row * 26,
			function() return db.chat.langs[lang] end,
			function(v) db.chat.langs[lang] = v end, COL_W - 30)
		cb.lang = lang
		langChecks[#langChecks + 1] = cb
	end
	y = y - 26 * 2 - 6
	Note(frame, "chatNote", y)
	y = y - 34

	-- 창 높이를 내용에 맞춤 (아래 버튼 자리 포함)
	frame:SetHeight(-y + 56)

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
SlashCmdList.WOWCHATTRANSLATOR = function(msg)
	msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
	if msg == "status" or msg == "상태" or msg == "debug" then
		if ns.PrintStatus then ns.PrintStatus() end
		return
	end
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
