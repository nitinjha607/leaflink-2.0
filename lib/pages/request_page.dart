import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore



class RequestPage extends StatefulWidget {
  final String username;
  final String userIconUrl;

  const RequestPage({Key? key, required this.username, required this.userIconUrl})
      : super(key: key);

  @override
  _RequestPageState createState() => _RequestPageState();

}


class _RequestPageState extends State<RequestPage> {
  bool _isButtonDisabled = false;

void _handleRequest() {
  if (!_isButtonDisabled) {
    // Add your request logic here
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String senderUsername = user.email ?? 'Unknown';
      String recipientUsername = widget.username;
      String status = 'pending';

      // Check if a request already exists
      FirebaseFirestore.instance
          .collection('requests')
          .where('senderUsername', isEqualTo: senderUsername)
          .where('recipientUsername', isEqualTo: recipientUsername)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.size == 0) {
          // No existing request, add a new request
          FirebaseFirestore.instance.collection('requests').add({
            'senderUsername': senderUsername,
            'recipientUsername': recipientUsername,
            'status': status,
          });
          setState(() {
            _isButtonDisabled = true; // Disable the button after sending the request
          });
        } else {
          // Request already exists, handle accordingly (e.g., show a message)
          bool shouldDisableButton = true; // Set this based on your desired logic
          if (shouldDisableButton) {
            setState(() {
              _isButtonDisabled = true;
            });
          }
        }
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text('Request Page'),
  backgroundColor: const Color.fromRGBO(97, 166, 171, 1), // Set the background color
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
                child: SvgPicture.asset(
                  'assets/icons/leaf.svg',
                  color: Colors.white,
                  width: 48,
                  height: 48,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.username,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : _handleRequest,
              child: Text('Request'),
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: 16,
                ),
                backgroundColor: _isButtonDisabled ? Colors.grey : Colors.blue,
                disabledBackgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}