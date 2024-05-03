import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class BarChartContent extends StatelessWidget {
  const BarChartContent({Key? key});

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email;

    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: LoadingAnimationWidget.dotsTriangle(
              color: Color.fromRGBO(97, 166, 171, 1),
              size: 50, // Adjust loader size
            ),
          ));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("graphdata")
              .where('email', isEqualTo: currentUserEmail)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: LoadingAnimationWidget.dotsTriangle(
                  color: Color.fromRGBO(97, 166, 171, 1),
                  size: 50, // Adjust loader size
                ),
              ));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // Check if no documents are retrieved
            if (snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No data available'));
            }

            // Convert the documents into a list of week data
            List<int> weekDataList = [];
            snapshot.data!.docs.forEach((doc) {
              weekDataList.add(doc['week1']);
              weekDataList.add(doc['week2']);
              weekDataList.add(doc['week3']);
              weekDataList.add(doc['week4']);
              weekDataList.add(doc['week5']);
            });

            // Convert week data list to BarChartGroupData
            List<BarChartGroupData> barChartGroupData = [];
            int maxBarIndex = 0;
            double maxBarValue = weekDataList[0].toDouble();
            for (int i = 0; i < weekDataList.length; i++) {
              if (weekDataList[i] > maxBarValue) {
                maxBarValue = weekDataList[i].toDouble();
                maxBarIndex = i;
              }
              barChartGroupData.add(BarChartGroupData(
                x: i + 1,
                barRods: [
                  BarChartRodData(
                    toY: weekDataList[i].toDouble(), // Use week data as y value
                    color: i == maxBarIndex
                        ? const Color.fromRGBO(
                            144, 175, 175, 1) // Different color for max value
                        : const Color.fromRGBO(57, 80, 92, 1),
                    width: 25,
                  ),
                ],
              ));
            }

            return BarChart(
              BarChartData(
                maxY: 15,
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
          },
        );
      },
    );
  }
}

Widget getTitles(double value, TitleMeta meta) {
  Widget text;
  switch (value.toInt()) {
    case 1:
      text = Text(
        'WEEK 1',
        style: TextStyle(
          fontSize: 10,
          color: const Color.fromRGBO(16, 25, 22, 1),
        ),
      );
      break;
    case 2:
      text = Text(
        'WEEK 2',
        style: TextStyle(
          fontSize: 10,
          color: const Color.fromRGBO(16, 25, 22, 1),
        ),
      );
      break;
    case 3:
      text = Text(
        'WEEK 3',
        style: TextStyle(
          fontSize: 10,
          color: const Color.fromRGBO(16, 25, 22, 1),
        ),
      );
      break;
    case 4:
      text = Text(
        'WEEK 4',
        style: TextStyle(
          fontSize: 10,
          color: const Color.fromRGBO(16, 25, 22, 1),
        ),
      );
      break;
    case 5:
      text = Text(
        'WEEK 5',
        style: TextStyle(
          fontSize: 10,
          color: const Color.fromRGBO(16, 25, 22, 1),
        ),
      );
      break;
    default:
      text = const Text('');
      break;
  }
  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: text,
  );
}
