import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shell/main_shell.dart';
import '../home/view/home_view.dart';
import '../facility/view/facility_list_view.dart';
import '../facility/view/facility_detail_view.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    // 메인 탭 (BottomNavigationBar)
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (c, s) => const HomeView()),
        GoRoute(path: '/chat', builder: (c, s) => const Scaffold(body: Center(child: Text('AI 챗봇 - 팀원 E')))),
        GoRoute(path: '/map', builder: (c, s) => const Scaffold(body: Center(child: Text('지도 - 팀원 C')))),
        GoRoute(path: '/favorites', builder: (c, s) => const Scaffold(body: Center(child: Text('즐겨찾기 - 팀원 D')))),
        GoRoute(path: '/profile', builder: (c, s) => const Scaffold(body: Center(child: Text('프로필 - 팀원 D')))),
      ],
    ),
    // 상세 화면 (탭바 없음)
    GoRoute(
      path: '/facilities/:category',
      builder: (c, s) => FacilityListView(categoryId: s.pathParameters['category']!),
    ),
    GoRoute(
      path: '/facility/:id',
      builder: (c, s) => FacilityDetailView(
        facilityId: s.pathParameters['id']!,
        categoryId: s.uri.queryParameters['category'] ?? 'medical',
      ),
    ),
    GoRoute(path: '/search', builder: (c, s) => const Scaffold(body: Center(child: Text('검색 - 팀원 D')))),
  ],
);