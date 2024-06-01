import 'package:flutter/material.dart';
import 'package:sentryhome/components/my_button.dart';


class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "QR Scanner",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Center(
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
    );
  }
}
