-- Additional interface languages and character lookup messages.
local ADDON, ns = ...
ns.TARGETS = {"ko", "en", "zhCN", "zhTW", "ja", "ru", "es"}
ns.TARGET_NAME.ja, ns.TARGET_NAME.es = "日本語", "Español"
ns.SAME_SOURCE.ja, ns.SAME_SOURCE.es = "ja", "es"
ns.DEFAULTS.chat.langs.es = true
local locale = GetLocale()
if locale == "esES" or locale == "esMX" then ns.CLIENT_TARGET = "es"
elseif locale == "jaJP" then ns.CLIENT_TARGET = "ja" end
ns.STR.ja = {
 tipUse="使用:", tipEquip="装備:", tipProc="命中時:", title="WoW Chat Translator",
 secTooltip="ツールチップ翻訳", optTooltip="アイテム・呪文の英語説明を翻訳",
 optCollect="未翻訳の文を収集 (/wct collect)",
 tooltipNote="未翻訳の説明をツールチップ下部の WoW Chat Translator 欄に表示します。",
 collectCount="収集した未翻訳の文: %d", collectCleared="収集した文を削除しました。",
 collectHow="ログアウト後、WTF\\Account\\(account)\\SavedVariables\\WoWChatTranslator.lua に保存されます。作者に送信すると辞書を補強できます。(/wct collect clear)",
 glossTitle="%s → 日本語", rough="おおよその意味", terms="登録された表現", noTerms="辞書に登録された表現がありません。",
 clickHint="クリック: コピー画面を開く", copyTitle="Ctrl+C でコピーして翻訳サービスに貼り付けてください",
 copyDonate="Ctrl+C でコピーしてブラウザーに貼り付けてください", close="閉じる", donate="寄付",
 secTarget="翻訳先の言語", auto="自動 - ゲーム言語 (%s)",
 targetNote="他の言語のチャットを選択した言語に翻訳します。画面の言語も切り替わります。",
 secChat="チャット翻訳", optEnabled="チャット翻訳を有効にする", optInline="メッセージの後に意味を表示",
 optCover="意味を表示する最低辞書一致率: %d%%", optTag="メッセージの前に言語タグを表示",
 optHover="メッセージにマウスを重ねて意味を表示", optSelf="自分のメッセージを除外",
 langs="翻訳する言語（翻訳先と同じ言語は除外）", chatNote="設定は新しいメッセージに適用されます。状態: /wct status",
 langName={ko="韓国語",en="英語",zh="中国語",ja="日本語",ru="ロシア語",es="スペイン語"},
 tag={ko="KO",en="EN",zh="ZH",ja="JA",ru="RU",es="ES"},
}
ns.STR.es = {
 tipUse="Uso:", tipEquip="Equipar:", tipProc="Probabilidad al golpear:", title="WoW Chat Translator",
 secTooltip="Traducción de descripciones", optTooltip="Traducir las descripciones en inglés de objetos y hechizos",
 optCollect="Recopilar frases sin traducir (/wct collect)",
 tooltipNote="Las descripciones sin traducir se muestran al final en la sección WoW Chat Translator.",
 collectCount="Frases sin traducir recopiladas: %d", collectCleared="Se borraron las frases recopiladas.",
 collectHow="Se guardan al salir en WTF\\Account\\(account)\\SavedVariables\\WoWChatTranslator.lua. Envía el archivo al autor para ampliar el diccionario. (/wct collect clear)",
 glossTitle="%s → Español", rough="Significado aproximado", terms="Expresiones conocidas", noTerms="No hay expresiones conocidas en el diccionario.",
 clickHint="Clic: abrir la ventana de copia", copyTitle="Pulsa Ctrl+C y pega el texto en un traductor",
 copyDonate="Pulsa Ctrl+C y pega el texto en tu navegador", close="Cerrar", donate="Donar",
 secTarget="Idioma de destino", auto="Automático - idioma del juego (%s)",
 targetNote="Los otros idiomas se traducen al seleccionado. La interfaz también cambia de idioma.",
 secChat="Traducción del chat", optEnabled="Activar traducción del chat", optInline="Añadir el significado al mensaje",
 optCover="Cobertura mínima del diccionario: %d%%", optTag="Mostrar una etiqueta de idioma antes del mensaje",
 optHover="Mostrar el significado al pasar el ratón", optSelf="Excluir mis mensajes",
 langs="Idiomas que traducir (se excluye el idioma de destino)", chatNote="Los cambios se aplican a los mensajes nuevos. Estado: /wct status",
 langName={ko="Coreano",en="Inglés",zh="Chino",ja="Japonés",ru="Ruso",es="Español"},
 tag={ko="KO",en="EN",zh="ZH",ja="JA",ru="RU",es="ES"},
}
local spanishNames={ko="스페인어",en="Spanish",zhCN="西班牙语",zhTW="西班牙語",ru="испанский"}
for lang,label in pairs(spanishNames) do ns.STR[lang].langName.es=label;ns.STR[lang].tag.es="ES" end
ns.PlayerLookupText = {
 ko={level="레벨 %s",loading="불러오는 중… (최대 %d초)",busy="%s 조회 중… (최대 %d초)\n완료 후 Shift+클릭으로 조회하세요.",wait="다음 조회까지 %d초 · 이후 Shift+클릭으로 조회",failed="조회 응답이 없습니다. Shift+클릭으로 다시 조회하세요.",hint="Shift+클릭으로 캐릭터 정보를 조회하세요."},
 en={level="Level %s",loading="Loading… (up to %ds)",busy="Looking up %s (up to %ds).\nShift-click after completion.",wait="Next lookup in %ds; Shift-click after the wait",failed="No response. Shift-click to retry.",hint="Shift-click to look up character details."},
 zhCN={level="等级 %s",loading="读取中…（最多%d秒）",busy="正在查询%s（最多%d秒）\n完成后按Shift点击查询。",wait="下次查询还需%d秒；之后按Shift点击",failed="查询无响应。按Shift点击重试。",hint="按Shift点击查询角色信息。"},
 zhTW={level="等級 %s",loading="讀取中…（最多%d秒）",busy="正在查詢%s（最多%d秒）\n完成後按Shift點擊查詢。",wait="下次查詢還需%d秒；之後按Shift點擊",failed="查詢無回應。按Shift點擊重試。",hint="按Shift點擊查詢角色資訊。"},
 ja={level="レベル %s",loading="読み込み中…（最大%d秒）",busy="%sを検索中（最大%d秒）\n完了後にShift+クリックしてください。",wait="次の検索まで%d秒・その後Shift+クリック",failed="応答がありません。Shift+クリックで再試行。",hint="Shift+クリックでキャラクター情報を検索します。"},
 ru={level="Уровень %s",loading="Загрузка… (до %d с)",busy="Поиск %s (до %d с)\nПосле завершения нажмите Shift+щелчок.",wait="До следующего поиска %d с; затем Shift+щелчок",failed="Нет ответа. Shift+щелчок для повтора.",hint="Shift+щелчок для поиска персонажа."},
 es={level="Nivel %s",loading="Cargando… (hasta %d s)",busy="Buscando a %s (hasta %d s)\nPulsa Mayús+clic cuando termine.",wait="Próxima consulta en %d s; después Mayús+clic",failed="Sin respuesta. Mayús+clic para reintentar.",hint="Mayús+clic para consultar el personaje."},
}
ns.ApplyTarget()
