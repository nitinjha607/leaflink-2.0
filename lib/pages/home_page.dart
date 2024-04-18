// ignore_for_file: library_private_types_in_public_api
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leaflink/pages/welcome_page.dart';
import 'package:leaflink/solutionpage.dart';
import 'package:leaflink/pages/loader_page.dart';
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
import 'package:google_gemini/google_gemini.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

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

  DateTime now = DateTime.now();
  final int currentMonth = DateTime.now().month;
  final gemini =
      GoogleGemini(apiKey: "AIzaSyBOF5UUEHg4Io02E5p6QkhIPtccXexa5eQ");
  final ImagePicker _picker =
      ImagePicker(); // Create an instance of ImagePicker
  File? capturedImage; // Define File variable to store the captured image
  List<XFile> images = [];
  String imageProcessingResponseText = '';
  bool _deleteDataClicked = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  void _requestLocationPermission() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location services are disabled')));
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        _showPermissionDialog();
        return;
      }
    }

    // Location permissions granted, now you can get the location
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    LocationData? locationData;
    try {
      locationData = await Location().getLocation();
    } catch (e) {
      print('Error getting location: $e');
      // Handle error - display a message to the user or retry obtaining location
      return;
    }

    if (locationData != null) {
      // Now you have the location data, you can use it as needed
      print(
          'Current Location: ${locationData.latitude}, ${locationData.longitude}');
    } else {
      // Location data is null, handle this case
      print('Failed to get current location');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Text(
            'This app needs access to your location to function properly.'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await Location().requestPermission();
              // Check permission again after the user interacts with the dialog
              _requestLocationPermission();
            },
            child: Text('Grant'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Handle if the user denies permission
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Location permission denied')));
            },
            child: Text('Deny'),
          ),
        ],
      ),
    );
  }

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

  // Function to capture image and redirect to SolutionPage
  Future<void> captureImageAndRedirect() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      capturedImage = File(pickedFile.path);

      Navigator.pushNamed(context, LoaderPage.routeName);
      // Upload the captured image to Firebase Storage
      final imageUrl = await uploadImageToFirebase(capturedImage!);

      Navigator.pop(context);

      Navigator.pushNamed(context, SolutionPage.routeName, arguments: imageUrl);
    } else {
      // Dismiss the blank scaffold if no image is selected

      print('No image selected.');
    }
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

  Future<void> _deleteUserDataFromFirestore(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        _deleteDataClicked = true;
      });

      String userEmail = user.email ?? '';

      final List<String> collectionsToDelete = [
        'events',
        'graphdata',
        'posts',
        'users'
      ];

      for (final String collectionName in collectionsToDelete) {
        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(collectionName)
            .where('email', isEqualTo: userEmail)
            .get();

        for (final QueryDocumentSnapshot doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
        print('User data deleted from $collectionName collection');
      }
    }
  }

  Future<void> deleteUserAccount(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseAuth.instance.currentUser?.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your account and data have been deleted.'),
          ),
        );

        print('User account deleted');

        // Navigate to login or register page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your account has been deleted please logout'),
          ),
        );

        Navigator.pushNamed(context, WelcomePage.routeName);
        print('No user is currently signed in');
      }
    } catch (e) {
      print('Error during account deletion: $e');
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(57, 80, 92, 1),
                    foregroundColor: const Color.fromRGBO(246, 245, 235, 1),
                  ),
                  onPressed: () {
                    _deleteUserDataFromFirestore(context);
                  },
                  child: Text(
                    "DELETE DATA",
                    style: TextStyle(
                      fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(57, 80, 92, 1),
                    foregroundColor: const Color.fromRGBO(246, 245, 235, 1),
                  ),
                  onPressed: () {
                    if (_deleteDataClicked) {
                      deleteUserAccount(context);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Your Account has been deleted. Please Logout."),
                        ),
                      );
                    } else {
                      // Show a snackbar indicating that DELETE DATA must be clicked first
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please click on DELETE DATA first."),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "DELETE",
                    style: TextStyle(
                      fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                    ),
                  ),
                ),
              ],
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
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 40, bottom: 10),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 55.0,
                        color: Colors.white,
                      ),
                    ),
                    Text("L E A F L I N K",
                        style: TextStyle(
                          fontFamily: GoogleFonts.comfortaa().fontFamily,
                          fontSize: MediaQuery.of(context).size.height * 0.04,
                          color: const Color.fromRGBO(16, 25, 22, 1),
                        )),
                  ],
                )),
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
                color: Color.fromRGBO(246, 245, 235, 1),
              ),
              SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(15),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color.fromRGBO(204, 221, 221, 1),
                  ),
                  child: Column(children: [
                    const SizedBox(height: 30),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SNAP. SCAN. SAVE THE PLANET!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.022,
                              color: const Color.fromRGBO(16, 25, 22, 1),
                              fontFamily: GoogleFonts.comfortaa().fontFamily,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: Text(
                              "What can we help you reduce, reuse, or recycle today?",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.02,
                                color: const Color.fromRGBO(16, 25, 22, 1),
                                fontFamily:
                                    GoogleFonts.kohSantepheap().fontFamily,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: MediaQuery.of(context).size.height * 0.07,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(246, 245, 235, 1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.07),
                                  child: Text(
                                    'Scan Here',
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.03,
                                      color:
                                          const Color.fromRGBO(16, 25, 22, 1),
                                      fontFamily:
                                          GoogleFonts.comfortaa().fontFamily,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromRGBO(246, 245, 235, 1),
                                    foregroundColor:
                                        const Color.fromRGBO(57, 80, 92, 1),
                                    shape: const CircleBorder(
                                        side: BorderSide(
                                      color: Colors.transparent,
                                    )),
                                  ),
                                  onPressed: () {
                                    captureImageAndRedirect();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: MediaQuery.of(context).size.height *
                                          0.035,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                    SizedBox(height: 50),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Add space between sections
                        Text(
                          "WATCH YOUR ACTIONS GROW!",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                MediaQuery.of(context).size.height * 0.022,
                            color: const Color.fromRGBO(16, 25, 22, 1),
                            fontFamily: GoogleFonts.comfortaa().fontFamily,
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: Text(
                            "See how many trees you've saved and carbon you've cut",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.02,
                              color: const Color.fromRGBO(16, 25, 22, 1),
                              fontFamily:
                                  GoogleFonts.kohSantepheap().fontFamily,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.82,
                          height: MediaQuery.of(context).size.height * 0.35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Color.fromRGBO(246, 245, 235, 1),
                          ),
                          child: ChartContainer(
                            title: '',
                            color: Color.fromRGBO(246, 245, 235, 1),
                            chart: BarChartContent(),
                            currentMonthValue: monthName(currentMonth),
                          ),
                        ),

                        SizedBox(height: 25),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),

        //navbar
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: true,
          showUnselectedLabels: false,
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
