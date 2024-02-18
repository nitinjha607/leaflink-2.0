import 'package:flutter/material.dart';
import 'package:leaflink/pages/connect_page.dart';
import 'package:leaflink/pages/eventmanagement_page.dart';
import 'package:leaflink/pages/added_events.dart';
import 'package:leaflink/pages/home_page.dart';
import 'package:leaflink/pages/leaderboard_page.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart'; // Import the necessary package
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
              height: MediaQuery.of(context).size.height,
              margin: const EdgeInsets.all(15),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Color.fromRGBO(204, 221, 221, 1),
              ),
              child: StreamBuilder<List<String>>(
                stream: getDatesStream(),
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
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final List<String> dates = snapshot.data!;
                    return SfCalendar(
                      view: CalendarView.month,
                      todayHighlightColor:
                          const Color.fromRGBO(97, 166, 171, 1),
                      dataSource: _getCalendarDataSource(dates),
                      monthViewSettings: MonthViewSettings(
                        appointmentDisplayMode:
                            MonthAppointmentDisplayMode.appointment,
                      ),
                      selectionDecoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                            color: const Color.fromRGBO(97, 166, 171, 1),
                            width: 1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),
                        shape: BoxShape.rectangle,
                      ),
                      cellEndPadding: 0,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      //navbar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
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
            child: Icon(Icons.add),
            backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
            foregroundColor: const Color.fromRGBO(16, 25, 22, 1),
            heroTag: 'addeventfab',
          ),
          SizedBox(width: 16), // Add spacing between the FABs
          FloatingActionButton(
            onPressed: () {
              // Navigate to the AddedEventsPage
              Navigator.pushNamed(context, AddedEventsPage.routeName);
            },
            child: Icon(Icons.event),
            backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
            foregroundColor: const Color.fromRGBO(16, 25, 22, 1),
            heroTag: 'showeventfab',
          ),
        ],
      ),
    );
  }

  _AppointmentDataSource _getCalendarDataSource(List<String> dates) {
    List<Appointment> appointments = [];
    final DateFormat dateFormat = DateFormat('MM/dd/yyyy');
    for (String date in dates) {
      try {
        DateTime dateTime = dateFormat.parse(date);
        appointments.add(Appointment(
          startTime: dateTime,
          endTime: dateTime.add(Duration(minutes: 10)),
          subject: 'Event',
          color: const Color.fromRGBO(97, 166, 171, 1),
          startTimeZone: '',
          endTimeZone: '',
          isAllDay: true,
        ));
      } catch (e) {
        print('Error parsing date: $date');
        print(e);
      }
    }
    return _AppointmentDataSource(appointments);
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> dates) {
    appointments = dates;
  }
}

Stream<List<String>> getDatesStream() {
  return FirebaseFirestore.instance
      .collection("events")
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => doc['date'] as String).toList();
  });
}
