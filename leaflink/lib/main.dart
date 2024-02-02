import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leaflink/auth/login_or_register.dart';
import 'package:leaflink/pages/connect_page.dart';
import 'package:leaflink/pages/eventscalendar_page.dart';
import 'package:leaflink/pages/forgotpass_page.dart';
import 'package:leaflink/pages/home_page.dart';
import 'package:leaflink/pages/settingpages/editprofile_page.dart';
import 'package:leaflink/pages/settingpages/help_page.dart';
import 'package:leaflink/pages/settingpages/privacy_page.dart';
import 'package:leaflink/pages/settingpages/language_page.dart';
import 'package:leaflink/pages/settingpages/notification_page.dart';
import 'package:leaflink/pages/leaderboard_page.dart';
import 'package:leaflink/pages/Create_Post_Page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyBzLPGrr3V11mHhIVFk_friu47oR5LBsSs',
      authDomain: 'leaf-link-1e912-default-rtdb.firebaseio.com',
      projectId: 'leaf-link-1e912',
      appId: '821697692793:android:195ad8509aa13d7ac400a8',
      messagingSenderId: '821697692793',
        storageBucket: 'gs://leaf-link-1e912.appspot.com'
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
        ConnectPage.routeName: (BuildContext context) => const ConnectPage(),
        CalendarPage.routeName: (BuildContext context) => const CalendarPage(),
        LeaderboardPage.routeName: (BuildContext context) =>
            const LeaderboardPage(),
        EditProfilePage.routeName: (BuildContext context) =>
            const EditProfilePage(),
        HelpPage.routeName: (BuildContext context) => const HelpPage(),
        NotificationPage.routeName: (BuildContext context) =>
            const NotificationPage(),
        PrivacyPage.routeName: (BuildContext context) => const PrivacyPage(),
        LanguagePage.routeName: (BuildContext context) => const LanguagePage(),
        CreatePostPage.routeName: (BuildContext context) => const CreatePostPage(),
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
          return CircularProgressIndicator(); // or a loading screen
        } else if (snapshot.hasData) {
          return HomePage(); // user is logged in
        } else {
          return LogInOrRegister(); // user is not logged in
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
