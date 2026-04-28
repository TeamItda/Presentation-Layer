import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../viewmodel/facility_detail_viewmodel.dart';
import '../viewmodel/facility_list_viewmodel.dart';
import '../../non_payment/view/non_payment_view.dart';
import '../../review/view/review_write_view.dart';

class FacilityDetailView extends StatefulWidget {
  final String facilityId;
  final String categoryId;
  const FacilityDetailView({super.key, required this.facilityId, required this.categoryId});

  @override
  State<FacilityDetailView> createState() => _FacilityDetailViewState();
}

class _FacilityDetailViewState extends State<FacilityDetailView> {
  String _reviewTab = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final listVm = context.read<FacilityListViewModel>();
      final detailVm = context.read<FacilityDetailViewModel>();

      if (listVm.facilities.isEmpty) {
        listVm.loadFacilities(widget.categoryId).then((_) {
          _findAndSetFacility(listVm, detailVm);
        });
      } else {
        _findAndSetFacility(listVm, detailVm);
      }
    });
  }

  void _findAndSetFacility(FacilityListViewModel listVm, FacilityDetailViewModel detailVm) {
    Map<String, dynamic>? found;
    for (final f in listVm.facilities) {
      if (f['id'] == widget.facilityId) {
        found = f;
        break;
      }
    }
    if (found != null) {
      detailVm.setFacility(found);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FacilityDetailViewModel>();
    final f = vm.facility;

    if (f == null || f.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: Colors.white,
                child: Row(
                  children: [
                    GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back, size: 22)),
                    const SizedBox(width: 10),
                    const Text('로딩 중...', style: TextStyle(fontSize: 16, color: AppColors.subText)),
                  ],
                ),
              ),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
      );
    }

    final cat = getCategoryById(widget.categoryId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, f, vm),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMiniMap(cat),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBasicInfo(f, cat),
                          const SizedBox(height: 10),
                          if (widget.categoryId == 'medical') _buildMedicalInfo(f),
                          if (widget.categoryId == 'pharmacy') _buildPharmacyInfo(f),
                          if (widget.categoryId == 'education') _buildEducationInfo(f),
                          if (widget.categoryId == 'childcare') _buildChildcareInfo(f),
                          if (widget.categoryId == 'welfare') _buildWelfareInfo(f),
                          if (widget.categoryId == 'food') _buildFoodInfo(f),
                          if (widget.categoryId == 'culture') _buildCultureInfo(f),
                          if (widget.categoryId == 'government') _buildGovernmentInfo(f),
                          const SizedBox(height: 8),
                          _buildReviewSection(vm),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> f, FacilityDetailViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back, size: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(f['name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text), overflow: TextOverflow.ellipsis),
          ),
          GestureDetector(
            onTap: () => vm.toggleFavorite(),
            child: Icon(vm.isFavorite ? Icons.favorite : Icons.favorite_border, color: vm.isFavorite ? Colors.red : AppColors.subText, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMap(Category cat) {
    return Container(
      height: 120,
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFDBEAFE), Color(0xFFF0FDF4)])),
      child: Center(
        child: Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: cat.color, shape: BoxShape.circle),
          child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 14))),
        ),
      ),
    );
  }

  Widget _buildBasicInfo(Map<String, dynamic> f, Category cat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: cat.bgColor, borderRadius: BorderRadius.circular(6)),
              child: Text('${cat.icon} ${cat.name}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cat.color)),
            ),
            if (f['type'] != null && f['type'].toString().isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                child: Text(f['type'].toString(), style: const TextStyle(fontSize: 10, color: AppColors.subText)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (f['addr'] != null) Text('📍 ${f['addr']}', style: const TextStyle(fontSize: 12, color: AppColors.subText)),
        if (f['tel'] != null && f['tel'].toString().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('📞 ${f['tel']}', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
        ],
        if (f['homepage'] != null && f['homepage'].toString().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('🌐 ${f['homepage']}', style: const TextStyle(fontSize: 11, color: AppColors.primary)),
        ],
      ],
    );
  }

  Widget _buildMedicalInfo(Map<String, dynamic> f) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🩺 진료 정보', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 8),
          if (f['dept'] != null && f['dept'].toString().isNotEmpty) ...[
            const Text('진료과목', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.subText)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4, runSpacing: 4,
              children: (f['dept'] as String).split(', ').map((d) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                child: Text(d, style: const TextStyle(fontSize: 9, color: AppColors.primary)),
              )).toList(),
            ),
          ],
          const SizedBox(height: 8),
          if (f['totalDocs'] != null)
            Text('👨‍⚕️ 총 의사 수: ${f['totalDocs']}명 (전문의 ${f['specialists'] ?? 0}명)', style: const TextStyle(fontSize: 11, color: AppColors.subText)),
          if (f['equip'] != null && f['equip'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('🔬 ${f['equip']}', style: const TextStyle(fontSize: 11, color: AppColors.subText)),
          ],
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NonPaymentView(
                    hospitalId: widget.facilityId,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: AppColors.medical, borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Text('💰 비급여 진료비 조회', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyInfo(Map<String, dynamic> f) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💊 약국 정보', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 6),
          if (f['tel'] != null && f['tel'].toString().isNotEmpty)
            Text('📞 전화: ${f['tel']}', style: const TextStyle(fontSize: 11, color: AppColors.subText)),
          if (f['addr'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('📍 주소: ${f['addr']}', style: const TextStyle(fontSize: 11, color: AppColors.subText)),
            ),
        ],
      ),
    );
  }

  Widget _buildEducationInfo(Map<String, dynamic> f) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏫 학교 정보', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 6),
          if (f['type'] != null) Text('학교급: ${f['type']}', style: const TextStyle(fontSize: 11, color: AppColors.subText)),
          if (f['fondType'] != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text('설립유형: ${f['fondType']}', style: const TextStyle(fontSize: 11, color: AppColors.subText))),
          if (f['coedu'] != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text('남녀공학: ${f['coedu']}', style: const TextStyle(fontSize: 11, color: AppColors.subText))),
          if (f['hsType'] != null && f['hsType'].toString().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text('고교유형: ${f['hsType']}', style: const TextStyle(fontSize: 11, color: AppColors.subText))),
          if (f['homepage'] != null && f['homepage'].toString().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text('🌐 ${f['homepage']}', style: const TextStyle(fontSize: 11, color: AppColors.primary))),
        ],
      ),
    );
  }

  Widget _buildChildcareInfo(Map<String, dynamic> f) {
    final capacity = (f['capacity'] as num?)?.toInt() ?? 0;
    final current = (f['currentCount'] as num?)?.toInt() ?? 0;
    final occupancy = (f['occupancyRate'] as num?)?.toDouble() ?? 0.0;
    final hasCctv = f['hasCctv'] as bool? ?? false;
    final staff = (f['staffCount'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🍼 보육 정보', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('정원 / 현원', style: const TextStyle(fontSize: 11, color: AppColors.subText)),
              Text('$current / $capacity명', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: occupancy,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                occupancy >= 0.9 ? const Color(0xFFEF4444) : occupancy >= 0.7 ? const Color(0xFFF59E0B) : AppColors.childcare,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('${(occupancy * 100).toStringAsFixed(0)}% 충족', style: const TextStyle(fontSize: 10, color: AppColors.subText)),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoBadge(hasCctv ? '📷 CCTV 설치' : '📷 CCTV 미설치', hasCctv ? const Color(0xFFEFF6FF) : const Color(0xFFFEF2F2), hasCctv ? AppColors.primary : const Color(0xFFEF4444)),
              const SizedBox(width: 8),
              _infoBadge('👩‍🏫 교직원 $staff명', const Color(0xFFF0FDF4), AppColors.welfare),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelfareInfo(Map<String, dynamic> f) {
    final capacity = (f['capacity'] as num?)?.toInt() ?? 0;
    final staff = (f['staffCount'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🤝 복지시설 정보', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 8),
          if (f['type'] != null && f['type'].toString().isNotEmpty)
            _infoRow('시설 유형', f['type'].toString()),
          if (capacity > 0) ...[
            const SizedBox(height: 4),
            _infoRow('정원', '$capacity명'),
          ],
          if (staff > 0) ...[
            const SizedBox(height: 4),
            _infoRow('직원 수', '$staff명'),
          ],
        ],
      ),
    );
  }

  Widget _buildFoodInfo(Map<String, dynamic> f) {
    final rating = (f['rating'] as num?)?.toDouble() ?? 0.0;
    final category = f['category']?.toString() ?? f['type']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🍽 맛집 정보', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 8),
          if (category.isNotEmpty) ...[
            _infoBadge('🏷 $category', const Color(0xFFFFF7ED), AppColors.food),
            const SizedBox(height: 8),
          ],
          if (rating > 0) ...[
            Row(
              children: [
                ...List.generate(5, (i) {
                  if (i < rating.floor()) return const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B));
                  if (i < rating) return const Icon(Icons.star_half, size: 16, color: Color(0xFFF59E0B));
                  return const Icon(Icons.star_border, size: 16, color: Color(0xFFE2E8F0));
                }),
                const SizedBox(width: 6),
                Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
              ],
            ),
          ] else
            const Text('평점 정보 없음', style: TextStyle(fontSize: 11, color: AppColors.subText)),
        ],
      ),
    );
  }

  Widget _buildCultureInfo(Map<String, dynamic> f) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎭 문화시설 정보', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 8),
          if (f['type'] != null && f['type'].toString().isNotEmpty)
            _infoBadge('🏛 ${f['type']}', const Color(0xFFF5F3FF), AppColors.culture),
          if (f['homepage'] != null && f['homepage'].toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('🌐 ${f['homepage']}', style: const TextStyle(fontSize: 11, color: AppColors.primary)),
          ],
        ],
      ),
    );
  }

  Widget _buildGovernmentInfo(Map<String, dynamic> f) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏛 공공기관 정보', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 8),
          if (f['type'] != null && f['type'].toString().isNotEmpty)
            _infoBadge('🏢 ${f['type']}', const Color(0xFFECFEFF), AppColors.government),
          if (f['tel'] != null && f['tel'].toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            _infoRow('대표번호', f['tel'].toString()),
          ],
          if (f['homepage'] != null && f['homepage'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('🌐 ${f['homepage']}', style: const TextStyle(fontSize: 11, color: AppColors.primary)),
          ],
        ],
      ),
    );
  }

  Widget _infoBadge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.subText)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text)),
      ],
    );
  }

  Widget _buildReviewSection(FacilityDetailViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('💬 후기 (${vm.reviews.length})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReviewWriteView(
                      facilityId: widget.facilityId,
                      facilityName: context.read<FacilityDetailViewModel>().facility?['name'],
                    ),
                  ),
                );
              },
              child: const Text('후기 작성 ›', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _reviewTabButton('후기 목록', _reviewTab == 'all', () => setState(() => _reviewTab = 'all')),
            const SizedBox(width: 6),
            _reviewTabButton('내 후기', _reviewTab == 'my', () => setState(() => _reviewTab = 'my')),
          ],
        ),
        const SizedBox(height: 8),
        if (_reviewTab == 'all')
          ...vm.reviews.map((rv) => _buildReviewCard(rv))
        else
          const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('작성한 후기가 없습니다', style: TextStyle(fontSize: 12, color: AppColors.subText)))),
      ],
    );
  }

  Widget _reviewTabButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: active ? AppColors.primary : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.subText)),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> rv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Text(rv['user'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                ...List.generate(5, (i) => Icon(Icons.star, size: 10, color: i < rv['rating'] ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0))),
              ]),
              Text(rv['date'], style: const TextStyle(fontSize: 9, color: AppColors.subText)),
            ],
          ),
          const SizedBox(height: 4),
          Text(rv['text'], style: const TextStyle(fontSize: 11, color: AppColors.subText)),
        ],
      ),
    );
  }
}