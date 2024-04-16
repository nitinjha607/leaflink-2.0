import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleSignInButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;

  const GoogleSignInButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // You can customize the button color
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/google.png', // Replace with your Google logo image asset
            height: 20.0, // Adjust the height as needed
          ),
          SizedBox(width: 8.0),
          Text(
            text,
            style: TextStyle(
                color: Color.fromRGBO(16, 25, 22, 1),
                fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                fontSize: MediaQuery.of(context).size.height * 0.02),
          ),
        ],
      ),
    );
  }
}
