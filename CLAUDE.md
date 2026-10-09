# WoW Chat Translator

WoW Forever addon (Interface 16001). Translates foreign chat into the local language with a built-in dictionary.
Release: put a new `## vX.Y.Z` heading at the top of `CHANGELOG.md` and push it to main (the workflow tags the commit and runs BigWigsMods/packager), or push a `v*` tag. Uploads go to CurseForge 1733319 only (`CF_API_KEY` secret).

## Rules

- Do not add `Co-Authored-By`, `Claude-Session` or any other AI signature lines to commit messages, PR descriptions or release notes.
- The CurseForge changelog comes from `CHANGELOG.md` (`manual-changelog` in `.pkgmeta`), not from commit messages. Update it for every release.
- Dictionary: `Glossary*.lua` (term=Korean=English). Other local languages: `tools/tr_*.txt` (English|简体中文|Русский), then run `python3 tools/build_translations.py` to regenerate `Translations.lua` (Traditional Chinese is converted automatically). Commit the generated file.
- Tooltip translation: `tools/tooltip_text.txt` (sentences, `#` for numbers) and `tools/tooltip_names.txt` (item/spell names) and `tools/tooltip_patterns.txt` (Lua patterns; `%=1` keeps a capture untranslated, e.g. spell names), then `python3 tools/build_tooltip.py` regenerates `TooltipText.lua`. Collected untranslated sentences come from the user's SavedVariables (`WoWChatTranslatorDB.collected`).
- Game data tables: `python3 tools/fetch_db.py <dir> [ForeverExtra.lua]` downloads spellbook/talents/items (en/ko/zh/tw), then `python3 tools/build_db.py <dir>` regenerates `TooltipDB.lua` (exact sentences, names, similar-sentence list). Hand-made tables take priority. Do not name the data source in README, CHANGELOG or descriptions.
- Unreleased changes go under a heading without a version (e.g. `## 다음 버전`); only a `## vX.Y.Z` heading triggers a release.
- `TradMap.lua` is generated (OpenCC t2s); do not edit by hand.
