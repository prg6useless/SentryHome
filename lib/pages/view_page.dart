import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VideoFeedPage extends StatefulWidget {
  @override
  _VideoFeedPageState createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  Uint8List? _currentFrame;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start a timer to fetch video frames at regular intervals
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchVideoFrame();
    });
  }

  void fetchVideoFrame() async {
    try {
      // Make an HTTP GET request to fetch the video frame
      var response =
          await http.get(Uri.parse('http://192.168.1.69:8000/video_feed'));
      if (response.statusCode == 200) {
        setState(() {
          // Update the UI with the received video frame
          _currentFrame = response.bodyBytes;
        });
      } else {
        print('Failed to fetch video frame: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching video frame: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Feed'),
      ),
      body: Center(
        child: _currentFrame != null
            ? Image.memory(
                _currentFrame!,
                fit: BoxFit.contain,
              )
            : CircularProgressIndicator(), // Show loading indicator if frame not received yet
      ),
    );
  }

  @override
  void dispose() {
    // Cancel the timer to prevent memory leaks
    _timer!.cancel();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Video Feed App',
    home: VideoFeedPage(),
  ));
}
