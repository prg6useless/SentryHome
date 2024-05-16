import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:sentryhome/services/firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

import "../components/my_button.dart";
import "../components/my_textfield.dart";
import "../helper/helper_functions.dart";

class SignupPage extends StatefulWidget {
  final void Function()? onTap;

  const SignupPage({super.key, required this.onTap});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // firestore
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController confirmPWController = TextEditingController();

  void signupUser() async {
    // show  loading circle
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    // make sure the passwords match
    if (passwordController.text != confirmPWController.text) {
      // pop the loading circle
      Navigator.pop(context);
      // show error msg
      displayMessageToUser("Passwords dont match", context);
    }
    // creating the user
    else {
      try {
        UserCredential? userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);

        // create and add user to firestore

        createUserDocument(userCredential);

        // pop loading circle
        if (context.mounted) Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        // pop loading circle
        if (context.mounted) Navigator.pop(context);
        // display error msg
        if (context.mounted) displayMessageToUser(e.code, context);
      }
    }
  }

  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        "email": userCredential.user!.email,
        "username": usernameController.text,
      });
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
              // username

              MyTextField(
                hintText: "Username",
                obscureText: false,
                controller: usernameController,
                prefixIcon: const Icon(Icons.person),
              ),
              // email
              const SizedBox(height: 10),

              MyTextField(
                hintText: "Email",
                obscureText: false,
                controller: emailController,
                prefixIcon: const Icon(Icons.email),
              ),

              // password
              const SizedBox(height: 10),

              MyTextField(
                hintText: "Password",
                obscureText: true,
                controller: passwordController,
                prefixIcon: const Icon(Icons.password),
              ),

              const SizedBox(height: 10),

              //  confirm password
              MyTextField(
                hintText: "Confirm Password",
                obscureText: true,
                controller: confirmPWController,
                prefixIcon: const Icon(Icons.password),
              ),

              const SizedBox(height: 10),

              // forgot passwrod
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 10),

              // login button
              MyButton(text: "SignUp", onTap: signupUser),

              const SizedBox(height: 25),

              // dont have an account? sign up

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      " Login",
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
