import 'package:flutter/material.dart';
import 'package:leaflink/pages/connect_page.dart';
import 'package:leaflink/pages/eventmanagement_page.dart';
import 'package:leaflink/pages/home_page.dart';
import 'package:leaflink/pages/leaderboard_page.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart'; // Import the necessary package
import 'package:google_fonts/google_fonts.dart';
import 'package:leaflink/pages/added_events.dart'; // Import the AddedEventsPage

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
        title: Text(
          "Events Calendar",
          style: TextStyle(
            fontFamily: GoogleFonts.comfortaa().fontFamily,
            fontSize: MediaQuery.of(context).size.height * 0.04,
            color: const Color.fromRGBO(16, 25, 22, 1),
          ),
        ),
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
      ),
      body: SafeArea(
          child: Stack(children: [
        Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(246, 245, 235, 1),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height,
          margin: const EdgeInsets.all(15),
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
      ])),

      //navbar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
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
              Navigator.pushNamed(context, HomePage.routeName);
              break;
            case 1:
              Navigator.pushNamed(context, ConnectPage.routeName);
              break;
            case 2:
              // Handle navigation or other actions for the Calendar page
              break;
            case 3:
              Navigator.pushNamed(context, LeaderboardPage.routeName);
              break;
          }
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Navigate to the page where events can be managed
              Navigator.pushNamed(context, EventManagementPage.routeName);
            },
            child: Icon(Icons.event),
            backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
          ),
          SizedBox(width: 16), // Add spacing between the FABs
          FloatingActionButton(
            onPressed: () {
              // Navigate to the AddedEventsPage
              Navigator.pushNamed(context, AddedEventsPage.routeName);
            },
            child: Icon(Icons.add),
            backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
          ),
        ],
      ),
    );
  }
}
