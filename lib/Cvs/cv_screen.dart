import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findjob_app/Widgets/cv_widget.dart';
import 'package:flutter/material.dart';

import '../Search/profile_company.dart';

class CvScreen extends StatefulWidget {
  final String uid;

  const CvScreen({required this.uid});

  @override
  State<CvScreen> createState() => _CvScreenState();
}

class _CvScreenState extends State<CvScreen> {

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _getCV() async {
    final collectionRef = FirebaseFirestore.instance
        .collection('cvs')
        .where('uid', isEqualTo: widget.uid) // Filter CVs by matching UID
        .withConverter<Map<String, dynamic>>(
      fromFirestore: (snapshot, _) => snapshot.data()!,
      toFirestore: (data, _) => data,
    );

    final snapshots = await collectionRef.get();
    return snapshots.docs;
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
          title: const Text(
            'Các CV của tôi',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
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
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    userID: widget.uid,
                  ),
                ),
              );
            },
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        body: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          future: _getCV(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.data?.isNotEmpty == true) {
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int index) {
                  var cvData = snapshot.data?[index].data();
                  return CvWidget(
                    usercvImages: cvData['usercvImages'] ?? '',
                    name: cvData['name'] ?? '',
                    jobCategory: cvData['jobCategory'] ?? '',
                    uid: cvData['uid'] ?? '',
                    cvID: cvData['cvID'] ?? '',
                    userID: cvData['userID'] ?? '',
                  );
                },
              );
            } else {
              return const Center(
                child: Text('Bạn chưa tạo CV nào'),
              );
            }
          },
        ),
      ),
    );
  }
}
