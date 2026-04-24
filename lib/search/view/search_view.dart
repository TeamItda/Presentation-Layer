import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../search/viewmodel/search_viewmodel.dart';
import '../../facility/viewmodel/facility_list_viewmodel.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<String> _popularKeywords = ['#병원', '#약국', '#맛집', '#어린이집', '#문화시설'];

  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    // 최근 검색어 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchViewModel>().init();
      _focusNode.requestFocus();
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    context.read<SearchViewModel>().onSearchChanged(query);

    // FacilityListViewModel에서 실제 시설 데이터 가져와서 필터링
    final allFacilities =
        context.read<FacilityListViewModel>().facilities;

    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = allFacilities
            .where((f) =>
        (f['name'] ?? '').toString().contains(query) ||
            (f['type'] ?? '').toString().contains(query) ||
            (f['addr'] ?? '').toString().contains(query))
            .toList();
      }
    });
  }

  void _onRecentSearchTap(String keyword) {
    _searchController.text = keyword;
    _searchController.selection =
        TextSelection.fromPosition(TextPosition(offset: keyword.length));
  }

  void _onPopularKeywordTap(String keyword) {
    final query = keyword.replaceFirst('#', '');
    _searchController.text = query;
    _searchController.selection =
        TextSelection.fromPosition(TextPosition(offset: query.length));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Color _categoryColor(String category) {
    switch (category) {
      case '의료시설': return const Color(0xFFE53935);
      case '약국':    return const Color(0xFF43A047);
      case '맛집':    return const Color(0xFFFF7043);
      case '유아돌봄': return const Color(0xFFAB47BC);
      case '노인복지': return const Color(0xFFFF8F00);
      case '교육시설': return const Color(0xFF1E88E5);
      case '문화시설': return const Color(0xFF00ACC1);
      default:        return const Color(0xFF78909C);
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case '의료시설': return Icons.local_hospital_outlined;
      case '약국':    return Icons.medication_outlined;
      case '맛집':    return Icons.restaurant_outlined;
      case '유아돌봄': return Icons.child_care_outlined;
      case '노인복지': return Icons.elderly_outlined;
      case '교육시설': return Icons.school_outlined;
      case '문화시설': return Icons.museum_outlined;
      default:        return Icons.place_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(vm),
      body: vm.searchText.isEmpty
          ? _buildEmptyState(vm)
          : _buildSearchResults(vm),
    );
  }

  // ───────────────────────────────────────────
  // AppBar
  // ───────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(SearchViewModel vm) {
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
          suffixIcon: vm.searchText.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.close, color: Colors.grey[400], size: 20),
            onPressed: () {
              _searchController.clear();
              vm.clearSearchText();
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
        onSubmitted: (value) => vm.submitSearch(value),
      ),
      titleSpacing: 0,
    );
  }

  // ───────────────────────────────────────────
  // 검색어 없을 때: 최근 검색어 + 인기 검색어
  // ───────────────────────────────────────────
  Widget _buildEmptyState(SearchViewModel vm) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (vm.recentSearches.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '최근 검색어',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
              GestureDetector(
                onTap: () => vm.clearRecentSearches(),
                child: Text('전체 삭제',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...vm.recentSearches.map((keyword) => _buildRecentItem(keyword, vm)),
        ],
        const SizedBox(height: 20),
        const Text(
          '인기 검색어',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
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

  Widget _buildRecentItem(String keyword, SearchViewModel vm) {
    return InkWell(
      onTap: () => _onRecentSearchTap(keyword),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(keyword,
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ),
            GestureDetector(
              onTap: () => vm.removeRecentSearch(keyword),
              child: Icon(Icons.close, size: 16, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeywordChip(String keyword) {
    return GestureDetector(
      onTap: () => _onPopularKeywordTap(keyword),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────
  // 검색 결과
  // ───────────────────────────────────────────
  Widget _buildSearchResults(SearchViewModel vm) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 52, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text("'${vm.searchText}' 검색 결과가 없어요",
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            const SizedBox(height: 8),
            Text('다른 키워드로 검색해보세요',
                style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            '검색 결과 ${_searchResults.length}개',
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
        ),
        ..._searchResults.map((facility) => _buildResultItem(facility)),
      ],
    );
  }

  Widget _buildResultItem(Map<String, dynamic> facility) {
    final category = facility['type'] ?? '';
    final color = _categoryColor(category);
    final icon = _categoryIcon(category);

    return InkWell(
      onTap: () {
        // 실제 구현 시: context.push('/facility/${facility['id']}')
        context.read<SearchViewModel>().submitSearch(facility['name'] ?? '');
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(facility['name'] ?? '',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  const SizedBox(height: 3),
                  Text(facility['addr'] ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(category,
                      style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 11, color: Colors.amber[600]),
                    const SizedBox(width: 2),
                    Text(
                      (facility['rating'] ?? 0.0).toString(),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      facility['dist'] ?? '',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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