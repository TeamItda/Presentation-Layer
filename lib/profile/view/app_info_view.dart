import 'package:flutter/material.dart';

class AppInfoView extends StatelessWidget {
  const AppInfoView({super.key});

  // 더미 데이터 — 실제 구현 시 package_info_plus 패키지로 교체
  static const String _appName = '종로 라이프 가이드';
  static const String _appSubtitle = '종로구 생활정보 통합 안내';
  static const String _appVersion = '버전 1.0.0';
  static const String _techStack = 'Flutter + Dart + GPT API';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── 앱 로고 + 이름 + 버전 ──
            _buildAppHeader(),
            const SizedBox(height: 12),
            // ── 개발 정보 ──
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────
  // AppBar
  // ───────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
          Icon(Icons.info_outline, color: Color(0xFF1E88E5), size: 20),
          SizedBox(width: 6),
          Text(
            '앱 정보',
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
  // 앱 로고 + 이름 + 버전
  // ───────────────────────────────────────────
  Widget _buildAppHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF2F4F7),
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          const Text('🏘️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          // 앱 이름
          const Text(
            _appName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          // 부제목
          Text(
            _appSubtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 6),
          // 버전
          Text(
            _appVersion,
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────
  // 개발 정보 섹션
  // ───────────────────────────────────────────
  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '개발 정보',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _techStack,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}