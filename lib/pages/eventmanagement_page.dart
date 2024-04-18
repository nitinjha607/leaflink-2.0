import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leaflink/components/my_textfield.dart';
import 'package:leaflink/components/my_button.dart';
import 'package:leaflink/selectvenue_page.dart';

class EventManagementPage extends StatefulWidget {
  static const String routeName = 'eventmanagement_page';

  @override
  _EventManagementPageState createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  final nameController = TextEditingController();
  final titleController = TextEditingController();
  final platformController = TextEditingController();
  final linkController = TextEditingController();
  final locationController = TextEditingController();
  final coordinateController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String _venueSelection = 'Virtual'; // Default selection
  final _formKey = GlobalKey<FormState>();
  late TextEditingController addressController;

  String _formatDate(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  String _formatTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final time = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat.jm().format(time);
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    addressController = TextEditingController();
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Event',
          style: TextStyle(
            fontFamily: GoogleFonts.comfortaa().fontFamily,
            fontSize: MediaQuery.of(context).size.height * 0.03,
            color: const Color.fromRGBO(16, 25, 22, 1),
          ),
        ),
        backgroundColor: Color.fromRGBO(97, 166, 171, 1),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyTextField(
                  controller: titleController,
                  hintText: 'Title',
                  obscureText: false,
                ),
                MyTextField(
                  controller: nameController,
                  hintText: 'Host',
                  obscureText: false,
                ),
                SizedBox(height: 20),
                Text(
                  'Select Date:',
                  style: TextStyle(
                    fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                    color: const Color.fromRGBO(16, 25, 22, 1),
                  ),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: IgnorePointer(
                    child: MyTextField(
                      controller: TextEditingController(
                          text: _formatDate(_selectedDate)),
                      hintText: 'Date',
                      obscureText: false,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Select Time:',
                  style: TextStyle(
                    fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                    color: const Color.fromRGBO(16, 25, 22, 1),
                  ),
                ),
                SizedBox(height: 20),
                _buildTimePicker(),
                SizedBox(height: 20),
                Text(
                  'Select Venue:',
                  style: TextStyle(
                    fontFamily: GoogleFonts.kohSantepheap().fontFamily,
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                    color: const Color.fromRGBO(16, 25, 22, 1),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Radio(
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Color.fromRGBO(97, 166, 171, 1);
                        }
                        return Color.fromRGBO(97, 166, 171, 1);
                      }),
                      focusColor: const Color.fromRGBO(204, 221, 221, 1),
                      value: 'Virtual',
                      groupValue: _venueSelection,
                      onChanged: (value) {
                        setState(() {
                          _venueSelection = value.toString();
                        });
                      },
                    ),
                    Text('Virtual'),
                    SizedBox(width: 20),
                    Radio(
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Color.fromRGBO(97, 166, 171, 1);
                        }
                        return Color.fromRGBO(97, 166, 171, 1);
                      }),
                      focusColor: const Color.fromRGBO(204, 221, 221, 1),
                      value: 'In-person',
                      groupValue: _venueSelection,
                      onChanged: (value) {
                        setState(() {
                          _venueSelection = value.toString();
                        });
                      },
                    ),
                    Text('In-person'),
                  ],
                ),
                if (_venueSelection == 'Virtual') ...[
                  SizedBox(height: 20),
                  MyTextField(
                    controller: platformController,
                    hintText: 'Platform',
                    obscureText: false,
                  ),
                  MyTextField(
                    controller: linkController,
                    hintText: 'Link',
                    obscureText: false,
                  ),
                ],
                if (_venueSelection == 'In-person') ...[
                  SizedBox(height: 20),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      _selectAddress();
                    },
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(204, 221, 221, 1),
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          children: [
                            Text("Select Address"),
                            Icon(Icons.location_on_sharp),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 20),
                Center(
                  child: MyButton(
                    onTap: () {
                      _submitForm();
                    },
                    text: 'Add Event',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool _validateForm() {
    if (_venueSelection == 'Virtual') {
      return titleController.text.isNotEmpty &&
          nameController.text.isNotEmpty &&
          linkController.text.isNotEmpty;
    } else {
      return titleController.text.isNotEmpty &&
          nameController.text.isNotEmpty &&
          addressController.text.isNotEmpty;
    }
  }

  bool _isDateAfterCurrentDate() {
    final selectedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final currentDate = DateTime.now();
    return selectedDateTime.isAfter(currentDate);
  }

  void _addEventToDatabase() {
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('events');
    collRef
        .add({
          'title': titleController.text,
          'name': nameController.text,
          'venue': _venueSelection == 'Virtual'
              ? {
                  'platform': platformController.text,
                  'link': linkController.text
                }
              : {
                  'address': addressController.text,
                },
          'date': _formatDate(_selectedDate),
          'time': _formatTime(_selectedTime),
          'email': FirebaseAuth.instance.currentUser!.email,
        })
        .then((value) => {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Event added successfully')),
              ),
              titleController.clear(),
              nameController.clear(),
              platformController.clear(),
              linkController.clear(),
              locationController.clear(),
              setState(() {
                _selectedDate = DateTime.now();
                _selectedTime = TimeOfDay.now();
                _venueSelection = 'Virtual';
              }),
            })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add event: $error')),
          );
        });
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );

        if (picked != null) {
          setState(() {
            _selectedTime = picked;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          '${_selectedTime.format(context)}',
          style: TextStyle(
            fontFamily: GoogleFonts.kohSantepheap().fontFamily,
          ),
        ),
      ),
    );
  }

  void _selectAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectVenuePage(),
      ),
    ).then((coordinates) {
      if (coordinates != null) {
        setState(() {
          addressController.text = coordinates.toString();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Coordinates cannot be null')),
        );
      }
    });
  }

  void _submitForm() {
    if (_venueSelection == 'Virtual' &&
        (platformController.text.isEmpty || linkController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all virtual fields')),
      );
      return;
    }

    if (_validateForm() && _isDateAfterCurrentDate()) {
      if (_venueSelection == 'In-person' && addressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an address')),
        );
        return;
      }
      _addEventToDatabase();
    } else {
      String errorMessage = '';
      if (!_validateForm()) {
        errorMessage = 'Please fill all the fields.';
      } else {
        errorMessage = 'Please select a date after the current date.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}
