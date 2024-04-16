import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leaflink/components/my_textfield.dart';
import 'package:leaflink/components/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventManagementPage extends StatefulWidget {
  static const String routeName = 'eventmanagement_page';

  @override
  _EventManagementPageState createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  final nameController = TextEditingController();
  final titleController = TextEditingController();
  final platformController = TextEditingController(); // Added for link input
  final linkController = TextEditingController(); // Added for link input
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String _venueSelection = 'Virtual'; // Default selection
  final _formKey = GlobalKey<FormState>();

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
                  Column(
                    children: [
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

  void _submitForm() {
    if (_validateForm() && _isDateAfterCurrentDate()) {
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

  bool _validateForm() {
    if (_venueSelection == 'Virtual') {
      return titleController.text.isNotEmpty &&
          nameController.text.isNotEmpty &&
          linkController.text.isNotEmpty;
    } else {
      return titleController.text.isNotEmpty && nameController.text.isNotEmpty;
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
              : _venueSelection,
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
              platformController.clear(), // Clear platform input
              linkController.clear(), // Clear link input
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
}
