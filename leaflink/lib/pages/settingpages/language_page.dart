import 'package:flutter/material.dart';

class LanguagePage extends StatelessWidget {
  static const String routeName = 'language_page';

  const LanguagePage({super.key});

  void back(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: SafeArea(
                child: Center(
                    child: Stack(children: [
      Positioned(
        top: 16,
        left: 16,
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color.fromRGBO(246, 245, 235, 1),
          onPressed: () => back(context),
        ),
      )
    ])))));
  }
}
