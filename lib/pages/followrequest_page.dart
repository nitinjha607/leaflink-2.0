import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowRequestPage extends StatefulWidget {
  const FollowRequestPage({Key? key}) : super(key: key);

  @override
  _FollowRequestPageState createState() => _FollowRequestPageState();
}

class _FollowRequestPageState extends State<FollowRequestPage> {
  List<Map<String, String>> requestedUsers = [];
  List<Map<String, String>> acceptedUsers = [];
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  @override
  void dispose() {
    _isFetching = false;
    super.dispose();
  }

  void fetchRequestedUsers() async {
    _isFetching = true;
    String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentUserEmail == null) {
      _showSnackBar("User not properly authenticated.");
      _isFetching = false;
      return;
    }

    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .doc(currentUserEmail)
          .get();

      if (documentSnapshot.exists && _isFetching) {
        List<dynamic> requestedEmails = documentSnapshot.get('requested') ?? [];
        List<Map<String, String>> usersInfo = [];

        for (String userEmail in requestedEmails) {
          var userInfo = await fetchUserInfo(userEmail);
          if (!_isFetching) return; // Exit if fetching was canceled
          usersInfo.add({
            'email': userEmail,
            'username': userInfo['username'] ?? 'No Name',
            'imageUrl': userInfo['imageUrl'] ?? '',
          });
        }

        if (mounted) {
          setState(() {
            requestedUsers = usersInfo;
          });
        }
      } else {
        _showSnackBar("No follow requests found.");
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Failed to fetch requests: $e");
      }
    }
    _isFetching = false;
  }

  Future<Map<String, String>> fetchUserInfo(String userEmail) async {
    Map<String, String> userInfo = {'imageUrl': '', 'username': 'No Name'};
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty && _isFetching) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        userInfo['imageUrl'] = userData['imageUrl'] as String? ?? '';
        userInfo['username'] = userData['username'] as String? ?? 'No Name';
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
    return userInfo;
  }

  void _showSnackBar(String message) {
    if (mounted) {
      final snackBar = SnackBar(content: Text(message));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _acceptRequest(String userEmail) async {
    String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentUserEmail == null) {
      _showSnackBar("User not properly authenticated.");
      return;
    }

    final DocumentReference requestDoc =
        FirebaseFirestore.instance.collection('requests').doc(currentUserEmail);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(requestDoc);

      if (snapshot.exists) {
        List<dynamic> requested = List.from(snapshot.get('requested') ?? []);
        List<dynamic> accepted = List.from(snapshot.get('accepted') ?? []);

        if (requested.contains(userEmail)) {
          requested.remove(userEmail); // Remove from requested list
          accepted.add(userEmail); // Add to accepted list

          transaction.update(
              requestDoc, {'requested': requested, 'accepted': accepted});

          _showSnackBar("Request from $userEmail accepted.");
        } else {
          _showSnackBar("Request from $userEmail not found.");
        }
      } else {
        _showSnackBar("No follow requests data found.");
      }
    }).catchError((error) {
      _showSnackBar("Failed to update follow request: $error");
    });
  }

  void _rejectRequest(String userEmail) async {
    String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentUserEmail == null) {
      _showSnackBar("User not properly authenticated.");
      return;
    }

    final DocumentReference requestDoc =
        FirebaseFirestore.instance.collection('requests').doc(currentUserEmail);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(requestDoc);

      if (snapshot.exists) {
        List<dynamic> requested = List.from(snapshot.get('requested') ?? []);

        if (requested.contains(userEmail)) {
          requested.remove(userEmail); // Remove from requested list

          transaction.update(requestDoc, {'requested': requested});

          _showSnackBar("Request from $userEmail rejected.");
        } else {
          _showSnackBar("Request from $userEmail not found.");
        }
      } else {
        _showSnackBar("No follow requests data found.");
      }
    }).catchError((error) {
      _showSnackBar("Failed to update follow request: $error");
    });
  }

  void fetchRequests() async {
    _isFetching = true;
    String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentUserEmail == null) {
      _showSnackBar("User not properly authenticated.");
      _isFetching = false;
      return;
    }

    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .doc(currentUserEmail)
          .get();

      if (documentSnapshot.exists && _isFetching) {
        List<dynamic> requestedEmails = documentSnapshot.get('requested') ?? [];
        List<dynamic> acceptedEmails = documentSnapshot.get('accepted') ?? [];
        List<Map<String, String>> usersInfo = [];
        List<Map<String, String>> acceptedInfo = [];

        for (String userEmail in requestedEmails) {
          var userInfo = await fetchUserInfo(userEmail);
          if (!_isFetching) return; // Exit if fetching was canceled
          usersInfo.add({
            'email': userEmail,
            'username': userInfo['username'] ?? 'No Name',
            'imageUrl': userInfo['imageUrl'] ?? '',
          });
        }

        for (String userEmail in acceptedEmails) {
          var userInfo = await fetchUserInfo(userEmail);
          if (!_isFetching) return; // Exit if fetching was canceled
          acceptedInfo.add({
            'email': userEmail,
            'username': userInfo['username'] ?? 'No Name',
            'imageUrl': userInfo['imageUrl'] ?? '',
          });
        }

        if (mounted) {
          setState(() {
            requestedUsers = usersInfo;
            acceptedUsers = acceptedInfo;
          });
        }
      } else {
        _showSnackBar("No follow requests found.");
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Failed to fetch requests: $e");
      }
    }
    _isFetching = false;
  }

  void removeFromAccepted(String userEmail) async {
    String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentUserEmail == null) {
      _showSnackBar("User not properly authenticated.");
      return;
    }

    final DocumentReference requestDoc =
        FirebaseFirestore.instance.collection('requests').doc(currentUserEmail);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(requestDoc);

      if (snapshot.exists) {
        List<dynamic> accepted = List.from(snapshot.get('accepted') ?? []);

        if (accepted.contains(userEmail)) {
          accepted.remove(userEmail); // Remove from accepted list

          transaction.update(requestDoc, {'accepted': accepted});

          _showSnackBar("User $userEmail removed from followers.");
        } else {
          _showSnackBar("User $userEmail not found in followers.");
        }
      } else {
        _showSnackBar("No follow requests data found.");
      }
    }).catchError((error) {
      _showSnackBar("Failed to update follow request: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Follow Requests'),
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildSection('Pending Requests', requestedUsers),
            buildSection('Followers', acceptedUsers),
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title, List<Map<String, String>> users) {
    return Container(
      margin: const EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Color.fromRGBO(204, 221, 221, 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: Theme.of(context).textTheme.headline6),
          ),
          users.isEmpty
              ? Center(child: Text("No $title."))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: users[index]['imageUrl']!.isNotEmpty
                              ? NetworkImage(users[index]['imageUrl']!)
                              : null,
                          child: users[index]['imageUrl']!.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(users[index]['username']!),
                        subtitle: Text(users[index]['email']!),
                        trailing: title == 'Pending Requests'
                            ? buildTrailingButtons(users[index]['email']!)
                            : (title == 'Followers'
                                ? IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () => removeFromAccepted(
                                        users[index]['email']!),
                                  )
                                : null),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget? buildTrailingButtons(String email) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () => _acceptRequest(email),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => _rejectRequest(email),
        ),
      ],
    );
  }
}
