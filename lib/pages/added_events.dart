import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leaflink/selectvenue_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/services.dart';

class AddedEventsPage extends StatefulWidget {
  static const String routeName = 'added_events';

  const AddedEventsPage({Key? key}) : super(key: key);

  @override
  _AddedEventsPageState createState() => _AddedEventsPageState();
}

class _AddedEventsPageState extends State<AddedEventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.075,
        title: Text(
          "Events",
          style: TextStyle(
            fontFamily: GoogleFonts.comfortaa().fontFamily,
            fontSize: MediaQuery.of(context).size.height * 0.03,
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
              child: Container(
                margin: const EdgeInsets.all(15),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color.fromRGBO(204, 221, 221, 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      const Text(
                        "Upcoming Events",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(child: eventsList(past: false)),
                      SizedBox(height: 20),
                      Text(
                        "Past Events",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(child: eventsList(past: true)),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget eventsList({required bool past}) {
  DateTime currentDate = DateTime.now();

  return FutureBuilder(
    future: Firebase.initializeApp(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: LoadingAnimationWidget.dotsTriangle(
            color: Color.fromRGBO(97, 166, 171, 1),
            size: 50, // Adjust loader size
          ),
        );
      }
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("events").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.dotsTriangle(
                color: Color.fromRGBO(97, 166, 171, 1),
                size: 50, // Adjust loader size
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<Widget> events = [];

          snapshot.data!.docs.forEach((doc) {
            // Parse date manually from Firestore document
            String dateString = doc['date'];
            List<String> dateParts = dateString.split('/');
            int month = int.parse(dateParts[0]);
            int day = int.parse(dateParts[1]);
            int year = int.parse(dateParts[2]);
            DateTime eventDate = DateTime(year, month, day);

            if ((past && eventDate.isBefore(currentDate)) ||
                (!past && eventDate.isAfter(currentDate))) {
              events.add(_buildEventTile(context, doc));
            }
          });

          return ListView(
            children: events,
          );
        },
      );
    },
  );
}

Widget _buildEventTile(BuildContext context, DocumentSnapshot doc) {
  return GestureDetector(
    onTap: () {
      if (doc['venue'] is Map) {
        // If it's a virtual event with a link, copy the link and show a Snackbar
        Clipboard.setData(ClipboardData(text: doc['venue']['link']));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Link copied')),
        );
      } else {
        // For in-person events or events without a link, navigate to the detail page
        Navigator.pushNamed(context, SelectVenuePage.routeName);
      }
    },
    child: Card(
      color: Color.fromRGBO(246, 245, 235, 1),
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          doc['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  doc['venue'] is String
                      ? doc['venue']
                      : doc['venue']['platform'], // Handle map case
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            if (doc['venue'] is Map) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.link, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    doc['venue']['link'],
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  doc['time'],
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  doc['name'],
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          doc['date'],
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
    ),
  );
}
