import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../review/viewmodel/review_viewmodel.dart';

class MyReviewsView extends StatefulWidget {
  const MyReviewsView({super.key});

  @override
  State<MyReviewsView> createState() => _MyReviewsViewState();
}

class _MyReviewsViewState extends State<MyReviewsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewViewModel>().loadMyReviews();
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

  void _deleteReview(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('후기 삭제',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text('후기를 삭제할까요?',
            style: TextStyle(fontSize: 14, color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('취소', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ReviewViewModel>().deleteReview(id);
            },
            child: const Text('삭제',
                style: TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: _buildAppBar(),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.errorMessage != null
          ? _buildErrorState(vm)
          : vm.myReviews.isEmpty
          ? _buildEmptyState()
          : _buildReviewList(vm),
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
          Text('📝', style: TextStyle(fontSize: 18)),
          SizedBox(width: 6),
          Text('내가 쓴 후기',
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

  Widget _buildReviewList(ReviewViewModel vm) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: vm.myReviews.length,
      itemBuilder: (context, index) {
        return _buildReviewCard(vm.myReviews[index]);
      },
    );
  }

  Widget _buildReviewCard(ReviewItem review) {
    final color = _categoryColor(review.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 카테고리 태그 + 시설명 + 삭제 버튼
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(review.category,
                    style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(review.facilityName,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87),
                    overflow: TextOverflow.ellipsis),
              ),
              GestureDetector(
                onTap: () => _deleteReview(context, review.id),
                child: Icon(Icons.delete_outline,
                    size: 20, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 별점
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 18,
                color: index < review.rating
                    ? const Color(0xFFFFC107)
                    : Colors.grey[300],
              );
            }),
          ),
          const SizedBox(height: 10),

          // 후기 내용
          Text(review.content,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey[700], height: 1.5)),
          const SizedBox(height: 10),

          // 작성일
          Text(review.formattedDate,
              style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_off_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('작성한 후기가 없어요',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text('시설 상세에서 후기를 남겨보세요',
              style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildErrorState(ReviewViewModel vm) {
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
            onPressed: () => vm.loadMyReviews(),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}