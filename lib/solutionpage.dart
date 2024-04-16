import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:google_gemini/google_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/gestures.dart'; // Import gesture_detector.dart

class SolutionPage extends StatelessWidget {
  static const String routeName = 'solutionpage';

  const SolutionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.075,
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
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(15),
                    height: null, // Set height to null for dynamic adjustment
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color.fromRGBO(204, 221, 221, 1),
                    ),
                    child: FutureBuilder<String>(
                      future: generateContent(imageUrl),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: LoadingAnimationWidget.dotsTriangle(
                              color: Color.fromRGBO(97, 166, 171, 1),
                              size: 50, // Adjust loader size
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final generatedText = snapshot.data!;
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              generatedText,
                              style: TextStyle(
                                fontFamily:
                                    GoogleFonts.kohSantepheap().fontFamily,
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.02,
                                color: const Color.fromRGBO(16, 25, 22, 1),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(15),
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color.fromRGBO(204, 221, 221, 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text.rich(
                        TextSpan(
                          text: 'Post your contributions on the ',
                          style: TextStyle(
                            fontFamily: GoogleFonts.comfortaa().fontFamily,
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                            color: const Color.fromRGBO(16, 25, 22, 1),
                          ),
                          children: [
                            TextSpan(
                              text: 'Connect page',
                              style: const TextStyle(
                                color: Color.fromRGBO(97, 166, 171, 1),
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(context, 'connect_page');
                                },
                            ),
                            TextSpan(
                              text:
                                  ' to join the leaderboard and grow the graph!',
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> generateContent(String imageUrl) async {
    final gemini = GoogleGemini(
        apiKey:
            "AIzaSyBOF5UUEHg4Io02E5p6QkhIPtccXexa5eQ"); // Replace "YOUR_API_KEY" with your actual API key
    final resizedImage = await resizeImage(imageUrl);
    final generatedContent = await gemini.generateFromTextAndImages(
      query:
          'Identify the waste and categorize in a category of waste and give me three to four pointers under the headings recycle reuse and reduce(be more specific about the recycle heading). In case it is a living object just generate that content cannot be generated for this object',
      image: resizedImage,
    );
    return generatedContent.text ?? 'No content generated';
  }

  Future<File> resizeImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final image = img.decodeImage(response.bodyBytes);
        final resizedImage = img.copyResize(image!, width: 600);
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
