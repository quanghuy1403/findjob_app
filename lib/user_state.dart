import 'package:findjob_app/Jobs/jobs_screen.dart';
import 'package:findjob_app/LoginPage/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserState extends StatefulWidget {
  @override
  State<UserState> createState() => _UserStateState();
}

class _UserStateState extends State<UserState> {
  Future<bool> _isUserInGroup(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('groups').doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (userSnapshot.hasData && userSnapshot.data != null) {
          final userId = userSnapshot.data!.uid;
          return FutureBuilder<bool>(
            future: _isUserInGroup(userId),
            builder: (context, groupSnapshot) {
              if (groupSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (groupSnapshot.hasData && groupSnapshot.data != true) {
                print('Người dùng đã đăng nhập và thuộc nhóm');
                return JobScreen(); // Màn hình khi người dùng đã đăng nhập và thuộc nhóm
              } else {
                print('Người dùng không thuộc nhóm hoặc tài khoản bị xóa');
                return Login(); // Điều hướng đến màn hình đăng nhập
              }
            },
          );
        } else {
          print('Người dùng chưa được đăng nhập');
          return Login(); // Màn hình đăng nhập
        }
      },
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: UserState(),
    );
  }
}