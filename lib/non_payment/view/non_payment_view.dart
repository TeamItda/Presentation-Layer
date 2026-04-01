import 'package:flutter/material.dart';

// ── 데이터 모델 ──────────────────────────────
class NonPaymentItem {
  final String hospitalName;
  final int minPrice;
  final int maxPrice;
  final int avgPrice;

  const NonPaymentItem({
    required this.hospitalName,
    required this.minPrice,
    required this.maxPrice,
    required this.avgPrice,
  });
}

class NonPaymentCategory {
  final String name; // 예: 'MRI (뇌)'
  final List<NonPaymentItem> items;

  const NonPaymentCategory({
    required this.name,
    required this.items,
  });
}

// ── 화면 ─────────────────────────────────────
class NonPaymentView extends StatefulWidget {
  // 병원 상세에서 진입 시 특정 병원 ID 전달 (없으면 전체 비교 화면)
  // 실제 구현 시 → 이 ID로 해당 병원 데이터만 먼저 필터링
  final String? hospitalId;

  const NonPaymentView({super.key, this.hospitalId});

  @override
  State<NonPaymentView> createState() => _NonPaymentViewState();
}

class _NonPaymentViewState extends State<NonPaymentView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  // 더미 데이터 — 나중에 HIRA 비급여진료비 API로 교체
  final List<NonPaymentCategory> _allCategories = const [
    NonPaymentCategory(
      name: 'MRI (뇌)',
      items: [
        NonPaymentItem(hospitalName: '강남세브란스', minPrice: 350000, maxPrice: 450000, avgPrice: 400000),
        NonPaymentItem(hospitalName: '삼성서울병원', minPrice: 380000, maxPrice: 520000, avgPrice: 450000),
      ],
    ),
    NonPaymentCategory(
      name: '초음파 (복부)',
      items: [
        NonPaymentItem(hospitalName: '강남세브란스', minPrice: 80000, maxPrice: 120000, avgPrice: 100000),
        NonPaymentItem(hospitalName: '삼성서울병원', minPrice: 90000, maxPrice: 150000, avgPrice: 115000),
        NonPaymentItem(hospitalName: '연세가정의학과', minPrice: 50000, maxPrice: 70000, avgPrice: 60000),
      ],
    ),
    NonPaymentCategory(
      name: '도수치료 (1회)',
      items: [
        NonPaymentItem(hospitalName: '강남세브란스', minPrice: 80000, maxPrice: 100000, avgPrice: 90000),
        NonPaymentItem(hospitalName: '삼성서울병원', minPrice: 70000, maxPrice: 90000, avgPrice: 80000),
      ],
    ),
    NonPaymentCategory(
      name: 'CT (흉부)',
      items: [
        NonPaymentItem(hospitalName: '강남세브란스', minPrice: 120000, maxPrice: 200000, avgPrice: 160000),
        NonPaymentItem(hospitalName: '삼성서울병원', minPrice: 130000, maxPrice: 210000, avgPrice: 170000),
      ],
    ),
  ];

  List<NonPaymentCategory> get _filteredCategories {
    if (_searchText.isEmpty) return _allCategories;
    return _allCategories
        .where((c) =>
    c.name.contains(_searchText) ||
        c.items.any((i) => i.hospitalName.contains(_searchText)))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 가격 포맷 (1000 단위 콤마)
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    ) +
        '원';
  }

  // 카테고리 내에서 최저 평균가 병원 찾기
  int _getMinAvg(NonPaymentCategory category) {
    return category.items.map((i) => i.avgPrice).reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _filteredCategories.isEmpty
                ? _buildEmptyState()
                : _buildCategoryList(),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────
  // AppBar
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
      title: const Row(
        children: [
          Text('💰', style: TextStyle(fontSize: 18)),
          SizedBox(width: 6),
          Text(
            '비급여 진료비 비교',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.grey[200]),
      ),
    );
  }

  // ───────────────────────────────────────────
  // 검색 바
  // ───────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: '비급여 항목 검색 (예: MRI, 초음파)',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.close, color: Colors.grey[400], size: 18),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchText = '');
            },
          )
              : null,
          filled: true,
          fillColor: Colors.white,
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
        onChanged: (value) => setState(() => _searchText = value.trim()),
      ),
    );
  }

  // ───────────────────────────────────────────
  // 카테고리 목록
  // ───────────────────────────────────────────
  Widget _buildCategoryList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredCategories.length,
      itemBuilder: (context, index) {
        return _buildCategorySection(_filteredCategories[index]);
      },
    );
  }

  // ───────────────────────────────────────────
  // 카테고리 섹션 (제목 + 테이블)
  // ───────────────────────────────────────────
  Widget _buildCategorySection(NonPaymentCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 제목
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // 테이블
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // 테이블 헤더
                _buildTableHeader(),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                // 테이블 행
                ...category.items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final isLowest = item.avgPrice == _getMinAvg(category);
                  final isLast = idx == category.items.length - 1;
                  return Column(
                    children: [
                      _buildTableRow(item, isLowest),
                      if (!isLast)
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 테이블 헤더 행
  Widget _buildTableHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE3E7F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Text(
              '병원명',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          _headerCell('최소'),
          _headerCell('최대'),
          _headerCell('평균'),
        ],
      ),
    );
  }

  Widget _headerCell(String text) {
    return SizedBox(
      width: 72,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  // 테이블 데이터 행
  Widget _buildTableRow(NonPaymentItem item, bool isLowest) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // 병원명 + 최저가 뱃지
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    item.hospitalName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLowest) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '최저',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 최소
          SizedBox(
            width: 72,
            child: Text(
              _formatPrice(item.minPrice),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          // 최대
          SizedBox(
            width: 72,
            child: Text(
              _formatPrice(item.maxPrice),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          // 평균 (강조 색상)
          SizedBox(
            width: 72,
            child: Text(
              _formatPrice(item.avgPrice),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isLowest
                    ? const Color(0xFF2E7D32) // 최저가 → 초록
                    : const Color(0xFFE53935), // 나머지 → 빨강
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────
  // 검색 결과 없음
  // ───────────────────────────────────────────
  Widget _buildEmptyState() {
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
            '다른 항목으로 검색해보세요',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}