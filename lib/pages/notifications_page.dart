import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detection Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () => _deleteAllEvents(context),
            tooltip: 'Delete All Events',
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('detection_events')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No detection events found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var event = snapshot.data!.docs[index];

              return DetectionEventTile(
                imageUrl: event['image_url'],
                detectedObject: event['object'],
                timestamp: event['timestamp'],
              );
            },
          );
        },
      ),
    );
  }

  void _deleteAllEvents(BuildContext context) {
    // Show a confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete All Events'),
          content: Text(
              'Are you sure you want to delete all detection events? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _confirmDeleteAllEvents();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteAllEvents() async {
    var collection = FirebaseFirestore.instance.collection('detection_events');

    // Batch delete all documents
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }

    // Show a snackbar after deletion
  }
}

class DetectionEventTile extends StatelessWidget {
  final String imageUrl;
  final String detectedObject;
  final String timestamp;

  DetectionEventTile({
    required this.imageUrl,
    required this.detectedObject,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) =>
                Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              detectedObject,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Timestamp: ${DateTime.parse(timestamp).toLocal()}',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
