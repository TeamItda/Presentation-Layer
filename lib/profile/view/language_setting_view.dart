import 'package:flutter/material.dart';

// 언어 데이터 모델
class LanguageItem {
  final String code;   // 국가 코드 (KR, US, CN, JP)
  final String name;   // 언어 이름 (한국어, English ...)
  final String locale; // 실제 locale 코드 (ko, en, zh, ja)

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
  // 지원 언어 목록
  final List<LanguageItem> _languages = const [
    LanguageItem(code: 'KR', name: '한국어', locale: 'ko'),
    LanguageItem(code: 'US', name: 'English', locale: 'en'),
    LanguageItem(code: 'CN', name: '中文', locale: 'zh'),
    LanguageItem(code: 'JP', name: '日本語', locale: 'ja'),
  ];

  // 현재 선택된 언어 (기본값: 한국어)
  // 실제 구현 시 → profileViewModel.currentLanguage 로 교체
  String _selectedLocale = 'ko';

  void _onLanguageSelected(String locale) {
    setState(() {
      _selectedLocale = locale;
    });
    // 실제 구현 시:
    // profileViewModel.changeLang(locale) → notifyListeners()
    // 앱 전체 UI 언어 즉시 변경
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: _buildAppBar(),
      body: _buildLanguageList(),
    );
  }

  // ───────────────────────────────────────────
  // AppBar: 뒤로가기 + 언어 설정 타이틀
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
      title: Row(
        children: [
          const Icon(Icons.language, color: Color(0xFF3D5AFE), size: 20),
          const SizedBox(width: 6),
          const Text(
            '언어 설정',
            style: TextStyle(
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

  // ───────────────────────────────────────────
  // 언어 선택 리스트
  // ───────────────────────────────────────────
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

  // ───────────────────────────────────────────
  // 언어 아이템 카드
  // ───────────────────────────────────────────
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
            // 국가 코드 (KR, US, CN, JP)
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
            // 언어 이름
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
            // 선택된 언어에만 체크 표시
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