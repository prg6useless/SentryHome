import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VideoFeedPage extends StatefulWidget {
  @override
  _VideoFeedPageState createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  Uint8List? _imageBytes;
  late Timer _fetchTimer;
  late Timer _playbackTimer;
  late http.Client _httpClient;
  List<Uint8List> _frameBuffer = [];
  int _bufferSize = 100; // Increased buffer size for smoother playback
  int _currentFrameIndex = 0;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    _fetchTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      _fetchFrame();
    });
    _startPlayback();
  }

  @override
  void dispose() {
    _fetchTimer.cancel();
    _playbackTimer.cancel();
    _httpClient.close();
    super.dispose();
  }

  Future<void> _fetchFrame() async {

    try {
      final response = await _httpClient.get(Uri.parse(
          'http://192.168.1.94:8000/frame')); // Replace with your actual endpoint
      if (response.statusCode == 200) {
        setState(() {
          if (_frameBuffer.length < _bufferSize) {
            _frameBuffer.add(response.bodyBytes);
          }
        });
      } else {
        // Handle error
        //print('Error fetching frame: ${response.statusCode}');
      }
    } catch (e) {
      //print('Error fetching frame: $e');
    }
  }

  void _startPlayback() {
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 45), (timer) {
      //fps counter
      if (_frameBuffer.isNotEmpty) {
        setState(() {
          _imageBytes = _frameBuffer[_currentFrameIndex];
          _currentFrameIndex = (_currentFrameIndex + 1) % _frameBuffer.length;
          if (_frameBuffer.length == _bufferSize) {
            _frameBuffer.removeAt(0);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Stream'),
      ),
      body: Center(
        child: _imageBytes != null
            ? Image.memory(_imageBytes!)
            : const CircularProgressIndicator(),
      ),
    );
  }
}
