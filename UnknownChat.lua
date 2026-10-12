-- Bounded local collection of untranslated chat expressions.
local ADDON, ns = ...
local function UsefulUnknown(lang, word)
    if type(word) ~= "string" or word == "" then return false end
    if word:find("%a") and word:find("%d") then return false end
    if word:find("discord.gg",1,true) or word:find("https?://") then return false end
    -- UTF-8 CJK characters occupy three bytes; one isolated character lacks context.
    if #word <= 1 or (#word == 3 and word:byte(1) >= 224) then return false end
    if ns.SlashMeaning and ns.SlashMeaning(word, lang, "ko") then return false end
    local dictionaries = ns.Dict or {}
    if dictionaries[lang] and dictionaries[lang][word] then return false end
    if word:match("^[%w%p%s]+$") and dictionaries.en and dictionaries.en[word] then return false end
    return true
end
function ns.RecordUnknownChat(text, lang, gloss)
    if not ns.db or not gloss.unknown or #gloss.unknown == 0 then return end
    local db = ns.db.unknownChat
    if type(db) ~= "table" then db = {words = {}, samples = {}}; ns.db.unknownChat = db end
    local wordCount = 0
    for key in pairs(db.words) do
        local source, term = key:match("^([^:]+):(.*)$")
        if source and UsefulUnknown(source, term) then wordCount = wordCount + 1
        else db.words[key] = nil end
    end
    local seen = {}
    for _, word in ipairs(gloss.unknown) do
        local key = lang .. ":" .. word
        if not seen[key] and UsefulUnknown(lang, word) then
            seen[key] = true
            if db.words[key] then db.words[key] = db.words[key] + 1
            elseif wordCount < 500 then db.words[key], wordCount = 1, wordCount + 1 end
        end
    end
    if gloss.cover < 70 and #text <= 300 then
        local sample = lang .. ": " .. text
        for i, old in ipairs(db.samples) do
            if old == sample then table.remove(db.samples, i); break end
        end
        while #db.samples >= 100 do table.remove(db.samples, 1) end
        db.samples[#db.samples + 1] = sample
    end
end
function ns.ShowUnknownChat()
    local db = ns.db and ns.db.unknownChat
    if not db then ns.ShowCopy(GetLocale() == "koKR" and "아직 수집된 미등록 표현이 없습니다." or "No unknown expressions collected yet.") return end
    local sorted = {}
    for word, count in pairs(db.words) do
        local lang, term = word:match("^([^:]+):(.*)$")
        if lang and UsefulUnknown(lang, term) then sorted[#sorted + 1] = {word, count} end
    end
    table.sort(sorted, function(a, b) if a[2] == b[2] then return a[1] < b[1] end return a[2] > b[2] end)
    local lines = {"Untranslated chat expressions / 미등록 채팅 표현"}
    for i = 1, math.min(#sorted, 100) do lines[#lines + 1] = sorted[i][2] .. "  " .. sorted[i][1] end
    lines[#lines + 1] = "\nSamples / 문장 예시"
    for _, sample in ipairs(db.samples) do lines[#lines + 1] = sample end
    ns.ShowCopy(table.concat(lines, "\n"), GetLocale() == "koKR" and "미등록 표현 전체 복사: Ctrl+C" or "Copy unknown expressions: Ctrl+C")
end
