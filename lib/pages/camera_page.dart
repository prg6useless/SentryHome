import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "QR Code",
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
        child: Container(
          color: Colors.grey[200],
          height: 200.0,
          width: 200.0,
          child: const Center(
            child: Text(
              "QR Code Placeholder",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
