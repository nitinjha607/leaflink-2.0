import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Page'),
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('requests').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot> requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              String recipientUsername = requests[index]['recipientUsername'];
              String senderUsername = requests[index]['senderUsername'];
              String status = requests[index]['status'];

              // Check if the recipient email is the current user's email
              if (recipientUsername == FirebaseAuth.instance.currentUser!.displayName) {
                return ListTile(
                  title: Text('From: $senderUsername'),
                  subtitle: Text('Status: $status'),
                );
              } else {
                return Container(); // Return an empty container if the request should not be shown
              }
            },
          );
        },
      ),
    );
  }
}
