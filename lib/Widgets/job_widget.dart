// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:findjob_app/Jobs/job_details.dart';
// import 'package:findjob_app/Services/global_method.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// import '../Jobs/jobs_screen.dart';
//
// class JobWidget extends StatefulWidget {
//   final String jobTitle;
//   final String jobDescription;
//   final String jobSalary;
//   final String jobId;
//   final String uploadedBy;
//   final String userImageUrl; // Change from final to allow updates
//   final String name;
//   final bool recruitment;
//   final String email;
//   final String location;
//   final String jobStyle; // Add jobStyle here
//   final Timestamp createAt;
//   // final Timestamp? deadlineDateTimeStamp;
//   final Timestamp deadlineDateTimeStamp;
//
//   JobWidget({
//     required this.jobTitle,
//     required this.jobDescription,
//     required this.jobSalary,
//     required this.jobId,
//     required this.uploadedBy,
//     required this.userImageUrl,
//     required this.name,
//     required this.recruitment,
//     required this.email,
//     required this.location,
//     required this.jobStyle, // Initialize jobStyle here
//     required this.deadlineDateTimeStamp,
//     required this.createAt,
//   });
//   @override
//   State<JobWidget> createState() => _JobWidgetState();
// }
//
// class _JobWidgetState extends State<JobWidget> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   _deleteDialog() {
//     User? user = _auth.currentUser;
//     final _uid = user!.uid;
//     showDialog(
//       context: context,
//       builder: (ctx) {
//         return AlertDialog(
//           actions: [
//             SizedBox(height: 10),
//             TextButton(
//               onPressed: () async {
//                 try {
//                   if (widget.uploadedBy == _uid) {
//                     await FirebaseFirestore.instance
//                         .collection('jobs')
//                         .doc(widget.jobId)
//                         .delete();
//                     await Fluttertoast.showToast(
//                       msg: 'Công việc đã được xóa',
//                       toastLength: Toast.LENGTH_LONG,
//                       backgroundColor: Colors.grey,
//                       fontSize: 18.0,
//                     );
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => JobScreen()),
//                     );
//                   } else {
//                     GlobalMethod.showErrorDialog(
//                       error: 'Bạn không thể biểu diễn hành động này',
//                       ctx: ctx,
//                     );
//                   }
//                 } catch (error) {
//                   GlobalMethod.showErrorDialog(
//                     error: 'Mục này không thể bị xóa',
//                     ctx: ctx,
//                   );
//                 }
//               },
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.delete,
//                     color: Colors.red,
//                   ),
//                   Text(
//                     'Xóa',
//                     style: TextStyle(
//                       color: Colors.red,
//                     ),
//                   )
//                 ],
//               ),
//             )
//           ],
//         );
//       },
//     );
//   }
//
//   // Color _getBackgroundColor() {
//   //   return widget.jobStyle == 'Online' ? Colors.blueGrey : Colors.blueGrey;
//   // }
//   Color _getBackgroundColor() {
//     if (widget.deadlineDateTimeStamp != null) {
//       DateTime deadlineDate = widget.deadlineDateTimeStamp.toDate();
//       DateTime currentDate = DateTime.now();
//
//       if (currentDate.isAfter(deadlineDate)) {
//         return Colors.white12; // Công việc đã quá hạn
//       }
//     }
//     return widget.jobStyle == 'Online' ? Colors.blueGrey : Colors.blueGrey;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: _getBackgroundColor(), // Use function to get background color
//       elevation: 8,
//       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       child: ListTile(
//         onTap: () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (_) => JobDetailsScreen(
//                 uploadedBy: widget.uploadedBy,
//                 jobID: widget.jobId,
//                 userID: widget.uploadedBy,
//               ),
//             ),
//           );
//         },
//         onLongPress: () {
//           _deleteDialog();
//         },
//         contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//         leading: Container(
//           //padding: const EdgeInsets.only(right: 12),
//           decoration: const BoxDecoration(
//             border: Border(
//               right: BorderSide(width: 1),
//             ),
//           ),
//           child: Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: NetworkImage(
//                   widget.userImageUrl ??
//                       'https://as2.ftcdn.net/v2/jpg/02/29/75/83/1000_F_229758328_7x8jwCwjtBMmC6rgFzLFhZoEpLobB6L8.jpg',
//                 ),
//               ),
//             ),
//           ),
//         ),
//         title: Text(
//           (widget.jobTitle).toUpperCase(),
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(
//             color: Colors.yellow,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Text(
//               widget.name,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 color: Colors.black54,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               '${widget.jobSalary}\$', // Thêm $ vào trước số tiền
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 17,
//               ),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               widget.jobStyle,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: widget.jobStyle == 'Online'
//                     ? Colors.red
//                     : Colors.green, // Set color based on jobStyle
//                 fontWeight: FontWeight.bold,
//                 fontSize: 13,
//               ),
//             ),
//           ],
//         ),
//         trailing: const Icon(
//           Icons.keyboard_arrow_right,
//           color: Colors.black,
//           size: 30,
//         ),
//       ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:findjob_app/Jobs/job_details.dart';
// import 'package:findjob_app/Services/global_method.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// import '../Jobs/jobs_screen.dart';
//
// class JobWidget extends StatefulWidget {
//   final String jobTitle;
//   final String jobDescription;
//   final String jobSalary;
//   final String jobId;
//   final String uploadedBy;
//   final String userImageUrl;
//   final String name;
//   final bool recruitment;
//   final String email;
//   final String location;
//   final String jobStyle;
//   final Timestamp createAt;
//   final Timestamp deadlineDateTimeStamp;
//   final String jobCategory; // Add jobCategory here
//
//   JobWidget({
//     required this.jobTitle,
//     required this.jobDescription,
//     required this.jobSalary,
//     required this.jobId,
//     required this.uploadedBy,
//     required this.userImageUrl,
//     required this.name,
//     required this.recruitment,
//     required this.email,
//     required this.location,
//     required this.jobStyle,
//     required this.deadlineDateTimeStamp,
//     required this.createAt,
//     required this.jobCategory, // Initialize jobCategory here
//   });
//
//   @override
//   State<JobWidget> createState() => _JobWidgetState();
// }
//
// class _JobWidgetState extends State<JobWidget> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   _deleteDialog() {
//     User? user = _auth.currentUser;
//     final _uid = user!.uid;
//     showDialog(
//       context: context,
//       builder: (ctx) {
//         return AlertDialog(
//           actions: [
//             SizedBox(height: 10),
//             TextButton(
//               onPressed: () async {
//                 try {
//                   if (widget.uploadedBy == _uid) {
//                     await FirebaseFirestore.instance
//                         .collection('jobs')
//                         .doc(widget.jobId)
//                         .delete();
//                     await Fluttertoast.showToast(
//                       msg: 'Công việc đã được xóa',
//                       toastLength: Toast.LENGTH_LONG,
//                       backgroundColor: Colors.grey,
//                       fontSize: 18.0,
//                     );
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => JobScreen()),
//                     );
//                   } else {
//                     GlobalMethod.showErrorDialog(
//                       error: 'Bạn không thể biểu diễn hành động này',
//                       ctx: ctx,
//                     );
//                   }
//                 } catch (error) {
//                   GlobalMethod.showErrorDialog(
//                     error: 'Mục này không thể bị xóa',
//                     ctx: ctx,
//                   );
//                 }
//               },
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.delete,
//                     color: Colors.red,
//                   ),
//                   Text(
//                     'Xóa',
//                     style: TextStyle(
//                       color: Colors.red,
//                     ),
//                   )
//                 ],
//               ),
//             )
//           ],
//         );
//       },
//     );
//   }
//
//   Color _getBackgroundColor() {
//     if (widget.deadlineDateTimeStamp != null) {
//       DateTime deadlineDate = widget.deadlineDateTimeStamp.toDate();
//       DateTime currentDate = DateTime.now();
//
//       if (currentDate.isAfter(deadlineDate)) {
//         return Colors.white12; // Công việc đã quá hạn
//       }
//     }
//     return widget.jobStyle == 'Online' ? Colors.blueGrey : Colors.blueGrey;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: _getBackgroundColor(),
//       elevation: 8,
//       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       child: ListTile(
//         onTap: () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (_) => JobDetailsScreen(
//                 uploadedBy: widget.uploadedBy,
//                 jobID: widget.jobId,
//                 userID: widget.uploadedBy,
//               ),
//             ),
//           );
//         },
//         onLongPress: () {
//           _deleteDialog();
//         },
//         contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//         leading: Container(
//           decoration: const BoxDecoration(
//             border: Border(
//               right: BorderSide(width: 1),
//             ),
//           ),
//           child: Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: NetworkImage(
//                   widget.userImageUrl ??
//                       'https://as2.ftcdn.net/v2/jpg/02/29/75/83/1000_F_229758328_7x8jwCwjtBMmC6rgFzLFhZoEpLobB6L8.jpg',
//                 ),
//               ),
//             ),
//           ),
//         ),
//         title: Text(
//           (widget.jobTitle).toUpperCase(),
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(
//             color: Colors.yellow,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Text(
//               widget.name,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 color: Colors.black54,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               '${widget.jobSalary}\$',
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 17,
//               ),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               widget.jobStyle,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: widget.jobStyle == 'Online' ? Colors.red : Colors.green,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 13,
//               ),
//             ),
//             const SizedBox(height: 5),
//             if (widget
//                 .jobCategory.isNotEmpty) // Check if jobCategory is not empty
//               Text(
//                 widget.jobCategory,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 13,
//                 ),
//               ),
//           ],
//         ),
//         trailing: const Icon(
//           Icons.keyboard_arrow_right,
//           color: Colors.black,
//           size: 30,
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findjob_app/Jobs/job_details.dart';
import 'package:findjob_app/Services/global_method.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Jobs/jobs_screen.dart';

class JobWidget extends StatefulWidget {
  final String jobTitle;
  final String jobDescription;
  final String jobSalary;
  final String jobId;
  final String uploadedBy;
  final String userImageUrl;
  final String name;
  final bool recruitment;
  final String email;
  final String location;
  final String jobStyle;
  final Timestamp createAt;
  final Timestamp deadlineDateTimeStamp;
  final String jobCategory;
  //final String deadlineDate;
  final String jobLocation;

  JobWidget({
    required this.jobTitle,
    required this.jobDescription,
    required this.jobSalary,
    required this.jobId,
    required this.uploadedBy,
    required this.userImageUrl,
    required this.name,
    required this.recruitment,
    required this.email,
    required this.location,
    required this.jobStyle,
    required this.deadlineDateTimeStamp,
    required this.createAt,
    required this.jobCategory,
    //required this.deadlineDate,
    required this.jobLocation,
  });

  @override
  State<JobWidget> createState() => _JobWidgetState();
}

class _JobWidgetState extends State<JobWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _deleteDialog() {
    User? user = _auth.currentUser;
    final _uid = user!.uid;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          actions: [
            SizedBox(height: 10),
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => JobScreen()),
                    );
                  } else {
                    GlobalMethod.showErrorDialog(
                      error: 'Bạn không thể biểu diễn hành động này',
                      ctx: ctx,
                    );
                  }
                } catch (error) {
                  GlobalMethod.showErrorDialog(
                    error: 'Mục này không thể bị xóa',
                    ctx: ctx,
                  );
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  Text(
                    'Xóa',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  )
                ],
              ),
            )
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
              builder: (_) => JobDetailsScreen(
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
                      widget.userImageUrl ??
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
