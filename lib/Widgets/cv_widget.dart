import 'package:findjob_app/Cvs/cv_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CvWidget extends StatefulWidget {
  final String usercvImages;
  final String name;
  final String jobCategory;
  final String uid;
  final String cvID;
  final String userID;

  CvWidget({
    required this.usercvImages,
    required this.name,
    required this.jobCategory,
    required this.uid,
    required this.cvID,
    required this.userID
  });

  @override
  State<CvWidget> createState() => _CvWidgetState();
}

class _CvWidgetState extends State<CvWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey,
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: ListTile(
        onTap: () {
          print("Navigating to CvDetailsScreen with cvID: ${widget.cvID}"); // Debugging statement
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CvDetailsScreen(cvID: widget.cvID)
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30), // Tăng padding
        leading: Container(
          width: 60, // Tăng kích thước
          height: 60,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                widget.usercvImages.isNotEmpty
                    ? widget.usercvImages
                    : 'https://as2.ftcdn.net/v2/jpg/02/29/75/83/1000_F_229758328_7x8jwCwjtBMmC6rgFzLFhZoEpLobB6L8.jpg',
              ),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        title: Text(
          widget.name.toUpperCase(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.yellow,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: widget.jobCategory.isNotEmpty
            ? Text(
          widget.jobCategory,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        )
            : null,
        trailing: const Icon(
          Icons.keyboard_arrow_right,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
}