import 'dart:math';
import 'package:leaflink/pages/eventscalendar_page.dart';
import 'package:leaflink/pages/leaderboard_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:leaflink/pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';

class Post {
  final String id;
  final String imageUrl;
  final String caption;
  final String username;
  int likes;
  List<String> likedBy;
  bool reported;

  Post({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.username,
    required this.likes,
    required this.likedBy,
    required this.reported,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final email = (data['email'] ?? '') as String;
    final username = email.substring(0, min(7, email.length));
    return Post(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'] ?? '',
      username: username,
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      reported: data['reported'] ?? false,
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;
  final Function(Post) onLike;

  const PostCard({required this.post, required this.onLike, Key? key})
      : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  int? _selectedOption;

  final _reportOptions = [
    'Option 1',
    'Option 2',
    'Option 3',
  ];

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.likedBy
        .contains(FirebaseAuth.FirebaseAuth.instance.currentUser!.email);
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final randomAnimalIcon = Icons.pets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(
                randomAnimalIcon,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Text(
              widget.post.username,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Spacer(),
            if (!widget.post.reported)
              IconButton(
                onPressed: _showReportDialog,
                icon: Icon(Icons.report),
              ),
          ],
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            widget.post.caption,
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              widget.onLike(widget.post);
              _isLiked = !_isLiked;
            });
          },
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () {
                    print(widget.post.imageUrl);
                  },
                  child: Image.network(
                    widget.post.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          widget.onLike(widget.post);
                          _isLiked = !_isLiked;
                        });
                      },
                      icon: Icon(Icons.favorite),
                      color: _isLiked ? Colors.red : Colors.grey,
                      iconSize: 30,
                    ),
                    Text(
                      '${widget.post.likes} Likes',
                      style: TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      onPressed: () {
                        _sharePost(widget.post.caption, widget.post.imageUrl);
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
  }

  void _sharePost(String caption, String imageUrl) async {
    await FlutterShare.share(
      title: 'Check out this post',
      text: '$caption\n$imageUrl',
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Report Post'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < _reportOptions.length; i++)
                    RadioListTile(
                      title: Text(_reportOptions[i]),
                      value: i,
                      groupValue: _selectedOption,
                      onChanged: (value) {
                        setState(() {
                          _selectedOption = value as int?;
                        });
                      },
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _selectedOption != null ? _submitReport : null,
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitReport() async {
    if (_selectedOption != null) {
      try {
        await FirebaseFirestore.instance.collection('reports').add({
          'option': _reportOptions[_selectedOption!],
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          widget.post.reported = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report submitted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        print('Error submitting report: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting report. Please try again later.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a report option'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
      if (snapshot.docs.isNotEmpty) {
        List<Post> posts = snapshot.docs
            .map((doc) => Post.fromDocument(doc))
            .where((post) => post != null)
            .toList();
        setState(() {
          _posts = posts;
          _error = false;
        });
      } else {
        setState(() {
          _error = true;
        });
      }
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

  void _handleLike(Post post) {
    setState(() {
      bool alreadyLiked = post.likedBy
          .contains(FirebaseAuth.FirebaseAuth.instance.currentUser!.email);
      if (alreadyLiked) {
        post.likes--;
        post.likedBy
            .remove(FirebaseAuth.FirebaseAuth.instance.currentUser!.email!);
      } else {
        post.likes++;
        post.likedBy
            .add(FirebaseAuth.FirebaseAuth.instance.currentUser!.email!);
      }
    });

    FirebaseFirestore.instance.collection('posts').doc(post.id).update({
      'likes': post.likes,
      'likedBy': post.likedBy,
    });
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
            fontSize: MediaQuery.of(context).size.height * 0.04,
            color: const Color.fromRGBO(16, 25, 22, 1),
          ),
        ),
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
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
                : RefreshIndicator(
                    onRefresh: _fetchPosts,
                    child: ListView.separated(
                      itemCount: _posts.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(height: 16),
                      itemBuilder: (BuildContext context, int index) {
                        if (!_posts[index].reported) {
                          return PostCard(
                            post: _posts[index],
                            onLike: _handleLike,
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
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
