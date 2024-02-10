// ignore_for_file: library_private_types_in_public_api
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
//import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leaflink/pages/connect_page.dart';
import 'package:leaflink/pages/eventscalendar_page.dart';
import 'package:leaflink/pages/leaderboard_page.dart';
import 'package:leaflink/auth/login_or_register.dart';
import 'package:leaflink/pages/settingpages/editprofile_page.dart';
import 'package:leaflink/pages/settingpages/help_page.dart';
import 'package:leaflink/pages/settingpages/language_page.dart';
import 'package:leaflink/pages/settingpages/notification_page.dart';
import 'package:leaflink/pages/graphicaldata/chart_container.dart';
import 'package:leaflink/pages/graphicaldata/bar_chart.dart';
import 'dart:io';
import 'package:flutter/services.dart';
//import 'package:image_cropper/image_cropper.dart';

//import 'package:http/http.dart' as http;
//import 'dart:convert';

class HomePage extends StatefulWidget {
  static const String routeName = 'home_page';

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView'),
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  final searchController = TextEditingController();
  DateTime now = DateTime.now();
  final int currentMonth = DateTime.now().month;
  final ImagePicker _picker =
      ImagePicker(); // Create an instance of ImagePicker
  File? capturedImage; // Define File variable to store the captured image
  List<XFile> images = [];
  String imageProcessingResponseText = '';

  String monthName(int monthNumber) {
    switch (monthNumber) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

//function for camera redirect
  Future<void> captureImageAndRedirect() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      print('Image captured from camera: ${pickedFile.path}');

      final String renamedPath = '${Directory.systemTemp.path}/temp.jpeg';
      final File renamedImage = File(renamedPath);
      await pickedFile.saveTo(renamedImage.path);

      setState(() {
        capturedImage = renamedImage;
      });

      if (capturedImage != null) {
        final imageUrl = await uploadImageToFirebase(capturedImage!);

        if (imageUrl.isNotEmpty) {
          navigateToWebView('https://leaf-link-1e912.web.app/');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to upload image to Firebase.'),
          ));
        }
      } else {
        print('Captured image is null.');
      }
    } else {
      print('Image capture from camera canceled.');
    }
  }

// Function to navigate to WebView page
  Future<void> navigateToWebView(String url) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    await Future.delayed(Duration(seconds: 2)); // Simulating loading time

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewPage(url: url)),
    );

    // Dismiss loading screen
    Navigator.pop(context);

    // Show snackbar for login
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('If desired response not achieved, please login again.'),
    ));
  }

// Function to upload the image to Firebase storage
  Future<String> uploadImageToFirebase(File imageFile) async {
    try {
      final firebase_storage.Reference storageRef =
          firebase_storage.FirebaseStorage.instance.ref().child("images");
      // Generate a unique filename based on the current timestamp
      final String fileName = "temp.jpg"; // Change the filename here
      final firebase_storage.UploadTask uploadTask =
          storageRef.child(fileName).putFile(imageFile);

      final firebase_storage.TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);
      final String imageUrl = await taskSnapshot.ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error uploading image to Firebase: $e');
      return '';
    }
  }

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
              height: MediaQuery.of(context).size.height * 0.8,
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
              height: MediaQuery.of(context).size.height * 0.7,
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
              height: MediaQuery.of(context).size.height * 0.6,
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
                title: Text("View Profile",
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
                right: MediaQuery.of(context).size.width * -0.02,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5)),
                    color: Color.fromRGBO(246, 245, 235, 1),
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: ChartContainer(
                    title: '',
                    color: const Color.fromRGBO(246, 245, 235, 1),
                    chart: const BarChartContent(),
                    currentMonthValue: monthName(currentMonth),
                  ),
                ),
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
                left: MediaQuery.of(context).size.width * -0.02,
                child: Container(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.height * 0.009,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.07,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(246, 245, 235, 1),
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: const Color.fromRGBO(57, 80, 92, 1),
                          size: MediaQuery.sizeOf(context).height * 0.035,
                        ),
                        onPressed: () {
                          captureImageAndRedirect();
                        },
                      ),
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
