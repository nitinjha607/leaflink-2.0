// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoaderPage extends StatefulWidget {
  static const String routeName = 'loader_page';

  const LoaderPage({Key? key}) : super(key: key);

  @override
  _LoaderPageState createState() => _LoaderPageState();
}

class _LoaderPageState extends State<LoaderPage> {
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
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(246, 245, 235, 1),
                )),
            Container(
                alignment: Alignment.center,
                child: Container(
                    margin: const EdgeInsets.all(15),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color.fromRGBO(204, 221, 221, 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: LoadingAnimationWidget.dotsTriangle(
                        color: Color.fromRGBO(97, 166, 171, 1),
                        size: 50, // Adjust loader size
                      ),
                    ))),
          ],
        ),
      ),
    );
  }
}
