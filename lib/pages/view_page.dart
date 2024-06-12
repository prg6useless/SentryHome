import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VideoFeedPage extends StatefulWidget {
  @override
  _VideoFeedPageState createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  late Uint8List _imageBytes;
  late Timer _timer;
  bool _isError = false;

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
    try {
      final response =
          await http.get(Uri.parse('http://192.168.101.3:8000/frame'));
      if (response.statusCode == 200) {
        setState(() {
          _imageBytes = response.bodyBytes;
          _isError = false;
        });
      } else {
        setState(() {
          _isError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
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
        child: _isError
            ? Text(
                'No Feed',
                style: TextStyle(fontSize: 24.0),
              )
            : _imageBytes != null
                ? Image.memory(_imageBytes)
                : CircularProgressIndicator(),
      ),
    );
  }
}
