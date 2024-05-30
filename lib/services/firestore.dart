import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // get collection of accounts
  final CollectionReference accounts =
      FirebaseFirestore.instance.collection('accounts');

  // CREATE
  Future<void> addaccount(String username, String email, String password) {
    return accounts.add({
      'username': username,
      "email": email,
      "password": password,
      'timestamp': Timestamp.now()
    });
  }

  //getuserdetailsfunction
  Future<DocumentSnapshot> getUserDetails(String email) async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(email)
        .get();
  }

  //fetch user details that matchs the email

  // READ
  // Stream<QuerySnapshot> getaccountsStream() {
  //   final accountsStream =
  //       accounts.orderBy('timestamp', descending: true).snapshots();
  //   return accountsStream;
  // }

  // // UPDATE given the doc id
  // Future<void> updateaccount(String docID, String newaccount) {
  //   return accounts
  //       .doc(docID)
  //       .update({'account': newaccount, 'timestamp': Timestamp.now()});
  // }

  // // DELETE
  // Future<void> deleteaccount(String docID) {
  //   return accounts.doc(docID).delete();
  // }
}
