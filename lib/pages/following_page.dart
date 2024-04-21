import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({Key? key}) : super(key: key);

  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  List<Map<String, String>> sentRequests = [];
  List<Map<String, String>> acceptedRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequestsData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchRequestsData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      _showSnackBar("User not properly authenticated.");
      return;
    }

    try {
      var requestedSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('requested', arrayContains: user.email)
          .get();

      var acceptedSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('accepted', arrayContains: user.email)
          .get();

      List<Map<String, String>> tempSentRequests = [];
      List<Map<String, String>> tempAcceptedRequests = [];

      for (var doc in requestedSnapshot.docs) {
        Map<String, String> userDetails = await _fetchUserDetails(doc.id);
        if (userDetails.isNotEmpty) {
          tempSentRequests.add(userDetails);
        }
      }

      for (var doc in acceptedSnapshot.docs) {
        Map<String, String> userDetails = await _fetchUserDetails(doc.id);
        if (userDetails.isNotEmpty) {
          tempAcceptedRequests.add(userDetails);
        }
      }

      setState(() {
        sentRequests = tempSentRequests;
        acceptedRequests = tempAcceptedRequests;
      });
    } catch (e) {
      _showSnackBar("Failed to fetch requests data: $e");
    }
  }

  Future<Map<String, String>> _fetchUserDetails(String email) async {
    try {
      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        var userData = userSnapshot.docs.first.data();
        return {
          'username': userData['username'] as String? ?? 'Unknown',
          'email': email,
          'imageUrl': userData['imageUrl'] as String? ?? '',
        };
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
    return {};
  }

  void _removeUser(String targetEmail, String arrayField) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) {
      _showSnackBar("User not properly authenticated.");
      return;
    }

    try {
      // Target the document of the user you want to update.
      DocumentReference requestDoc =
          FirebaseFirestore.instance.collection('requests').doc(targetEmail);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(requestDoc);
        if (!snapshot.exists) {
          throw Exception("Document does not exist!");
        }

        // Fetch the current array from the document, expecting it to contain currentUser's email
        List<dynamic> currentList = List.from(snapshot.get(arrayField) ?? []);
        if (currentList.contains(currentUser.email)) {
          // Remove currentUser's email from the array
          currentList.remove(currentUser.email);
          // Update the document with the modified array
          transaction.update(requestDoc, {arrayField: currentList});
          _showSnackBar(
              "You have been removed from $arrayField list of ${targetEmail}.");
          _fetchRequestsData(); // Refresh data
        } else {
          _showSnackBar(
              "You are not found in $arrayField list of ${targetEmail}.");
        }
      });
    } catch (e) {
      _showSnackBar("Failed to remove user from list: $e");
      print(e);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Following'),
        backgroundColor: Color.fromRGBO(97, 166, 171, 1),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildSection('Sent Requests', sentRequests, 'requested'),
            _buildSection('Accepted Requests', acceptedRequests, 'accepted'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      String title, List<Map<String, String>> users, String arrayField) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color.fromRGBO(204, 221, 221, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: users[index]['imageUrl']!.isNotEmpty
                        ? NetworkImage(users[index]['imageUrl']!)
                        : null,
                    child: users[index]['imageUrl']!.isEmpty
                        ? Icon(Icons.person)
                        : null,
                  ),
                  title: Text(users[index]['username']!),
                  subtitle: Text(users[index]['email']!),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _removeUser(users[index]['email']!, arrayField),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
