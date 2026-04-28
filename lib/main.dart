import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCsDGv8oYY0TAncNzGFe7orsbjcsigE77U",
      authDomain: "yeogiyo-59f27.firebaseapp.com",
      projectId: "yeogiyo-59f27",
      storageBucket: "yeogiyo-59f27.firebasestorage.app",
      messagingSenderId: "292137139277",
      appId: "1:292137139277:web:39c8cab9136825f01e3004",
    ),
  );
  runApp(const YeogiyoApp());
}