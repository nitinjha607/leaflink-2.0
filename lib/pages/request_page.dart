import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';


class RequestPage extends StatefulWidget {
  final String username;
  final String userIconUrl;

  const RequestPage({Key? key, required this.username, required this.userIconUrl})
      : super(key: key);

  @override
  _RequestPageState createState() => _RequestPageState();

}


class _RequestPageState extends State<RequestPage> {
  bool _isButtonDisabled = false;

  void _handleRequest() {
    if (!_isButtonDisabled) {
      // Add your request logic here
      setState(() {
        _isButtonDisabled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromRGBO(97, 166, 171, 1),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/leaf.svg',
                  color: Colors.white,
                  width: 48,
                  height: 48,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.username,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : _handleRequest,
              child: Text('Request'),
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: 16,
                ),
                backgroundColor: _isButtonDisabled ? Colors.grey : Colors.blue,
                disabledBackgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}