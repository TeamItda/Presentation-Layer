import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Allow the app to boot in local/dev environments where Firebase
    // configuration files have not been added yet.
  }
  runApp(const YeogiyoApp());
}
