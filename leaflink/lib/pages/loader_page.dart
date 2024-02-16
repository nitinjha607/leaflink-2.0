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
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: LoadingAnimationWidget.dotsTriangle(
                    color: Color.fromRGBO(97, 166, 171, 1),
                    size: 50, // Adjust loader size
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Text(
                  randomFact,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
