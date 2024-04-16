import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePostPage extends StatefulWidget {
  static const String routeName = 'create_post_page';

  const CreatePostPage({Key? key}) : super(key: key);

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  TextEditingController _captionController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _image;
  bool isLoading = false;
  late String? _userId; // Variable to hold the user's UID

  @override
  void initState() {
    super.initState();
    // Get the current user's UID when the widget initializes
    _userId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _selectImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> postImage() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Upload to Firebase Storage
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('posts/${DateTime.now().toString()}');

      await ref.putFile(_image!);

      // Get download URL
      final String downloadURL = await ref.getDownloadURL();
      final String userEmail = FirebaseAuth.instance.currentUser!.email!;
      final String username = await _getUsername(userEmail); // Get username
      int currentWeek = ((DateTime.now()
                  .difference(
                      DateTime(DateTime.now().year, DateTime.now().month, 1))
                  .inDays) /
              7)
          .ceil();

      // Save post to Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'imageUrl': downloadURL,
        'caption': _captionController.text,
        'timestamp': Timestamp.now(),
        'email': userEmail,
        'username': username,
        'likes': 0,
        'likedBy': [],
      });

      // Initialize graphdata if not exist for the user
      if (_userId != null) {
        final graphDataRef =
            FirebaseFirestore.instance.collection('graphdata').doc(_userId!);
        graphDataRef.get().then((docSnapshot) {
          if (!docSnapshot.exists) {
            // Initialize week data for a new user
            Map<String, dynamic> initData = {
              'username': username,
              'email': userEmail,
              'week1': 0,
              'week2': 0,
              'week3': 0,
              'week4': 0,
              'week5': 0,
              'total': 0,
            };
            graphDataRef.set(initData);
          }
          // Increment the current week's value in graphdata
          graphDataRef.update({
            'week$currentWeek': FieldValue.increment(1),
          }).then((_) {
            // Update total field
            graphDataRef.get().then((docSnapshot) {
              if (docSnapshot.exists) {
                num total = 0;
                for (int i = 1; i <= 5; i++) {
                  total += (docSnapshot.data()!['week$i'] ?? 0) as num;
                }
                graphDataRef.update({'total': total.toInt()});
              }
            });
          });
        });
      }

      // Hide loading indicator
      setState(() {
        isLoading = false;
      });

      // Show success message
      showSnackBar('Posted successfully!');

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      // Hide loading indicator
      setState(() {
        isLoading = false;
      });

      print('Error creating post: $e');
      showSnackBar('Error creating post. Please try again.');
    }
  }

  Future<String> _getUsername(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final user = querySnapshot.docs.first.data()['username'] as String;
      return user;
    } else {
      return '';
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Post',
          style: TextStyle(
            fontFamily: GoogleFonts.comfortaa().fontFamily,
            fontSize: MediaQuery.of(context).size.height * 0.03,
            color: const Color.fromRGBO(16, 25, 22, 1),
          ),
        ),
        backgroundColor: Color.fromRGBO(97, 166, 171, 1),
      ),
      backgroundColor: Color.fromRGBO(246, 245, 235, 1),
      body: isLoading
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: LoadingAnimationWidget.dotsTriangle(
                  color: Color.fromRGBO(97, 166, 171, 1),
                  size: 50, // Adjust loader size
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 16),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color.fromRGBO(97, 166, 171, 1),
                      ),
                      child: InkWell(
                        onTap: _selectImage,
                        child: _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _image!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.black,
                                  size: 50,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _captionController,
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                      decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(252, 251, 241, 1)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(204, 221, 221, 1)),
                          ),
                          fillColor: const Color.fromRGBO(204, 221, 221, 1),
                          filled: true,
                          labelText: 'Write a caption...',
                          labelStyle: TextStyle(
                            color: Color.fromRGBO(97, 166, 171, 1),
                            fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                          )),
                      cursorColor: Color.fromRGBO(97, 166, 171, 1),
                      maxLines: 4,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: postImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(97, 166, 171, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromRGBO(246, 245, 235, 1),
                            fontFamily: GoogleFonts.comfortaa().fontFamily,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
