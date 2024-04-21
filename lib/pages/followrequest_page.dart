import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowRequestPage extends StatefulWidget {
  const FollowRequestPage({Key? key}) : super(key: key);

  @override
  _FollowRequestPageState createState() => _FollowRequestPageState();
}

class _FollowRequestPageState extends State<FollowRequestPage> {
  List<String> requestedUsers = []; // State to hold the requested users

  @override
  void initState() {
    super.initState();
    fetchRequestedUsers();
  }

  void fetchRequestedUsers() async {
    String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentUserEmail == null) {
      _showSnackBar("User not properly authenticated.");
      return;
    }

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .doc(currentUserEmail)
        .get();

    if (documentSnapshot.exists) {
      List<dynamic> requested = documentSnapshot.get('requested') ?? [];
      setState(() {
        requestedUsers = List<String>.from(requested);
      });
    } else {
      _showSnackBar("No follow requests found.");
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Follow Request Page'),
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
      ),
      body: requestedUsers.isEmpty
          ? Center(child: Text("No follow requests."))
          : ListView.builder(
              itemCount: requestedUsers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(requestedUsers[index]),
                );
              },
            ),
    );
  }
}
