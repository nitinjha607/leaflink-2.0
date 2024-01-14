// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:leaflink/pages/connect_page.dart';
import 'package:leaflink/pages/home_page.dart';
import 'package:leaflink/pages/leaderboard_page.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart'; // Import the necessary package
import 'package:google_fonts/google_fonts.dart';

class CalendarPage extends StatefulWidget {
  static const String routeName = 'calendar_page';

  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _selectedIndex = 2; // Set the initial index to 2 for the Calendar page

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.075,
          automaticallyImplyLeading: false,
          title: Text("Events Calendar",
              style: TextStyle(
                fontFamily: GoogleFonts.comfortaa().fontFamily,
                fontSize: MediaQuery.of(context).size.height * 0.04,
                color: const Color.fromRGBO(16, 25, 22, 1),
              )),
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
                  )),
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
                  child: SfCalendar(
                    view: CalendarView.month,
                    // Add any additional properties or controllers as needed
                  ),
                ),
              ),
            ],
          ),
        ),

        //navbar
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.connect_without_contact),
              label: 'Connect',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard),
              label: 'Leaderboard',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromRGBO(16, 25, 22, 1),
          unselectedItemColor: const Color.fromRGBO(57, 80, 92, 1),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });

            switch (index) {
              case 0:
                // Navigate to the HomePage
                Navigator.pushNamed(context, HomePage.routeName);
                break;
              case 1:
                // Navigate to the ConnectPage
                Navigator.pushNamed(context, ConnectPage.routeName);
                break;
              case 2:
                // Navigate to CalendarPage
                break;
              case 3:
                // Navigate to the LeaderboardPage
                Navigator.pushNamed(context, LeaderboardPage.routeName);
                break;
            }
          },
        ));
  }
}
