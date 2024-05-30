// import 'package:flutter/material.dart';
// import 'package:sentryhome/components/my_drawer.dart';
// import 'package:sentryhome/pages/qr_scanner_page.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "H O M E",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         foregroundColor: Theme.of(context).colorScheme.inversePrimary,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.qr_code_scanner),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const QRScannerPage()),
//               );
//             },
//           ),
//         ],
//       ),
//       drawer: const MyDrawer(),
//       body: const Column(
//         children: [
//           // Add content for the home page here
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:sentryhome/components/my_drawer.dart';
import 'package:sentryhome/pages/qr_scanner_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for the cameras
    final List<Map<String, String>> cameras = [
      {"name": "Front Door", "location": "Entrance", "status": "Active"},
      {"name": "Backyard", "location": "Garden", "status": "Inactive"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRScannerPage()),
              );
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Live View",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            _buildLiveViewList(),
            const SizedBox(height: 16.0),
            const Text(
              "Playback Recordings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            _buildPlaybackRecordingsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveViewList() {
    final liveViews = [
      {"name": "Camera 01", "time": "12:00:00", "status": "red"},
      {"name": "Camera 02", "time": "07:20:30", "status": "green"},
      {"name": "Camera 03", "time": "11:46:22", "status": "green"},
      {"name": "Camera 04", "time": "12:00:00", "status": "red"},
    ];

    return Column(
      children: liveViews.map((liveView) {
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            color: Colors.black,
          ),
          title: Text(liveView['name']!),
          subtitle: Text(liveView['time']!),
          trailing: Icon(
            Icons.circle,
            color: liveView['status'] == "red" ? Colors.red : Colors.green,
            size: 14,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlaybackRecordingsList() {
    final playbackRecordings = [
      {"name": "Recording 01", "time": "15:00:00", "date": "12-02-2022"},
      {"name": "Recording 02", "time": "16:10:00", "date": "18-12-2022"},
      {"name": "Recording 03", "time": "03:50:40", "date": "22-07-2023"},
      {"name": "Recording 04", "time": "05:10:55", "date": "17-08-2023"},
    ];

    return Column(
      children: playbackRecordings.map((recording) {
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            color: Colors.black,
          ),
          title: Text(recording['name']!),
          subtitle: Text("${recording['time']} ${recording['date']}"),
        );
      }).toList(),
    );
  }
}
