import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../non_payment/viewmodel/non_payment_viewmodel.dart';

class NonPaymentView extends StatefulWidget {
  final String? hospitalId;

  const NonPaymentView({super.key, this.hospitalId});

  @override
  State<NonPaymentView> createState() => _NonPaymentViewState();
}

class _NonPaymentViewState extends State<NonPaymentView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NonPaymentViewModel>().loadNonPayments();
    });
    _searchController.addListener(() {
      context.read<NonPaymentViewModel>().search(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    ) +
        '원';
  }

  int _getMinAvg(NonPaymentCategory category) {
    return category.items.map((i) => i.avgPrice).reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NonPaymentViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(vm),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                ? _buildErrorState(vm)
                : vm.categories.isEmpty
                ? _buildEmptyState()
                : _buildCategoryList(vm),
          ),
        ],
      ),
    );
  }

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
          Text('비급여 진료비 비교',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
        ],
      ),
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.grey[200]),
      ),
    );
  }

  Widget _buildSearchBar(NonPaymentViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: '비급여 항목 검색 (예: MRI, 초음파)',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.close, color: Colors.grey[400], size: 18),
            onPressed: () {
              _searchController.clear();
              vm.search('');
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
      ),
    );
  }

  Widget _buildCategoryList(NonPaymentViewModel vm) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: vm.categories.length,
      itemBuilder: (context, index) {
        return _buildCategorySection(vm.categories[index]);
      },
    );
  }

  Widget _buildCategorySection(NonPaymentCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category.name,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
          const SizedBox(height: 8),
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
                _buildTableHeader(),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
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
            child: Text('병원명',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
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
      child: Text(text,
          textAlign: TextAlign.right,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87)),
    );
  }

  Widget _buildTableRow(NonPaymentItem item, bool isLowest) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Flexible(
                  child: Text(item.hospitalName,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87),
                      overflow: TextOverflow.ellipsis),
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
                    child: const Text('최저',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 72,
            child: Text(_formatPrice(item.minPrice),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          SizedBox(
            width: 72,
            child: Text(_formatPrice(item.maxPrice),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          SizedBox(
            width: 72,
            child: Text(_formatPrice(item.avgPrice),
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isLowest
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE53935))),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 52, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('검색 결과가 없어요',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text('다른 항목으로 검색해보세요',
              style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildErrorState(NonPaymentViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 52, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(vm.errorMessage!,
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => vm.loadNonPayments(),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}