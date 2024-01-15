<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leaflink/components/my_textfield.dart';
import 'package:leaflink/components/my_button.dart';
import 'package:google_fonts/google_fonts.dart';
=======
// ignore_for_file: library_private_types_in_public_api
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leaflink/pages/connect_page.dart';
import 'package:leaflink/pages/eventscalendar_page.dart';
import 'package:leaflink/pages/leaderboard_page.dart';
import 'package:leaflink/auth/login_or_register.dart';
import 'package:leaflink/pages/settingpages/editprofile_page.dart';
import 'package:leaflink/pages/settingpages/help_page.dart';
import 'package:leaflink/pages/settingpages/privacy_page.dart';
import 'package:leaflink/pages/settingpages/language_page.dart';
import 'package:leaflink/pages/settingpages/notification_page.dart';

class HomePage extends StatefulWidget {
  static const String routeName = 'home_page';

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  final searchController = TextEditingController();

  // Function to handle user logout
  Future<void> logoutUser(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      print('User logged out successfully');

      // Navigate to the login page after logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LogInOrRegister(), // Your login page widget
        ),
      );
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Function to handle user account deletion
  Future<void> deleteUserAccount(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();

        print('User account deleted successfully');

        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('Your account has been deleted. Please logout.'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LogInOrRegister(), // Your login page widget
          ),
        );
      } else {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('Your account has been deleted. Please logout.'),
          ),
        );

        print('No user is currently signed in');
      }
    } catch (e) {
      print('Error during account deletion: $e');
      // Handle error as needed
    }
  }

  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          title: Text(
            "Delete Account Confirmation",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: GoogleFonts.comfortaa().fontFamily,
              fontSize: MediaQuery.of(context).size.height * 0.03,
              color: const Color.fromRGBO(97, 166, 171, 1),
            ),
          ),
          content: Text(
            "Are you sure you want to delete your account?",
            style: TextStyle(
                fontSize: MediaQuery.sizeOf(context).width * 0.04,
                fontFamily: GoogleFonts.kohSantepheap().fontFamily),
            textAlign: TextAlign.center,
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(57, 80, 92, 1),
                foregroundColor: const Color.fromRGBO(246, 245, 235, 1),
              ),
              onPressed: () {
                deleteUserAccount(context);

                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "DELETE",
                style: TextStyle(
                  fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(204, 221, 221, 1),
                foregroundColor: const Color.fromRGBO(246, 245, 235, 1),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "BACK",
                style: TextStyle(
                  fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to show logout confirmation dialog
  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          title: Text(
            "Logout Confirmation",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: GoogleFonts.comfortaa().fontFamily,
              fontSize: MediaQuery.of(context).size.height * 0.03,
              color: const Color.fromRGBO(97, 166, 171, 1),
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: TextStyle(
                fontSize: MediaQuery.sizeOf(context).width * 0.04,
                fontFamily: GoogleFonts.kohSantepheap().fontFamily),
            textAlign: TextAlign.center,
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(57, 80, 92, 1),
                foregroundColor: const Color.fromRGBO(246, 245, 235, 1),
              ),
              onPressed: () {
                logoutUser(context);
              },
              child: Text(
                "LOGOUT",
                style: TextStyle(
                  fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(204, 221, 221, 1),
                foregroundColor: const Color.fromRGBO(246, 245, 235, 1),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "BACK",
                style: TextStyle(
                  fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //functions
    void editprofile() {
      Navigator.pushNamed(context, EditProfilePage.routeName);
    }

    void languageandregion() {
      Navigator.pushNamed(context, LanguagePage.routeName);
    }

    void helpandsupport() {
      Navigator.pushNamed(context, HelpPage.routeName);
    }

    void privacy() {
      Navigator.pushNamed(context, PrivacyPage.routeName);
    }

    void notifications() {
      Navigator.pushNamed(context, NotificationPage.routeName);
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.075,
          iconTheme: IconThemeData(
            color: const Color.fromRGBO(16, 25, 22, 1),
            size: MediaQuery.of(context).size.height * 0.04,
          ),
          title: Text("Home",
              style: TextStyle(
                fontFamily: GoogleFonts.comfortaa().fontFamily,
                fontSize: MediaQuery.of(context).size.height * 0.04,
                color: const Color.fromRGBO(16, 25, 22, 1),
              )),
          backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
        ),

        //sidebar-settings
        drawer: Drawer(
          backgroundColor: const Color.fromRGBO(204, 221, 221, 1),
          child: Stack(children: [
//logout
            Container(
              alignment: Alignment.bottomLeft,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(204, 221, 221, 1),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25), topRight: Radius.zero),
              ),
              child: ListTile(
                title: Text("Logout",
                    style: TextStyle(
                      fontFamily: GoogleFonts.comfortaa().fontFamily,
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                      color: const Color.fromRGBO(57, 80, 92, 1),
                    )),
                leading: const Icon(
                  CupertinoIcons.arrow_left_square_fill,
                  color: Color.fromRGBO(57, 80, 92, 1),
                ),
                onTap: () {
                  // Show the alert dialog
                  showLogoutConfirmationDialog(context);
                },
              ),
            ),

            //delete account
            Container(
              alignment: Alignment.bottomLeft,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(192, 215, 215, 1),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25), topRight: Radius.zero),
              ),
              child: ListTile(
                  title: Text("Delete Account",
                      style: TextStyle(
                        fontFamily: GoogleFonts.comfortaa().fontFamily,
                        fontSize: MediaQuery.of(context).size.height * 0.025,
                        color: const Color.fromRGBO(16, 25, 22, 1),
                      )),
                  leading: const Icon(
                    CupertinoIcons.delete_solid,
                    color: Color.fromRGBO(16, 25, 22, 1),
                  ),
                  onTap: () {
                    showDeleteConfirmationDialog(context);
                    // Show the alert dialog
                  }),
            ),

            //notifications
            Container(
              alignment: Alignment.bottomLeft,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(180, 209, 210, 1),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25), topRight: Radius.zero),
              ),
              child: ListTile(
                title: Text("Notification",
                    style: TextStyle(
                      fontFamily: GoogleFonts.comfortaa().fontFamily,
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                      color: const Color.fromRGBO(16, 25, 22, 1),
                    )),
                leading: const Icon(
                  CupertinoIcons.bell_circle_fill,
                  color: Color.fromRGBO(16, 25, 22, 1),
                ),
                onTap: notifications,
              ),
            ),

            //privacy
            Container(
              alignment: Alignment.bottomLeft,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(165, 202, 203, 1),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25), topRight: Radius.zero),
              ),
              child: ListTile(
                title: Text("Privacy",
                    style: TextStyle(
                      fontFamily: GoogleFonts.comfortaa().fontFamily,
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                      color: const Color.fromRGBO(16, 25, 22, 1),
                    )),
                leading: const Icon(
                  CupertinoIcons.shield_lefthalf_fill,
                  color: Color.fromRGBO(16, 25, 22, 1),
                ),
                onTap: privacy,
              ),
            ),

            //help
            Container(
              alignment: Alignment.bottomLeft,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(148, 193, 195, 1),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25), topRight: Radius.zero),
              ),
              child: ListTile(
                title: Text("Help & Support",
                    style: TextStyle(
                      fontFamily: GoogleFonts.comfortaa().fontFamily,
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                      color: const Color.fromRGBO(16, 25, 22, 1),
                    )),
                leading: const Icon(
                  CupertinoIcons.question_circle_fill,
                  color: Color.fromRGBO(16, 25, 22, 1),
                ),
                onTap: helpandsupport,
              ),
            ),

            //langauge
            Container(
              alignment: Alignment.bottomLeft,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(133, 185, 188, 1),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25), topRight: Radius.zero),
              ),
              child: ListTile(
                title: Text("Language & Region",
                    style: TextStyle(
                      fontFamily: GoogleFonts.comfortaa().fontFamily,
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                      color: const Color.fromRGBO(16, 25, 22, 1),
                    )),
                leading: const Icon(
                  CupertinoIcons.globe,
                  color: Color.fromRGBO(16, 25, 22, 1),
                ),
                onTap: languageandregion,
              ),
            ),

            //edit profile
            Container(
              alignment: Alignment.bottomLeft,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(116, 176, 180, 1),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25), topRight: Radius.zero),
              ),
              child: ListTile(
                title: Text("Edit Profile",
                    style: TextStyle(
                      fontFamily: GoogleFonts.comfortaa().fontFamily,
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                      color: const Color.fromRGBO(16, 25, 22, 1),
                    )),
                leading: const Icon(
                  CupertinoIcons.person_alt_circle_fill,
                  color: Color.fromRGBO(16, 25, 22, 1),
                ),
                onTap: editprofile,
              ),
            ),

            //header
            Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.2,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(97, 166, 171, 1),
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(25), topRight: Radius.zero),
                ),
                child: Text("L E A F L I N K",
                    style: TextStyle(
                      fontFamily: GoogleFonts.comfortaa().fontFamily,
                      fontSize: MediaQuery.of(context).size.height * 0.04,
                      color: const Color.fromRGBO(16, 25, 22, 1),
                    ))),
          ]),
        ),

        //background
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
                  )),

              //searchbar
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                right: MediaQuery.of(context).size.width * 0.06,
                child: Text(
                  "WATCH YOUR ACTIONS GROW!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.sizeOf(context).height * 0.022,
                    color: const Color.fromRGBO(16, 25, 22, 1),
                    fontFamily: GoogleFonts.comfortaa().fontFamily,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.35,
                right: MediaQuery.of(context).size.width * 0.05,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Text(
                      " See how many trees you've saved and carbon you've cut",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: MediaQuery.sizeOf(context).height * 0.02,
                        color: const Color.fromRGBO(16, 25, 22, 1),
                        fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                      )),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                right: MediaQuery.of(context).size.width * -0.01,
                child: Container(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.height * 0.02,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: MediaQuery.of(context).size.height * 0.35,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5),
                                bottomLeft: Radius.circular(5)),
                            color: Color.fromRGBO(246, 245, 235, 1),
                          ),
                        ),
                      ],
                    )),
              ),

              //graphical data
              Positioned(
                top: MediaQuery.of(context).size.height * 0.05,
                left: MediaQuery.of(context).size.width * 0.06,
                child: Text(
                  "SNAP. SCAN. SAVE THE PLANET!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.sizeOf(context).height * 0.022,
                    color: const Color.fromRGBO(16, 25, 22, 1),
                    fontFamily: GoogleFonts.comfortaa().fontFamily,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.1,
                left: MediaQuery.of(context).size.width * 0.055,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Text(
                      "What can we help you reduce, reuse, or recycle today?",
                      style: TextStyle(
                        fontSize: MediaQuery.sizeOf(context).height * 0.02,
                        color: const Color.fromRGBO(16, 25, 22, 1),
                        fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                      )),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                left: MediaQuery.of(context).size.width * 0,
                child: Container(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.height * 0.009,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.65,
                            height: MediaQuery.of(context).size.height * 0.07,
                            child: TextField(
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.025),
                              controller: searchController,
                              obscureText: false,
                              decoration: InputDecoration(
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromRGBO(246, 245, 235, 1)),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromRGBO(246, 245, 235, 1)),
                                  ),
                                  fillColor:
                                      const Color.fromRGBO(246, 245, 235, 1),
                                  filled: true,
                                  hintText: "SEARCH",
                                  hintStyle: TextStyle(
                                    color: const Color.fromRGBO(57, 80, 92, 1),
                                    fontFamily:
                                        GoogleFonts.comfortaa().fontFamily,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.025,
                                  ),
                                  suffixIcon: Icon(
                                    Icons.search_rounded,
                                    color: const Color.fromRGBO(57, 80, 92, 1),
                                    size: MediaQuery.sizeOf(context).height *
                                        0.035,
                                  )),
                            )),
                        Container(
                          margin: EdgeInsets.all(15),
                          width: MediaQuery.of(context).size.height * 0.07,
                          height: MediaQuery.of(context).size.height * 0.07,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(246, 245, 235, 1),
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: const Color.fromRGBO(57, 80, 92, 1),
                            size: MediaQuery.sizeOf(context).height * 0.035,
                          ),
                        )
                      ],
                    )),
              )
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
                break;
              case 1:
                // Navigate to the ConnectPage
                Navigator.pushNamed(context, ConnectPage.routeName);
                break;
              case 2:
                // Navigate to CalendarPage
                Navigator.pushNamed(context, CalendarPage.routeName);
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
>>>>>>> 88936df4e48e7f1713b2133bebd6b31a5b468f1f

class ForgotPasswordPage extends StatelessWidget {
  static const String routeName = 'forgot_password_page';

  final TextEditingController emailorusernameController =
      TextEditingController();

  void back(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> sendPasswordResetEmail(String userEmail) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail);
      print('Password reset email sent successfully');
    } catch (e) {
      print('Error sending password reset email: $e');
      // Handle error (show an error message to the user, etc.)
    }
  }

  void confirm() async {
    final userEmail = emailorusernameController.text;
    await sendPasswordResetEmail(userEmail);
    // Provide user feedback, e.g., show a message that the email has been sent.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                color: const Color.fromRGBO(97, 166, 171, 1),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                  color: const Color.fromRGBO(246, 245, 235, 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                height: MediaQuery.of(context).size.height * 0.95,
                width: MediaQuery.of(context).size.width * 0.95,
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.03,
                left: MediaQuery.of(context).size.width * 0.05,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: const Color.fromRGBO(97, 166, 171, 1),
                  onPressed: () => back(context),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 100.0, bottom: 20),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.04,
                          fontFamily: GoogleFonts.comfortaa().fontFamily,
                          color: const Color.fromRGBO(16, 25, 22, 1),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 30.0, bottom: 30.0, left: 10, right: 10),
                      child: Text(
                        'Enter the email or username associated with your account, we will send you a link to change the password',
                        style: TextStyle(
                          color: const Color.fromRGBO(66, 123, 138, 1),
                          fontSize: MediaQuery.of(context).size.height * 0.022,
                          fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    MyTextField(
                      controller: emailorusernameController,
                      hintText: 'Email/Username',
                      obscureText: false,
                    ),
                    MyButton(
                      onTap: confirm,
                      text: 'Confirm',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
