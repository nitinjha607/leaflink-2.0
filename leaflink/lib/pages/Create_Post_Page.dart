import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      // Save post to Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'imageUrl': downloadURL,
        'caption': _captionController.text,
        'timestamp': Timestamp.now(),
        'likes': 0,
        'email': FirebaseAuth.instance.currentUser!.email,
      });

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
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(97, 166, 171, 1),
      ),
      backgroundColor: Colors.green[50],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
                      decoration: InputDecoration(
                        labelText: 'Write a caption...',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      maxLines: 4,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: postImage,
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(97, 166, 171, 1),
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
                            color: Colors.white,
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
