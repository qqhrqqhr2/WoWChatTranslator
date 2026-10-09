"""WoW Forever 게임 데이터(주문·특성·아이템)를 영어/한국어/간체/번체로 모은다.
툴팁 번역표(build_tooltip.py)의 재료가 된다.
사용: python3 tools/fetch_db.py <출력 폴더>
      (출력 폴더에 spellbook/talents/dungeons/items JSON 이 생긴다)
"""
import json
import os
import re
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor

BASE = "https://wowf.io"
LANGS = ["en", "ko", "zh", "tw"]
CLASSES = ["warrior", "paladin", "hunter", "rogue", "priest", "shaman", "mage", "warlock", "druid"]
PROFS = ["alchemy", "blacksmithing", "cooking", "enchanting", "engineering", "first-aid",
         "leatherworking", "tailoring", "mining", "fishing", "herbalism", "skinning"]
OUT = sys.argv[1]
os.makedirs(OUT, exist_ok=True)


def curl(url, tries=3):
    for _ in range(tries):
        r = subprocess.run(["curl", "-s", "--compressed", "-m", "60", url], capture_output=True)
        if r.returncode == 0 and r.stdout:
            return r.stdout.decode("utf-8", "replace")
        time.sleep(2)
    return ""


def page_data(url):
    """Next.js 페이지에 묻혀 있는 데이터 문자열"""
    h = curl(url)
    chunks = re.findall(r'self\.__next_f\.push\(\[1,"(.*?)"\]\)</script>', h, re.S)
    out = []
    for c in chunks:
        try:
            out.append(json.loads('"' + c + '"'))
        except Exception:
            pass
    return "".join(out)


def objects_with(big, key):
    """big 안에서 key 를 가진 JSON 객체를 모두 꺼낸다"""
    dec = json.JSONDecoder()
    res = []
    for m in re.finditer(r'\{"id":', big):
        try:
            obj, _ = dec.raw_decode(big, m.start())
        except Exception:
            continue
        if isinstance(obj, dict) and key in obj:
            res.append(obj)
    return res


def walk(o, fn):
    if isinstance(o, dict):
        fn(o)
        for v in o.values():
            walk(v, fn)
    elif isinstance(o, list):
        for v in o:
            walk(v, fn)


# 1) 주문책·특성 ---------------------------------------------------------
def fetch_class_pages(kind):
    res = {}
    for lang in LANGS:
        res[lang] = {}
        for cls in CLASSES:
            big = page_data(f"{BASE}/{lang}/{kind}/{cls}")
            found = {}
            for obj in objects_with(big, "ranks"):
                sid = obj.get("id")
                if not isinstance(sid, str):
                    continue
                ranks = []
                for r in obj.get("ranks") or []:
                    if isinstance(r, dict):
                        ranks.append(r.get("desc") or "")
                    elif isinstance(r, str):
                        ranks.append(r)
                found[sid] = {"name": obj.get("name"), "nameEn": obj.get("nameEn"), "ranks": ranks}
            res[lang][cls] = found
            print(kind, lang, cls, len(found), flush=True)
            time.sleep(0.3)
    json.dump(res, open(os.path.join(OUT, f"{kind}.json"), "w"), ensure_ascii=False)
    return res


# 2) 던전 페이지의 아이템(이름·효과)과 아이템 ID 모으기 ---------------------
def fetch_dungeon_items():
    sm = curl(f"{BASE}/sitemap.xml")
    urls = sorted(set(u for u in re.findall(r"<loc>([^<]+)</loc>", sm) if "/en/dungeons/" in u))
    items = {lang: {} for lang in LANGS}
    for url in urls:
        for lang in LANGS:
            big = page_data(url.replace("/en/", f"/{lang}/"))
            for obj in objects_with(big, "effects"):
                if isinstance(obj.get("id"), int):
                    items[lang][obj["id"]] = {"name": obj.get("name"), "effects": obj.get("effects") or [],
                                              "flavor": obj.get("flavor")}
            time.sleep(0.2)
        print("dungeon", url.rsplit("/", 2)[-2:], len(items["en"]), flush=True)
    return items


def profession_item_ids():
    ids = set()
    for p in PROFS:
        pg, pages = 1, 1
        while pg <= pages:
            try:
                d = json.loads(curl(f"{BASE}/api/professions/{p}/recipes?l=en&p={pg}"))
            except Exception:
                break
            pages = d.get("pages", 1)
            for x in d.get("items", []):
                if x.get("i"):
                    ids.add(x["i"])
                for r in x.get("r") or []:
                    if isinstance(r, list) and r:
                        ids.add(r[0])
            pg += 1
            time.sleep(0.2)
        print("prof", p, len(ids), flush=True)
    return ids


# 3) 아이템 API (개별) ----------------------------------------------------
def fetch_item(args):
    iid, lang = args
    txt = curl(f"{BASE}/api/items/{iid}?l={lang}")
    try:
        d = json.loads(txt)
    except Exception:
        return iid, lang, None
    if not isinstance(d, dict) or d.get("id") != iid:
        return iid, lang, None
    return iid, lang, {"name": d.get("name"), "effects": d.get("effects") or [], "flavor": d.get("flavor")}


def main():
    fetch_class_pages("spellbook")
    fetch_class_pages("talents")
    items = fetch_dungeon_items()
    ids = profession_item_ids()
    extra = sys.argv[2] if len(sys.argv) > 2 else None
    if extra and os.path.exists(extra):
        ids |= set(int(x) for x in re.findall(r"\[(\d{5,7})\]\s*=", open(extra, encoding="utf-8").read()))
    # 포에버에서 새로 생긴 아이템(대부분 ID 100000 이상)만 개별 조회
    todo = sorted(i for i in ids if i >= 100000 and i not in items["en"])
    print("item api:", len(todo), flush=True)
    jobs = [(i, l) for i in todo for l in LANGS]
    with ThreadPoolExecutor(max_workers=6) as ex:
        for n, (iid, lang, d) in enumerate(ex.map(fetch_item, jobs), 1):
            if d:
                items[lang][iid] = d
            if n % 400 == 0:
                print("  items", n, "/", len(jobs), flush=True)
    json.dump(items, open(os.path.join(OUT, "items.json"), "w"), ensure_ascii=False)
    print("done", {l: len(v) for l, v in items.items()})


if __name__ == "__main__":
    main()
