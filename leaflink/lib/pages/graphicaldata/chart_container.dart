import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartContainer extends StatelessWidget {
  final Color color;
  final String title;
  final Widget chart;
  final String currentMonthValue;

  const ChartContainer({
    super.key,
    required this.title,
    required this.color,
    required this.chart,
    required this.currentMonthValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.width * 0.95 * 0.65,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(bottom: 40), // Adjust the value as needed
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
          Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: chart,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RotatedBox(
                    quarterTurns: -1,
                    child: Expanded(
                      child: Column(
                        children: [
                          Text(
                            'CONTRIBUTIONS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.022,
                              color: const Color.fromRGBO(16, 25, 22, 1),
                              fontFamily: GoogleFonts.comfortaa().fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
