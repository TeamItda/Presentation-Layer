# -*- coding: utf-8 -*-
"""
국민건강보험공단 장기요양기관 시설별 현황 엑셀에서 종로구 시설 추출.
기존 jongno_welfare.json 에 longTermAdminSym/adminPttnCd 매핑 + 신규 시설 추가.

Run: python tool/build_jongno_welfare.py
"""
import json
import sys
import time
import urllib.parse
import urllib.request
from collections import defaultdict
from pathlib import Path

import openpyxl

GOOGLE_API_KEY = "AIzaSyDDxfuNuVSbsOg5myMHfVGGnG1tEPhlgFs"


def geocode(address: str):
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
        print(f"  geocode error: {e}", file=sys.stderr)
    return None, None

XLSX_PATH = Path("assets/국민건강보험공단_장기요양기관 시설별 현황_20250401.xlsx")
LOCAL_JSON_PATH = Path("assets/jongno_welfare.json")
OUT_PATH = Path("assets/jongno_welfare.json")

# 시설로서 의미 있는 행정구분코드 (재가요양은 사무소형태가 많아 제외)
PHYSICAL_FACILITY_CODES = {"A01", "A02", "A03", "A04", "A05", "AAA", "B03", "C03"}

# adminPttnCd → 시설 유형 한글 라벨
TYPE_LABELS = {
    "A01": "노인요양시설",
    "A02": "노인전문요양시설",
    "A03": "노인요양시설(데이케어)",
    "A04": "노인요양공동생활가정",
    "A05": "노인요양시설(단기보호 전환)",
    "AAA": "입소시설",
    "B01": "재가노인복지시설 방문요양",
    "B02": "재가노인복지시설 방문목욕",
    "B03": "주야간보호",
    "B04": "재가노인복지시설 단기보호",
    "B05": "방문간호",
    "B06": "재가노인복지시설 복지용구",
    "C01": "재가센터 방문요양",
    "C02": "재가센터 방문목욕",
    "C03": "재가센터 주야간보호",
    "C04": "재가센터 단기보호",
    "C05": "재가센터 방문간호",
    "C06": "재가센터 복지용구",
    "Z01": "기타",
    "S41": "치매전담형 노인요양공동생활가정",
}


def main():
    wb = openpyxl.load_workbook(XLSX_PATH, read_only=True)
    sheets = wb.worksheets
    sh_general, sh_acceptance, sh_staff, sh_codes = sheets

    # 1) 일반현황: 종로구 시설만 (시도='11' AND 시군구='110')
    facilities = {}  # longTermAdminSym → meta
    for r in sh_general.iter_rows(values_only=True, min_row=2):
        if not r or len(r) < 10:
            continue
        if str(r[3]).strip() != "11" or str(r[4]).strip() != "110":
            continue
        sym = str(r[0]).strip()
        facilities[sym] = {
            "longTermAdminSym": sym,
            "name": (r[1] or "").strip(),
            "addr": (r[9] or "").strip(),
        }

    # 2) 입소인원: 시설별 adminPttnCd → 정원/현원
    pattern_capacity = defaultdict(dict)  # sym → {code: (cap, cur, label)}
    for r in sh_acceptance.iter_rows(values_only=True, min_row=2):
        if not r or len(r) < 5:
            continue
        sym = str(r[0]).strip()
        if sym not in facilities:
            continue
        code = (r[1] or "").strip()
        label = (r[2] or "").strip()
        cap = int(r[3] or 0)
        cur = int(r[4] or 0)
        pattern_capacity[sym][code] = {
            "label": label or TYPE_LABELS.get(code, code),
            "capacity": cap,
            "current": cur,
        }

    # 3) 인력현황: 시설별 직원 수 합계 (시설장+사회복지사+간호사+요양보호사+기타)
    pattern_staff = defaultdict(int)  # sym → total staff
    pattern_staff_breakdown = defaultdict(dict)
    for r in sh_staff.iter_rows(values_only=True, min_row=2):
        if not r or len(r) < 16:
            continue
        sym = str(r[0]).strip()
        if sym not in facilities:
            continue
        code = (r[1] or "").strip()
        nums = [int(x or 0) for x in r[3:16]]
        total = sum(nums)
        pattern_staff[sym] += total

    # 4) 시설별 대표 adminPttnCd 선정 (시설형 코드 우선, 그 중 정원 큰 것)
    def pick_primary(sym):
        caps = pattern_capacity.get(sym, {})
        # 1순위: 시설형 코드 중 정원 최대
        physical = {k: v for k, v in caps.items() if k in PHYSICAL_FACILITY_CODES}
        if physical:
            best = max(physical.items(), key=lambda kv: kv[1]["capacity"])
            return best[0], best[1]
        # 2순위: 아무거나 정원 최대
        if caps:
            best = max(caps.items(), key=lambda kv: kv[1]["capacity"])
            return best[0], best[1]
        return None, None

    # 5) 표시할 시설만 필터 (시설형 코드를 하나라도 보유한 시설)
    display_facilities = []
    for sym, meta in facilities.items():
        caps = pattern_capacity.get(sym, {})
        if not any(c in PHYSICAL_FACILITY_CODES for c in caps):
            continue
        code, info = pick_primary(sym)
        if not code:
            continue
        display_facilities.append({
            "longTermAdminSym": sym,
            "adminPttnCd": code,
            "name": meta["name"],
            "addr": meta["addr"],
            "type": info["label"],
            "capacity": info["capacity"],
            "currentCount": info["current"],
            "staffCount": pattern_staff.get(sym, 0),
        })

    # 6) 기존 로컬 JSON 로드 (좌표 보존용)
    local = json.loads(LOCAL_JSON_PATH.read_text(encoding="utf-8"))
    local_by_name = {row["name"]: row for row in local.get("data", [])}

    # 7) 매칭/병합: 이름이 같으면 기존 좌표 유지, 아니면 좌표 없음
    out = []
    used_local_ids = set()
    for f in display_facilities:
        local_match = local_by_name.get(f["name"])
        if local_match:
            used_local_ids.add(local_match["id"])
            out.append({
                "id": local_match["id"],
                "name": f["name"],
                "addr": f["addr"] or local_match.get("addr", ""),
                "lat": local_match.get("lat"),
                "lng": local_match.get("lng"),
                "type": f["type"],
                "capacity": f["capacity"],
                "currentCount": f["currentCount"],
                "staffCount": f["staffCount"],
                "tel": local_match.get("tel", ""),
                "longTermAdminSym": f["longTermAdminSym"],
                "adminPttnCd": f["adminPttnCd"],
            })
        else:
            print(f"  geocoding: {f['name']}")
            lat, lng = geocode(f["addr"])
            time.sleep(0.05)
            out.append({
                "id": f"ltc-{f['longTermAdminSym']}",
                "name": f["name"],
                "addr": f["addr"],
                "lat": lat,
                "lng": lng,
                "type": f["type"],
                "capacity": f["capacity"],
                "currentCount": f["currentCount"],
                "staffCount": f["staffCount"],
                "tel": "",
                "longTermAdminSym": f["longTermAdminSym"],
                "adminPttnCd": f["adminPttnCd"],
            })

    # 8) 기존 로컬 시설 중 매칭 안 된 것 보존 (노인복지관·사회복지관·경로당 등 장기요양 외)
    for row in local.get("data", []):
        if row["id"] in used_local_ids:
            continue
        out.append(row)

    # 9) 정원 큰 순으로 정렬
    out.sort(key=lambda x: -int(x.get("capacity") or 0))

    OUT_PATH.write_text(
        json.dumps({"data": out}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    print(f"종로구 장기요양시설: {len(display_facilities)}개")
    print(f"기존 로컬 매칭: {len(used_local_ids)}개")
    print(f"신규 추가: {len(display_facilities) - len(used_local_ids)}개")
    print(f"로컬 전용 (장기요양 외) 보존: {len(local.get('data', [])) - len(used_local_ids)}개")
    print(f"최종 총 시설 수: {len(out)}개")
    print(f"Wrote {OUT_PATH}")


if __name__ == "__main__":
    main()
