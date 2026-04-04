import 'package:flutter/material.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // 더미 데이터 — 나중에 ViewModel + SharedPreferences로 교체
  final List<String> _recentSearches = ['서울대병원', '어린이집', '광장시장'];
  final List<String> _popularKeywords = ['#병원', '#약국', '#맛집', '#어린이집', '#문화시설'];

  // 검색어가 있을 때 보여줄 더미 결과
  final List<Map<String, String>> _allFacilities = [
    {'name': '종로내과의원', 'category': '의료시설', 'address': '종로구 자하문로 9', 'distance': '350m', 'rating': '4.8'},
    {'name': '서울대학교병원', 'category': '의료시설', 'address': '종로구 대학로 101', 'distance': '0.8km', 'rating': '4.5'},
    {'name': '경복궁칼국수', 'category': '맛집', 'address': '종로구 효자로 1', 'distance': '220m', 'rating': '4.7'},
    {'name': '종로은누리약국', 'category': '약국', 'address': '종로구 종로 180', 'distance': '180m', 'rating': '4.5'},
    {'name': '광장시장', 'category': '맛집', 'address': '종로구 창경궁로 88', 'distance': '1.2km', 'rating': '4.6'},
    {'name': '혜화치과', 'category': '의료시설', 'address': '종로구 혜화로 10', 'distance': '480m', 'rating': '4.6'},
    {'name': '종로노인종합복지관', 'category': '노인복지', 'address': '종로구 삼일대로 457', 'distance': '460m', 'rating': '4.3'},
    {'name': '창신어린이집', 'category': '유아돌봄', 'address': '종로구 창신길 43', 'distance': '620m', 'rating': '4.4'},
  ];

  String _searchText = '';
  List<Map<String, String>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 키보드 자동 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _searchText = query;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allFacilities
            .where((f) =>
        f['name']!.contains(query) ||
            f['category']!.contains(query) ||
            f['address']!.contains(query))
            .toList();
      }
    });
  }

  void _onRecentSearchTap(String keyword) {
    _searchController.text = keyword;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: keyword.length),
    );
  }

  void _onPopularKeywordTap(String keyword) {
    // '#' 제거 후 검색
    final query = keyword.replaceFirst('#', '');
    _searchController.text = query;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
  }

  void _removeRecentSearch(String keyword) {
    setState(() {
      _recentSearches.remove(keyword);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // 카테고리별 색상
  Color _categoryColor(String category) {
    switch (category) {
      case '의료시설':
        return const Color(0xFFE53935);
      case '약국':
        return const Color(0xFF43A047);
      case '맛집':
        return const Color(0xFFFF7043);
      case '유아돌봄':
        return const Color(0xFFAB47BC);
      case '노인복지':
        return const Color(0xFFFF8F00);
      case '교육시설':
        return const Color(0xFF1E88E5);
      case '문화시설':
        return const Color(0xFF00ACC1);
      default:
        return const Color(0xFF78909C);
    }
  }

  // 카테고리별 아이콘
  IconData _categoryIcon(String category) {
    switch (category) {
      case '의료시설':
        return Icons.local_hospital_outlined;
      case '약국':
        return Icons.medication_outlined;
      case '맛집':
        return Icons.restaurant_outlined;
      case '유아돌봄':
        return Icons.child_care_outlined;
      case '노인복지':
        return Icons.elderly_outlined;
      case '교육시설':
        return Icons.school_outlined;
      case '문화시설':
        return Icons.museum_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _searchText.isEmpty ? _buildEmptyState() : _buildSearchResults(),
    );
  }

  // ───────────────────────────────────────────
  // AppBar: 뒤로가기 + 검색 입력창
  // ───────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          hintText: '종로구 시설 검색',
          hintStyle: TextStyle(fontSize: 15, color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.close, color: Colors.grey[400], size: 20),
            onPressed: () {
              _searchController.clear();
            },
          )
              : null,
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
            const BorderSide(color: Color(0xFF3D5AFE), width: 1.5),
          ),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            // 실제 구현 시: 최근 검색어에 추가 (SharedPreferences)
          }
        },
      ),
      titleSpacing: 0,
    );
  }

  // ───────────────────────────────────────────
  // 검색어 없을 때: 최근 검색어 + 인기 검색어
  // ───────────────────────────────────────────
  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // ── 최근 검색어 ──
        if (_recentSearches.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '최근 검색어',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _recentSearches.clear());
                },
                child: Text(
                  '전체 삭제',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._recentSearches.map((keyword) => _buildRecentItem(keyword)),
        ],

        // ── 인기 검색어 ──
        const SizedBox(height: 20),
        const Text(
          '인기 검색어',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularKeywords
              .map((keyword) => _buildKeywordChip(keyword))
              .toList(),
        ),
      ],
    );
  }

  // 최근 검색어 항목
  Widget _buildRecentItem(String keyword) {
    return InkWell(
      onTap: () => _onRecentSearchTap(keyword),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                keyword,
                style:
                const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            GestureDetector(
              onTap: () => _removeRecentSearch(keyword),
              child: Icon(Icons.close, size: 16, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  // 인기 검색어 칩
  Widget _buildKeywordChip(String keyword) {
    return GestureDetector(
      onTap: () => _onPopularKeywordTap(keyword),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDDE1FF)),
        ),
        child: Text(
          keyword,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF3D5AFE),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────
  // 검색어 있을 때: 검색 결과 목록
  // ───────────────────────────────────────────
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 52, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "'$_searchText' 검색 결과가 없어요",
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Text(
              '다른 키워드로 검색해보세요',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // 결과 수 표시
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            '검색 결과 ${_searchResults.length}개',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ..._searchResults.map((facility) => _buildResultItem(facility)),
      ],
    );
  }

  // 검색 결과 카드 아이템
  Widget _buildResultItem(Map<String, String> facility) {
    final color = _categoryColor(facility['category']!);
    final icon = _categoryIcon(facility['category']!);

    return InkWell(
      onTap: () {
        // 실제 구현 시: context.push('/facility/${facility['id']}')
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // 카테고리 아이콘 원형
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            // 시설 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    facility['name']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    facility['address']!,
                    style:
                    TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            // 오른쪽: 카테고리 태그 + 거리
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    facility['category']!,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 11, color: Colors.amber[600]),
                    const SizedBox(width: 2),
                    Text(
                      facility['rating']!,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      facility['distance']!,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}