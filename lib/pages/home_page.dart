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
    try {
      final ListResult result = await FirebaseStorage.instance.ref().list();
      setState(() {
        videoList = result.items.map((item) => item.name).toList();
      });
    } catch (e) {
      // Handle errors if any
      print("Error fetching video list: $e");
    }
  }

  Future<void> deleteVideo(String videoName) async {
    try {
      // Get reference to the video
      final Reference videoRef =
          FirebaseStorage.instance.ref().child(videoName);
      // Delete the video from Firebase Storage
      await videoRef.delete();
      // Remove the video from the local list and refresh the UI
      setState(() {
        videoList.remove(videoName);
      });
    } catch (e) {
      // Handle errors if any
      print("Error deleting video: $e");
    }
  }

  void refreshPage() {
    fetchVideoList();
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                refreshPage();
              });
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
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteConfirmationDialog(videoName);
            },
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerPage(videoName: videoName),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  void _showDeleteConfirmationDialog(String videoName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Video"),
          content: Text("Are you sure you want to delete $videoName?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop();
                deleteVideo(videoName);
              },
            ),
          ],
        );
      },
    );
  }
}
