import 'package:flutter/material.dart';
import 'package:leaflink/pages/login_page.dart';
import 'package:leaflink/pages/register_page.dart';

class LogInOrRegister extends StatefulWidget {
  static const String routeName = 'loginorregister_page';
  const LogInOrRegister({super.key});

  @override
  State<LogInOrRegister> createState() => _LogInOrRegisterState();
}

class _LogInOrRegisterState extends State<LogInOrRegister> {
  //initially login page
  bool showLogInPage = true;

  //toggle between login and register
  void togglePages() {
    setState(() {
      showLogInPage = !showLogInPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLogInPage) {
      return LoginPage(onTap: togglePages);
    } else {
      return RegisterPage(onTap: togglePages);
    }
  }
}
