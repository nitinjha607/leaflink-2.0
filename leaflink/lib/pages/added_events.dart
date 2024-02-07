import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddedEventsPage extends StatefulWidget {
  static const String routeName = 'added_events_page';

  @override
  _AddedEventsPageState createState() => _AddedEventsPageState();
}

class _AddedEventsPageState extends State<AddedEventsPage> {
  late List<Event> _upcomingEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchUpcomingEvents();
  }

  Future<void> _fetchUpcomingEvents() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('timestamp')
          .get();

      List<Event> events = snapshot.docs
          .map((doc) => Event.fromSnapshot(doc))
          .where((event) => event.timestamp.isAfter(DateTime.now()))
          .toList();

      setState(() {
        _upcomingEvents = events;
      });
    } catch (e) {
      print('Error fetching upcoming events: $e');
      // Handle error fetching events
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Events'),
      ),
      body: _upcomingEvents.isEmpty
          ? Center(
              child: Text('No upcoming events found.'),
            )
          : ListView.builder(
              itemCount: _upcomingEvents.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_upcomingEvents[index].title),
                  subtitle: Text(_upcomingEvents[index].venue),
                  trailing: Text(
                    '${_upcomingEvents[index].timestamp.day}/${_upcomingEvents[index].timestamp.month}/${_upcomingEvents[index].timestamp.year}',
                  ),
                );
              },
            ),
    );
  }
}

class Event {
  final String title;
  final String venue;
  final DateTime timestamp;

  Event({
    required this.title,
    required this.venue,
    required this.timestamp,
  });

  factory Event.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Event(
      title: data['title'] ?? '',
      venue: data['venue'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

// Other parts of your application...

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        AddedEventsPage.routeName: (context) => AddedEventsPage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AddedEventsPage.routeName);
          },
          child: Text('View Upcoming Events'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
