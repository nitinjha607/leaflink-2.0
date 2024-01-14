import 'package:flutter/material.dart';
import 'package:leaflink/components/my_textfield.dart';
import 'package:leaflink/components/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leaflink/pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key, required this.onTap});

  // text editing controllers
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasController = TextEditingController();
  final void Function()? onTap;

  // Firebase authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register user method
  Future<void> registerUser(BuildContext context) async {
    try {
      // Validate email, username, and passwords
      if (emailController.text.isEmpty ||
          usernameController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all the fields.'),
          ),
        );
        return;
      }

      if (passwordController.text != confirmPasController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match.'),
          ),
        );
        return;
      }

      // Create a user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Display success message
      print('User registered successfully!');

      // Navigate to the home page after registration
      // Ensure that the current widget is still mounted before navigating
      if (context != null && Navigator.canPop(context)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }
    } catch (e) {
      // Handle registration errors
      print('Error during registration: $e');
      // Display an error message to the user if needed
      String errorMessage = 'Error during registration. Please try again.';
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMessage =
              'Email is already in use. Please use a different email.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 70.0, bottom: 10),
                child: Text(
                  'Welcome to Leaflink!',
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
                controller: usernameController,
                hintText: 'Username',
                obscureText: false,
              ),
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              MyTextField(
                controller: confirmPasController,
                hintText: 'Re-enter Password',
                obscureText: true,
              ),
              MyButton(
                onTap: () => registerUser(context),
                text: 'Register',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already a member? ",
                    style: TextStyle(
                      fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                      color: Color.fromRGBO(16, 25, 22, 1),
                    ),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      'Login here',
                      style: TextStyle(
                          color: const Color.fromRGBO(57, 80, 92, 1),
                          fontSize: MediaQuery.of(context).size.height * 0.02,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.kohSantepheap().fontFamily),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    ));
  }
}
