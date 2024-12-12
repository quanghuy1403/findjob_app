import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CvDetailsScreen extends StatefulWidget {
  final String cvID;

  const CvDetailsScreen({
    required this.cvID,
  });

  @override
  State<CvDetailsScreen> createState() => _CvDetailsScreenState();
}

class _CvDetailsScreenState extends State<CvDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? cvauthorName;
  String? userImageUrl;
  String? jobCategory;
  String? phone;
  String? address;
  String? facebook;
  String? email;
  String? goal;

  List<Map<String, String>> workExperience = [];
  List<Map<String, String>> activities = [];
  List<Map<String, String>> awards = [];
  List<Map<String, String>> certificates = [];
  List<Map<String, String>> education = [];
  List<Map<String, String>> hobbies = [];
  List<Map<String, String>> projects = [];
  List<Map<String, String>> referees = [];
  List<Map<String, String>> skills = [];

  // Method to fetch CV data and check user ID
  Future<void> _getCvData() async {
    if (widget.cvID.isEmpty) {
      print("Error: cvID is empty");
      return;
    }

    try {
      final DocumentSnapshot cvDoc = await _firestore.collection('cvs').doc(widget.cvID).get();

      if (cvDoc.exists) {
        final cvData = cvDoc.data() as Map<String, dynamic>;
        final cvUID = cvData['uid'] as String?;

        // Check if the CV's UID exists in the 'users' collection
        if (cvUID != null) {
          final userDoc = await _firestore.collection('users').doc(cvUID).get();

          if (userDoc.exists) {
            setState(() {
              // Fetch and display CV data
              cvauthorName = cvData['name'] ?? 'No Name';
              userImageUrl = cvData['usercvImages'] ?? '';
              jobCategory = cvData['jobCategory'] ?? '';
              phone = cvData['phone'] ?? '';
              address = cvData['address'] ?? '';
              facebook = cvData['facebook'] ?? '';
              email = cvData['email'] ?? '';
              goal = cvData['goal'] ?? '';

              workExperience = List<Map<String, String>>.from(cvData['workExperience'] ?? []);
              activities = List<Map<String, String>>.from(cvData['activities'] ?? []);
              awards = List<Map<String, String>>.from(cvData['award'] ?? []);
              certificates = List<Map<String, String>>.from(cvData['certificate'] ?? []);
              education = List<Map<String, String>>.from(cvData['education'] ?? []);
              hobbies = List<Map<String, String>>.from(cvData['hobby'] ?? []);
              projects = List<Map<String, String>>.from(cvData['project'] ?? []);
              referees = List<Map<String, String>>.from(cvData['referee'] ?? []);
              skills = List<Map<String, String>>.from(cvData['skill'] ?? []);
            });
          } else {
            print("No user found with uid: $cvUID");
          }
        }
      } else {
        print("Document does not exist for cvID: ${widget.cvID}");
      }
    } catch (e) {
      print("Error fetching document for cvID: ${widget.cvID}: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    print("Fetching data for cvID: ${widget.cvID}");
    _getCvData();
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
            icon: const Icon(Icons.close, size: 35, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (cvauthorName != null) Text("Name: $cvauthorName"),
              if (userImageUrl != null && userImageUrl!.isNotEmpty)
                Image.network(userImageUrl!),
              if (jobCategory != null) Text("Job Category: $jobCategory"),
              if (phone != null) Text("Phone: $phone"),
              if (address != null) Text("Address: $address"),
              if (facebook != null) Text("Facebook: $facebook"),
              if (email != null) Text("Email: $email"),
              if (goal != null) Text("Goal: $goal"),
              // Add other information display widgets as necessary
            ],
          ),
        ),
      ),
    );
  }
}
