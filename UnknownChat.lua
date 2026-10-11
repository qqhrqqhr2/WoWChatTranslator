-- Bounded local collection of untranslated chat expressions.
local ADDON, ns = ...
function ns.RecordUnknownChat(text, lang, gloss)
    if not ns.db or not gloss.unknown or #gloss.unknown == 0 then return end
    local db = ns.db.unknownChat
    if type(db) ~= "table" then db = {words = {}, samples = {}}; ns.db.unknownChat = db end
    local wordCount = 0
    for _ in pairs(db.words) do wordCount = wordCount + 1 end
    local seen = {}
    for _, word in ipairs(gloss.unknown) do
        local key = lang .. ":" .. word
        if not seen[key] and #word > 1 then
            seen[key] = true
            if db.words[key] then db.words[key] = db.words[key] + 1
            elseif wordCount < 500 then db.words[key], wordCount = 1, wordCount + 1 end
        end
    end
    if gloss.cover < 70 and #text <= 300 and #db.samples < 100 then
        local sample = lang .. ": " .. text
        for _, old in ipairs(db.samples) do if old == sample then return end end
        db.samples[#db.samples + 1] = sample
    end
end
function ns.ShowUnknownChat()
    local db = ns.db and ns.db.unknownChat
    if not db then ns.ShowCopy(GetLocale() == "koKR" and "아직 수집된 미등록 표현이 없습니다." or "No unknown expressions collected yet.") return end
    local sorted = {}
    for word, count in pairs(db.words) do sorted[#sorted + 1] = {word, count} end
    table.sort(sorted, function(a, b) if a[2] == b[2] then return a[1] < b[1] end return a[2] > b[2] end)
    local lines = {"Untranslated chat expressions / 미등록 채팅 표현"}
    for i = 1, math.min(#sorted, 100) do lines[#lines + 1] = sorted[i][2] .. "  " .. sorted[i][1] end
    lines[#lines + 1] = "\nSamples / 문장 예시"
    for _, sample in ipairs(db.samples) do lines[#lines + 1] = sample end
    ns.ShowCopy(table.concat(lines, "\n"), GetLocale() == "koKR" and "미등록 표현 전체 복사: Ctrl+C" or "Copy unknown expressions: Ctrl+C")
end
