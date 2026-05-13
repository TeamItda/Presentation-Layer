import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../profile/viewmodel/profile_viewmodel.dart';
import '../../facility/viewmodel/facility_list_viewmodel.dart';
import '../../map/viewmodel/map_viewmodel.dart';
import '../../home/viewmodel/home_viewmodel.dart';
import '../../favorite/viewmodel/favorite_viewmodel.dart';
import '../../non_payment/viewmodel/non_payment_viewmodel.dart';

class LanguageItem {
  final String code;
  final String name;
  final String locale;

  const LanguageItem({
    required this.code,
    required this.name,
    required this.locale,
  });
}

class LanguageSettingView extends StatefulWidget {
  const LanguageSettingView({super.key});

  @override
  State<LanguageSettingView> createState() => _LanguageSettingViewState();
}

class _LanguageSettingViewState extends State<LanguageSettingView> {
  final List<LanguageItem> _languages = const [
    LanguageItem(code: 'KR', name: '한국어', locale: 'ko'),
    LanguageItem(code: 'US', name: 'English', locale: 'en'),
    LanguageItem(code: 'CN', name: '中文', locale: 'zh'),
    LanguageItem(code: 'JP', name: '日本語', locale: 'ja'),
  ];

  late String _selectedLocale;

  @override
  void initState() {
    super.initState();
    // 현재 앱 언어로 초기값 설정
    _selectedLocale = context.read<AuthViewModel>().selectedLanguage;
  }

  void _onLanguageSelected(String locale) {
    setState(() => _selectedLocale = locale);
    // 앱 전체 언어 즉시 변경
    context.setLocale(Locale(locale));
    context.read<AuthViewModel>().selectLanguage(locale);
    context.read<ProfileViewModel>().changeLang(locale);
    context.read<FacilityListViewModel>().changeLang(locale);
    context.read<MapViewModel>().changeLang(locale);
    context.read<HomeViewModel>().changeLang(locale);
    context.read<FavoriteViewModel>().changeLang(locale);
    context.read<NonPaymentViewModel>().changeLang(locale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: _buildAppBar(),
      body: _buildLanguageList(),
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
          const Icon(Icons.language, color: Color(0xFF3D5AFE), size: 20),
          const SizedBox(width: 6),
          Text(
            'profile.language_setting'.tr(),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      titleSpacing: 0,
    );
  }

  Widget _buildLanguageList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _languages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final lang = _languages[index];
        final isSelected = _selectedLocale == lang.locale;
        return _buildLanguageItem(lang, isSelected);
      },
    );
  }

  Widget _buildLanguageItem(LanguageItem lang, bool isSelected) {
    return GestureDetector(
      onTap: () => _onLanguageSelected(lang.locale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3D5AFE)
                : const Color(0xFFE0E0E0),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                lang.code,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF3D5AFE)
                      : Colors.grey[500],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                lang.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF3D5AFE)
                      : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                color: Color(0xFF3D5AFE),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}