import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:video_player/video_player.dart';

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
        'http://192.168.101.3:8000/frame')); // Replace 'YOUR_ENDPOINT_HERE' with your actual endpoint
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

// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class VideoFeedPage extends StatefulWidget {
//   @override
//   _VideoFeedPageState createState() => _VideoFeedPageState();
// }

// class _VideoFeedPageState extends State<VideoFeedPage> {
//   Uint8List? _imageBytes;
//   late Timer _timer;
//   String? _deviceIp;

//   @override
//   void initState() {
//     super.initState();
//     _getDeviceIp().then((ip) {
//       if (ip != null) {
//         setState(() {
//           _deviceIp = ip;
//         });
//         _timer = Timer.periodic(Duration(milliseconds: 500), (_) {
//           _fetchFrame();
//         });
//       } else {
//         print("Failed to get IP address.");
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   Future<String?> _getDeviceIp() async {
//     try {
//       final List<NetworkInterface> interfaces = await NetworkInterface.list(
//         type: InternetAddressType.IPv4,
//         includeLoopback: false,
//       );
//       for (var interface in interfaces) {
//         for (var address in interface.addresses) {
//           if (address.address.startsWith('192.168.')) {
//             // Assuming local network IP
//             return address.address;
//           }
//         }
//       }
//     } catch (e) {
//       print("Failed to get IP address: $e");
//     }
//     return null;
//   }

//   Future<void> _fetchFrame() async {
//     if (_deviceIp == null) return;
//     final response = await http.get(Uri.parse('http://$_deviceIp:8000/frame'));
//     if (response.statusCode == 200) {
//       setState(() {
//         _imageBytes = response.bodyBytes;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Video Stream'),
//       ),
//       body: Center(
//         child: _imageBytes != null
//             ? Image.memory(_imageBytes!)
//             : CircularProgressIndicator(),
//       ),
//     );
//   }
// }
