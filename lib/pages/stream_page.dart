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
  String? _deviceIp;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getDeviceIp().then((ip) {
      setState(() {
        _deviceIp = ip;
      });
    });
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
        if (!_isStreaming && _deviceIp != null) {
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

  Future<String?> _getDeviceIp() async {
    try {
      final List<NetworkInterface> interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      for (var interface in interfaces) {
        for (var address in interface.addresses) {
          if (address.address.startsWith('192.168.')) {
            // Assuming local network IP
            return address.address;
          }
        }
      }
    } catch (e) {
      print("Failed to get IP address: $e");
    }
    return null;
  }

  Future<void> _sendFrame(CameraImage image) async {
    try {
      // Convert CameraImage to image package's Image
      final img.Image convertedImage = _convertYUV420toImageColor(image);
      // Encode to JPEG
      final List<int> jpegBytes = img.encodeJpg(convertedImage);
      // Convert to Uint8List
      final Uint8List jpegUint8List = Uint8List.fromList(jpegBytes);

      final uri = Uri.parse('http://$_deviceIp:8000/stream');
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
    if (_deviceIp == null) return;
    final uri = Uri.parse('http://$_deviceIp:8000/');
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

