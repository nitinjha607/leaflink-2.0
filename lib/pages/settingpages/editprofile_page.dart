import 'dart:io';
import 'package:leaflink/pages/Create_Post_Page.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class EditProfilePage extends StatefulWidget {
  static const String routeName = 'edit_profile_page';
  EditProfilePage({Key? key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final String? userEmail =
      FirebaseAuth.FirebaseAuth.instance.currentUser!.email;
  String? imageUrl;

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
              child: userDetails(),
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
                              child: CircularProgressIndicator(),
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
                                  elevation: 0,
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
                                          Icons.delete,
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
                                  child: CircularProgressIndicator(),
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
                                                    Icons.delete,
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
    // Share post logic
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

  Widget userDetails() {
    Future<void> _removeImage() async {
      try {
        final String? currentUserEmail =
            FirebaseAuth.FirebaseAuth.instance.currentUser!.email;

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUserEmail)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          String userId = querySnapshot.docs.first.id;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'imageUrl': null});
        }
      } catch (e) {
        print('Error removing user profile image: $e');
      }

      setState(() {
        imageUrl = null;
      });
    }

    Future<void> _selectImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(
                '${FirebaseAuth.FirebaseAuth.instance.currentUser!.uid}.jpg');

        UploadTask uploadTask = ref.putFile(File(pickedFile.path));

        await uploadTask.whenComplete(() {});

        final String downloadUrl = await ref.getDownloadURL();

        try {
          final String? currentUserEmail =
              FirebaseAuth.FirebaseAuth.instance.currentUser!.email;

          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: currentUserEmail)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            String userId = querySnapshot.docs.first.id;
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .update({'imageUrl': downloadUrl});
          }
        } catch (e) {
          print('Error updating user profile image: $e');
        }

        setState(() {
          imageUrl = downloadUrl;
        });
      }
    }

    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: LoadingAnimationWidget.dotsTriangle(
                color: Color.fromRGBO(97, 166, 171, 1),
                size: 50,
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("users").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: LoadingAnimationWidget.dotsTriangle(
                    color: Color.fromRGBO(97, 166, 171, 1),
                    size: 50,
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final String? currentUserEmail =
                FirebaseAuth.FirebaseAuth.instance.currentUser!.email;
            final userData = snapshot.data!.docs.firstWhere(
              (doc) => doc['email'] == currentUserEmail,
            );

            final String user = userData['username'];
            final userImageUrl = userData['imageUrl']; // Added userImageUrl

            return Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.all(0),
              color: Color.fromRGBO(246, 245, 235, 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            title: Text(
                              "Edit Profile Image",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: GoogleFonts.comfortaa().fontFamily,
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.03,
                                color: const Color.fromRGBO(97, 166, 171, 1),
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(57, 80, 92, 1),
                                  foregroundColor:
                                      const Color.fromRGBO(246, 245, 235, 1),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _selectImage();
                                },
                                child: Text(
                                  "Select Image",
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.kohSantepheap().fontFamily,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(57, 80, 92, 1),
                                  foregroundColor:
                                      const Color.fromRGBO(246, 245, 235, 1),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _removeImage();
                                },
                                child: Text(
                                  "Remove Image",
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.kohSantepheap().fontFamily,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: userImageUrl != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(userImageUrl),
                              radius: 50,
                            )
                          : const CircleAvatar(
                              backgroundColor: Color.fromRGBO(97, 166, 171, 1),
                              child: Icon(
                                Symbols.eco,
                                color: Color.fromRGBO(246, 245, 235, 1),
                              ),
                            ),
                    ),
                  ),
                  Text(
                    'User Email: $currentUserEmail',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                      backgroundColor: Color.fromRGBO(246, 245, 235, 1),
                      color: Color.fromRGBO(16, 25, 22, 1),
                    ),
                  ),
                  Text(
                    'Username: $user',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                      backgroundColor: Color.fromRGBO(246, 245, 235, 1),
                      color: Color.fromRGBO(16, 25, 22, 1),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
