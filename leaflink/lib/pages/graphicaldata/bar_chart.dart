import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BarChartContent extends StatelessWidget {
  const BarChartContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: 7.5,
        barGroups: barChartGroupData,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: getTitles,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            top: BorderSide.none,
            right: BorderSide.none,
            bottom: BorderSide.none,
            left: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

//random static data for now
List<BarChartGroupData> barChartGroupData = [
  BarChartGroupData(x: 1, barRods: [
    BarChartRodData(
      toY: 10,
      color: const Color.fromRGBO(57, 80, 92, 1),
      width: 30,
    ),
  ]),
  BarChartGroupData(x: 2, barRods: [
    BarChartRodData(
      toY: 13.5,
      color: const Color.fromRGBO(144, 175, 175, 1),
      width: 30,
    ),
  ]),
  BarChartGroupData(x: 3, barRods: [
    BarChartRodData(
      toY: 12.6,
      color: const Color.fromRGBO(57, 80, 92, 1),
      width: 30,
    ),
  ]),
  BarChartGroupData(x: 4, barRods: [
    BarChartRodData(
      toY: 11.4,
      color: const Color.fromRGBO(57, 80, 92, 1),
      width: 30,
    ),
  ]),
  BarChartGroupData(x: 5, barRods: [
    BarChartRodData(
      toY: 7.5,
      color: const Color.fromRGBO(57, 80, 92, 1),
      width: 30,
    ),
  ]),
];

Widget getTitles(double value, TitleMeta meta) {
  Widget text;
  switch (value.toInt()) {
    case 1:
      text = Text(
        'WEEK 1',
        style: TextStyle(
          fontSize: 10,
          color: const Color.fromRGBO(16, 25, 22, 1),
          fontFamily: GoogleFonts.kohSantepheap().fontFamily,
        ),
      );
      break;
    case 2:
      text = Text(
        'WEEK 2',
        style: TextStyle(
          fontSize: 10,
          color: const Color.fromRGBO(16, 25, 22, 1),
          fontFamily: GoogleFonts.kohSantepheap().fontFamily,
        ),
      );
      break;
    case 3:
      text = Text(
        'WEEK 3',
        style: TextStyle(
          fontSize: 10,
          color: const Color.fromRGBO(16, 25, 22, 1),
          fontFamily: GoogleFonts.kohSantepheap().fontFamily,
        ),
      );
      break;
    case 4:
      text = Text(
        'WEEK 4',
        style: TextStyle(
          fontSize: 10,
          color: const Color.fromRGBO(16, 25, 22, 1),
          fontFamily: GoogleFonts.kohSantepheap().fontFamily,
        ),
      );
      break;
    case 5:
      text = Text(
        'WEEK 5',
        style: TextStyle(
          fontSize: 10,
          color: const Color.fromRGBO(16, 25, 22, 1),
          fontFamily: GoogleFonts.kohSantepheap().fontFamily,
        ),
      );
      break;

    default:
      text = const Text('');
      break;
  }
  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 16,
    child: text,
  );
}
