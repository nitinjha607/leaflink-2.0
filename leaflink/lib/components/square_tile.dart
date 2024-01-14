import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  const SquareTile({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.03),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[200],
          ),
          child: Image.asset(
            imagePath,
            height: MediaQuery.of(context).size.height * 0.05,
          ),
        ),
      ],
    );
  }
}
