import 'package:easy_localization/easy_localization.dart';
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
  const FacilityDetailView({
    super.key,
    required this.facilityId,
    required this.categoryId,
  });

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

  void _findAndSetFacility(
    FacilityListViewModel listVm,
    FacilityDetailViewModel detailVm,
  ) {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'facility.loading'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.subText,
                      ),
                    ),
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
                          if (widget.categoryId == 'medical')
                            _buildMedicalInfo(f),
                          if (widget.categoryId == 'pharmacy')
                            _buildPharmacyInfo(f),
                          if (widget.categoryId == 'education')
                            _buildEducationInfo(f),
                          if (widget.categoryId == 'childcare')
                            _buildChildcareInfo(f),
                          if (widget.categoryId == 'welfare')
                            _buildWelfareInfo(f, vm),
                          if (widget.categoryId == 'food') _buildFoodInfo(f),
                          if (widget.categoryId == 'culture')
                            _buildCultureInfo(f),
                          if (widget.categoryId == 'government')
                            _buildGovernmentInfo(f),
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

  Widget _buildHeader(
    BuildContext context,
    Map<String, dynamic> f,
    FacilityDetailViewModel vm,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              f['name'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => vm.toggleFavorite(),
            child: Icon(
              vm.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: vm.isFavorite ? Colors.red : AppColors.subText,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMap(Category cat) {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDBEAFE), Color(0xFFF0FDF4)],
        ),
      ),
      child: Center(
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: cat.color, shape: BoxShape.circle),
          child: Center(
            child: Text(cat.icon, style: const TextStyle(fontSize: 14)),
          ),
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
              decoration: BoxDecoration(
                color: cat.bgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${cat.icon} ${cat.name}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cat.color,
                ),
              ),
            ),
            if (f['type'] != null && f['type'].toString().isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  f['type'].toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.subText,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (f['addr'] != null)
          Text(
            '📍 ${f['addr']}',
            style: const TextStyle(fontSize: 12, color: AppColors.subText),
          ),
        if (f['tel'] != null && f['tel'].toString().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '📞 ${f['tel']}',
            style: const TextStyle(fontSize: 12, color: AppColors.primary),
          ),
        ],
        if (f['homepage'] != null && f['homepage'].toString().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '🌐 ${f['homepage']}',
            style: const TextStyle(fontSize: 11, color: AppColors.primary),
          ),
        ],
      ],
    );
  }

  Widget _buildMedicalInfo(Map<String, dynamic> f) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'facility.medical_info'.tr(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          if (f['dept'] != null && f['dept'].toString().isNotEmpty) ...[
            Text(
              'facility.medical_dept'.tr(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.subText,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: (f['dept'] as String)
                  .split(', ')
                  .map(
                    (d) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 8),
          if (f['totalDocs'] != null)
            Text(
              'facility.medical_doctors'.tr(
                namedArgs: {
                  'total': '${f['totalDocs']}',
                  'specialists': '${f['specialists'] ?? 0}',
                },
              ),
              style: const TextStyle(fontSize: 11, color: AppColors.subText),
            ),
          if (f['equip'] != null && f['equip'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '🔬 ${f['equip']}',
              style: const TextStyle(fontSize: 11, color: AppColors.subText),
            ),
          ],
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NonPaymentView(
                    hospitalId: f['id'],
                    hospitalName: f['name'],
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.medical,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'facility.non_payment'.tr(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyInfo(Map<String, dynamic> f) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'facility.pharmacy_info'.tr(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          if (f['tel'] != null && f['tel'].toString().isNotEmpty)
            Text(
              '${'facility.pharmacy_tel'.tr()}${f['tel']}',
              style: const TextStyle(fontSize: 11, color: AppColors.subText),
            ),
          if (f['addr'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${'facility.pharmacy_addr'.tr()}${f['addr']}',
                style: const TextStyle(fontSize: 11, color: AppColors.subText),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEducationInfo(Map<String, dynamic> f) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'facility.education_info'.tr(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          if (f['type'] != null)
            Text(
              '${'facility.edu_level'.tr()}${f['type']}',
              style: const TextStyle(fontSize: 11, color: AppColors.subText),
            ),
          if (f['fondType'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${'facility.edu_fond'.tr()}${f['fondType']}',
                style: const TextStyle(fontSize: 11, color: AppColors.subText),
              ),
            ),
          if (f['coedu'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${'facility.edu_coedu'.tr()}${f['coedu']}',
                style: const TextStyle(fontSize: 11, color: AppColors.subText),
              ),
            ),
          if (f['hsType'] != null && f['hsType'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${'facility.edu_hstype'.tr()}${f['hsType']}',
                style: const TextStyle(fontSize: 11, color: AppColors.subText),
              ),
            ),
          if (f['homepage'] != null && f['homepage'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '🌐 ${f['homepage']}',
                style: const TextStyle(fontSize: 11, color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChildcareInfo(Map<String, dynamic> f) {
    final capacity = (f['capacity'] as num?)?.toInt() ?? 0;
    final current = (f['currentCount'] as num?)?.toInt() ?? 0;
    final occupancy = (f['occupancyRate'] as num?)?.toDouble() ?? 0.0;
    final staff = (f['staffCount'] as num?)?.toInt() ?? 0;
    final operatingHours = (f['operatingHours'] ?? '').toString();
    final publicPrivate = (f['publicPrivate'] ?? '').toString();
    final typeText = (f['type'] ?? '').toString();
    final tel = (f['tel'] ?? '').toString();
    final addr = (f['addr'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'facility.childcare_info'.tr(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          if (typeText.isNotEmpty) ...[
            _infoRow('facility.welfare_type'.tr(), typeText),
            const SizedBox(height: 4),
          ],
          if (operatingHours.isNotEmpty) ...[
            _infoRow('운영시간', operatingHours),
            const SizedBox(height: 4),
          ],
          if (addr.isNotEmpty) ...[
            _infoRow('facility.pharmacy_addr'.tr().replaceAll(': ', ''), addr),
            const SizedBox(height: 4),
          ],
          if (tel.isNotEmpty) ...[
            _infoRow('facility.government_tel'.tr(), tel),
            const SizedBox(height: 8),
          ],
          if (capacity > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'facility.childcare_capacity'.tr(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.subText,
                  ),
                ),
                Text(
                  '$current / $capacity${'facility.capacity_unit'.tr()}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
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
                  occupancy >= 0.9
                      ? const Color(0xFFEF4444)
                      : occupancy >= 0.7
                      ? const Color(0xFFF59E0B)
                      : AppColors.childcare,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'facility.childcare_occupancy'.tr(
                namedArgs: {'rate': (occupancy * 100).toStringAsFixed(0)},
              ),
              style: const TextStyle(fontSize: 10, color: AppColors.subText),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              if (publicPrivate.isNotEmpty) ...[
                _infoBadge(
                  '$publicPrivate',
                  publicPrivate == '공립'
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFFFF7ED),
                  publicPrivate == '공립' ? AppColors.primary : AppColors.food,
                ),
                const SizedBox(width: 8),
              ],
              if (staff > 0)
                _infoBadge(
                  'facility.childcare_staff'.tr(namedArgs: {'count': '$staff'}),
                  const Color(0xFFF0FDF4),
                  AppColors.welfare,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelfareInfo(Map<String, dynamic> f, FacilityDetailViewModel vm) {
    final capacity = (f['capacity'] as num?)?.toInt() ?? 0;
    final localStaff = (f['staffCount'] as num?)?.toInt() ?? 0;
    final tel = (f['tel'] ?? '').toString();
    final addr = (f['addr'] ?? '').toString();

    final ltcStaff = vm.ltcStaff;
    final ltcPrograms = vm.ltcPrograms;
    final ltcAcceptance = vm.ltcAcceptance;
    final apiStaffTotal = ltcStaff?.total ?? 0;
    final staffTotal = apiStaffTotal > 0 ? apiStaffTotal : localStaff;
    final apiCurrent = ltcAcceptance?.current ?? 0;
    final apiCapacity = ltcAcceptance?.capacity ?? 0;
    final showCapacity = apiCapacity > 0 ? apiCapacity : capacity;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'facility.welfare_info'.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              if (vm.isLtcLoading) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (f['type'] != null && f['type'].toString().isNotEmpty) ...[
            _infoRow('facility.welfare_type'.tr(), f['type'].toString()),
            const SizedBox(height: 4),
          ],
          if (addr.isNotEmpty) ...[
            _infoRow('facility.pharmacy_addr'.tr().replaceAll(': ', ''), addr),
            const SizedBox(height: 4),
          ],
          if (tel.isNotEmpty) ...[
            _infoRow('facility.government_tel'.tr(), tel),
            const SizedBox(height: 4),
          ],
          if (showCapacity > 0) ...[
            if (apiCapacity > 0)
              _infoRow(
                'facility.childcare_capacity'.tr(),
                '$apiCurrent / $apiCapacity${'facility.capacity_unit'.tr()}',
              )
            else
              _infoRow(
                'facility.welfare_capacity'.tr(),
                '$showCapacity${'facility.capacity_unit'.tr()}',
              ),
            const SizedBox(height: 4),
          ],
          if (staffTotal > 0) ...[
            _infoRow(
              'facility.welfare_staff'.tr(),
              '$staffTotal${'facility.staff_unit'.tr()}',
            ),
          ],
          if (ltcStaff != null && ltcStaff.nonZeroRoles.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              '👥 직군별 인력',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ltcStaff.nonZeroRoles
                  .map(
                    (e) => _infoBadge(
                      '${e.key} ${e.value}',
                      const Color(0xFFF0FDF4),
                      AppColors.welfare,
                    ),
                  )
                  .toList(),
            ),
          ],
          if (ltcPrograms.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '🎯 프로그램 현황 (${ltcPrograms.length}개)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 6),
            ...ltcPrograms
                .take(20)
                .map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.welfare,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: p.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),
                                TextSpan(
                                  text: '  ·  ${p.typeLabel}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.subText,
                                  ),
                                ),
                                if (p.location != null)
                                  TextSpan(
                                    text: '  ·  ${p.location}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.subText,
                                    ),
                                  ),
                                if (p.targetCount > 0)
                                  TextSpan(
                                    text: '  ·  ${p.targetCount}명',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.subText,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'facility.food_info'.tr(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          if (category.isNotEmpty) ...[
            _infoBadge('🏷 $category', const Color(0xFFFFF7ED), AppColors.food),
            const SizedBox(height: 8),
          ],
          if (rating > 0) ...[
            Row(
              children: [
                ...List.generate(5, (i) {
                  if (i < rating.floor())
                    return const Icon(
                      Icons.star,
                      size: 16,
                      color: Color(0xFFF59E0B),
                    );
                  if (i < rating)
                    return const Icon(
                      Icons.star_half,
                      size: 16,
                      color: Color(0xFFF59E0B),
                    );
                  return const Icon(
                    Icons.star_border,
                    size: 16,
                    color: Color(0xFFE2E8F0),
                  );
                }),
                const SizedBox(width: 6),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ] else
            Text(
              'facility.food_no_rating'.tr(),
              style: const TextStyle(fontSize: 11, color: AppColors.subText),
            ),
        ],
      ),
    );
  }

  Widget _buildCultureInfo(Map<String, dynamic> f) {
    final type = (f['type'] ?? '').toString();
    final addr = (f['addr'] ?? '').toString();
    final tel = (f['tel'] ?? '').toString();
    final homepage = (f['homepage'] ?? '').toString();

    // 유형별 색상/이모지 매핑
    const typeEmoji = {
      '미술관': '🖼',
      '박물관': '🏛',
      '공연장': '🎭',
      '도서관': '📚',
      '문학관': '📖',
      '문화의집': '🏠',
      '지방문화원': '🎨',
      '생활문화센터': '🎪',
      '지역문화재단': '🏢',
      '고궁': '🏯',
    };
    final emoji = typeEmoji[type] ?? '🏛';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'facility.culture_info'.tr(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          if (type.isNotEmpty)
            _infoBadge(
              '$emoji $type',
              const Color(0xFFF5F3FF),
              AppColors.culture,
            ),
          if (addr.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow('facility.pharmacy_addr'.tr().replaceAll(': ', ''), addr),
          ],
          if (tel.isNotEmpty) ...[
            const SizedBox(height: 4),
            _infoRow('facility.government_tel'.tr(), tel),
          ],
          if (homepage.isNotEmpty) ...[
            const SizedBox(height: 4),
            _infoRow('홈페이지', homepage),
          ],
        ],
      ),
    );
  }

  Widget _buildGovernmentInfo(Map<String, dynamic> f) {
    final type = (f['type'] ?? '').toString();
    final operatingHours = (f['operatingHours'] ?? '').toString();
    const typeEmoji = {
      '구청': '🏛',
      '주민센터': '🏢',
      '경찰서': '👮',
      '소방서': '🚒',
      '보건소': '🏥',
      '세무서': '💰',
      '우체국': '📮',
      '행정기관': '🏛',
      '교육기관': '🎓',
      '복지기관': '🤝',
    };
    final emoji = typeEmoji[type] ?? '🏢';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'facility.government_info'.tr(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          if (type.isNotEmpty)
            _infoBadge(
              '$emoji $type',
              const Color(0xFFECFEFF),
              AppColors.government,
            ),
          if (operatingHours.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow('운영시간', operatingHours),
          ],
          if (f['tel'] != null && f['tel'].toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            _infoRow('facility.government_tel'.tr(), f['tel'].toString()),
          ],
          if (f['homepage'] != null && f['homepage'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '🌐 ${f['homepage']}',
              style: const TextStyle(fontSize: 11, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoBadge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.subText),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
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
            Text(
              'facility.review_title'.tr(
                namedArgs: {'count': '${vm.reviews.length}'},
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReviewWriteView(
                      facilityId: widget.facilityId,
                      facilityName: context
                          .read<FacilityDetailViewModel>()
                          .facility?['name'],
                    ),
                  ),
                );
              },
              child: Text(
                'facility.review_write'.tr(),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _reviewTabButton(
              'facility.review_all'.tr(),
              _reviewTab == 'all',
              () => setState(() => _reviewTab = 'all'),
            ),
            const SizedBox(width: 6),
            _reviewTabButton(
              'facility.review_my'.tr(),
              _reviewTab == 'my',
              () => setState(() => _reviewTab = 'my'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (vm.isReviewLoading)
          const Center(child: CircularProgressIndicator())
        else if (_reviewTab == 'all')
          vm.reviews.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'facility.review_empty'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.subText,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: vm.reviews
                      .map((rv) => _buildReviewCard(rv))
                      .toList(),
                )
        else
          vm.myReviews.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'facility.review_empty'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.subText,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: vm.myReviews
                      .map((rv) => _buildReviewCard(rv))
                      .toList(),
                ),
      ],
    );
  }

  Widget _reviewTabButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.subText,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> rv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    rv['user'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  ...List.generate(
                    5,
                    (i) => Icon(
                      Icons.star,
                      size: 10,
                      color: i < rv['rating']
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                ],
              ),
              Text(
                rv['date'],
                style: const TextStyle(fontSize: 9, color: AppColors.subText),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            rv['text'],
            style: const TextStyle(fontSize: 11, color: AppColors.subText),
          ),
        ],
      ),
    );
  }
}
