import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/viewmodel/auth_viewmodel.dart';
import 'core/constants.dart';
import 'profile/viewmodel/profile_viewmodel.dart';
import 'router/app_router.dart';

class YeogiyoApp extends StatefulWidget {
  const YeogiyoApp({super.key});

  @override
  State<YeogiyoApp> createState() => _YeogiyoAppState();
}

class _YeogiyoAppState extends State<YeogiyoApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authVm = context.read<AuthViewModel>();
      await authVm.loadUserInfo();

      final lang = authVm.selectedLanguage;
      if (mounted) {
        context.setLocale(Locale(lang));
        context.read<ProfileViewModel>().changeLang(lang);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
    );
  }
}