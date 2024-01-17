import 'package:flutter/material.dart';

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
        primary: Colors.white, // You can customize the button color
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
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
