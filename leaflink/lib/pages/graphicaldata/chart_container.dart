import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartContainer extends StatelessWidget {
  final Color color;
  final String title;
  final Widget chart;

  const ChartContainer({
    Key? key,
    required this.title,
    required this.color,
    required this.chart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.width * 0.95 * 0.65,
        padding: EdgeInsets.fromLTRB(0, 10, 20, 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: chart,
                  ),
                ),
                RotatedBox(
                    quarterTurns: -1,
                    child: Expanded(
                      child: Text(
                        '      TREES SAVED',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height * 0.022,
                          color: const Color.fromRGBO(16, 25, 22, 1),
                          fontFamily: GoogleFonts.comfortaa().fontFamily,
                        ),
                      ),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
