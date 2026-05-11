import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../profile/viewmodel/profile_viewmodel.dart';
import '../../profile/view/language_setting_view.dart';
import '../../profile/view/app_info_view.dart';
import '../../profile/view/my_reviews_view.dart';
import '../../favorite/view/favorite_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    _buildUserCard(context),
                    const SizedBox(height: 12),
                    _buildMenuGroup(context, vm),
                    const SizedBox(height: 24),
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

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.person, size: 22, color: Colors.black87),
          const SizedBox(width: 8),
          Text(
            'profile.title'.tr(),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vm.nickname.isEmpty ? 'profile.no_name'.tr() : vm.nickname,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                vm.email,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup(BuildContext context, ProfileViewModel vm) {
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
            title: 'profile.language_setting'.tr(),
            trailingText: vm.currentLanguage,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LanguageSettingView()),
            ),
            showDivider: true,
          ),
          _buildMenuItem(
            context,
            icon: Icons.edit_note,
            iconColor: const Color(0xFFFF7043),
            title: 'profile.my_reviews'.tr(),
            trailingText: '${vm.reviewCount}${'profile.count_suffix'.tr()}',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyReviewsView()),
            ),
            showDivider: true,
          ),
          _buildMenuItem(
            context,
            icon: Icons.favorite,
            iconColor: const Color(0xFFE53935),
            title: 'profile.favorites'.tr(),
            trailingText: '${vm.favoriteCount}${'profile.count_suffix'.tr()}',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const FavoriteView(showBackButton: true),
              ),
            ),
            showDivider: true,
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            iconColor: const Color(0xFF1E88E5),
            title: 'profile.app_info'.tr(),
            trailingText: '',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AppInfoView()),
            ),
            showDivider: false,
          ),
        ],
      ),
    );
  }

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
                Icon(icon, size: 22, color: iconColor),
                const SizedBox(width: 12),
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

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text(
              'profile.logout'.tr(),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
            content: Text(
              'profile.logout_confirm'.tr(),
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  'common.cancel'.tr(),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  'profile.logout'.tr(),
                  style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          final vm = context.read<AuthViewModel>();
          await vm.signOut();
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
        child: Center(
          child: Text(
            'profile.logout'.tr(),
            style: const TextStyle(
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