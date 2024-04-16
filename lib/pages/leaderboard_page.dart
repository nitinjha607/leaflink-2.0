import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:leaflink/pages/connect_page.dart';
import 'package:leaflink/pages/eventscalendar_page.dart';
import 'package:leaflink/pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LeaderboardPage extends StatefulWidget {
  static const String routeName = 'leaderboard_page';

  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  int _selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.075,
        automaticallyImplyLeading: false,
        title: Text(
          "Leaderboard",
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
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.all(15),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color.fromRGBO(204, 221, 221, 1),
                ),
                child: ranklist(),
              ),
            ),
          ],
        ),
      ),
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
              Navigator.pushNamed(context, CalendarPage.routeName);
              break;
            case 3:
              break;
          }
        },
      ),
    );
  }
}

Widget ranklist() {
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
        stream: FirebaseFirestore.instance.collection("graphdata").snapshots(),
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

          final sortedDocs = snapshot.data!.docs.toList()
            ..sort((a, b) => b['total'].compareTo(a['total']));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    tileColor: const Color.fromRGBO(57, 80, 92, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    title: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Text(
                                "Rank",
                                style: TextStyle(
                                  color: const Color.fromRGBO(246, 245, 235, 1),
                                  fontSize:
                                      MediaQuery.of(context).size.height * 0.02,
                                  fontFamily:
                                      GoogleFonts.comfortaa().fontFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 40),
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Text(
                                'User',
                                style: TextStyle(
                                  color: const Color.fromRGBO(246, 245, 235, 1),
                                  fontSize:
                                      MediaQuery.of(context).size.height * 0.02,
                                  fontFamily:
                                      GoogleFonts.comfortaa().fontFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 40),
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Text(
                                'Points',
                                style: TextStyle(
                                  color: const Color.fromRGBO(246, 245, 235, 1),
                                  fontSize:
                                      MediaQuery.of(context).size.height * 0.02,
                                  fontFamily:
                                      GoogleFonts.comfortaa().fontFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedDocs.length,
                  itemBuilder: (context, index) {
                    final doc = sortedDocs[index];
                    final rank = (index + 1).toString();
                    final user = doc['username'].toString();
                    final points = doc['total'].toString();

                    final tileDecoration = index < 3
                        ? index == 0
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: AssetImage('assets/images/image1.png'),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : index == 1
                                ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/image2.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/image3.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                        : BoxDecoration(
                            color: Color.fromRGBO(180, 209, 210, 1),
                            borderRadius: BorderRadius.circular(10));

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      decoration: tileDecoration,
                      child: Card(
                        color: const Color.fromARGB(0, 255, 255, 255),
                        elevation: 0, // Optional: remove shadow
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Text(
                                  rank,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color.fromRGBO(57, 80, 92, 1),
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.018,
                                    fontFamily:
                                        GoogleFonts.kohSantepheap().fontFamily,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  user,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color.fromRGBO(57, 80, 92, 1),
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02,
                                    fontFamily:
                                        GoogleFonts.kohSantepheap().fontFamily,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  points,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color.fromRGBO(57, 80, 92, 1),
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02,
                                    fontFamily:
                                        GoogleFonts.kohSantepheap().fontFamily,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
