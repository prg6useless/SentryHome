// import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
// import "package:flutter/widgets.dart";
import "package:sentryhome/components/my_button.dart";
import "package:sentryhome/components/my_textfield.dart";
// import "package:sentryhome/services/firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

import "../helper/helper_functions.dart";

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  void login() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    // try to sign in
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      // pop loading circle
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop loading circle
      if (context.mounted) Navigator.pop(context);
      // display error msg
      if (context.mounted) displayMessageToUser(e.code, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo
              Icon(
                Icons.person,
                size: 100,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),

              const SizedBox(height: 25),
              // app name
              const Text(
                "SENTRY HOME",
                style: TextStyle(
                  fontSize: 30,
                  // color: Colors.black,
                ),
              ),
              const SizedBox(height: 50),
              // email

              MyTextField(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController),

              //  password
              const SizedBox(height: 10),

              MyTextField(
                  hintText: "Password",
                  obscureText: true,
                  controller: passwordController),

              const SizedBox(height: 10),

              // forgot passwrod
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Forgot Password?",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  )
                ],
              ),

              const SizedBox(height: 10),

              // login button
              MyButton(text: "Login", onTap: login),

              const SizedBox(height: 25),

              // dont have an account? sign up

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      " Sign Up",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
