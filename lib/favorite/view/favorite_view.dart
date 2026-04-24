import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../favorite/viewmodel/favorite_viewmodel.dart';

class FavoriteView extends StatefulWidget {
  final bool showBackButton;

  const FavoriteView({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<FavoriteView> createState() => _FavoriteViewState();
}

class _FavoriteViewState extends State<FavoriteView> {
  @override
  void initState() {
    super.initState();
    // 즐겨찾기 목록 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteViewModel>().loadFavorites();
    });
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

  void _removeFavorite(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('즐겨찾기 해제',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text('즐겨찾기에서 삭제할까요?',
            style: TextStyle(fontSize: 14, color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('취소', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<FavoriteViewModel>().removeFavorite(id);
            },
            child: const Text('삭제',
                style: TextStyle(
                    color: Color(0xFFE53935), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FavoriteViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(vm),
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.errorMessage != null
                  ? _buildErrorState(vm.errorMessage!)
                  : vm.favorites.isEmpty
                  ? _buildEmptyState()
                  : _buildFavoriteList(vm),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────
  // 상단 타이틀
  // ───────────────────────────────────────────
  Widget _buildHeader(FavoriteViewModel vm) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          if (widget.showBackButton) ...[
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back, size: 22, color: Colors.black87),
            ),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.favorite, size: 22, color: Color(0xFFE53935)),
          const SizedBox(width: 8),
          const Text('즐겨찾기',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
          const Spacer(),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${vm.favorites.length}개',
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────
  // 즐겨찾기 목록
  // ───────────────────────────────────────────
  Widget _buildFavoriteList(FavoriteViewModel vm) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: vm.favorites.length,
      itemBuilder: (context, index) {
        return _buildFavoriteCard(vm.favorites[index]);
      },
    );
  }

  Widget _buildFavoriteCard(FavoriteItem item) {
    final color = _categoryColor(item.category);
    final icon = _categoryIcon(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // 실제 구현 시: context.push('/facility/${item.id}')
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(item.address,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[500]),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(item.category,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star_rounded,
                            size: 13, color: Colors.amber[600]),
                        const SizedBox(width: 2),
                        Text(item.rating.toString(),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500])),
                        const SizedBox(width: 8),
                        Text(item.distance,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _removeFavorite(context, item.id),
                child: const Icon(Icons.favorite,
                    color: Color(0xFFE53935), size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────
  // 빈 상태
  // ───────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('즐겨찾기한 시설이 없어요',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text('시설 상세에서 ❤️를 눌러 추가해보세요',
              style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────
  // 에러 상태
  // ───────────────────────────────────────────
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 52, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<FavoriteViewModel>().loadFavorites(),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}