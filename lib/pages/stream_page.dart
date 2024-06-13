import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class CameraStreamPage extends StatefulWidget {
  @override
  _CameraStreamPageState createState() => _CameraStreamPageState();
}

class _CameraStreamPageState extends State<CameraStreamPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras![0], ResolutionPreset.medium);
    await _controller!.initialize();
    setState(() {});
  }

  void _startStreaming() {
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.startImageStream((CameraImage image) async {
        if (!_isStreaming) {
          _isStreaming = true;
          await _sendFrame(image);
          _isStreaming = false;
        }
      });
    }
  }

  void _stopStreaming() {
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.stopImageStream();
      setState(() {
        _isStreaming = false;
      });
    }
  }

  Future<void> _sendFrame(CameraImage image) async {
    try {
      // Convert CameraImage to image package's Image
      final img.Image convertedImage = _convertYUV420toImageColor(image);
      // Encode to JPEG
      final List<int> jpegBytes = img.encodeJpg(convertedImage);
      // Convert to Uint8List
      final Uint8List jpegUint8List = Uint8List.fromList(jpegBytes);

      final uri = Uri.parse('http://192.168.101.4:8000/stream');
      await http.post(uri, body: jpegUint8List);
    } catch (e) {
      print('Error sending frame: $e');
    }
  }

  img.Image _convertYUV420toImageColor(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final imgLib = img.Image(width: width, height: height);

    final planeY = image.planes[0];
    final planeU = image.planes[1];
    final planeV = image.planes[2];

    final uvRowStride = planeU.bytesPerRow;
    final uvPixelStride = planeU.bytesPerPixel ?? 1;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = (y >> 1) * uvRowStride + (x >> 1) * uvPixelStride;
        final int index = y * width + x;

        final yp = planeY.bytes[index];
        final up = planeU.bytes[uvIndex];
        final vp = planeV.bytes[uvIndex];

        final yValue = yp.toDouble();
        final uValue = up.toDouble() - 128;
        final vValue = vp.toDouble() - 128;

        // Convert YUV to RGB
        final r = (yValue + 1.402 * vValue).clamp(0, 255).toInt();
        final g = (yValue - 0.344136 * uValue - 0.714136 * vValue)
            .clamp(0, 255)
            .toInt();
        final b = (yValue + 1.772 * uValue).clamp(0, 255).toInt();

        // Set pixel color
        imgLib.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return img.copyRotate(imgLib, angle: 90);
  }

  Future<void> _test() async {
    final uri = Uri.parse('http://192.168.101.4:8000/');
    final response = await http.get(uri);
    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Stream')),
      body: _controller == null
          ? Center(child: CircularProgressIndicator())
          : CameraPreview(_controller!),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _startStreaming,
            icon: const Icon(Icons.videocam),
            label: const Text('Start Streaming',
                style: TextStyle(color: Colors.black)),
            foregroundColor: Colors.black,
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: _stopStreaming,
            icon: const Icon(Icons.stop),
            label: const Text('Stop Streaming',
                style: TextStyle(color: Colors.black)),
            foregroundColor: Colors.black,
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: _test,
            icon: const Icon(Icons.portable_wifi_off_outlined),
            label: const Text('Test', style: TextStyle(color: Colors.black)),
            foregroundColor: Colors.black,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
