import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leaflink/auth/login_or_register.dart';
import 'package:leaflink/mappage.dart';
import 'package:leaflink/pages/connect_page.dart';
import 'package:leaflink/pages/eventscalendar_page.dart';
import 'package:leaflink/pages/forgotpass_page.dart';
import 'package:leaflink/pages/home_page.dart';
import 'package:leaflink/pages/settingpages/editprofile_page.dart';
import 'package:leaflink/pages/settingpages/help_page.dart';
import 'package:leaflink/pages/settingpages/language_page.dart';
import 'package:leaflink/pages/settingpages/notification_page.dart';
import 'package:leaflink/pages/leaderboard_page.dart';
import 'package:leaflink/pages/eventmanagement_page.dart';
import 'package:leaflink/pages/Create_Post_Page.dart';
import 'package:leaflink/pages/added_events.dart';
import 'package:leaflink/pages/welcome_page.dart';
import 'package:leaflink/solutionpage.dart';
import 'package:leaflink/pages/loader_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBzLPGrr3V11mHhIVFk_friu47oR5LBsSs',
      authDomain: 'leaf-link-1e912-default-rtdb.firebaseio.com',
      projectId: 'leaf-link-1e912',
      appId: '821697692793:android:195ad8509aa13d7ac400a8',
      messagingSenderId: '821697692793',
      storageBucket: 'leaf-link-1e912.appspot.com',
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthenticationWrapper(),
      routes: <String, WidgetBuilder>{
        LogInOrRegister.routeName: (BuildContext context) => LogInOrRegister(),
        ForgotPasswordPage.routeName: (BuildContext context) =>
            ForgotPasswordPage(),
        HomePage.routeName: (BuildContext context) => const HomePage(),
        ConnectPage.routeName: (BuildContext context) => ConnectPage(),
        CalendarPage.routeName: (BuildContext context) => const CalendarPage(),
        LeaderboardPage.routeName: (BuildContext context) =>
            const LeaderboardPage(),
        EditProfilePage.routeName: (BuildContext context) => EditProfilePage(),
        HelpPage.routeName: (BuildContext context) => const HelpPage(),
        NotificationPage.routeName: (BuildContext context) =>
            NotificationPage(),
        LanguagePage.routeName: (BuildContext context) => const LanguagePage(),
        EventManagementPage.routeName: (BuildContext context) =>
            EventManagementPage(),
        CreatePostPage.routeName: (BuildContext context) => CreatePostPage(),
        AddedEventsPage.routeName: (BuildContext context) => AddedEventsPage(),
        SolutionPage.routeName: (BuildContext context) => SolutionPage(),
        BlankPage.routeName: (BuildContext context) => BlankPage(),
        LoaderPage.routeName: (BuildContext context) => LoaderPage(),
      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: LoadingAnimationWidget.dotsTriangle(
              color: Color.fromRGBO(97, 166, 171, 1),
              size: 50, // Adjust loader size
            ),
          ); // or a loading screen
        } else if (snapshot.hasData) {
          return HomePage(); // user is logged in
        } else {
          return WelcomePage(); // user is not logged in
        }
      },
    );
  }
}

// Function to handle user registration
Future<void> registerUser(String email, String password) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    print('User registered successfully');
  } on FirebaseAuthException catch (e) {
    print('Failed to register user: $e');
  }
}

// Function to handle user login
Future<void> loginUser(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    print('User logged in successfully');
  } on FirebaseAuthException catch (e) {
    print('Failed to log in: $e');
  }
}
