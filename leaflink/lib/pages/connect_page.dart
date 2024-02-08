import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:leaflink/pages/Create_Post_Page.dart';
import 'package:leaflink/pages/eventscalendar_page.dart';
import 'package:leaflink/pages/home_page.dart';
import 'package:leaflink/pages/leaderboard_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;

class Post {
  final String id;
  final String imageUrl;
  final String caption;
  final String username;
  int likes;
  List<String> likedBy;

  Post({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.username,
    required this.likes,
    required this.likedBy,
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

  @override
  void initState() {
    super.initState();
    // Check if the post is liked by the current user
    _isLiked = widget.post.likedBy
        .contains(FirebaseAuth.FirebaseAuth.instance.currentUser!.email);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.onLike(widget.post);
          _isLiked = !_isLiked; // Toggle the liked status
        });
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${widget.post.username}: ${widget.post.caption}',
                style: TextStyle(
                  color: const Color.fromARGB(255, 26, 25, 25),
                  fontSize: 16,
                ),
              ),
            ),
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
                      _isLiked = !_isLiked; // Toggle the liked status
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
    );
  }

  void _sharePost(String caption, String imageUrl) async {
    await FlutterShare.share(
      title: 'Check out this post',
      text: '$caption\n$imageUrl',
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
            .where((post) => post != null) // Filter out null posts
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
      // Check if the current user has already liked the post
      bool alreadyLiked = post.likedBy
          .contains(FirebaseAuth.FirebaseAuth.instance.currentUser!.email);

      // If the user already liked the post, remove the like
      if (alreadyLiked) {
        post.likes--;
        post.likedBy
            .remove(FirebaseAuth.FirebaseAuth.instance.currentUser!.email!);
      } else {
        // If the user hasn't liked the post, add the like
        post.likes++;
        post.likedBy
            .add(FirebaseAuth.FirebaseAuth.instance.currentUser!.email!);
      }
    });

    // Update likes count and likedBy list in Firestore
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
                : RefreshIndicator(
                    onRefresh: _fetchPosts,
                    child: ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (BuildContext context, int index) {
                        return PostCard(
                          post: _posts[index],
                          onLike: _handleLike,
                        );
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
