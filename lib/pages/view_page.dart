import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class VideoFeedPage extends StatefulWidget {
  @override
  _VideoFeedPageState createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  late Uint8List _imageBytes;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 500), (_) {
      _fetchFrame();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchFrame() async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.102:8000/frame')); // Replace 'YOUR_ENDPOINT_HERE' with your actual endpoint
    if (response.statusCode == 200) {
      setState(() {
        _imageBytes = response.bodyBytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Stream'),
      ),
      body: Center(
        child: _imageBytes != null
            ? Image.memory(_imageBytes)
            : CircularProgressIndicator(),
      ),
    );
  }
}
