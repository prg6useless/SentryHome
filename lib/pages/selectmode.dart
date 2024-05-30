import 'package:flutter/material.dart';
import 'package:sentryhome/components/my_button.dart';
import 'package:sentryhome/components/my_drawer.dart';

class SelectMode extends StatelessWidget {
  const SelectMode({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "S E L E C T M O D E",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // center this text
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyButton(
                    text: "Use as Camera",
                    onTap: () {
                      Navigator.pushNamed(context, '/stream');
                    }),
                const SizedBox(height: 25),
                MyButton(
                    text: "Use as Viewer",
                    onTap: () {
                      Navigator.pushNamed(context, '/view');
                    })
              ],
            ),
          ),
        ));
  }
}
