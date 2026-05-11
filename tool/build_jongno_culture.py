# -*- coding: utf-8 -*-
"""
문화체육관광부 전국문화기반시설 현황 엑셀에서 종로구 시설 추출.
도서관 / 박물관 / 미술관 / 공연장(문예회관) / 문화의집 / 문학관 / 지방문화원 / 생활문화센터 / 지역문화재단.

Run: python tool/build_jongno_culture.py
"""
import json
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

import openpyxl

XLSX_PATH = Path("assets/culture_facillity_2025.xlsx")
LOCAL_JSON_PATH = Path("assets/jongno_culture.json")

GOOGLE_API_KEY = "AIzaSyDDxfuNuVSbsOg5myMHfVGGnG1tEPhlgFs"


def geocode(address):
    if not address:
        return None, None
    url = (
        "https://maps.googleapis.com/maps/api/geocode/json?"
        + urllib.parse.urlencode({
            "address": address,
            "language": "ko",
            "key": GOOGLE_API_KEY,
        })
    )
    try:
        with urllib.request.urlopen(url, timeout=10) as r:
            data = json.loads(r.read().decode("utf-8"))
        if data.get("status") == "OK" and data.get("results"):
            loc = data["results"][0]["geometry"]["location"]
            return loc["lat"], loc["lng"]
    except Exception as e:
        print(f"  geocode error for {address[:40]}: {e}", file=sys.stderr)
    return None, None


def s(v):
    return "" if v is None else str(v).strip()


def is_jongno(sido, sgg):
    sido_s = s(sido)
    sgg_s = s(sgg)
    return ('서울' in sido_s or '서울특별' in sido_s) and ('종로' in sgg_s)


def is_jongno_in_addr(addr):
    a = s(addr)
    return '종로구' in a


# 시트별 추출기. 각 함수는 (name, addr, tel, homepage) 튜플 반환 (없으면 None)
def extract_library(ws, type_label):
    """국립도서관/공공도서관: header row 4, data row 5+"""
    out = []
    for r in range(5, ws.max_row + 1):
        sido = ws.cell(r, 2).value
        sgg = ws.cell(r, 3).value
        if not is_jongno(sido, sgg):
            continue
        out.append({
            'name': s(ws.cell(r, 5).value),
            'addr': s(ws.cell(r, 6).value),
            'tel': s(ws.cell(r, 7).value),
            'homepage': s(ws.cell(r, 8).value) or None,
            'type': type_label,
        })
    return out


def extract_museum(ws, type_label):
    """박물관/미술관: 헤더 row 5+6 (소재지=c2/c3, 명=c6, 주소=c7, 연락처=c8, 홈=c13). Data row 7+"""
    out = []
    for r in range(7, ws.max_row + 1):
        sido = ws.cell(r, 2).value
        sgg = ws.cell(r, 3).value
        if not is_jongno(sido, sgg):
            continue
        out.append({
            'name': s(ws.cell(r, 6).value),
            'addr': s(ws.cell(r, 7).value),
            'tel': s(ws.cell(r, 8).value),
            'homepage': s(ws.cell(r, 13).value) or None,
            'type': type_label,
        })
    return out


def extract_munyeo(ws, type_label):
    """문예회관: header row 4+5. col2=시도, col3=시군구, col5=시설명, col6=주소, col7=연락처, col10=홈"""
    out = []
    for r in range(6, ws.max_row + 1):
        sido = ws.cell(r, 2).value
        sgg = ws.cell(r, 3).value
        if not is_jongno(sido, sgg):
            continue
        out.append({
            'name': s(ws.cell(r, 5).value),
            'addr': s(ws.cell(r, 6).value),
            'tel': s(ws.cell(r, 7).value),
            'homepage': s(ws.cell(r, 10).value) or None,
            'type': type_label,
        })
    return out


def extract_jiban(ws, type_label):
    """지방문화원: row 4 header, data row 5+. col2=시도, col3=시군구, col4=문화원명, col7=주소, col8=연락처, col9=홈"""
    out = []
    for r in range(5, ws.max_row + 1):
        sido = ws.cell(r, 2).value
        sgg = ws.cell(r, 3).value
        if not is_jongno(sido, sgg):
            continue
        out.append({
            'name': s(ws.cell(r, 4).value),
            'addr': s(ws.cell(r, 7).value),
            'tel': s(ws.cell(r, 8).value),
            'homepage': s(ws.cell(r, 9).value) or None,
            'type': type_label,
        })
    return out


def extract_house(ws, type_label):
    """문화의집: col2=시도, col3=시군구, col4=문화의집명, col5=주소, col6=전화, col7=홈"""
    out = []
    for r in range(5, ws.max_row + 1):
        sido = ws.cell(r, 2).value
        sgg = ws.cell(r, 3).value
        if not is_jongno(sido, sgg):
            continue
        out.append({
            'name': s(ws.cell(r, 4).value),
            'addr': s(ws.cell(r, 5).value),
            'tel': s(ws.cell(r, 6).value),
            'homepage': s(ws.cell(r, 7).value) or None,
            'type': type_label,
        })
    return out


def extract_munhakwan(ws, type_label):
    """문학관: row 5+6 헤더. col2=시도, col3=시군구, col10=문학관명, col11=주소, col12=연락처, col14=홈"""
    out = []
    for r in range(7, ws.max_row + 1):
        sido = ws.cell(r, 2).value
        sgg = ws.cell(r, 3).value
        if not is_jongno(sido, sgg):
            continue
        out.append({
            'name': s(ws.cell(r, 10).value),
            'addr': s(ws.cell(r, 11).value),
            'tel': s(ws.cell(r, 12).value),
            'homepage': s(ws.cell(r, 14).value) or None,
            'type': type_label,
        })
    return out


def extract_living(ws, type_label):
    """생활문화센터: col2=시도, col3=시군구, col4=시설명, col9=주소, col10=전화, col11=홈"""
    out = []
    for r in range(5, ws.max_row + 1):
        sido = ws.cell(r, 2).value
        sgg = ws.cell(r, 3).value
        if not is_jongno(sido, sgg):
            continue
        out.append({
            'name': s(ws.cell(r, 4).value),
            'addr': s(ws.cell(r, 9).value),
            'tel': s(ws.cell(r, 10).value),
            'homepage': s(ws.cell(r, 11).value) or None,
            'type': type_label,
        })
    return out


def extract_jaedan(ws, type_label):
    """지역문화재단: col2=시도, col3=시군구, col4=재단명, col5=주소, col6=연락처, col7=홈"""
    out = []
    for r in range(5, ws.max_row + 1):
        sido = ws.cell(r, 2).value
        sgg = ws.cell(r, 3).value
        if not is_jongno(sido, sgg):
            continue
        out.append({
            'name': s(ws.cell(r, 4).value),
            'addr': s(ws.cell(r, 5).value),
            'tel': s(ws.cell(r, 6).value),
            'homepage': s(ws.cell(r, 7).value) or None,
            'type': type_label,
        })
    return out


SHEET_MAP = [
    # (sheet_index, type_label, extractor)
    (0, '도서관', extract_library),
    (1, '도서관', extract_library),
    (2, '박물관', extract_museum),
    (3, '미술관', extract_museum),
    (5, '공연장', extract_munyeo),
    (7, '문화의집', extract_house),
    (8, '문학관', extract_munhakwan),
    (6, '지방문화원', extract_jiban),
    (4, '생활문화센터', extract_living),
    (9, '지역문화재단', extract_jaedan),
]


def main():
    wb = openpyxl.load_workbook(XLSX_PATH, read_only=False)
    all_rows = []
    for idx, type_label, fn in SHEET_MAP:
        ws = wb.worksheets[idx]
        rows = fn(ws, type_label)
        rows = [r for r in rows if r['name']]
        print(f'sheet[{idx}] {wb.sheetnames[idx]} ({type_label}): {len(rows)}개')
        all_rows.extend(rows)

    # Add coords
    print('\n=== Geocoding ===')
    out = []
    seen_names = set()
    for r in all_rows:
        if r['name'] in seen_names:
            continue
        seen_names.add(r['name'])
        lat, lng = geocode(r['addr'])
        time.sleep(0.05)
        out.append({
            'id': f'cu_{abs(hash(r["name"])) % 100000:05d}',
            'name': r['name'],
            'addr': r['addr'],
            'lat': lat,
            'lng': lng,
            'type': r['type'],
            'tel': r['tel'],
            'homepage': r['homepage'],
        })
        if lat:
            print(f'  [OK] {r["name"]} ({r["type"]}) -> ({lat:.4f}, {lng:.4f})')
        else:
            print(f'  [FAIL] {r["name"]} ({r["type"]}) -> 좌표 없음')

    # Sort by type then name
    type_order = {'미술관': 0, '박물관': 1, '공연장': 2, '도서관': 3,
                  '문학관': 4, '문화의집': 5, '지방문화원': 6,
                  '생활문화센터': 7, '지역문화재단': 8}
    out.sort(key=lambda x: (type_order.get(x['type'], 99), x['name']))

    LOCAL_JSON_PATH.write_text(
        json.dumps({'data': out}, ensure_ascii=False, indent=2),
        encoding='utf-8',
    )
    print(f'\nTotal: {len(out)}개')
    print(f'좌표 있음: {sum(1 for x in out if x["lat"])}')
    by_type = {}
    for x in out:
        by_type[x['type']] = by_type.get(x['type'], 0) + 1
    for t, c in by_type.items():
        print(f'  {t}: {c}개')
    print(f'\nWrote {LOCAL_JSON_PATH}')


if __name__ == '__main__':
    main()
