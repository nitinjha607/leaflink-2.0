import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leaflink/components/my_button.dart';

class LanguagePage extends StatefulWidget {
  static const String routeName = 'language_page';

  const LanguagePage({Key? key}) : super(key: key);

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String? selectedLanguage;
  String? selectedRegion;

  void back(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.075,
        title: Text(
          "Language and Region",
          style: TextStyle(
            fontFamily: GoogleFonts.comfortaa().fontFamily,
            fontSize: MediaQuery.of(context).size.height * 0.03,
            color: const Color.fromRGBO(16, 25, 22, 1),
          ),
        ),
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => back(context),
          color: const Color.fromRGBO(16, 25, 22, 1),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(246, 245, 235, 1),
              ),
            ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: _buildDropdownButton(
                        labelText: 'Select Language',
                        value: selectedLanguage,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedLanguage = newValue;
                          });
                        },
                        items: ['Hindi', 'Spanish', 'French', 'English'],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: _buildDropdownButton(
                        labelText: 'Select Region',
                        value: selectedRegion,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRegion = newValue;
                          });
                        },
                        items: ['USA', 'Canada', 'UK', 'France', 'India'],
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: MyButton(
                        onTap: () {
                          // Handle save options
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'This feature will be available in the future',
                              ),
                            ),
                          );
                        },
                        text: 'Save and Continue',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownButton({
    required String labelText,
    required String? value,
    required ValueChanged<String?> onChanged,
    required List<String> items,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 36,
          hint: Text(labelText),
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }
}
