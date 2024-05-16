import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final Icon prefixIcon;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
        fillColor: const Color.fromRGBO(160, 160, 160, 0.7),
        filled: true,
        // make prefixIcon sent as a string to an Icon
        prefixIcon: prefixIcon,
      ),
      obscureText: obscureText,
    );
  }
}
