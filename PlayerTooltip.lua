-- Character information for player links in chat.
local ADDON, ns = ...
local cache, count = {}, 0
local tip
local hoveredOwner, hoveredLink
local pending
local failedUntil = {}
local Key
local nextAllowed = 0
local REQUEST_INTERVAL, RESPONSE_TIMEOUT = 3, 2
local whoMode, ownRequest, ownRouting = 0, false, false
local function IsSecret(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end
local function Now() return GetTime and GetTime() or 0 end
ns.playerLookupStatus = {state = "idle"}
local function Status(state, detail)
    ns.playerLookupStatus.state, ns.playerLookupStatus.detail = state, detail
end
local function Text(key, ...)
    local lang = ns.GetTarget and ns.GetTarget() or (GetLocale() == "koKR" and "ko" or "en")
    local dict = ns.PlayerLookupText and (ns.PlayerLookupText[lang] or ns.PlayerLookupText.en)
    if not dict then return key end
    return string.format(dict[key], ...)
end
Key = function(name)
    if IsSecret(name) or type(name) ~= "string" then return nil end
    local short, realm = name:match("^([^%-]+)%-(.+)$")
    local localRealm = GetRealmName and GetRealmName()
    if short and localRealm and realm:gsub("%s", ""):lower() == localRealm:gsub("%s", ""):lower() then name = short end
    return name:lower()
end
local function Remember(name, data)
    local key = Key(name)
    if not key or key == "" then return end
    if not cache[key] then
        if count >= 500 then cache, count = {}, 0 end
        cache[key], count = {}, count + 1
    end
    for field, value in pairs(data) do
        if not IsSecret(value) and value ~= nil then cache[key][field] = value end
    end
end
local function CollectWho()
    local api = C_FriendList
    local getCount = GetNumWhoResults or (api and api.GetNumWhoResults)
    local getInfo = GetWhoInfo or (api and api.GetWhoInfo)
    if not getCount or not getInfo then return end
    local ok, n = pcall(getCount)
    ns.playerLookupStatus.resultCount = n
    if not ok or type(n) ~= "number" then
        ns.playerLookupStatus.readError = ok and "GetNumWhoResults returned no number" or tostring(n)
        return
    end
    for i = 1, math.min(n, 100) do
        local success, name, guild, level, race, class, zone = pcall(getInfo, i)
        if i == 1 then
            if type(name) == "table" then
                local fields = {}
                for k, v in pairs(name) do fields[#fields + 1] = tostring(k) .. "=" .. tostring(v) end
                table.sort(fields)
                ns.playerLookupStatus.firstResult = table.concat(fields, ", ")
            else ns.playerLookupStatus.firstResult = tostring(name) .. "/" .. tostring(level) end
        end
        if success then
            if type(name) == "table" then
                local row = name
                name, guild, level, race, class, zone = row.fullName or row.name,
                    row.fullGuildName or row.guild, row.level, row.raceStr or row.race,
                    row.classStr or row.class, row.area or row.zone
            end
            if type(name) == "string" and type(level) == "number" and level > 0 then
                Remember(name, {level = level, guild = guild or "", race = race,
                    class = class, zone = zone or "", who = true})
            end
        end
    end
end
local function WhoAPI(method)
    return _G[method] or (C_FriendList and (C_FriendList[method] or (method == "SetWhoToUI" and C_FriendList.SetWhoToUi)))
end
local function SetRouting(mode)
    local setter = WhoAPI("SetWhoToUI")
    if setter then
        ownRouting = true
        local value = mode
        if C_FriendList and setter == C_FriendList.SetWhoToUi then value = mode == true or mode == 1 end
        local ok, err = pcall(setter, value)
        if not ok then Status("routing-error", tostring(err)) end
        ownRouting = false
    end
end
local function FinishRequest(restoreRouting)
    local old = pending
    pending = nil
    if not old then return end
    if old.frame and old.registered then old.frame:RegisterEvent("WHO_LIST_UPDATE") end
    if restoreRouting then SetRouting(old.mode) end
end
local socialLoaded = false
local function EnsureSocialUI()
    if socialLoaded then return end
    if FriendsFrame then socialLoaded = true return end
    local loader = UIParentLoadAddOn or (C_AddOns and C_AddOns.LoadAddOn) or LoadAddOn
    if loader then
        local ok, loaded, reason = pcall(loader, "Blizzard_FriendsFrame")
        ns.playerLookupStatus.socialLoad = tostring(ok) .. "/" .. tostring(loaded) .. "/" .. tostring(reason)
        socialLoaded = FriendsFrame ~= nil
    else ns.playerLookupStatus.socialLoad = "loader unavailable" end
end
local function StartRequest(name, attempt)
    EnsureSocialUI()
    local sender = WhoAPI("SendWho")
    if not sender then Status("unsupported", "SendWho unavailable") return false end
    -- A visible Who window belongs to the user's search.
    if WhoFrame and WhoFrame.IsShown and WhoFrame:IsShown() then return false end
    local frame = FriendsFrame
    local registered = frame and frame.IsEventRegistered and frame:IsEventRegistered("WHO_LIST_UPDATE")
    pending = {name = name, attempt = attempt or 1, started = Now(), mode = whoMode, frame = frame, registered = registered}
    if registered then frame:UnregisterEvent("WHO_LIST_UPDATE") end
    SetRouting(1)
    ownRequest = true
    local queryName = name:match("^[^%-]+") or name
    queryName = queryName:gsub('["\\]', '')
    local query = 'n-"' .. queryName .. '"'
    ns.playerLookupStatus.query = query
    Status("requested", name)
    local ok, err = pcall(sender, query)
    ownRequest = false
    nextAllowed = Now() + REQUEST_INTERVAL
    if not ok then
        Status("send-error", tostring(err))
        failedUntil[Key(name)] = Now() + 30
        FinishRequest(true)
        return false
    end
    return true
end
-- Character lookups are dispatched only by Shift-click.
function ns.RequestPlayerInfo(link)
    local name = type(link) == "string" and link:match("^player:([^:]+)")
    if not name then return false end
    ns.playerLookupStatus.clicks = (ns.playerLookupStatus.clicks or 0) + 1
    local now = Now()
    local info = cache[Key(name)]
    if pending and now - pending.started >= RESPONSE_TIMEOUT then
        failedUntil[Key(pending.name)] = now + 60
        FinishRequest(true)
    end
    if not (info and info.level) and not pending and now >= nextAllowed then
        failedUntil[Key(name)] = nil
        ns.playerLookupStatus.requestSource = "shift-click"
        StartRequest(name, 1)
    end
    ns.playerLookupStatus.tooltipDirty = true
    return true
end
-- Keep tooltip rendering outside request dispatch and isolate UI errors.
local tooltipDirty = false
local function RefreshHoveredTooltip()
    if not hoveredOwner or not hoveredLink or not tip then return end
    local ok, err = pcall(ns.ShowPlayerTooltip, hoveredOwner, hoveredLink, true)
    if not ok then
        ns.playerLookupStatus.tooltipError = tostring(err)
        tooltipDirty = false
    end
end
-- Observe manual searches so automatic requests do not consume their results.
if hooksecurefunc then
    local function manualQuery()
        if not ownRequest then
            FinishRequest(false)
            nextAllowed = Now() + REQUEST_INTERVAL
        end
    end
    local function manualRouting(mode)
        if not ownRouting then whoMode = mode end
    end
    if SendWho then pcall(hooksecurefunc, "SendWho", manualQuery)
    elseif C_FriendList and C_FriendList.SendWho then pcall(hooksecurefunc, C_FriendList, "SendWho", manualQuery) end
    if SetWhoToUI then pcall(hooksecurefunc, "SetWhoToUI", manualRouting)
    elseif C_FriendList and C_FriendList.SetWhoToUI then pcall(hooksecurefunc, C_FriendList, "SetWhoToUI", manualRouting)
    elseif C_FriendList and C_FriendList.SetWhoToUi then pcall(hooksecurefunc, C_FriendList, "SetWhoToUi", manualRouting) end
end
local function Matches(unit, name)
    if not UnitExists(unit) or not UnitIsPlayer(unit) then return false end
    local n, realm = UnitName(unit)
    return Key(name) == Key(n) or (realm and realm ~= "" and Key(name) == Key(n .. "-" .. realm))
end
local function FindUnit(name)
    for _, unit in ipairs({"player", "target", "focus", "mouseover"}) do
        if Matches(unit, name) then return unit end
    end
    for i = 1, 40 do
        local unit = "raid" .. i
        if Matches(unit, name) then return unit end
        if i <= 4 and Matches("party" .. i, name) then return "party" .. i end
    end
end
local function GetTip(owner)
    if not tip then
        tip = CreateFrame("GameTooltip", "WoWChatTranslatorPlayerTooltip", UIParent, "GameTooltipTemplate")
    end
    -- Re-anchoring a visible tooltip can trigger native hide/show callbacks.
    if tip:GetOwner() ~= owner then
        tip:SetOwner(owner, "ANCHOR_CURSOR")
    end
    tip:ClearLines()
    return tip
end
function ns.ShowPlayerTooltip(owner, link, fromRefresh)
    local name = type(link) == "string" and link:match("^player:([^:]+)")
    if not name then return end
    hoveredOwner, hoveredLink = owner, link
    local tt = GetTip(owner)
    local unit = FindUnit(name)
    if unit then
        tt:SetUnit(unit)
        -- Put the addon label before the native unit tooltip lines.
        local title = _G["WoWChatTranslatorPlayerTooltipTextLeft1"]
        if title then
            local nameText = title:GetText()
            title:SetText("WoWChatTranslator\n" .. (nameText or name))
        else
            tt:AddLine("WoWChatTranslator", 0.3, 0.8, 1)
        end
        tt:Show()
        return
    end
    local info = cache[Key(name)] or {}
    local level, class, race, guild, zone = info.level, info.class, info.race, info.guild, info.zone
    if not fromRefresh and GetNumGuildMembers and GetGuildRosterInfo then
        for i = 1, GetNumGuildMembers() do
            local n, _, _, l, c, z = GetGuildRosterInfo(i)
            if Key(n) == Key(name) then
                level, class, zone = l, c, z
                guild = GetGuildInfo("player")
                if level and level > 0 then Remember(name, {level = level, class = class, guild = guild, zone = zone}) end
                break
            end
        end
    end
    tt:AddLine("WoWChatTranslator", 0.3, 0.8, 1)
    tt:AddLine(name, 1, 1, 1)
    if guild and guild ~= "" then tt:AddLine("<" .. guild .. ">", 0.3, 1, 0.3) end
    local details = {}
    if level and level > 0 then details[#details + 1] = Text("level", level) end
    if race and race ~= "" then details[#details + 1] = race end
    if class and class ~= "" then details[#details + 1] = class end
    if #details > 0 then tt:AddLine(table.concat(details, " "), 1, 0.82, 0) end
    if zone and zone ~= "" then tt:AddLine(zone, 0.7, 0.7, 0.7) end
    if not level then
        local now, message = Now()
        if pending then
            local remaining = math.max(0, math.ceil(RESPONSE_TIMEOUT - (now - pending.started)))
            if Key(pending.name) == Key(name) then
                message = Text("loading", remaining)
            else
                message = Text("busy", pending.name, remaining)
            end
        elseif now < nextAllowed then
            local remaining = math.ceil(nextAllowed - now)
            message = Text("wait", remaining)
        elseif (failedUntil[Key(name)] or 0) > now then
            message = Text("failed")
        else
            message = Text("hint")
        end
        tt:AddLine(message, 0.6, 0.6, 0.6, true)
    end
    tt:Show()
end
function ns.HidePlayerTooltip(owner)
    if hoveredOwner == owner then hoveredOwner, hoveredLink = nil, nil end
    if tip and tip:GetOwner() == owner then tip:Hide() end
end
-- Response handling updates cached information and the current hover.
local events = CreateFrame("Frame")
pcall(events.RegisterEvent, events, "WHO_LIST_UPDATE")
pcall(events.RegisterEvent, events, "CHAT_MSG_SYSTEM")
for _, event in ipairs({"CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_CHANNEL"}) do
    pcall(events.RegisterEvent, events, event)
end
events:SetScript("OnEvent", function(self, event, ...)
    if event == "WHO_LIST_UPDATE" then
        ns.playerLookupStatus.events = (ns.playerLookupStatus.events or 0) + 1
    end
    if event == "WHO_LIST_UPDATE" or event == "CHAT_MSG_SYSTEM" then
        local function refresh()
            CollectWho()
            if event == "WHO_LIST_UPDATE" and pending then
                local info = cache[Key(pending.name)]
                if info and info.level then
                    Status("received", pending.name)
                    FinishRequest(true)
                end
            end
            tooltipDirty = true
        end
        if C_Timer and C_Timer.After then C_Timer.After(0, refresh) else refresh() end
        return
    end
    local name, guid = select(2, ...), select(12, ...)
    if IsSecret(name) or IsSecret(guid) then return end
    if type(name) ~= "string" or type(guid) ~= "string" or guid == "" or not GetPlayerInfoByGUID then return end
    local ok, class, _, race = pcall(GetPlayerInfoByGUID, guid)
    if not ok or IsSecret(class) or IsSecret(race) or not class then return end
    Remember(name, {class = class, race = race})
end)

local elapsed, lastDisplaySecond = 0, nil
events:SetScript("OnUpdate", function(self, dt)
    elapsed = elapsed + dt
    if elapsed < 0.2 then return end
    elapsed = 0
    local now = Now()
    if pending then
        CollectWho()
        local info = cache[Key(pending.name)]
        if info and info.level then
            Status("received", pending.name)
            FinishRequest(true)
            tooltipDirty = true
        end
    end
    if pending and now - pending.started >= RESPONSE_TIMEOUT then
        local name = pending.name
        Status("timeout", name)
        failedUntil[Key(name)] = now + 60
        FinishRequest(true)
        tooltipDirty = true
    end
    local second = math.floor(now)
    if tooltipDirty or ns.playerLookupStatus.tooltipDirty or (hoveredOwner and hoveredLink and second ~= lastDisplaySecond) then
        lastDisplaySecond = second
        tooltipDirty, ns.playerLookupStatus.tooltipDirty = false, false
        RefreshHoveredTooltip()
    end
    ns.playerLookupStatus.mode = "shift-click"
    ns.playerLookupStatus.pending = pending and pending.name or nil
    ns.playerLookupStatus.pendingAge = pending and math.floor(now - pending.started) or nil
    ns.playerLookupStatus.nextDelay = math.max(0, math.ceil(nextAllowed - now))
end)
