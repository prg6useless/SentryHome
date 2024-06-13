import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkModeEnabled;
  final ValueChanged<bool> onDarkModeChanged;

  const SettingsPage({
    Key? key,
    required this.isDarkModeEnabled,
    required this.onDarkModeChanged,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isMotDetEnabled = false; // Initially set to false (light mode)

  @override
  void initState() {
    super.initState();
    _fetchMotionDetectionSetting();
  }

  Future<void> _fetchMotionDetectionSetting() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .get();
      if (userDoc.exists) {
        setState(() {
          _isMotDetEnabled = userDoc.data()?['motionDetectionEnabled'] ?? false;
        });
      }
    }
  }

  Future<void> _updateMotionDetectionSetting(bool isEnabled) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .update({
        'motionDetectionEnabled': isEnabled,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsItem(
            context,
            icon: Icons.camera_alt,
            text: "Camera Settings",
            onTap: () {},
          ),
          _buildSettingsItem(
            context,
            icon: Icons.directions_walk,
            text: "Motion Detection",
            trailing: Switch(
              value: _isMotDetEnabled,
              onChanged: (value) {
                setState(() {
                  _isMotDetEnabled = value;
                });
                _updateMotionDetectionSetting(value);
              },
            ),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.palette,
            text: "Toggle Dark Mode",
            trailing: Switch(
              value: widget.isDarkModeEnabled,
              onChanged: widget.onDarkModeChanged,
            ),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.help_outline,
            text: "FAQ",
            onTap: () {
              // Add functionality for FAQ if needed
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.info_outline,
            text: "About",
            onTap: () {
              // Add functionality for About if needed
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    Widget? trailing,
    void Function()? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
