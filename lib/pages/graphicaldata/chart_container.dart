import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartContainer extends StatelessWidget {
  final Color color;
  final String title;
  final Widget chart;
  final String currentMonthValue;

  const ChartContainer({
    Key? key, // Corrected the super key to key
    required this.title,
    required this.color,
    required this.chart,
    required this.currentMonthValue,
  }) : super(key: key); // Added super constructor

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.width * 0.95,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 10,
            left: 20,
            child: Text(
              currentMonthValue,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.028,
                color: const Color.fromRGBO(16, 25, 22, 1),
                fontFamily: GoogleFonts.comfortaa().fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 20,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.65,
              height: MediaQuery.of(context).size.height * 0.15,
              child: chart,
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.05,
            right: 0,
            child: RotatedBox(
              quarterTurns: -1,
              child: Text(
                'CONTRIBUTIONS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height * 0.022,
                  color: const Color.fromRGBO(16, 25, 22, 1),
                  fontFamily: GoogleFonts.comfortaa().fontFamily,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
