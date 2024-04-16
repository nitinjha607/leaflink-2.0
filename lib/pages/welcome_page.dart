import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leaflink/auth/login_or_register.dart';
import 'package:leaflink/components/my_button.dart';

class WelcomePage extends StatefulWidget {
  static const String routeName = 'welcome_page';

  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5), // Adjust the duration as needed
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment(
                    0.8,
                    0.0,
                  ),
                  colors: [
                    const Color.fromRGBO(222, 255, 229, 1),
                    const Color.fromRGBO(190, 213, 235, 1),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 200.0),
                    child: Text(
                      'Welcome to LEAFLINK',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.08,
                        fontFamily: GoogleFonts.comfortaa().fontFamily,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 100,
                      ),
                    ),
                  ),
                  Text(
                    'Your Green Gateway',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.06,
                      fontFamily: GoogleFonts.comfortaa().fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  MyButton(
                    onTap: () => Navigator.pushNamed(
                      context,
                      LogInOrRegister.routeName,
                    ),
                    text: 'Continue  →',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
