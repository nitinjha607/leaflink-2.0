import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostPage extends StatefulWidget {
  static const String routeName = 'create_post_page';

  const CreatePostPage({Key? key}) : super(key: key);

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  TextEditingController _captionController = TextEditingController();
  final _imagePicker = ImagePicker();
  late File _image = File(''); // Initialize with a default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image Picker
              InkWell(
                onTap: () async {
                  final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }
                },
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    shape: BoxShape.circle,
                  ),
                  child: _image != null
                      ? Image.file(_image, fit: BoxFit.cover)
                      : Icon(
                          Icons.add_a_photo,
                          color: Colors.white,
                          size: 50,
                        ),
                ),
              ),
              SizedBox(height: 16),

              // Caption Input
              TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  labelText: 'Caption',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 4,
              ),
              SizedBox(height: 16),

              // Create Post Button
              ElevatedButton(
                onPressed: () {
                  // Handle the logic for creating the post with the caption and image
                  String caption = _captionController.text;
                  // Add your logic to save the post with the caption and image
                  // For simplicity, just print the caption and image path for now
                  print('Post Created with Caption: $caption and Image Path: ${_image.path}');
                  // You may want to navigate back or perform other actions after post creation
                },
                child: Text('Create Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
}
