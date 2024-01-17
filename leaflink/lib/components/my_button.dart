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
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.0135),
        primary: const Color.fromRGBO(97, 166, 171, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
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
    );
  }
}
