import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;

  const MyButton({
    Key? key,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Use the onTap callback passed to the widget
      child: Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.0135),
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.085,
          right: MediaQuery.of(context).size.width * 0.085,
          bottom: MediaQuery.of(context).size.height * 0.009,
          top: MediaQuery.of(context).size.height * 0.009,
        ),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(97, 166, 171, 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: const Color.fromRGBO(246, 245, 235, 1),
              fontSize: 16,
              fontFamily: GoogleFonts.comfortaa().fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}
