import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart'
    as img; // Import image package for image manipulation
import 'package:google_gemini/google_gemini.dart';
import 'package:google_fonts/google_fonts.dart';

class SolutionPage extends StatelessWidget {
  static const String routeName = 'solutionpage';

  const SolutionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.075,
        automaticallyImplyLeading: false,
        title: Text(
          "Solution",
          style: TextStyle(
            fontFamily: GoogleFonts.comfortaa().fontFamily,
            fontSize: MediaQuery.of(context).size.height * 0.04,
            color: const Color.fromRGBO(16, 25, 22, 1),
          ),
        ),
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
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
            Container(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.all(15),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color.fromRGBO(204, 221, 221, 1),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Your Solution',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      FutureBuilder<String>(
                        future: generateContent(imageUrl),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final generatedText = snapshot.data!;
                            return Text(generatedText);
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      // Add additional content or functionality as needed
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

  Future<String> generateContent(String imageUrl) async {
    final gemini =
        GoogleGemini(apiKey: "AIzaSyBOF5UUEHg4Io02E5p6QkhIPtccXexa5eQ");
    final resizedImage = await resizeImage(imageUrl);
    final generatedContent = await gemini.generateFromTextAndImages(
      query: 'What is this object?',
      image: resizedImage,
    );
    return generatedContent.text ?? 'No content generated';
  }

  Future<File> resizeImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final image = img.decodeImage(response.bodyBytes);
        final resizedImage = img.copyResize(image!,
            width: 600); // Resize the image to a smaller size
        final tempDir = await getTemporaryDirectory();
        final tempPath = tempDir.path;
        final file = File('$tempPath/resized_image.jpg');
        await file.writeAsBytes(img.encodeJpg(resizedImage));
        return file;
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading image: $e');
    }
  }
}
