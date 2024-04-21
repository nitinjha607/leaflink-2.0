import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leaflink/components/my_button.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class RequestPage extends StatefulWidget {
  final String username;
  final String userIconUrl;
  final String useremail;

  const RequestPage({
    Key? key,
    required this.username,
    required this.userIconUrl,
    required this.useremail,
  }) : super(key: key);

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  void _handleRequest() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      String senderEmail = user.email!;
      String recipientEmail = widget.useremail;

      DocumentReference requestDoc =
          FirebaseFirestore.instance.collection('requests').doc(recipientEmail);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(requestDoc);

        if (!snapshot.exists) {
          // If the document does not exist, create it with the current sender in 'requested' array
          transaction.set(requestDoc, {
            'requested': [senderEmail]
          });
          _showSnackBar("Request successfully sent!");
        } else {
          List<dynamic> requested =
              List<dynamic>.from(snapshot.get('requested') as List);
          if (!requested.contains(senderEmail)) {
            requested.add(senderEmail);
            transaction.update(requestDoc, {'requested': requested});
            _showSnackBar("Request successfully sent!");
          } else {
            _showSnackBar("Request already sent!");
          }
        }
      }).catchError((error) {
        _showSnackBar("Failed to send request: $error");
      });
    } else {
      _showSnackBar("User not properly authenticated.");
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
        title: Text('Request Page'),
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromRGBO(97, 166, 171, 1),
              ),
              child: Center(
                child: Icon(
                  Symbols.eco,
                  color: Color.fromRGBO(246, 245, 235, 1),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.username,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            MyButton(
              onTap: _handleRequest,
              text: 'Request',
            ),
          ],
        ),
      ),
    );
  }
}
