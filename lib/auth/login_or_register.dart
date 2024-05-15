import 'package:flutter/material.dart';

import '../pages/login.dart';
import '../pages/signup.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // initially show LoginPage
  bool showLogin = true;

  // toggle between login and register
  void toggleView() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLogin
        ? LoginPage(onTap: toggleView)
        : SignupPage(onTap: toggleView);
  }
}
