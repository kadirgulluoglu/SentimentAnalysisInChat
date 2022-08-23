import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nlpproje/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/chat_page.dart';

bool rememberme = true;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  rememberme = prefs.getBool('BeniHatirla') ?? false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Duygu Analizi',
      home: rememberme ? const ChatPage() : Login(),
    );
  }
}
