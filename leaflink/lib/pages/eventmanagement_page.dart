import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class EventManagementPage extends StatefulWidget {
  static const String routeName = 'eventmanagement_page';

  @override
  _EventManagementPageState createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

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
          'Event Management',
          style: TextStyle(
            fontFamily: 'YourFont', // Change to your desired font family
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromRGBO(
            97, 166, 171, 1), // Match CalendarPage's app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
                style: TextStyle(
                  fontFamily: 'YourFont', // Change to your desired font family
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter title';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Venue',
                ),
                style: TextStyle(
                  fontFamily: 'YourFont', // Change to your desired font family
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter venue';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Select Date:',
                style: TextStyle(
                  fontFamily: 'YourFont', // Change to your desired font family
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              _buildCalendar(),
              SizedBox(height: 20),
              Text(
                'Select Time:',
                style: TextStyle(
                  fontFamily: 'YourFont', // Change to your desired font family
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              _buildTimePicker(),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process form data
                      // For example, save to database
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Event added successfully')),
                      );
                    }
                  },
                  child: Text(
                    'Add Event',
                    style: TextStyle(
                      fontFamily:
                          'YourFont', // Change to your desired font family
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromRGBO(
                          97, 166, 171, 1), // Match CalendarPage's button color
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2021, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _selectedDate,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDate, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
        });
      },
      calendarStyle: CalendarStyle(
          // Customize calendar style here
          ),
    );
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
            fontFamily: 'YourFont', // Change to your desired font family
          ),
        ),
      ),
    );
  }
}
