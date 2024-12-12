import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findjob_app/userstatistics/each_list_statistics/each_applicant.dart';
import 'package:findjob_app/userstatistics/each_list_statistics/each_comments.dart';
import 'package:findjob_app/userstatistics/userstatistics.dart';
import 'package:flutter/material.dart';

class EachList extends StatefulWidget {
  final String jobID;
  final String uid;
  final String jobName;

  const EachList({Key? key, required this.jobID, required this.uid, required this.jobName}) : super(key: key);

  @override
  State<EachList> createState() => _EachListState();
}

class _EachListState extends State<EachList> {
  int _selectedIndex = 0;
  int totalApplicants = 0;
  int totalComments = 0;
  bool isLoading = true; // To show loading indicator

  @override
  void initState() {
    super.initState();
    loadJobStatistics();
  }

  Future<void> loadJobStatistics() async {
    await getTotalApplicants();
    await getTotalComments();
    setState(() {
      isLoading = false; // Data loading completed
    });
  }

// Get total applicants for a specific job
  Future<void> getTotalApplicants() async {
    try {
      // Get the job document based on jobID
      DocumentSnapshot jobDoc = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobID) // Get data for a specific job based on jobID
          .get();

      totalApplicants = (jobDoc['applicants'] as num).toInt(); // Assuming 'applicants' is a list field

    } catch (e) {
      print("Error getting total applicants: $e");
      setState(() {
        totalApplicants = 0; // In case of error, set applicants count to 0
      });
    }
  }


  // Get total comments for a specific job
  Future<void> getTotalComments() async {
    DocumentSnapshot jobDoc = await FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobID) // Get data for a specific job based on jobID
        .get();

    if (jobDoc.exists) {
      List<dynamic> comments = jobDoc['jobComments'] ?? []; // Assuming 'jobComments' is a list field
      setState(() {
        totalComments = comments.length; // Count comments
      });
    }
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return EachApplicant(jobID: widget.jobID);
      case 1:
        return EachComments(jobID: widget.jobID);
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
                    builder: (context) => UserStatisticsScreen(uid: widget.uid)),
              );
            },
          ),
          title: Text(widget.jobName,
              style: TextStyle(
                color: Colors.yellow,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              )),
          centerTitle: true,
        ),
        body: Column(
          children: [
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
                    icon: Icon(Icons.person),
                    label: isLoading ? 'Loading...' : 'Applicants: $totalApplicants',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.comment),
                    label: isLoading ? 'Loading...' : 'Comments: $totalComments',
                  ),
                ],
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.white,
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
              ),
            ),
            Expanded(
              child: Center(
                child: isLoading
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
