import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter_share/flutter_share.dart';
import 'package:leaflink/pages/Create_Post_Page.dart'; // Import the CreatePostPage

class EditProfilePage extends StatelessWidget {
  static const String routeName = 'edit_profile_page';

  const EditProfilePage({Key? key});

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
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(246, 245, 235, 1),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('email',
                      isEqualTo: FirebaseAuth.FirebaseAuth.instance.currentUser!
                          .email) // Filter posts by user's email
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  if (snapshot.data!.docs.isEmpty) {
                    return Column(
                      children: [
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            FirebaseAuth
                                .FirebaseAuth.instance.currentUser!.email!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "No posts found",
                                  style: TextStyle(fontSize: 18),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Redirect to create post page
                                    Navigator.pushNamed(
                                        context, CreatePostPage.routeName);
                                  },
                                  child: Text("Create your first post"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Text(
                          FirebaseAuth
                              .FirebaseAuth.instance.currentUser!.email!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            // Reload posts
                          },
                          child: ListView(
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                                  document.data() as Map<String, dynamic>;
                              bool isLiked = (data['likedBy'] as List<dynamic>)
                                  .contains(FirebaseAuth.FirebaseAuth.instance
                                      .currentUser!.email);
                              return Column(
                                children: [
                                  // Card with image, caption, like, share, and delete options
                                  Card(
                                    elevation: 5,
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
                                          subtitle: Image.network(
                                            data['imageUrl'],
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(Icons.error);
                                            },
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                _likePost(document, isLiked);
                                              },
                                              icon: Icon(Icons.favorite),
                                              color:
                                                  isLiked ? Colors.red : null,
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                _sharePost(data['caption'],
                                                    data['imageUrl']);
                                              },
                                              icon: Icon(Icons.share),
                                              color: Colors.blue,
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                _showDeleteDialog(
                                                    context, document);
                                              },
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
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
          title: Text("Delete Post"),
          content: Text("Are you sure you want to delete this post?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deletePost(document);
                Navigator.of(context).pop();
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
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
      // Unlike post
      FirebaseFirestore.instance.collection('posts').doc(document.id).update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove(
            [FirebaseAuth.FirebaseAuth.instance.currentUser!.email]),
      });
    } else {
      // Like post
      FirebaseFirestore.instance.collection('posts').doc(document.id).update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion(
            [FirebaseAuth.FirebaseAuth.instance.currentUser!.email]),
      });
    }
  }

  void _sharePost(String caption, String imageUrl) async {
    await FlutterShare.share(
      title: 'Check out this post',
      text: '$caption\n$imageUrl',
    );
  }
}
