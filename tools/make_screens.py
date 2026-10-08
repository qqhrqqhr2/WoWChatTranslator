"""CurseForge 소개 이미지 만들기 (게임 화면을 흉내 낸 설명용 이미지).
번역 결과는 tools/engine_samples.py 가 애드온 엔진으로 만든 실제 값을 쓴다.
사용: python3 tools/make_screens.py samples.json assets/screens
"""
import json
import os
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

S = json.load(open(sys.argv[1], encoding="utf-8"))
OUT = sys.argv[2]
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FD = "/usr/share/fonts/opentype/noto/"


def font(size, weight="Medium"):
    return ImageFont.truetype(FD + f"NotoSansCJK-{weight}.ttc", size, index=1)  # KR


W, H = 1280, 720

# 와우 채팅 색
C_CHANNEL = (255, 192, 192)
C_TRADE = (255, 192, 192)
C_GUILD = (64, 255, 64)
C_PARTY = (170, 170, 255)
C_WHISPER = (255, 128, 255)
C_INLINE = (136, 221, 136)
TAG = {"ko": (160, 232, 160), "zh": (255, 204, 102), "ja": (255, 153, 204), "ru": (153, 204, 255), "en": (204, 204, 204)}
TAGTXT = {
    "ko": {"ko": "韓", "zh": "中", "ja": "日", "ru": "RU", "en": "EN"},
    "en": {"ko": "KO", "zh": "ZH", "ja": "JA", "ru": "RU", "en": "EN"},
    "zhCN": {"ko": "韩", "zh": "中", "ja": "日", "ru": "俄", "en": "英"},
    "zhTW": {"ko": "韓", "zh": "中", "ja": "日", "ru": "俄", "en": "英"},
    "ru": {"ko": "KO", "zh": "ZH", "ja": "JA", "ru": "RU", "en": "EN"},
}
CLASS = {
    "warrior": (199, 156, 110), "mage": (105, 204, 240), "priest": (255, 255, 255), "rogue": (255, 245, 105),
    "hunter": (171, 212, 115), "druid": (255, 125, 10), "paladin": (245, 140, 186), "shaman": (0, 112, 222),
    "warlock": (148, 130, 201),
}


def background(seed=0):
    """판타지 느낌의 어두운 배경 (게임 이미지 아님)."""
    img = Image.new("RGB", (W, H))
    px = img.load()
    for y in range(H):
        t = y / H
        r = int(22 + 30 * t)
        g = int(30 + 10 * t)
        b = int(48 - 18 * t)
        for x in range(W):
            px[x, y] = (r, g, b)
    glow = Image.new("L", (W, H), 0)
    gd = ImageDraw.Draw(glow)
    cx = [900, 300, 640][seed % 3]
    gd.ellipse((cx - 420, -260, cx + 420, 420), fill=120)
    glow = glow.filter(ImageFilter.GaussianBlur(120))
    warm = Image.new("RGB", (W, H), (120, 90, 50))
    img = Image.composite(warm, img, glow.point(lambda v: v // 3))
    # 아래쪽 산 실루엣
    sil = ImageDraw.Draw(img)
    import math
    pts = [(0, H)]
    for x in range(0, W + 20, 20):
        y = int(H - 150 - 60 * math.sin(x / 170 + seed) - 30 * math.sin(x / 61 + seed * 2))
        pts.append((x, y))
    pts.append((W, H))
    sil.polygon(pts, fill=(14, 16, 24))
    return img.convert("RGBA")


def text_w(d, s, f):
    return d.textlength(s, font=f)


def draw_shadow_text(d, xy, s, f, fill):
    x, y = xy
    d.text((x + 1, y + 1), s, font=f, fill=(0, 0, 0, 230))
    d.text((x, y), s, font=f, fill=fill)


def draw_segments(d, x, y, segs, f, maxw, lh, indent=24, draw=True):
    """색이 다른 글자 조각들을 단어 단위로 줄바꿈하며 그린다. 끝난 y 를 돌려준다."""
    import re as _re
    cx = x
    for text, color in segs:
        for tok in _re.findall(r"\s+|\S+", text):
            w = text_w(d, tok, f)
            if cx + w > x + maxw and cx > x + indent:
                if tok.isspace():
                    continue
                y += lh
                cx = x + indent
            if cx + w > x + maxw:  # 한 단어가 너무 길면 글자 단위로
                for ch in tok:
                    cw = text_w(d, ch, f)
                    if cx + cw > x + maxw:
                        y += lh
                        cx = x + indent
                    if draw:
                        draw_shadow_text(d, (cx, y), ch, f, color)
                    cx += cw
                continue
            if draw:
                draw_shadow_text(d, (cx, y), tok, f, color)
            cx += w
    return y + lh


def panel(img, box, alpha=150, radius=8):
    ov = Image.new("RGBA", img.size, (0, 0, 0, 0))
    od = ImageDraw.Draw(ov)
    od.rounded_rectangle(box, radius=radius, fill=(0, 0, 0, alpha))
    return Image.alpha_composite(img, ov)


def caption(img, title, sub):
    d = ImageDraw.Draw(img)
    f1, f2 = font(44, "Bold"), font(24, "Regular")
    draw_shadow_text(d, (48, 36), title, f1, (255, 209, 0))
    draw_shadow_text(d, (50, 98), sub, f2, (225, 225, 225))
    return img


def chat_line(name_cls, name, channel, ch_color, sample, target, untouched=None):
    """채팅 한 줄을 조각 목록으로 만든다 (애드온이 실제로 붙이는 형식)."""
    segs = [(f"[{channel}] ", ch_color), ("[", ch_color), (name, CLASS[name_cls]), ("]: ", ch_color)]
    if untouched:
        segs.append((untouched, ch_color))
        return segs
    s = S[sample]
    g = s[target]
    same = {"ko": "ko", "en": "en", "zhCN": "zh", "zhTW": "zh", "ru": "ru"}[target]
    if g["lang"] == same:
        segs.append((s["text"], ch_color))
        return segs
    segs.append((f"[{TAGTXT[target][g['lang']]}] ", TAG[g["lang"]]))
    segs.append((s["text"], ch_color))
    segs.append((f" ({g['plain']})", C_INLINE))
    return segs


def legend(img, y, items):
    d = ImageDraw.Draw(img)
    f = font(22, "Regular")
    x = 48
    for chip, chip_color, label in items:
        draw_shadow_text(d, (x, y), chip, font(22, "Bold"), chip_color)
        x += text_w(d, chip, font(22, "Bold")) + 10
        draw_shadow_text(d, (x, y), label, f, (210, 210, 210))
        x += text_w(d, label, f) + 40


# 1) 한국어 클라이언트 채팅 -------------------------------------------------
def shot_chat(target, fname, title, sub, ch_names):
    img = caption(background(0), title, sub)
    d = ImageDraw.Draw(img)
    f = font(24, "Medium")
    general, trade, guild = ch_names
    lines = [
        chat_line("warrior", "Edrack", general, C_CHANNEL, "en1", target),
        chat_line("priest", "晨曦", general, C_CHANNEL, "zh1", target),
        chat_line("mage", "Иван", trade, C_TRADE, "ru1", target),
        chat_line("hunter", "Bob", trade, C_TRADE, "en3", target),
        chat_line("rogue", "ユキ", general, C_CHANNEL, "ja1", target),
    ]
    if target == "ko":
        lines.append(chat_line("paladin", "토끼", guild, C_GUILD, None, target, untouched="내일 화심 가실 분?"))
    else:
        lines.append(chat_line("paladin", "토끼", general, C_CHANNEL, "ko1", target))
    y = 184
    for segs in lines:
        y = draw_segments(d, 56, y, segs, f, W - 130, 36, draw=False) + 10
    bottom = y + 14
    img = panel(img, (36, 160, W - 36, bottom))
    d = ImageDraw.Draw(img)
    y = 184
    for segs in lines:
        y = draw_segments(d, 56, y, segs, f, W - 130, 36) + 10
    tags = TAGTXT[target]
    if target == "ko":
        legend(img, bottom + 22, [(f"[{tags['zh']}] [RU] [EN]", TAG["zh"], "원문 언어 표시"),
                          ("( … )", C_INLINE, "현지 언어로 풀이"), ("한국어", C_GUILD, "채팅은 그대로 표시")])
    else:
        legend(img, bottom + 22, [("[ZH] [RU] [KO]", TAG["zh"], "source language tag"),
                          ("( … )", C_INLINE, "meaning in your language"), ("English", (220, 220, 220), "chat is left as is")])
    img.convert("RGB").save(os.path.join(OUT, fname))


# 2) 마우스 오버 툴팁 --------------------------------------------------------
def shot_tooltip():
    img = caption(background(1), "Hover for details  ·  마우스를 올리면 자세히",
                  "원문, 대략적인 뜻, 찾은 표현 목록 · 클릭하면 원문 복사창 (번역기에 붙여넣기)")
    d = ImageDraw.Draw(img)
    f = font(23, "Medium")
    lines = [chat_line("warrior", "Edrack", "1. 공개 - 오그리마", C_CHANNEL, "en2", "ko"),
             chat_line("priest", "晨曦", "1. 공개 - 오그리마", C_CHANNEL, "zh2", "ko")]
    top = 520
    y = top + 18
    for segs in lines:
        y = draw_segments(d, 56, y, segs, f, W - 130, 34, draw=False) + 8
    img = panel(img, (36, top, W - 36, y + 10))
    d = ImageDraw.Draw(img)
    y = top + 18
    line_y = []
    for segs in lines:
        line_y.append(y)
        y = draw_segments(d, 56, y, segs, f, W - 130, 34) + 8

    # 툴팁 (중국어 메시지)
    s = S["zh2"]["ko"]
    tf, tb = font(21, "Regular"), font(21, "Bold")
    rows = [("title", "중국어 → 한국어"), ("orig", S["zh2"]["text"]), ("gap", ""), ("hdr", "대략적인 뜻"), ("rough", s["rough"]),
            ("gap", ""), ("hdr", "찾은 표현")]
    rows += [("term", t) for t in s["terms"][:5]]
    rows += [("gap", ""), ("hint", "클릭: 복사창 열기 (번역기에 붙여넣기)")]
    widths = []
    for kind, val in rows:
        if kind == "rough":
            widths.append(sum(text_w(d, p, tf) for _, p in val))
        elif kind == "term":
            widths.append(text_w(d, val[0], tf) + 60 + text_w(d, val[1], tf))
        elif kind != "gap":
            widths.append(text_w(d, val, tb if kind == "title" else tf))
    tw = int(max(widths)) + 32
    th = 22 + sum(12 if r[0] == "gap" else 29 for r in rows)
    cx, cy = 560, line_y[1] + 8          # 마우스 위치 (두 번째 줄 위)
    tx, ty = cx + 24, top - th - 10   # 채팅창 바로 위 (글을 가리지 않게)
    ov = Image.new("RGBA", img.size, (0, 0, 0, 0))
    od = ImageDraw.Draw(ov)
    od.rounded_rectangle((tx, ty, tx + tw, ty + th), radius=6, fill=(8, 8, 18, 240), outline=(150, 150, 160, 255), width=3)
    img = Image.alpha_composite(img, ov)
    d = ImageDraw.Draw(img)
    y = ty + 12
    for kind, val in rows:
        if kind == "gap":
            y += 12
            continue
        if kind == "title":
            d.text((tx + 16, y), val, font=tb, fill=(102, 204, 255))
        elif kind == "orig":
            d.text((tx + 16, y), val, font=tf, fill=(255, 255, 255))
        elif kind == "hdr":
            d.text((tx + 16, y), val, font=tf, fill=(255, 209, 0))
        elif kind == "rough":
            x = tx + 16
            for k, part in val:
                d.text((x, y), part, font=tf, fill=(153, 255, 153) if k == "hit" else (255, 255, 255))
                x += text_w(d, part, tf)
        elif kind == "term":
            d.text((tx + 16, y), val[0], font=tf, fill=(230, 230, 230))
            d.text((tx + tw - 16 - text_w(d, val[1], tf), y), val[1], font=tf, fill=(153, 255, 153))
        elif kind == "hint":
            d.text((tx + 16, y), val, font=tf, fill=(128, 128, 128))
        y += 29
    # 마우스 커서
    d.polygon([(cx, cy), (cx, cy + 30), (cx + 8, cy + 23), (cx + 14, cy + 36), (cx + 19, cy + 33), (cx + 13, cy + 21), (cx + 23, cy + 21)],
              fill=(255, 255, 255), outline=(0, 0, 0))
    img.convert("RGB").save(os.path.join(OUT, "03_tooltip.png"))


# 3) 설정창 ----------------------------------------------------------------
def shot_settings():
    img = caption(background(2), "Pick your local language  ·  현지 언어 선택",
                  "한국어 · English · 简体中文 · 繁體中文 · Русский — 바꾸면 번역과 화면 문구가 바로 바뀜")
    wx, wy, ww, wh = 340, 138, 600, 570
    ov = Image.new("RGBA", img.size, (0, 0, 0, 0))
    od = ImageDraw.Draw(ov)
    od.rounded_rectangle((wx, wy, wx + ww, wy + wh), radius=10, fill=(16, 14, 12, 245), outline=(120, 104, 74, 255), width=6)
    od.rounded_rectangle((wx + 8, wy + 8, wx + ww - 8, wy + wh - 8), radius=6, outline=(40, 34, 26, 255), width=2)
    img = Image.alpha_composite(img, ov)
    d = ImageDraw.Draw(img)
    gold, white, grey = (255, 209, 0), (255, 255, 255), (150, 150, 150)
    fT, fH, fL, fS = font(24, "Bold"), font(22, "Bold"), font(19, "Regular"), font(16, "Regular")
    title = "채팅 번역기 (WoW Chat Translator)"
    tx0 = wx + ww / 2 - text_w(d, title, fT) / 2 + 18
    d.text((tx0, wy + 18), title, font=fT, fill=gold)
    ic = Image.open(os.path.join(ROOT, "assets", "logo_1024.png")).convert("RGBA").resize((34, 34), Image.LANCZOS)
    img.alpha_composite(ic, (int(tx0 - 42), wy + 16))
    d = ImageDraw.Draw(img)
    d.text((wx + ww - 40, wy + 14), "×", font=font(26, "Bold"), fill=(200, 60, 40))
    col = [wx + 26, wx + 214, wx + 402]

    def check(x, y, label, on, color=white):
        d.rounded_rectangle((x, y + 2, x + 20, y + 22), radius=3, fill=(30, 30, 30), outline=(180, 160, 90), width=2)
        if on:
            d.line([(x + 4, y + 12), (x + 9, y + 18), (x + 18, y + 5)], fill=(255, 210, 0), width=4)
        d.text((x + 30, y), label, font=fL, fill=color)

    def small_btn(x, y, label):
        d.rounded_rectangle((x, y, x + 28, y + 26), radius=4, fill=(120, 20, 10), outline=(200, 160, 80), width=2)
        d.text((x + 14 - text_w(d, label, fL) / 2, y - 1), label, font=fL, fill=gold)

    x0, y = col[0], wy + 60
    d.text((x0, y), "현지 언어 (번역 결과 언어)", font=fH, fill=gold); y += 32
    check(x0, y, "자동 - 게임 언어 (한국어)", True); y += 28
    check(col[0], y, "한국어", False); check(col[1], y, "English", False); check(col[2], y, "简体中文", False); y += 28
    check(col[0], y, "繁體中文", False); check(col[1], y, "Русский", False); y += 32
    d.text((x0, y), "다른 언어 채팅을 모두 이 언어로 풀어 줍니다. 화면 문구도 이 언어로 바뀝니다.", font=fS, fill=grey); y += 34
    d.text((x0, y), "채팅 번역", font=fH, fill=gold); y += 32
    check(x0, y, "채팅 번역 사용", True); y += 28
    check(x0, y, "메시지 뒤에 대략적인 뜻 바로 붙이기", True); y += 30
    small_btn(x0 + 30, y, "-"); small_btn(x0 + 64, y, "+")
    d.text((x0 + 102, y), "뜻을 붙일 최소 풀이 비율: 40%", font=fL, fill=white); y += 32
    check(x0, y, "메시지 앞에 언어 표시 붙이기 ([中] [RU] 등)", True); y += 28
    check(x0, y, "메시지 전체에 마우스를 올려도 풀이 보기", True); y += 28
    check(x0, y, "내가 보낸 메시지는 제외", True); y += 32
    d.text((x0 + 4, y), "번역할 언어 (현지 언어와 같은 언어는 제외)", font=font(19, "Bold"), fill=gold); y += 28
    for i, (lab, color) in enumerate([("한국어", grey), ("중국어", white), ("일본어", white), ("러시아어", white), ("영어", white)]):
        check(col[i % 3], y + (i // 3) * 28, lab, True, color)
    # 아래 버튼
    for bx, lab, w in [(wx + 24, "후원하기", 120), (wx + ww - 124, "닫기", 100)]:
        by = wy + wh - 46
        d.rounded_rectangle((bx, by, bx + w, by + 30), radius=5, fill=(120, 20, 10), outline=(200, 160, 80), width=2)
        d.text((bx + w / 2 - text_w(d, lab, fL) / 2, by + 3), lab, font=fL, fill=gold)
    img.convert("RGB").save(os.path.join(OUT, "04_settings.png"))


# 4) 언어별 비교 ------------------------------------------------------------
def shot_languages():
    img = caption(background(1), "Every language → your language  ·  모든 언어를 현지 언어로",
                  "같은 메시지가 현지 언어 설정에 따라 이렇게 풀립니다 (같은 언어는 번역하지 않음)")
    img = panel(img, (36, 150, W - 36, 690))
    d = ImageDraw.Draw(img)
    fH, fL, fB = font(23, "Bold"), font(22, "Regular"), font(22, "Medium")
    names = {"ko": "한국어", "en": "English", "zhCN": "简体中文", "zhTW": "繁體中文", "ru": "Русский"}
    y = 170
    for key, src_lang, targets in [("ko1", "ko", ["en", "zhCN", "zhTW", "ru"]), ("zh1", "zh", ["ko", "en", "ru"]),
                                   ("en2", "en", ["ko", "zhCN", "ru"])]:
        src = S[key]["text"]
        draw_shadow_text(d, (56, y), "▶ " + src, fH, TAG[src_lang])
        y += 38
        for t in targets:
            draw_shadow_text(d, (84, y), names[t], fB, (200, 200, 200))
            draw_shadow_text(d, (250, y), S[key][t]["plain"], fL, C_INLINE)
            y += 32
        y += 12
    img.convert("RGB").save(os.path.join(OUT, "05_languages.png"))


# 0) 배너 -------------------------------------------------------------------
def banner():
    bw, bh = 1200, 360
    img = background(0).resize((bw, int(H * bw / W))).crop((0, 40, bw, 40 + bh))
    logo = Image.open(os.path.join(ROOT, "assets", "logo_1024.png")).convert("RGBA").resize((260, 260), Image.LANCZOS)
    img.alpha_composite(logo, (60, 50))
    d = ImageDraw.Draw(img)
    draw_shadow_text(d, (360, 70), "WoW Chat Translator", font(64, "Bold"), (255, 209, 0))
    draw_shadow_text(d, (364, 160), "Translate Korean · Chinese · Japanese · Russian · English chat", font(26, "Medium"), (235, 235, 235))
    draw_shadow_text(d, (364, 198), "into your own language — right in the chat window.", font(26, "Medium"), (235, 235, 235))
    draw_shadow_text(d, (364, 252), "외국어 채팅을 현지 언어로 · 게임 은어·약어·와우 용어 사전 4,800개", font(24, "Regular"), (200, 220, 200))
    img.convert("RGB").save(os.path.join(OUT, "00_banner.png"))


os.makedirs(OUT, exist_ok=True)
banner()
shot_chat("ko", "01_chat_korean.png", "Foreign chat in Korean  ·  외국어 채팅을 한국어로",
          "한국어 클라이언트 예시 — 중국어·러시아어·영어·일본어 채팅 뒤에 한국어 뜻이 붙습니다",
          ("1. 공개 - 오그리마", "2. 거래 - 오그리마", "길드"))
shot_chat("en", "02_chat_english.png", "Foreign chat in English  ·  영어 클라이언트",
          "English client example — Korean, Chinese, Russian and Japanese chat with the meaning appended",
          ("1. General - Orgrimmar", "2. Trade - Orgrimmar", "Guild"))
shot_tooltip()
shot_settings()
shot_languages()
print("done")
