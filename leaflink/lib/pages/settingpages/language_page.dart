import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguagePage extends StatelessWidget {
  static const String routeName = 'language_page';

  const LanguagePage({super.key});

  void back(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.075,
        title: Text(
          "Language and Region",
          style: TextStyle(
            fontFamily: GoogleFonts.comfortaa().fontFamily,
            fontSize: MediaQuery.of(context).size.height * 0.04,
            color: const Color.fromRGBO(16, 25, 22, 1),
          ),
        ),
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => back(context),
          color: const Color.fromRGBO(16, 25, 22, 1),
        ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
