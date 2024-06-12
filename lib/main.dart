import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentryhome/auth/auth.dart';
import 'package:sentryhome/auth/login_or_register.dart';
import 'package:sentryhome/pages/stream_page.dart';
import 'package:sentryhome/pages/view_page.dart';
import 'package:sentryhome/pages/view_recordings.dart';
import 'package:sentryhome/theme/dark_mode.dart';
import 'package:sentryhome/theme/light_mode.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/notifications_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/qr_scanner_page.dart';
import 'pages/camera_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkModeEnabled = false;

  void _toggleDarkMode(bool newValue) {
    setState(() {
      _isDarkModeEnabled = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: _isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      home: const AuthPage(),
      routes: {
        '/loginorregister': (context) => const LoginOrRegister(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => ProfilePage(),
        '/settings': (context) => SettingsPage(
              isDarkModeEnabled: _isDarkModeEnabled,
              onDarkModeChanged: _toggleDarkMode,
            ),
        '/notifications': (context) => const NotificationsPage(),
        "/stream": (context) => CameraStreamPage(),
        "/view": (context) => VideoFeedPage(),
        '/qrscanner': (context) => const QRScannerPage(),
        '/camera': (context) => const CameraPage(),
        '/viewrecordings': (context) => const VideoPlayerPage(videoName: "")
      },
    );
  }
}
