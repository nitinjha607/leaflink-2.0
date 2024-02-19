import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter_share/flutter_share.dart';
import 'package:leaflink/pages/Create_Post_Page.dart';
import 'package:flutter/cupertino.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditProfilePage extends StatelessWidget {
  static const String routeName = 'edit_profile_page';
  EditProfilePage({Key? key});

  // Add userEmail variable
  final String? userEmail =
      FirebaseAuth.FirebaseAuth.instance.currentUser!.email;

  void back(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.075,
        title: Text(
          "View Profile",
          style: TextStyle(
            fontFamily: GoogleFonts.comfortaa().fontFamily,
            fontSize: MediaQuery.of(context).size.height * 0.03,
            color: const Color.fromRGBO(16, 25, 22, 1),
          ),
        ),
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => back(context),
          color: const Color.fromRGBO(16, 25, 22, 1),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Redirect to create post page
              Navigator.pushNamed(context, CreatePostPage.routeName);
            },
            icon: Icon(Icons.add),
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Your Email: $userEmail',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                  backgroundColor: Color.fromRGBO(246, 245, 235, 1),
                  color: Color.fromRGBO(16, 25, 22, 1),
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Color.fromRGBO(246, 245, 235, 1),
                child: Container(
                  margin: const EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color.fromRGBO(204, 221, 221, 1),
                  ),
                  child: Column(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('events')
                            .where('email', isEqualTo: userEmail)
                            .snapshots(),
                        builder: (context, eventSnapshot) {
                          if (eventSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: LoadingAnimationWidget.dotsTriangle(
                                color: Color.fromRGBO(97, 166, 171, 1),
                                size: 50, // Adjust loader size
                              ),
                            );
                          } else if (eventSnapshot.hasError) {
                            return Text('Error: ${eventSnapshot.error}');
                          } else {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: eventSnapshot.data!.docs.length,
                              itemBuilder: (ctx, index) {
                                final eventData =
                                    eventSnapshot.data!.docs[index].data()
                                        as Map<String, dynamic>;
                                return Card(
                                  color: Color.fromRGBO(246, 245, 235, 1),
                                  margin: EdgeInsets.all(10),
                                  child: ListTile(
                                    title: Text(eventData['title']),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Date: ${eventData['date']}'),
                                        Text('Time: ${eventData['time']}'),
                                        Text('Venue: ${eventData['venue']}'),
                                      ],
                                    ),
                                    trailing: Card(
                                      color:
                                          const Color.fromRGBO(97, 166, 171, 1),
                                      child: IconButton(
                                        icon: Icon(
                                          CupertinoIcons.delete_solid,
                                          color: Color.fromRGBO(16, 25, 22, 1),
                                        ),
                                        onPressed: () {
                                          _deleteEvent(
                                              eventSnapshot
                                                  .data!.docs[index].reference,
                                              context);
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .where('email', isEqualTo: userEmail)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: LoadingAnimationWidget.dotsTriangle(
                                    color: Color.fromRGBO(97, 166, 171, 1),
                                    size: 50, // Adjust loader size
                                  ),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else {
                              if (snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "No posts found",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(
                                              57, 80, 92, 1),
                                          foregroundColor: const Color.fromRGBO(
                                              246, 245, 235, 1),
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(context,
                                              CreatePostPage.routeName);
                                        },
                                        child: Text(
                                          "Create your first post",
                                          style: TextStyle(
                                            fontFamily:
                                                GoogleFonts.kohSantepheap()
                                                    .fontFamily,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot document =
                                      snapshot.data!.docs[index];
                                  Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;
                                  bool isLiked =
                                      (data['likedBy'] as List<dynamic>)
                                          .contains(userEmail);
                                  return Column(
                                    children: [
                                      Card(
                                        color: Color.fromRGBO(246, 245, 235, 1),
                                        elevation: 0,
                                        margin: EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            ListTile(
                                              title: Text(
                                                data['caption'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Image.network(
                                                    data['imageUrl'],
                                                    width: double.infinity,
                                                    height: 200,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Icon(Icons.error);
                                                    },
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    "${data['likes']} Likes",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    _likePost(
                                                        document, isLiked);
                                                  },
                                                  icon: Icon(Icons.favorite),
                                                  color: isLiked
                                                      ? Colors.red
                                                      : null,
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    _sharePost(data['caption'],
                                                        data['imageUrl']);
                                                  },
                                                  icon: Icon(Icons.share),
                                                  color: const Color.fromRGBO(
                                                      97, 166, 171, 1),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    _showDeleteDialog(
                                                        context, document);
                                                  },
                                                  icon: Icon(
                                                    CupertinoIcons.delete_solid,
                                                    color: Color.fromRGBO(
                                                        16, 25, 22, 1),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          title: Text(
            "Delete Post",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: GoogleFonts.comfortaa().fontFamily,
              fontSize: MediaQuery.of(context).size.height * 0.03,
              color: const Color.fromRGBO(97, 166, 171, 1),
            ),
          ),
          content: Text(
            "Are you sure you want to delete this post?",
            style: TextStyle(
                fontSize: MediaQuery.sizeOf(context).width * 0.04,
                fontFamily: GoogleFonts.kohSantepheap().fontFamily),
            textAlign: TextAlign.center,
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(57, 80, 92, 1),
                foregroundColor: const Color.fromRGBO(246, 245, 235, 1),
              ),
              onPressed: () {
                _deletePost(document);
                Navigator.of(context).pop();
              },
              child: Text(
                "DELETE",
                style: TextStyle(
                  fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(204, 221, 221, 1),
                foregroundColor: const Color.fromRGBO(246, 245, 235, 1),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "BACK",
                style: TextStyle(
                  fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deletePost(DocumentSnapshot document) {
    FirebaseFirestore.instance.collection('posts').doc(document.id).delete();
  }

  void _likePost(DocumentSnapshot document, bool isLiked) {
    if (isLiked) {
      FirebaseFirestore.instance.collection('posts').doc(document.id).update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userEmail]),
      });
    } else {
      FirebaseFirestore.instance.collection('posts').doc(document.id).update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userEmail]),
      });
    }
  }

  void _sharePost(String caption, String imageUrl) async {
    await FlutterShare.share(
      title: 'Check out this post',
      text: '$caption\n$imageUrl',
    );
  }

  void _deleteEvent(DocumentReference documentRef, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          title: Text(
            "Delete Event",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: GoogleFonts.comfortaa().fontFamily,
              fontSize: MediaQuery.of(context).size.height * 0.03,
              color: const Color.fromRGBO(97, 166, 171, 1),
            ),
          ),
          content: Text(
            "Are you sure you want to delete this event?",
            style: TextStyle(
                fontSize: MediaQuery.sizeOf(context).width * 0.04,
                fontFamily: GoogleFonts.kohSantepheap().fontFamily),
            textAlign: TextAlign.center,
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(57, 80, 92, 1),
                foregroundColor: const Color.fromRGBO(246, 245, 235, 1),
              ),
              onPressed: () {
                documentRef.delete();
                Navigator.of(context).pop();
              },
              child: Text(
                "DELETE",
                style: TextStyle(
                  fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(204, 221, 221, 1),
                foregroundColor: const Color.fromRGBO(246, 245, 235, 1),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "BACK",
                style: TextStyle(
                  fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
