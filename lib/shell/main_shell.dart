import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _currentIndex(context),
          onTap: (i) => _onTap(context, i),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.subText,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '홈'),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_rounded),
              label: 'AI도우미',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: '지도'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded),
              label: '즐겨찾기',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: '프로필',
            ),
          ],
        ),
      ),
    );
  }

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/chat')) return 1;
    if (loc.startsWith('/map')) return 2;
    if (loc.startsWith('/favorites')) return 3;
    if (loc.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int i) {
    switch (i) {
      case 0:
        context.go('/home');
        return;
      case 1:
        context.go('/chat');
        return;
      case 2:
        context.go('/map');
        return;
      case 3:
        context.go('/favorites');
        return;
      case 4:
        context.go('/profile');
        return;
    }
  }
}
