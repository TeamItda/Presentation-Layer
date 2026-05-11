class LtcStaffStatus {
  final int chargeDoc;
  final int chrgDoc;
  final int cook;
  final int dent;
  final int equipLong;
  final int etcPer;
  final int hdOfce;
  final int hygiPrsn;
  final int mgmtPrsn;
  final int nur;
  final int nurArticle;
  final int nut;
  final int ofceEmp;
  final int physicalMTret;
  final int recuProtDelay;
  final int recuProt1;
  final int recuProt2;
  final int socWel;
  final int suppPrsn;
  final int wrkMTret;

  const LtcStaffStatus({
    this.chargeDoc = 0,
    this.chrgDoc = 0,
    this.cook = 0,
    this.dent = 0,
    this.equipLong = 0,
    this.etcPer = 0,
    this.hdOfce = 0,
    this.hygiPrsn = 0,
    this.mgmtPrsn = 0,
    this.nur = 0,
    this.nurArticle = 0,
    this.nut = 0,
    this.ofceEmp = 0,
    this.physicalMTret = 0,
    this.recuProtDelay = 0,
    this.recuProt1 = 0,
    this.recuProt2 = 0,
    this.socWel = 0,
    this.suppPrsn = 0,
    this.wrkMTret = 0,
  });

  int get total =>
      chargeDoc +
      chrgDoc +
      cook +
      dent +
      equipLong +
      etcPer +
      hdOfce +
      hygiPrsn +
      mgmtPrsn +
      nur +
      nurArticle +
      nut +
      ofceEmp +
      physicalMTret +
      recuProtDelay +
      recuProt1 +
      recuProt2 +
      socWel +
      suppPrsn +
      wrkMTret;

  // 0이 아닌 직군만 (label, count) 리스트로 반환 (상세화면 표시용)
  List<MapEntry<String, int>> get nonZeroRoles {
    final entries = <MapEntry<String, int>>[
      MapEntry('시설장', mgmtPrsn),
      MapEntry('사무국장', hdOfce),
      MapEntry('사회복지사', socWel),
      MapEntry('의사(촉탁의)', chargeDoc),
      MapEntry('진료의', chrgDoc),
      MapEntry('치과의', dent),
      MapEntry('간호사', nur),
      MapEntry('간호조무사', nurArticle),
      MapEntry('영양사', nut),
      MapEntry('물리치료사', physicalMTret),
      MapEntry('작업치료사', wrkMTret),
      MapEntry('요양보호사 1급', recuProt1),
      MapEntry('요양보호사 2급', recuProt2),
      MapEntry('요양보호사(대체)', recuProtDelay),
      MapEntry('조리원', cook),
      MapEntry('위생원', hygiPrsn),
      MapEntry('사무원', ofceEmp),
      MapEntry('지원인력', suppPrsn),
      MapEntry('장비기사', equipLong),
      MapEntry('기타', etcPer),
    ];
    return entries.where((e) => e.value > 0).toList();
  }
}
