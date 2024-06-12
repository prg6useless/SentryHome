import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sentryhome/components/my_drawer.dart';
import 'package:sentryhome/pages/qr_scanner_page.dart';
import 'package:sentryhome/pages/view_recordings.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> videoList = [];

  @override
  void initState() {
    super.initState();
    fetchVideoList();
  }

  Future<void> fetchVideoList() async {
    final ListResult result = await FirebaseStorage.instance.ref().list();
    setState(() {
      videoList = result.items.map((item) => item.name).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
      {"name": "Camera 01", "time": "12:00:00", "status": "green"},
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
          // subtitle: Text(liveView['time']!),
          trailing: Icon(
            Icons.circle,
            color: liveView['status'] == "red" ? Colors.red : Colors.green,
            size: 14,
          ),
          onTap: () {
            Navigator.pushNamed(context, '/view');
          },
        );
      }).toList(),
    );
  }

  Widget _buildPlaybackRecordingsList() {
    return Column(
      children: videoList.map((videoName) {
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            color: Colors.black,
          ),
          title: Text(videoName),
          subtitle: Text("Video"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VideoPlayerPage(videoName: videoName)),
            );
          },
        );
      }).toList(),
    );
  }
}
