import 'package:flutter/material.dart';
// import '../theme/dark_mode.dart';
// import '../theme/light_mode.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkModeEnabled = false; // Initially set to false (light mode)
  final _isMotDetEnabled = false; // Initially set to false (light mode)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "S E T T I N G S",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Dark Mode"),
                Switch(
                  value: _isDarkModeEnabled,
                  onChanged: _toggleDarkMode,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Motion Detection"),
                Switch(
                  value: _isMotDetEnabled,
                  onChanged: _toggleMotionDetectionMode,
                )
              ],
            ),
            // Add other settings here
          ],
        ),
      ),
    );
  }

  // this fucntion is not executed

  void _toggleDarkMode(bool newValue) {
    setState(() {
      // Update the state of the app
      // print("Dark mode enabled: $newValue");
      _isDarkModeEnabled = newValue;

      // Update the theme of the app
      if (_isDarkModeEnabled) {
        // Dark mode
      } else {
        // Light mode
      }
    });
  }

  void _toggleMotionDetectionMode(bool newValue) {}
}
