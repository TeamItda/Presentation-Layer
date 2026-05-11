import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../review/viewmodel/review_viewmodel.dart';

class ReviewWriteView extends StatefulWidget {
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
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  bool get _canSubmit =>
      _selectedRating > 0 && _reviewController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_canSubmit) return;

    final vm = context.read<ReviewViewModel>();
    final success = await vm.submitReview(
      facilityId: widget.facilityId,
      facilityName: widget.facilityName ?? 'review.default_facility'.tr(),
      rating: _selectedRating,
      content: _reviewController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('review.submit_success'.tr()),
          backgroundColor: const Color(0xFF3D5AFE),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('review.submit_fail'.tr()),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildFacilityName(),
                const SizedBox(height: 24),
                _buildStarRating(),
                const SizedBox(height: 32),
                _buildReviewInput(),
                const SizedBox(height: 32),
                _buildSubmitButton(vm.isSubmitting),
              ],
            ),
          ),
        ),
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
      title: Row(
        children: [
          const Text('✍️', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            'review.write_title'.tr(),
            style: const TextStyle(
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

  Widget _buildFacilityName() {
    return Column(
      children: [
        Text(
          widget.facilityName ?? 'review.default_facility'.tr(),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'review.select_rating'.tr(),
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isSelected = starIndex <= _selectedRating;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedRating = _selectedRating == starIndex ? 0 : starIndex;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 40,
              color: isSelected ? const Color(0xFFFFC107) : Colors.grey[350],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildReviewInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'review.review_content'.tr(),
          style: const TextStyle(
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
            hintText: 'review.review_hint'.tr(),
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
              borderSide: const BorderSide(color: Color(0xFF3D5AFE), width: 1.5),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isSubmitting) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isSubmitting
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : Text(
          'review.submit'.tr(),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}