import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nlpproje/ChatPage.dart';
import 'package:nlpproje/HomeScreen.dart';
import 'package:nlpproje/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      home: rememberme ? ChatPage() : Login(),
    );
  }
}
