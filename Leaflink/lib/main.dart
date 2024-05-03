import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leaflink/auth/login_or_register.dart';
import 'package:leaflink/selectvenue_page.dart';
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
  // Replace 'YOUR_API_KEY' with your actual API key
  apiKey: 'YOUR_API_KEY',

  // Replace 'YOUR_AUTH_DOMAIN' with your actual auth domain
  authDomain: 'YOUR_AUTH_DOMAIN',

  // Replace 'YOUR_PROJECT_ID' with your actual project ID
  projectId: 'YOUR_PROJECT_ID',

  // Replace 'YOUR_APP_ID' with your actual app ID
  appId: 'YOUR_APP_ID',

  // Replace 'YOUR_MESSAGING_SENDER_ID' with your actual messaging sender ID
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',

  // Replace 'YOUR_STORAGE_BUCKET' with your actual storage bucket
  storageBucket: 'YOUR_STORAGE_BUCKET',
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
        SelectVenuePage.routeName: (BuildContext context) => SelectVenuePage(),
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
