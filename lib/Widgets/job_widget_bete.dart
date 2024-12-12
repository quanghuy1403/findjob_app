import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findjob_app/Jobs/job_detail_beta.dart';
import 'package:findjob_app/Services/global_method.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class JobWidgetBeta extends StatefulWidget {
  final String jobTitle;
  final String jobDescription;
  final String jobSalary;
  final String jobId;
  final String uploadedBy;
  final String userImage; // Change from final to allow updates
  final String name;
  final bool recruitment;
  final String email;
  final String location;
  final String jobStyle;
  final Timestamp createAt;
  final Timestamp deadlineDateTimeStamp;
  final String jobCategory;
  final String jobLocation;

  JobWidgetBeta({
    required this.jobTitle,
    required this.jobDescription,
    required this.jobSalary,
    required this.jobId,
    required this.uploadedBy,
    required this.userImage,
    required this.name,
    required this.recruitment,
    required this.email,
    required this.location,
    required this.jobStyle,
    required this.createAt,
    required this.deadlineDateTimeStamp,
    required this.jobLocation,
    required this.jobCategory,
  });

  @override
  State<JobWidgetBeta> createState() => _JobWidgetState();
}

class _JobWidgetState extends State<JobWidgetBeta> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  _deleteDialog() {
    setState(() {
      _isLoading = true;
    });
    User? user = _auth.currentUser;
    final _uid = user!.uid;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Xóa công việc'),
          content: Text('Bạn có chắc chắn muốn xóa công việc này không?'),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  if (widget.uploadedBy == _uid) {
                    await FirebaseFirestore.instance
                        .collection('jobs')
                        .doc(widget.jobId)
                        .delete();
                    await Fluttertoast.showToast(
                      msg: 'Công việc đã được xóa',
                      toastLength: Toast.LENGTH_LONG,
                      backgroundColor: Colors.grey,
                      fontSize: 18.0,
                    );
                    Navigator.of(ctx).pop(); // Close the dialog
                  } else {
                    GlobalMethod.showErrorDialog(
                      error: 'Bạn không có quyền xóa công việc này',
                      ctx: ctx,
                    );
                  }
                } catch (error) {
                  GlobalMethod.showErrorDialog(
                    error: 'Không thể xóa công việc này: $error',
                    ctx: ctx,
                  );
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              child: const Text(
                'Xóa',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
              },
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  Color _getBackgroundColor() {
    if (widget.deadlineDateTimeStamp != null) {
      DateTime deadlineDate = widget.deadlineDateTimeStamp.toDate();
      DateTime currentDate = DateTime.now();

      if (currentDate.isAfter(deadlineDate)) {
        return Colors.white24; // Expired jobs
      } else {
        return Colors.blueGrey; // Active jobs
      }
    }
    return Colors.grey; // Default color
  }

  // viết hoa chữ cái đầu mỗi chữ
  String capitalizeEachWord(String text) {
    return text.split(' ').map((word) {
      return word.isNotEmpty
          ? word[0].toUpperCase() + word.substring(1).toLowerCase()
          : '';
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getBackgroundColor(),
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: ListTile(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => JobDetailsBetaScreen(
                uploadedBy: widget.uploadedBy,
                jobID: widget.jobId,
                userID: widget.uploadedBy,
              ),
            ),
          );
        },
        onLongPress: () {
          _deleteDialog();
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        leading: Container(
          width: 120,
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32, // Adjust width as necessary
                height: 32, // Adjust height as necessary
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      widget.userImage ??
                          'https://as2.ftcdn.net/v2/jpg/02/29/75/83/1000_F_229758328_7x8jwCwjtBMmC6rgFzLFhZoEpLobB6L8.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                  borderRadius:
                      BorderRadius.circular(16), // Optional: for rounded image
                ),
              ),
              const SizedBox(height: 4), // Space between image and name
              Text(
                widget.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              (widget.jobTitle).toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.yellow,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            // nganh nghe
            if (widget.jobCategory.isNotEmpty)
              Text(
                widget.jobCategory,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              capitalizeEachWord(widget.jobLocation),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ), // Adjust for layout
            // Luong
            Text(
              '${widget.jobSalary}\$',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            //const SizedBox(height: 5),
            // online or Offline
            Text(
              widget.jobStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    widget.jobStyle == 'Online' ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_right,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
}
