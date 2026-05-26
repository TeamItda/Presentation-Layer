import '../model/smu_building.dart';

/// 상명대학교 서울캠퍼스 주요 건물 데이터.
///
/// 좌표(left/top/width/height)는 assets/SMU_CAMPUSMAP.png(1000x1344) 위의
/// 정규화 비율(0~1)입니다. 이미지 위 위치를 보고 추정한 값이라 실제 정렬은
/// 직접 한 번 보고 미세 조정해 주세요. 좌표만 바꾸면 즉시 반영됩니다.
const List<SmuBuilding> smuBuildings = [
  SmuBuilding(
    id: 'mirae',
    name: '미래백년관',
    description: '상명대 100주년 기념 복합 강의·연구동',
    departments: ['중앙도서관', '대형 강의실', '세미나실'],
    floors: [
      SmuBuildingFloor(floor: 'B1', content: '주차장'),
      SmuBuildingFloor(floor: '1F', content: '로비, 카페, 안내데스크'),
      SmuBuildingFloor(floor: '2F~5F', content: '강의실, 세미나실'),
      SmuBuildingFloor(floor: '6F~7F', content: '교수 연구실'),
    ],
    phone: '02-2287-5114',
    left: 0.54, top: 0.27, width: 0.24, height: 0.10,
  ),
  SmuBuilding(
    id: 'culture_arts',
    name: '문화예술관',
    description: '공연·전시·실기 수업이 진행되는 예술 전용 건물',
    departments: ['문화예술경영학과', '음악학부', '공연 홀'],
    floors: [
      SmuBuildingFloor(floor: '1F', content: '공연장, 전시실'),
      SmuBuildingFloor(floor: '2F~4F', content: '실기실, 강의실'),
    ],
    phone: '02-2287-5028',
    left: 0.58, top: 0.42, width: 0.22, height: 0.10,
  ),
  SmuBuilding(
    id: 'convergence',
    name: '융합공학관',
    description: '공과대학 강의·연구실 위주의 건물',
    departments: ['컴퓨터과학과', '소프트웨어학과', '전자공학과'],
    floors: [
      SmuBuildingFloor(floor: '1F', content: '로비, 학과 사무실'),
      SmuBuildingFloor(floor: '2F~5F', content: '강의실, 실습실, 연구실'),
    ],
    phone: '02-2287-5061',
    left: 0.32, top: 0.45, width: 0.18, height: 0.08,
  ),
  SmuBuilding(
    id: 'graduate',
    name: '대학원관',
    description: '대학원 강의·연구 공간',
    departments: ['일반대학원', '특수대학원'],
    floors: [
      SmuBuildingFloor(floor: '1F', content: '대학원 행정실'),
      SmuBuildingFloor(floor: '2F~4F', content: '대학원 강의실, 연구실'),
    ],
    phone: '02-2287-5040',
    left: 0.30, top: 0.38, width: 0.16, height: 0.06,
  ),
  SmuBuilding(
    id: 'student_hall',
    name: '학생회관',
    description: '동아리·학생식당·복지시설이 모인 학생 활동의 중심',
    departments: ['총학생회', '동아리방', '학생식당', '편의점'],
    floors: [
      SmuBuildingFloor(floor: '1F', content: '학생식당, 편의점'),
      SmuBuildingFloor(floor: '2F', content: '카페, 복지매장'),
      SmuBuildingFloor(floor: '3F~4F', content: '동아리방, 총학생회'),
    ],
    phone: '02-2287-5040',
    left: 0.43, top: 0.40, width: 0.15, height: 0.06,
  ),
  SmuBuilding(
    id: 'hongji',
    name: '홍지관',
    description: '본부 행정·교양 강의실이 위치한 대표 건물',
    departments: ['총장실', '학사지원팀', '교양 강의실'],
    floors: [
      SmuBuildingFloor(floor: '1F', content: '학사지원팀, 안내'),
      SmuBuildingFloor(floor: '2F~3F', content: '본부 행정실, 회의실'),
      SmuBuildingFloor(floor: '4F~', content: '강의실'),
    ],
    phone: '02-2287-5000',
    left: 0.42, top: 0.52, width: 0.16, height: 0.06,
  ),
  SmuBuilding(
    id: 'biz',
    name: '경영경제관',
    description: '경영·경제대학 강의·연구실 건물',
    departments: ['경영학부', '경제금융학부', 'CASE 강의실'],
    floors: [
      SmuBuildingFloor(floor: '1F', content: '학부 행정실'),
      SmuBuildingFloor(floor: '2F~5F', content: '강의실, 교수 연구실'),
    ],
    phone: '02-2287-5070',
    left: 0.62, top: 0.55, width: 0.20, height: 0.09,
  ),
  SmuBuilding(
    id: 'prof1',
    name: '제1교수회관',
    description: '교수 연구실 및 학과 사무실',
    departments: ['인문·사회계 학과 연구실'],
    floors: [
      SmuBuildingFloor(floor: '1F~5F', content: '교수 연구실, 세미나실'),
    ],
    phone: '02-2287-5000',
    left: 0.32, top: 0.62, width: 0.18, height: 0.06,
  ),
  SmuBuilding(
    id: 'prof2',
    name: '제2교수회관',
    description: '교수 연구실 및 학과 사무실',
    departments: ['자연·공학계 학과 연구실'],
    floors: [
      SmuBuildingFloor(floor: '1F~5F', content: '교수 연구실, 실험실'),
    ],
    phone: '02-2287-5000',
    left: 0.50, top: 0.74, width: 0.22, height: 0.06,
  ),
  SmuBuilding(
    id: 'social',
    name: '사범대학(자연관)',
    description: '사범대학 및 자연과학대학 강의·실험 건물',
    departments: ['교육학과', '수학교육과', '생명과학과'],
    floors: [
      SmuBuildingFloor(floor: '1F', content: '학과 사무실'),
      SmuBuildingFloor(floor: '2F~4F', content: '강의실, 실험실'),
    ],
    phone: '02-2287-5080',
    left: 0.10, top: 0.66, width: 0.22, height: 0.07,
  ),
  SmuBuilding(
    id: 'smu_cultural',
    name: '상명교육문화관',
    description: '평생교육·대외 행사용 다목적 공간',
    departments: ['평생교육원', '대강당', '회의실'],
    floors: [
      SmuBuildingFloor(floor: '1F', content: '평생교육원 사무실'),
      SmuBuildingFloor(floor: '2F~3F', content: '대강당, 회의실'),
    ],
    phone: '02-2287-5000',
    left: 0.10, top: 0.78, width: 0.24, height: 0.07,
  ),
  SmuBuilding(
    id: 'stadium',
    name: '운동장',
    description: '학생 체육 활동 및 행사 공간',
    departments: ['축구장', '러닝 트랙'],
    floors: [],
    phone: null,
    left: 0.62, top: 0.05, width: 0.30, height: 0.12,
  ),
];
