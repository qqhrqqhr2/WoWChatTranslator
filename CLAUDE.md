# WoW Chat Translator

WoW Forever addon (Interface 16001). Translates foreign chat into the local language with a built-in dictionary.
Release: put a new `## vX.Y.Z` heading at the top of `CHANGELOG.md` and push it to main (the workflow tags the commit and runs BigWigsMods/packager), or push a `v*` tag. Uploads go to CurseForge only (set `## X-Curse-Project-ID` in the toc and the `CF_API_KEY` secret).

## Rules

- Do not add `Co-Authored-By`, `Claude-Session` or any other AI signature lines to commit messages, PR descriptions or release notes.
- The CurseForge changelog comes from `CHANGELOG.md` (`manual-changelog` in `.pkgmeta`), not from commit messages. Update it for every release.
- Dictionary: `Glossary*.lua` (term=Korean=English). Other local languages: `tools/tr_*.txt` (English|简体中文|Русский), then run `python3 tools/build_translations.py` to regenerate `Translations.lua` (Traditional Chinese is converted automatically). Commit the generated file.
- `TradMap.lua` is generated (OpenCC t2s); do not edit by hand.
