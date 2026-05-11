import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'app.dart';
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
      child: const YeogiyoApp(),
    ),
  );
}
