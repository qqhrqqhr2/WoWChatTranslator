-- WoW Chat Translator: 저장 설정과 시작 이벤트
local ADDON, ns = ...

local function merge(dst, src)
	for k, v in pairs(src) do
		if type(v) == "table" then
			if type(dst[k]) ~= "table" then dst[k] = {} end
			merge(dst[k], v)
		elseif dst[k] == nil then
			dst[k] = v
		end
	end
	return dst
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_LOGIN")
ev:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == ADDON then
		WoWChatTranslatorDB = merge(type(WoWChatTranslatorDB) == "table" and WoWChatTranslatorDB or {}, ns.DEFAULTS)
		ns.db = WoWChatTranslatorDB
		ns.ApplyTarget()
		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "PLAYER_LOGIN" then
		if ns.OnLogin then
			local ok, err = pcall(ns.OnLogin)
			if not ok and ns.status then ns.status.lastError = tostring(err) end
		end
	end
end)
