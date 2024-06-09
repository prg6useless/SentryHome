import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
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

      final uri = Uri.parse('http://192.168.101.15:8000/stream');
      await http.post(uri, body: jpegUint8List);
    } catch (e) {
      print('Error sending frame: $e');
    }
  }

  img.Image _convertCameraImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final img.Image imgImage = img.Image(width: width, height: height);

    // Plane[0] contains the Y component of the YUV420SP format
    final Plane plane = image.planes[0];
    final Uint8List bytes = plane.bytes;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int index = y * width + x;
        final int pixelValue = bytes[index];
        imgImage.setPixelRgba(x, y, pixelValue, pixelValue, pixelValue, 255);
      }
    }

    return imgImage;
  }

  img.Image _convertYUV420toImageColor(CameraImage image) {
    var imgLib = img.Image(
        width: image.width, height: image.height); // Create Image buffer

    Plane planeY = image.planes[0];
    Plane planeU = image.planes[1];
    Plane planeV = image.planes[2];

    int uvRowStride = planeU.bytesPerRow;
    int uvPixelStride = planeU.bytesPerPixel ?? 1;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final int uvIndex =
            uvRowStride * (y / 2).floor() + uvPixelStride * (x / 2).floor();
        final int index = y * image.width + x;

        final yp = planeY.bytes[index];
        final up = planeU.bytes[uvIndex];
        final vp = planeV.bytes[uvIndex];

        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

        // Set pixel color
        imgLib.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return img.copyRotate(imgLib, angle: 90);
  }

  Future<void> _test() async {
    final uri = Uri.parse('http://192.168.101.15:8000/');
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
          FloatingActionButton(
            onPressed: _startStreaming,
            child: Icon(Icons.videocam),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _stopStreaming,
            child: Icon(Icons.stop),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _test,
            child: Icon(Icons.portable_wifi_off_outlined),
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
