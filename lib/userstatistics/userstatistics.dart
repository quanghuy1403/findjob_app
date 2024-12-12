import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'liststatistics.dart';
import 'applicantstatistics.dart';
import 'commentstatistics.dart';

import '../Search/profile_company.dart';

class UserStatisticsScreen extends StatefulWidget {
  final String uid;
  UserStatisticsScreen({required this.uid});

  @override
  _UserStatisticsScreenState createState() => _UserStatisticsScreenState();
}

class _UserStatisticsScreenState extends State<UserStatisticsScreen> {
  int totalApplicants = 0;
  int totalJobs = 0;
  int totalComments = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    getTotalApplicants();
    getTotalJobs();
    getTotalComments();
  }

  Future<void> getTotalApplicants() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('jobs')
        .where('uploadedBy', isEqualTo: widget.uid)
        .get();

    int total = 0;
    for (var doc in querySnapshot.docs) {
      total += (doc['applicants'] as num).toInt();
    }

    setState(() {
      totalApplicants = total;
    });
  }

  Future<void> getTotalJobs() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('jobs')
        .where('uploadedBy', isEqualTo: widget.uid)
        .get();

    setState(() {
      totalJobs = querySnapshot.docs.length;
    });
  }

  Future<void> getTotalComments() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('jobs')
        .where('uploadedBy', isEqualTo: widget.uid)
        .get();

    int total = 0;
    for (var doc in querySnapshot.docs) {
      List<dynamic> comments = doc['jobComments'] ?? [];
      total += comments.length;
    }

    setState(() {
      totalComments = total;
    });
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return Liststatistics(uid: widget.uid);
      case 1:
        return Applicantstatistics(uid: widget.uid);
      case 2:
        return Commentstatistics(uid: widget.uid);
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade300, Colors.blueAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.2, 0.9],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.black.withOpacity(0.3),
                  width: 2.0,
                ),
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 35, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileScreen(userID: widget.uid)),
              );
            },
          ),
          title: Text("Thống kê dữ liệu",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Custom navigation bar at the top with gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepOrange.shade300, Colors.blueAccent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.2, 0.9],
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list_alt),
                    label: 'Job Posts: $totalJobs',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Applicants: $totalApplicants',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.comment),
                    label: 'Comments: $totalComments',
                  ),
                ],
                selectedItemColor: Colors.black, // Adjust as needed
                unselectedItemColor: Colors.white, // Adjust as needed
                backgroundColor: Colors.transparent,
                elevation: 0, // Remove shadow
                type: BottomNavigationBarType.fixed,
              ),
            ),
            Expanded(
              child: Center(
                child: totalJobs == 0 && totalApplicants == 0 && totalComments == 0
                    ? CircularProgressIndicator()
                    : _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
