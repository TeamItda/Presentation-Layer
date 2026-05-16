import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'auth/viewmodel/auth_viewmodel.dart';
import 'chat/viewmodel/chat_viewmodel.dart';
import 'facility/viewmodel/facility_detail_viewmodel.dart';
import 'facility/viewmodel/facility_list_viewmodel.dart';
import 'home/viewmodel/home_viewmodel.dart';
import 'map/viewmodel/map_viewmodel.dart';
import 'profile/viewmodel/profile_viewmodel.dart';
import 'favorite/viewmodel/favorite_viewmodel.dart';
import 'review/viewmodel/review_viewmodel.dart';
import 'non_payment/viewmodel/non_payment_viewmodel.dart';
import 'search/viewmodel/search_viewmodel.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (!kIsWeb && mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
        Locale('ja'),
        Locale('zh'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('ko'),
      child: MultiProvider(
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
        child: const YeogiyoApp(),
      ),
    ),
  );
}