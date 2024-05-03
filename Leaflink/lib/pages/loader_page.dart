import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoaderPage extends StatefulWidget {
  static const String routeName = 'loader_page';

  const LoaderPage({Key? key}) : super(key: key);

  @override
  _LoaderPageState createState() => _LoaderPageState();
}

class _LoaderPageState extends State<LoaderPage> {
  final List<String> environmentalFacts = [
    "Trees help reduce air pollution by absorbing harmful gases.",
    "The Amazon Rainforest produces 20% of the world's oxygen.",
    "Recycling one ton of paper saves 17 trees.",
    "Over 50,000 species of plants and animals become extinct each year due to deforestation.",
    "The Great Barrier Reef is the largest living structure on Earth, visible from outer space.",
    "A single tree can absorb as much as 48 pounds of carbon dioxide per year."
    // Add more environmental facts as needed
  ];

  String randomFact = '';

  @override
  void initState() {
    super.initState();
    getRandomFact();
  }

  void getRandomFact() {
    final Random random = Random();
    final int index = random.nextInt(environmentalFacts.length);
    setState(() {
      randomFact = environmentalFacts[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(204, 221, 221, 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: LoadingAnimationWidget.dotsTriangle(
                  color: Color.fromRGBO(97, 166, 171, 1),
                  size: 50, // Adjust loader size
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  randomFact,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comfortaa(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
