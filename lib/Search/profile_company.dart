import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findjob_app/Cvs/cv_screen.dart';
import 'package:findjob_app/userstatistics/userstatistics.dart';
import 'package:findjob_app/Jobs/userjobscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../Widgets/bottom_nav_bar.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  final String userID;
  const ProfileScreen({required this.userID});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? name;
  String email = '';
  String phoneNumber = '';
  String imageUrl = '';
  String joinedAt = '';
  String location = ''; // New field for location
  bool _isLoading = false;
  bool _isSameUser = true;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get();

      if (userDoc.exists) {
        setState(() {
          name = userDoc.get('name');
          email = userDoc.get('email');
          phoneNumber = userDoc.get('phoneNumber');
          imageUrl = userDoc.get('userImage');
          location = userDoc.get('location'); // Fetch location
          Timestamp joinedAtTimeStamp = userDoc.get('createAt');
          var joinedDate = joinedAtTimeStamp.toDate();
          joinedAt =
              '${joinedDate.year} - ${joinedDate.month} - ${joinedDate.day}';
        });

        User? user = _auth.currentUser;
        final _uid = user?.uid;
        print("Current User ID: $_uid");
        print("Widget User ID: ${widget.userID}");

        setState(() {
          _isSameUser = _uid == widget.userID;
          print("_isSameUser: $_isSameUser");
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget userInfo({required IconData icon, required String content}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            content,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _contactBy({
    required Color color,
    required Function fct,
    required IconData icon,
  }) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 30,
      child: CircleAvatar(
        radius: 23,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(icon, color: color),
          onPressed: () {
            fct();
          },
        ),
      ),
    );
  }

  void _openWhatsAppChat() async {
    var url = 'https://wa.me/$phoneNumber?text=Hello';
    launchUrlString(url);
  }

  void _mailTo() async {
    final Uri paramas = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=Write subject here, please&body=Hello, please write detail here.',
    );
    final url = paramas.toString();
    launchUrlString(url);
  }

  void _callPhoneNumber() async {
    var url = 'tel://$phoneNumber';
    launchUrlString(url);
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          child: GestureDetector(
            onTap: () {
              Navigator.of(ctx).pop();
            },
            child: Center(
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade300, Colors.blueAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.2, 0.9],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Row(
              children: [
                if (_isSameUser)
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                EditProfileScreen(userID: widget.userID)),
                      );
                    },
                  ),

                  IconButton(
                      onPressed: (){
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => UserStatisticsScreen(uid: widget.userID)
                            )
                        );
                      },
                      icon: Icon(Icons.account_tree_outlined, color: Colors.white,)
                  )
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 3),
        backgroundColor: Colors.transparent,
        body: Center(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Stack(
                      children: [
                        Card(
                          color: Colors.white10,
                          margin: const EdgeInsets.all(30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 50),
                                Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _showFullImage(imageUrl);
                                        },
                                        child: CircleAvatar(
                                          backgroundImage: imageUrl.isNotEmpty
                                              ? NetworkImage(imageUrl)
                                              : null,
                                          radius: 60, // Increased size
                                          backgroundColor: Colors.grey[300],
                                          child: imageUrl.isEmpty
                                              ? Icon(Icons.person, size: 60)
                                              : null,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        name ?? 'Tên ở đây',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24.0),
                                      ),
                                      const SizedBox(height: 15),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => UserJobScreen(
                                                userID: widget.userID,
                                              ),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors
                                              .white, // Màu nền trắng khi ấn
                                          foregroundColor: Colors
                                              .blue, // Màu chữ xanh khi ấn
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'Các công việc đã đăng',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 15),
                                      const Divider(
                                        thickness: 1,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 30),
                                      const Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Text(
                                          'Thông tin tài khoản:',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: userInfo(
                                          icon: Icons.email,
                                          content: email,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: userInfo(
                                          icon: Icons.phone,
                                          content: phoneNumber,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: userInfo(
                                          icon: Icons.location_on,
                                          content: location,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      const Divider(
                                        thickness: 1,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 35),
                                      if (_isSameUser)
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                _contactBy(
                                                  color: Colors.green,
                                                  fct: () {
                                                    _openWhatsAppChat();
                                                  },
                                                  icon: FontAwesome.whatsapp,
                                                ),
                                                _contactBy(
                                                  color: Colors.red,
                                                  fct: () {
                                                    _mailTo();
                                                  },
                                                  icon: Icons.mail_outline,
                                                ),
                                                _contactBy(
                                                  color: Colors.purple,
                                                  fct: () {
                                                    _callPhoneNumber();
                                                  },
                                                  icon: Icons.call,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 30),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
