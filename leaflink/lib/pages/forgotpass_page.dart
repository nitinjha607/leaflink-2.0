import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leaflink/components/my_textfield.dart';
import 'package:leaflink/components/my_button.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatelessWidget {
  static const String routeName = 'forgot_password_page';

  final TextEditingController emailorusernameController =
      TextEditingController();

  void back(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> sendPasswordResetEmail(
      String userEmail, BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail);
      print('Password reset email sent successfully');

      // Show a SnackBar on success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error sending password reset email: $e');
      // Handle error (show an error message to the user, etc.)
    }
  }

  void confirm(BuildContext context) async {
    final userEmail = emailorusernameController.text;
    await sendPasswordResetEmail(userEmail, context);
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
                      hintText: 'Email',
                      obscureText: false,
                    ),
                    MyButton(
                      onTap: () => confirm(context),
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
