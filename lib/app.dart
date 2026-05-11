import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/viewmodel/auth_viewmodel.dart';
import 'chat/viewmodel/chat_viewmodel.dart';
import 'core/constants.dart';
import 'facility/viewmodel/facility_detail_viewmodel.dart';
import 'facility/viewmodel/facility_list_viewmodel.dart';
import 'home/viewmodel/home_viewmodel.dart';
import 'map/viewmodel/map_viewmodel.dart';
import 'router/app_router.dart';

import 'profile/viewmodel/profile_viewmodel.dart';
import 'favorite/viewmodel/favorite_viewmodel.dart';
import 'review/viewmodel/review_viewmodel.dart';
import 'non_payment/viewmodel/non_payment_viewmodel.dart';
import 'search/viewmodel/search_viewmodel.dart';

class YeogiyoApp extends StatelessWidget {
  const YeogiyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => FacilityListViewModel()),
        ChangeNotifierProvider(create: (_) => FacilityDetailViewModel()),
        ChangeNotifierProvider(create: (_) => MapViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => FavoriteViewModel()),
        ChangeNotifierProvider(create: (_) => ReviewViewModel()),
        ChangeNotifierProvider(create: (_) => NonPaymentViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
      ],
      child: MaterialApp.router(
        title: 'Yeogiyo - 여기요',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          colorSchemeSeed: AppColors.primary,
          useMaterial3: true,
          fontFamily: 'Pretendard',
          scaffoldBackgroundColor: AppColors.background,
          textTheme: ThemeData(useMaterial3: true).textTheme.apply(
            fontFamily: 'Pretendard',
            bodyColor: AppColors.text,
            displayColor: AppColors.text,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.text,
            elevation: 0,
            centerTitle: false,
          ),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
