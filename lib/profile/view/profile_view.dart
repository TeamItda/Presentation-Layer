import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  // ── 더미 데이터 (나중에 ViewModel + Firebase Auth로 교체) ──
  static const String _userName = '홍길동';
  static const String _userEmail = 'hong@example.com';
  static const String _currentLanguage = '한국어';
  static const int _reviewCount = 0;
  static const int _favoriteCount = 0;
  static const String _appVersion = 'v1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── 상단 타이틀 ──
            _buildHeader(),

            // ── 메뉴 리스트 ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    // 사용자 정보 카드
                    _buildUserCard(),
                    const SizedBox(height: 12),

                    // 메뉴 그룹
                    _buildMenuGroup(context),
                    const SizedBox(height: 24),

                    // 로그아웃 버튼
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────
  // 상단 타이틀 "프로필"
  // ───────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.person, size: 22, color: Colors.black87),
          const SizedBox(width: 8),
          const Text(
            '프로필',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────
  // 사용자 정보 카드 (아바타 + 이름 + 이메일)
  // ───────────────────────────────────────────
  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // 아바타
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEF5),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(Icons.person, size: 28, color: Color(0xFF9E9EBF)),
          ),
          const SizedBox(width: 14),
          // 이름 + 이메일
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _userEmail,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────
  // 메뉴 그룹 (언어설정 / 내가 쓴 후기 / 즐겨찾기 / 앱 정보)
  // ───────────────────────────────────────────
  Widget _buildMenuGroup(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.language,
            iconColor: const Color(0xFF3D5AFE),
            title: '언어 설정',
            trailingText: _currentLanguage,
            onTap: () {
              // 실제 구현 시: context.push('/language-setting')
            },
            showDivider: true,
          ),
          _buildMenuItem(
            context,
            icon: Icons.edit_note,
            iconColor: const Color(0xFFFF7043),
            title: '내가 쓴 후기',
            trailingText: '$_reviewCount개',
            onTap: () {
              // 실제 구현 시: context.push('/my-reviews')
            },
            showDivider: true,
          ),
          _buildMenuItem(
            context,
            icon: Icons.favorite,
            iconColor: const Color(0xFFE53935),
            title: '즐겨찾기',
            trailingText: '$_favoriteCount개',
            onTap: () {
              // 실제 구현 시: 즐겨찾기 탭으로 전환
            },
            showDivider: true,
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            iconColor: const Color(0xFF1E88E5),
            title: '앱 정보',
            trailingText: _appVersion,
            onTap: () {
              // 실제 구현 시: context.push('/app-info')
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // 메뉴 아이템 (재사용 가능한 위젯)
  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String title,
        required String trailingText,
        required VoidCallback onTap,
        required bool showDivider,
      }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // 아이콘
                Icon(icon, size: 22, color: iconColor),
                const SizedBox(width: 12),
                // 타이틀
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // 오른쪽 텍스트 + 화살표
                Text(
                  trailingText,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[100],
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  // ───────────────────────────────────────────
  // 로그아웃 버튼
  // ───────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) =>
              AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: const Text(
                  '로그아웃',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                content: const Text(
                  '정말 로그아웃 하시겠어요?',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(
                        '취소', style: TextStyle(color: Colors.grey[600])),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
        );

        if (confirm == true && context.mounted) {
          print('로그아웃 시작');
          final vm = context.read<AuthViewModel>();
          await vm.signOut();
          print('로그아웃 완료');
          context.go('/login');
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            '로그아웃',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE53935),
            ),
          ),
        ),
      ),
    );
  }
}