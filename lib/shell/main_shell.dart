import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(index),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.subText,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: 'nav.home'.tr()),
            BottomNavigationBarItem(icon: const Icon(Icons.smart_toy_rounded), label: 'nav.chat'.tr()),
            BottomNavigationBarItem(icon: const Icon(Icons.map_rounded), label: 'nav.map'.tr()),
            BottomNavigationBarItem(icon: const Icon(Icons.favorite_rounded), label: 'nav.favorite'.tr()),
            BottomNavigationBarItem(icon: const Icon(Icons.person_rounded), label: 'nav.profile'.tr()),
          ],
        ),
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}