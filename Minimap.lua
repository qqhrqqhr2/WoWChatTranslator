-- WoW Chat Translator: 미니맵 버튼 (왼쪽 클릭: 설정, 드래그: 미니맵 둘레로 이동)
local ADDON, ns = ...
local L = setmetatable({}, { __index = function(_, k) return ns.L[k] end })
local ICON = "Interface\\AddOns\\" .. ADDON .. "\\Media\\icon"

local button
local RADIUS = 80

local function Place()
	if not button or not Minimap then return end
	local angle = math.rad((ns.db.minimap and ns.db.minimap.angle) or 205)
	local r = (Minimap:GetWidth() or 140) / 2 + 10
	if r < 60 or r > 140 then r = RADIUS end
	button:ClearAllPoints()
	button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * r, math.sin(angle) * r)
end

local function OnDragUpdate()
	local mx, my = Minimap:GetCenter()
	local cx, cy = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	cx, cy = cx / scale, cy / scale
	ns.db.minimap.angle = math.deg(math.atan2(cy - my, cx - mx)) % 360
	Place()
end

local function Create()
	if button or not Minimap then return end
	button = CreateFrame("Button", "WoWChatTranslatorMinimapButton", Minimap)
	button:SetSize(31, 31)
	button:SetFrameStrata("MEDIUM")
	button:SetFrameLevel(8)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:RegisterForDrag("LeftButton")
	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetTexture(ICON)
	icon:SetSize(20, 20)
	icon:SetPoint("TOPLEFT", 6, -5)
	local border = button:CreateTexture(nil, "OVERLAY")
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	border:SetSize(53, 53)
	border:SetPoint("TOPLEFT")

	button:SetScript("OnClick", function() ns.ToggleOptions() end)
	button:SetScript("OnDragStart", function(self) self:SetScript("OnUpdate", OnDragUpdate) end)
	button:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:AddLine("WoW Chat Translator", 0.4, 0.8, 1)
		GameTooltip:AddLine(L.minimapTip, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function() GameTooltip:Hide() end)
	Place()
end

function ns.UpdateMinimapButton()
	if not ns.db then return end
	ns.db.minimap = ns.db.minimap or { show = true, angle = 205 }
	if ns.db.minimap.show == false then
		if button then button:Hide() end
		return
	end
	Create()
	if button then button:Show(); Place() end
end

local prevLogin = ns.OnLogin
ns.OnLogin = function()
	if prevLogin then prevLogin() end
	pcall(ns.UpdateMinimapButton)
end
