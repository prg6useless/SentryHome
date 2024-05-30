import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _generalNotificationsEnabled = false;
  bool _motionDetectionNotificationsEnabled = false;
  bool _cameraHealthNotificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
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
          _buildNotificationItem(
            context,
            icon: Icons.notifications,
            text: "General Notifications",
            value: _generalNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _generalNotificationsEnabled = value;
              });
            },
          ),
          _buildNotificationItem(
            context,
            icon: Icons.directions_walk,
            text: "Motion Detection Notification",
            value: _motionDetectionNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _motionDetectionNotificationsEnabled = value;
              });
            },
          ),
          _buildNotificationItem(
            context,
            icon: Icons.camera,
            text: "Camera Health",
            value: _cameraHealthNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _cameraHealthNotificationsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
