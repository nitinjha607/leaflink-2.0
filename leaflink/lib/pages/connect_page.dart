import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:leaflink/pages/eventscalendar_page.dart';
import 'package:leaflink/pages/home_page.dart';
import 'package:leaflink/pages/leaderboard_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leaflink/pages/Create_Post_Page.dart';
import 'package:flutter_share/flutter_share.dart';

class Post {
  final String id;
  final String imageUrl;
  final String caption;

  Post({required this.id, required this.imageUrl, required this.caption});

  factory Post.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'] ?? '',
    );
  }
}

class ConnectPage extends StatefulWidget {
  static const String routeName = 'connect_page';

  const ConnectPage({Key? key}) : super(key: key);

  @override
  _ConnectPageState createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  int _selectedIndex = 1;
  List<Post> _posts = [];
  bool _loading = false;
  bool _error = false;

  static final Random _random = Random();

  final List<String> _usernames = [
    'JohnDoe',
    'JaneDoe',
    'Alice',
    'Bob',
    'Charlie',
    // Add more usernames as needed
  ];

  String _generateRandomUsername() {
    return _usernames[_random.nextInt(_usernames.length)];
  }

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _loading = true;
    });
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('posts').get();
      List<Post> posts =
          snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
      setState(() {
        _posts = posts;
        _error = false;
      });
    } catch (e) {
      print('Error fetching posts: $e');
      setState(() {
        _error = true;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _sharePost(String caption, String imageUrl) async {
    await FlutterShare.share(
      title: 'Check out this post',
      text: '$caption\n$imageUrl',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.075,
        automaticallyImplyLeading: false,
        title: Text(
          "Connect",
          style: TextStyle(
            fontFamily: GoogleFonts.comfortaa().fontFamily,
            fontSize: MediaQuery.of(context).size.height * 0.04,
            color: const Color.fromRGBO(16, 25, 22, 1),
          ),
        ),
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, CreatePostPage.routeName);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : _error
                ? Center(
                    child: Text(
                      'Error fetching posts. Please try again later.',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              // Add onTap functionality
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${_generateRandomUsername()}: ${_posts[index].caption}', // Display random username
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 26, 25, 25),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      print(_posts[index].imageUrl);
                                      // Add onTap functionality
                                    },
                                    child: Image.network(
                                      _posts[index].imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          // Add like functionality
                                        },
                                        icon: Icon(Icons.favorite),
                                        color: Colors.red,
                                        iconSize: 30,
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _sharePost(_posts[index].caption,
                                              _posts[index].imageUrl);
                                        },
                                        icon: Icon(Icons.share),
                                        color: Colors.blue,
                                        iconSize: 30,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.connect_without_contact),
            label: 'Connect',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(16, 25, 22, 1),
        unselectedItemColor: const Color.fromRGBO(57, 80, 92, 1),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushNamed(context, HomePage.routeName);
              break;
            case 1:
              break;
            case 2:
              Navigator.pushNamed(context, CalendarPage.routeName);
              break;
            case 3:
              Navigator.pushNamed(context, LeaderboardPage.routeName);
              break;
          }
        },
      ),
    );
  }
}
