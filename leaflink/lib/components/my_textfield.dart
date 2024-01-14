import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextField extends StatelessWidget {
  final dynamic controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.009),
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.83,
            height: MediaQuery.of(context).size.height * 0.074,
            child: TextField(
              style: TextStyle(
                fontSize: 15.0,
                fontFamily: GoogleFonts.kohSantepheap().fontFamily,
              ),
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromRGBO(252, 251, 241, 1)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromRGBO(204, 221, 221, 1)),
                ),
                fillColor: const Color.fromRGBO(204, 221, 221, 1),
                filled: true,
                hintText: hintText,
                hintStyle:
                    const TextStyle(color: Color.fromRGBO(252, 251, 241, 1)),
              ),
            )));
  }
}
