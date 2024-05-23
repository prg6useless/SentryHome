import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentryhome/auth/auth.dart';
import 'package:sentryhome/auth/login_or_register.dart';
import 'package:sentryhome/pages/selectmode.dart';
import 'package:sentryhome/pages/stream_page.dart';
import 'package:sentryhome/theme/dark_mode.dart';
import 'package:sentryhome/theme/light_mode.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/notifications_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      theme: lightMode,
      darkTheme: darkMode,
      //routes
      // initialRoute: '/',
      routes: {
        '/loginorregister': (context) => const LoginOrRegister(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => ProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/selectmode': (context) => const SelectMode(),
        "/stream": (context) => CameraStreamPage(),
      },
    );
  }
}
