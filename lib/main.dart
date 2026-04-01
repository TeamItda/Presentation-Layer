import 'package:flutter/material.dart';
import 'app.dart';

// TODO: Firebase 연동 시 아래 주석 해제
// import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Firebase 연동 시 아래 주석 해제
  // await Firebase.initializeApp();
  runApp(const YeogiyoApp());
}
