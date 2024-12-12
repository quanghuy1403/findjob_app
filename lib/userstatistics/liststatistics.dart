import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Widgets/list_job_statistics.dart';

class Liststatistics extends StatefulWidget {
  final String uid; // The user ID for the job posts

  // Constructor to receive uid
  const Liststatistics({super.key, required this.uid});

  @override
  _ListstatisticsState createState() => _ListstatisticsState();
}

class _ListstatisticsState extends State<Liststatistics> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // Lấy kích thước màn hình

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
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('uploadedBy', isEqualTo: widget.uid)
              .orderBy('createAt', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            // Xử lý dữ liệu snapshot từ Firestore
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.data?.docs.isNotEmpty == true) {
              return ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  var jobData = snapshot.data?.docs[index].data();
                  return ListJobStatistics(
                    jobTitle: jobData['jobTitle'],
                    jobDescription: jobData['jobDescription'],
                    jobId: jobData['jobId'],
                    uploadedBy: jobData['uploadedBy'],
                    userImage: jobData['userImage'],
                    jobSalary: jobData['jobSalary'],
                    name: jobData['name'],
                    recruitment: jobData['recruitment'],
                    email: jobData['email'],
                    location: jobData['location'],
                    jobStyle: jobData['jobStyle'],
                    createAt: jobData['createAt'],
                    deadlineDateTimeStamp: jobData['deadlineDateTimeStamp'],
                    jobLocation: jobData['jobLocation'],
                    jobCategory: jobData['jobCategory'],
                    //jobCategory: jobData['jobCategory'],
                  );
                },
              );
            } else {
              return const Center(
                child: Text('Bạn chưa đăng việc làm nào'),
              );
            }
          },
        ),
      ),
    );
  }
}
