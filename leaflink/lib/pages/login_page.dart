import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:leaflink/components/my_button.dart';
import 'package:leaflink/components/my_textfield.dart';
import 'package:leaflink/components/google_sign_in_button.dart'; // Add this import
import 'package:leaflink/pages/forgotpass_page.dart';
import 'package:leaflink/pages/home_page.dart';

class LoginPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  LoginPage({Key? key, required this.onTap});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final void Function()? onTap;

  Future<void> signInUser(BuildContext context) async {
    try {
      // Validate email and password
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter both email and password.'),
          ),
        );
        return;
      }

      // Sign in user with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Display success message or navigate to the next screen
      print('User signed in successfully!');

      // Navigate to the next screen or home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } catch (e) {
      // Handle sign-in errors
      print('Error during sign-in: $e');

      // Display an error message to the user if needed
      String errorMessage =
          'Error during sign-in. Please check your credentials.';
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          errorMessage = 'Invalid email or password.';
        } else {
          errorMessage = e.message ?? 'An error occurred.';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // The user canceled the Google Sign-In process
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Google credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Display success message or navigate to the next screen
      print('User signed in with Google successfully!');

      // Navigate to the next screen or home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } catch (e) {
      // Handle sign-in errors
      print('Error during Google sign-in: $e');

      // Display an error message to the user if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during Google sign-in. Please try again.'),
        ),
      );
    }
  }

  void forgotPassword(BuildContext context) {
    Navigator.pushNamed(context, ForgotPasswordPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
            SafeArea(
              child: Positioned(
                bottom: 0,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 1,
                  width: MediaQuery.of(context).size.width,
                  child: buildLoginForm(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoginForm(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                'Welcome back, you\'ve been missed!',
                style: TextStyle(
                  color: const Color.fromRGBO(16, 25, 22, 1),
                  fontSize: MediaQuery.of(context).size.height * 0.025,
                  fontFamily: GoogleFonts.comfortaa().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            MyTextField(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
            ),
            MyTextField(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
            ),
            Container(
              alignment: Alignment(-0.8, 0),
              child: GestureDetector(
                onTap: () => forgotPassword(context),
                child: Text(
                  'Forgot password?',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color.fromRGBO(66, 123, 138, 1),
                    fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                    fontSize: MediaQuery.of(context).size.height * 0.018,
                  ),
                ),
              ),
            ),
            MyButton(
              onTap: () => signInUser(context),
              text: 'Sign In',
            ),
            Padding(
              padding: EdgeInsets.only(left: 25.0, right: 25.0, bottom: 2.0),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Color.fromRGBO(16, 25, 22, 1),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(
                        color: Color.fromRGBO(16, 25, 22, 1),
                        fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Color.fromRGBO(16, 25, 22, 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            GoogleSignInButton(
              onPressed: () => signInWithGoogle(context),
              text: 'Sign In with Google',
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add your social login buttons here (unchanged code)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Not a member? ",
                  style: TextStyle(
                    fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                    color: Color.fromRGBO(16, 25, 22, 1),
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    'Register now',
                    style: TextStyle(
                      color: const Color.fromRGBO(57, 80, 92, 1),
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(onTap: () {}),
    );
  }
}
