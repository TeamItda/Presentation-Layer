import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeogiyo/app.dart';
import 'package:yeogiyo/chat/view/chat_view.dart';
import 'package:yeogiyo/favorite/view/favorite_view.dart';
import 'package:yeogiyo/map/view/map_view.dart';
import 'package:yeogiyo/profile/view/profile_view.dart';
import 'package:yeogiyo/router/app_router.dart';
import 'package:yeogiyo/search/view/search_view.dart';

void main() {
  Future<void> pumpAppAtRoute(WidgetTester tester, String location) async {
    appRouter.go(location);
    await tester.pumpWidget(const YeogiyoApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('AI chat route opens the chat screen', (tester) async {
    await pumpAppAtRoute(tester, '/chat');

    expect(find.byType(ChatView), findsOneWidget);
    expect(find.text('AI 도우미'), findsOneWidget);
    expect(find.text('자주 묻는 질문'), findsOneWidget);
  });

  testWidgets('Favorites route opens the favorites screen', (tester) async {
    await pumpAppAtRoute(tester, '/favorites');

    expect(find.byType(FavoriteView), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
  });

  testWidgets('Map route opens the map screen', (tester) async {
    await pumpAppAtRoute(tester, '/map');

    expect(find.byType(MapView), findsOneWidget);
  });

  testWidgets('Profile route opens the profile screen', (tester) async {
    await pumpAppAtRoute(tester, '/profile');

    expect(find.byType(ProfileView), findsOneWidget);
  });

  testWidgets('Search route opens the search screen', (tester) async {
    await pumpAppAtRoute(tester, '/search');

    expect(find.byType(SearchView), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
