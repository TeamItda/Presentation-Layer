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
      ],
      child: MaterialApp.router(
        title: 'Yeogiyo - 여기요',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: AppColors.primary,
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
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
