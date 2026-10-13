-- WoW Chat Translator: 설정창 개편·채널·도구·내 메시지 번역·나만의 단어 문구 (7개 언어)
local ADDON, ns = ...

ns.DEFAULTS.chat.playerTip = true      -- 채팅 이름에 캐릭터 정보 툴팁 (Shift+클릭 조회)
ns.DEFAULTS.chat.channels = { public = true, say = true, guild = true, group = true, whisper = true }
ns.DEFAULTS.minimap = { show = true, angle = 205 }
ns.DEFAULTS.custom = {}                 -- 나만의 단어: custom[원문 언어][열쇠] = { 원문, 뜻, 뜻 언어 }

local UI = {
	ko = {
		secLangs = "번역할 언어", secChannels = "번역할 채널", secMisc = "기타",
		chPublic = "공개 채널 (거래·파티찾기·공용)", chSay = "일반 대화·외치기", chGuild = "길드·관리자",
		chGroup = "파티·공격대·인스턴스", chWhisper = "귓속말",
		optPlayerTip = "채팅 이름에 캐릭터 정보 툴팁 (Shift+클릭 조회)",
		optMinimap = "미니맵 버튼 표시",
		btnUnknown = "미등록 표현", btnCollected = "수집 문장", btnStatus = "상태 복사", btnHelp = "명령어",
		langsShort = "번역할 언어 (현지 언어는 제외)",
		sameLang = "현지 언어",
		minimapTip = "왼쪽 클릭: 설정 열기\n드래그: 버튼 옮기기",
		outDone = "%s(으)로 바꿨습니다 (풀이 %d%%). 채팅 입력창을 확인하고 Enter를 누르세요.",
		outLeft = "번역 못 한 부분: %s",
		outUsage = "사용법: /wct en 보낼 문장  (en 영어 · zh 간체 · tw 번체 · ru · ja · es · ko)",
		outNone = "사전에 있는 표현이 없어 바꾸지 못했습니다.",
		addDone = "단어 추가: %s → %s", addUsage = "사용법: /wct add 단어=뜻   (삭제: /wct del 단어, 목록: /wct list)",
		delDone = "단어 삭제: %s", delNone = "내가 추가한 단어가 아닙니다: %s",
		listTitle = "내가 추가한 단어 %d개", listEmpty = "추가한 단어가 없습니다.",
		collectedTitle = "툴팁에서 모은 미번역 문장 %d개 (Ctrl+C로 복사)", collectedEmpty = "아직 모은 문장이 없습니다.",
		help = "/wct - 설정창\n/wct en 문장 - 내 메시지를 영어로 (zh·tw·ru·ja·es·ko)\n/wct add 단어=뜻 - 나만의 단어 추가\n/wct del 단어 - 삭제\n/wct list - 추가한 단어 목록\n/wct unknown - 채팅 미등록 표현\n/wct collect - 툴팁 미번역 문장\n/wct status - 상태 정보\n/wct test 문장 - 풀이 시험",
		helpTitle = "명령어 목록",
	},
	en = {
		secLangs = "Languages to translate", secChannels = "Channels to translate", secMisc = "Other",
		chPublic = "Public channels (Trade, LFG, General)", chSay = "Say and yell", chGuild = "Guild and officer",
		chGroup = "Party, raid and instance", chWhisper = "Whispers",
		optPlayerTip = "Character info on chat names (Shift-click)",
		optCover = "Min. coverage to append: %d%%",
		optMinimap = "Show minimap button",
		btnUnknown = "Unknown words", btnCollected = "Collected", btnStatus = "Copy status", btnHelp = "Commands",
		langsShort = "Languages to translate (local language excluded)",
		sameLang = "local language",
		minimapTip = "Left-click: open settings\nDrag: move the button",
		outDone = "Converted to %s (%d%% recognized). Check the chat box and press Enter.",
		outLeft = "Not translated: %s",
		outUsage = "Usage: /wct en your message  (en, zh, tw, ru, ja, es, ko)",
		outNone = "No dictionary expressions found; nothing was converted.",
		addDone = "Word added: %s → %s", addUsage = "Usage: /wct add word=meaning   (remove: /wct del word, list: /wct list)",
		delDone = "Word removed: %s", delNone = "Not one of your words: %s",
		listTitle = "Your words: %d", listEmpty = "You have not added any words.",
		collectedTitle = "Untranslated tooltip sentences: %d (Ctrl+C to copy)", collectedEmpty = "No sentences collected yet.",
		help = "/wct - settings\n/wct en text - convert your message to English (zh, tw, ru, ja, es, ko)\n/wct add word=meaning - add your own word\n/wct del word - remove it\n/wct list - your words\n/wct unknown - unknown chat expressions\n/wct collect - untranslated tooltip sentences\n/wct status - status\n/wct test text - test a message",
		helpTitle = "Commands",
	},
	zhCN = {
		secLangs = "要翻译的语言", secChannels = "要翻译的频道", secMisc = "其他",
		chPublic = "公共频道（交易、寻求组队、综合）", chSay = "说话和大喊", chGuild = "公会和官员",
		chGroup = "小队、团队和副本", chWhisper = "密语",
		optPlayerTip = "聊天角色名显示角色信息提示（Shift点击查询）",
		optMinimap = "显示小地图按钮",
		btnUnknown = "未登记词语", btnCollected = "收集的句子", btnStatus = "复制状态", btnHelp = "命令",
		langsShort = "要翻译的语言（排除本地语言）",
		sameLang = "本地语言",
		minimapTip = "左键：打开设置\n拖动：移动按钮",
		outDone = "已转换为%s（识别%d%%）。请检查聊天输入框后按回车。",
		outLeft = "未翻译部分：%s",
		outUsage = "用法：/wct en 要发送的句子（en、zh、tw、ru、ja、es、ko）",
		outNone = "没有找到词典中的表达，未转换。",
		addDone = "已添加词语：%s → %s", addUsage = "用法：/wct add 词语=意思（删除：/wct del 词语，列表：/wct list）",
		delDone = "已删除词语：%s", delNone = "不是你添加的词语：%s",
		listTitle = "你添加的词语：%d个", listEmpty = "还没有添加词语。",
		collectedTitle = "收集的未翻译提示句子：%d个（Ctrl+C复制）", collectedEmpty = "还没有收集到句子。",
		help = "/wct - 设置\n/wct en 句子 - 把你的消息转换为英语（zh、tw、ru、ja、es、ko）\n/wct add 词语=意思 - 添加自定义词语\n/wct del 词语 - 删除\n/wct list - 自定义词语列表\n/wct unknown - 未登记的聊天表达\n/wct collect - 未翻译的提示句子\n/wct status - 状态\n/wct test 句子 - 测试",
		helpTitle = "命令列表",
	},
	ja = {
		secLangs = "翻訳する言語", secChannels = "翻訳するチャンネル", secMisc = "その他",
		chPublic = "公開チャンネル（取引・LFG・全般）", chSay = "発言・叫び", chGuild = "ギルド・オフィサー",
		chGroup = "パーティ・レイド・インスタンス", chWhisper = "ささやき",
		optPlayerTip = "名前にキャラ情報を表示（Shift+クリック）",
		optMinimap = "ミニマップボタンを表示",
		btnUnknown = "未登録の表現", btnCollected = "収集した文", btnStatus = "状態をコピー", btnHelp = "コマンド",
		langsShort = "翻訳する言語（翻訳先の言語は除外）",
		sameLang = "翻訳先の言語",
		minimapTip = "左クリック：設定を開く\nドラッグ：ボタンを移動",
		outDone = "%sに変換しました（認識 %d%%）。入力欄を確認して Enter を押してください。",
		outLeft = "翻訳できなかった部分：%s",
		outUsage = "使い方：/wct en 送る文（en・zh・tw・ru・ja・es・ko）",
		outNone = "辞書にある表現がないため変換できませんでした。",
		addDone = "単語を追加：%s → %s", addUsage = "使い方：/wct add 単語=意味（削除：/wct del 単語、一覧：/wct list）",
		delDone = "単語を削除：%s", delNone = "追加した単語ではありません：%s",
		listTitle = "追加した単語：%d個", listEmpty = "追加した単語はありません。",
		collectedTitle = "収集した未翻訳の文：%d個（Ctrl+Cでコピー）", collectedEmpty = "まだ収集した文はありません。",
		help = "/wct - 設定\n/wct en 文 - 自分のメッセージを英語に（zh・tw・ru・ja・es・ko）\n/wct add 単語=意味 - 単語を追加\n/wct del 単語 - 削除\n/wct list - 追加した単語\n/wct unknown - 未登録のチャット表現\n/wct collect - 未翻訳のツールチップ文\n/wct status - 状態\n/wct test 文 - テスト",
		helpTitle = "コマンド一覧",
	},
	ru = {
		secLangs = "Переводить с языков", secChannels = "Переводить каналы", secMisc = "Прочее",
		chPublic = "Общие каналы (торговля, поиск группы)", chSay = "Сказать и крик", chGuild = "Гильдия и офицеры",
		chGroup = "Группа, рейд, подземелье", chWhisper = "Шёпот",
		optPlayerTip = "Инфо о персонаже (Shift+щелчок)",
		optMinimap = "Кнопка у миникарты",
		btnUnknown = "Новые слова", btnCollected = "Собранное", btnStatus = "Статус", btnHelp = "Команды",
		langsShort = "Переводить с языков (кроме родного)",
		sameLang = "родной язык",
		minimapTip = "Левый щелчок: настройки\nПеретаскивание: переместить",
		outDone = "Переведено на %s (распознано %d%%). Проверьте строку чата и нажмите Enter.",
		outLeft = "Не переведено: %s",
		outUsage = "Использование: /wct en сообщение  (en, zh, tw, ru, ja, es, ko)",
		outNone = "В словаре нет подходящих выражений, перевод не выполнен.",
		addDone = "Слово добавлено: %s → %s", addUsage = "Использование: /wct add слово=значение   (удалить: /wct del слово, список: /wct list)",
		delDone = "Слово удалено: %s", delNone = "Это не ваше слово: %s",
		listTitle = "Ваши слова: %d", listEmpty = "Вы ещё не добавили слов.",
		collectedTitle = "Непереведённые фразы подсказок: %d (Ctrl+C — копировать)", collectedEmpty = "Фраз пока нет.",
		help = "/wct - настройки\n/wct en текст - перевести своё сообщение на английский (zh, tw, ru, ja, es, ko)\n/wct add слово=значение - добавить слово\n/wct del слово - удалить\n/wct list - ваши слова\n/wct unknown - неизвестные выражения чата\n/wct collect - непереведённые фразы подсказок\n/wct status - статус\n/wct test текст - проверка",
		helpTitle = "Команды",
		-- 기존 문구 중 설정창에서 잘리던 것을 짧게
		optTooltip = "Переводить описания предметов и заклинаний",
		optHover = "Подсказка при наведении на сообщение",
	},
	es = {
		secLangs = "Idiomas que traducir", secChannels = "Canales que traducir", secMisc = "Otros",
		chPublic = "Canales públicos (Comercio, Buscar grupo)", chSay = "Decir y gritar", chGuild = "Hermandad y oficiales",
		chGroup = "Grupo, banda e instancia", chWhisper = "Susurros",
		optPlayerTip = "Info del personaje en nombres (Mayús+clic)",
		optTooltip = "Traducir descripciones de objetos y hechizos",
		optMinimap = "Mostrar botón del minimapa",
		btnUnknown = "Desconocidas", btnCollected = "Recopiladas", btnStatus = "Copiar estado", btnHelp = "Comandos",
		langsShort = "Idiomas que traducir (sin el idioma local)",
		sameLang = "idioma local",
		minimapTip = "Clic izquierdo: abrir ajustes\nArrastrar: mover el botón",
		outDone = "Convertido a %s (%d%% reconocido). Revisa el chat y pulsa Intro.",
		outLeft = "Sin traducir: %s",
		outUsage = "Uso: /wct en tu mensaje  (en, zh, tw, ru, ja, es, ko)",
		outNone = "No hay expresiones del diccionario; no se convirtió nada.",
		addDone = "Palabra añadida: %s → %s", addUsage = "Uso: /wct add palabra=significado   (borrar: /wct del palabra, lista: /wct list)",
		delDone = "Palabra borrada: %s", delNone = "No es una de tus palabras: %s",
		listTitle = "Tus palabras: %d", listEmpty = "No has añadido palabras.",
		collectedTitle = "Frases de descripciones sin traducir: %d (Ctrl+C para copiar)", collectedEmpty = "Todavía no hay frases.",
		help = "/wct - ajustes\n/wct en texto - convertir tu mensaje al inglés (zh, tw, ru, ja, es, ko)\n/wct add palabra=significado - añadir palabra\n/wct del palabra - borrar\n/wct list - tus palabras\n/wct unknown - expresiones desconocidas\n/wct collect - frases sin traducir\n/wct status - estado\n/wct test texto - probar",
		helpTitle = "Comandos",
	},
}
UI.zhTW = {}
for k, v in pairs(UI.zhCN) do UI.zhTW[k] = v end
-- 번체에서 다르게 쓰는 말
UI.zhTW.secLangs, UI.zhTW.secChannels, UI.zhTW.secMisc = "要翻譯的語言", "要翻譯的頻道", "其他"
UI.zhTW.chPublic, UI.zhTW.chSay, UI.zhTW.chGuild = "公共頻道（交易、尋求組隊、綜合）", "說話和大喊", "公會和幹部"
UI.zhTW.chGroup, UI.zhTW.chWhisper = "隊伍、團隊和副本", "密語"
UI.zhTW.optPlayerTip, UI.zhTW.optMinimap = "聊天角色名顯示角色資訊提示（Shift點擊查詢）", "顯示小地圖按鈕"
UI.zhTW.btnUnknown, UI.zhTW.btnCollected, UI.zhTW.btnStatus, UI.zhTW.btnHelp = "未登記詞語", "收集的句子", "複製狀態", "指令"
UI.zhTW.langsShort, UI.zhTW.sameLang = "要翻譯的語言（排除本地語言）", "本地語言"
UI.zhTW.minimapTip = "左鍵：開啟設定\n拖曳：移動按鈕"
UI.zhTW.outDone = "已轉換為%s（辨識%d%%）。請檢查聊天輸入框後按Enter。"
UI.zhTW.outLeft = "未翻譯部分：%s"
UI.zhTW.outUsage = "用法：/wct en 要傳送的句子（en、zh、tw、ru、ja、es、ko）"
UI.zhTW.outNone = "沒有找到詞典中的表達，未轉換。"
UI.zhTW.addDone = "已新增詞語：%s → %s"
UI.zhTW.addUsage = "用法：/wct add 詞語=意思（刪除：/wct del 詞語，列表：/wct list）"
UI.zhTW.delDone, UI.zhTW.delNone = "已刪除詞語：%s", "不是你新增的詞語：%s"
UI.zhTW.listTitle, UI.zhTW.listEmpty = "你新增的詞語：%d個", "還沒有新增詞語。"
UI.zhTW.collectedTitle, UI.zhTW.collectedEmpty = "收集的未翻譯提示句子：%d個（Ctrl+C複製）", "還沒有收集到句子。"
UI.zhTW.help = "/wct - 設定\n/wct en 句子 - 把你的訊息轉換為英語（zh、tw、ru、ja、es、ko）\n/wct add 詞語=意思 - 新增自訂詞語\n/wct del 詞語 - 刪除\n/wct list - 自訂詞語列表\n/wct unknown - 未登記的聊天表達\n/wct collect - 未翻譯的提示句子\n/wct status - 狀態\n/wct test 句子 - 測試"
UI.zhTW.helpTitle = "指令列表"

for lang, strings in pairs(UI) do
	local t = ns.STR[lang]
	if t then
		for k, v in pairs(strings) do t[k] = v end
	end
end
ns.ApplyTarget()
