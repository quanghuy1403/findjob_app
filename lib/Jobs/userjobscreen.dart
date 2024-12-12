import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findjob_app/Widgets/job_widget_bete.dart';
import 'package:flutter/material.dart';

import '../Search/profile_company.dart';

// Định nghĩa class UserJobScreen kế thừa từ StatefulWidget
class UserJobScreen extends StatefulWidget {
  final String userID; // Thuộc tính userID là required

  // Constructor khởi tạo với userID là required
  const UserJobScreen({required this.userID});

  @override
  State<UserJobScreen> createState() =>
      _UserJobScreenState(); // Tạo State cho UserJobScreen
}

// Định nghĩa State của UserJobScreen
class _UserJobScreenState extends State<UserJobScreen> {
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
        appBar: AppBar(
          title: const Text('CÁC VIỆC LÀM CỦA TÔI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
          centerTitle: true,
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
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white, // Màu trắng
            ), // Icon mũi tên quay lại
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProfileScreen(
                            userID: widget.userID,
                          ))); // Điều hướng quay lại ProfileScreen
            },
          ),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('uploadedBy', isEqualTo: widget.userID)
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
                  return JobWidgetBeta(
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
