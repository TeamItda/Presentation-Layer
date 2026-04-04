import 'package:flutter/material.dart';

class ReviewWriteView extends StatefulWidget {
  // 라우터에서 facilityId로 진입, facilityName은 선택적으로 전달
  final String facilityId;
  final String? facilityName;

  const ReviewWriteView({
    super.key,
    required this.facilityId,
    this.facilityName,
  });

  @override
  State<ReviewWriteView> createState() => _ReviewWriteViewState();
}

class _ReviewWriteViewState extends State<ReviewWriteView> {
  int _selectedRating = 0;        // 선택된 별점 (0 = 미선택)
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // 등록 버튼 활성화 조건: 별점 선택 + 내용 1자 이상
  bool get _canSubmit =>
      _selectedRating > 0 && _reviewController.text.trim().isNotEmpty;

  Future<void> _onSubmit() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    // 실제 구현 시: reviewViewModel.submitReview(
    //   facilityId: ...,
    //   rating: _selectedRating,
    //   content: _reviewController.text.trim(),
    // ) → Firestore reviews 컬렉션에 저장
    await Future.delayed(const Duration(milliseconds: 800)); // 더미 딜레이

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // 등록 완료 → 이전 화면(시설 상세)으로 복귀
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('후기가 등록되었어요 😊'),
        backgroundColor: const Color(0xFF3D5AFE),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: GestureDetector(
        // 키보드 바깥 탭 시 키보드 내리기
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── 시설명 ──
              _buildFacilityName(),
              const SizedBox(height: 24),

              // ── 별점 선택 ──
              _buildStarRating(),
              const SizedBox(height: 32),

              // ── 후기 입력 ──
              _buildReviewInput(),
              const SizedBox(height: 32),

              // ── 등록 버튼 ──
              _buildSubmitButton(),
            ],
          ),
        ),
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
          Text('✍️', style: TextStyle(fontSize: 18)),
          SizedBox(width: 6),
          Text(
            '후기 작성',
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
  // 시설명
  // ───────────────────────────────────────────
  Widget _buildFacilityName() {
    return Column(
      children: [
        Text(
          widget.facilityName ?? '시설 후기',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          '별점을 선택해주세요',
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────
  // 별점 선택 (★ 5개)
  // ───────────────────────────────────────────
  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isSelected = starIndex <= _selectedRating;
        return GestureDetector(
          onTap: () {
            setState(() {
              // 같은 별점 다시 탭하면 초기화
              _selectedRating =
              _selectedRating == starIndex ? 0 : starIndex;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 40,
              color: isSelected
                  ? const Color(0xFFFFC107)
                  : Colors.grey[350],
            ),
          ),
        );
      }),
    );
  }

  // ───────────────────────────────────────────
  // 후기 내용 입력
  // ───────────────────────────────────────────
  Widget _buildReviewInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '후기 내용',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _reviewController,
          maxLines: 5,
          maxLength: 300,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: '방문 경험을 자유롭게 작성해주세요',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Color(0xFF3D5AFE), width: 1.5),
            ),
          ),
          onChanged: (_) => setState(() {}), // 버튼 활성화 상태 업데이트
        ),
      ],
    );
  }

  // ───────────────────────────────────────────
  // 후기 등록 버튼
  // ───────────────────────────────────────────
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _canSubmit ? _onSubmit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3D5AFE),
          disabledBackgroundColor: Colors.grey[300],
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.grey[500],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          '후기 등록',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}