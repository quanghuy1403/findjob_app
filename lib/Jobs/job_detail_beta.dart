import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findjob_app/Jobs/userjobscreen.dart';
import 'package:findjob_app/Search/edi_job_beta.dart';
import 'package:findjob_app/Services/global_method.dart';
import 'package:findjob_app/Services/global_variables.dart';
import 'package:findjob_app/Widgets/comments_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

class JobDetailsBetaScreen extends StatefulWidget {
  final String uploadedBy;
  final String jobID;
  final String userID;

  const JobDetailsBetaScreen({
    required this.uploadedBy,
    required this.jobID,
    required this.userID,
  });
  @override
  State<JobDetailsBetaScreen> createState() => _JobDetailsBetaScreenState();
}
// class _JobDetailsBetaScreenState extends State<JobDetailsBetaScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   bool _isCommenting = false;
//
//   final TextEditingController _commentController = TextEditingController();
//
//   String? authorName;
//   String? userImageUrl;
//   String? jobCategory;
//   String? jobDescription;
//   String? jobSalary;
//   String? jobTitle;
//   bool? recruitment;
//   Timestamp? postedDateTimeStamp;
//   Timestamp? deadlineDateTimeStamp;
//   String? emailCompany;
//   String? postedDate;
//   String? deadlineDate;
//   String? locationCompany = '';
//   String? jobStyle;
//   int applicants = 0;
//   bool isDeadlineAvailable = false;
//   bool showComment = false;
//
//   void getJobData() async {
//     final DocumentSnapshot userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.uploadedBy)
//         .get();
//
//     if (userDoc == null) {
//       return;
//     } else {
//       setState(() {
//         authorName = userDoc.get('name');
//         userImageUrl = userDoc.get('userImage');
//       });
//     }
//     final DocumentSnapshot jobDatabase = await FirebaseFirestore.instance
//         .collection('jobs')
//         .doc(widget.jobID)
//         .get();
//
//     if (jobDatabase == null) {
//       return;
//     } else {
//       setState(() {
//         jobTitle = jobDatabase.get('jobTitle');
//         jobDescription = jobDatabase.get('jobDescription');
//         jobSalary = jobDatabase.get('jobSalary');
//         recruitment = jobDatabase.get('recruitment');
//         emailCompany = jobDatabase.get('email');
//         locationCompany = jobDatabase.get('location');
//         applicants = jobDatabase.get('applicants');
//         postedDateTimeStamp = jobDatabase.get('createAt');
//         deadlineDateTimeStamp = jobDatabase.get('deadlineDateTimeStamp');
//         deadlineDate = jobDatabase.get('deadlineDate');
//         var postDate = postedDateTimeStamp!.toDate();
//         postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
//         jobStyle = jobDatabase.get('jobStyle');
//       });
//
//       // Lấy dữ liệu từ Firestore
//       var date = deadlineDateTimeStamp?.toDate();
//
//       if (date != null) {
//         isDeadlineAvailable = date.isAfter(DateTime.now());
//       } else {
//         isDeadlineAvailable = false; // Nếu không có giá trị thì đặt là false.
//       }
//
// // In ra các giá trị để kiểm tra
//       print('Ngày hạn chót: $date');
//       print('Ngày hiện tại: ${DateTime.now()}');
//       print('isDeadlineAvailable: $isDeadlineAvailable');
//
// // Cập nhật giao diện
//       setState(() {
//         // Gán lại giá trị của isDeadlineAvailable nếu cần
//         isDeadlineAvailable = isDeadlineAvailable;
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getJobData();
//   }
//
//   Widget dividerWidget() {
//     return const Column(
//       children: [
//         SizedBox(
//           height: 10,
//         ),
//         Divider(
//           thickness: 1,
//           color: Colors.grey,
//         )
//       ],
//     );
//   }
//
//   applyForJob() {
//     final Uri params = Uri(
//       scheme: 'mailto',
//       path: emailCompany,
//       query:
//           'subject=Applying for $jobTitle&body=Hello,please attach Resume CV file',
//     );
//     final url = params.toString();
//     launchUrlString(url);
//     addNewApplicant();
//   }
//
//   void addNewApplicant() {
//     var docRef =
//         FirebaseFirestore.instance.collection('jobs').doc(widget.jobID);
//     docRef.update({'applicants': applicants + 1});
//     Navigator.pushReplacementNamed(context, 'Jobs/job_detail.dart');
//   }
//
//   bool showApplicantsDetail =
//       false; // Thêm biến state để điều khiển việc hiển thị chi tiết người xin việc
//
// // Hàm để toggle việc hiển thị chi tiết người xin việc
//   void toggleApplicantsDetail() {
//     setState(() {
//       showApplicantsDetail = !showApplicantsDetail;
//     });
//   }
//
//   void _showFullImage(String imageUrl) {
//     showDialog(
//       context: context,
//       builder: (ctx) => Dialog(
//         backgroundColor: Colors.transparent,
//         child: GestureDetector(
//           onTap: () {
//             Navigator.of(ctx).pop();
//           },
//           child: Center(
//             child: Image.network(imageUrl),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.deepOrange.shade300, Colors.blueAccent],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//           stops: const [0.2, 0.9],
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(
//           flexibleSpace: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.deepOrange.shade300, Colors.blueAccent],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//                 stops: const [0.2, 0.9],
//               ),
//               border: Border(
//                 bottom: BorderSide(
//                   color: Colors.black.withOpacity(0.3),
//                   width: 2.0,
//                 ),
//               ),
//             ),
//           ),
//           leading: IconButton(
//             icon: const Icon(Icons.close, size: 40, color: Colors.white),
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => UserJobScreen(userID: widget.userID)),
//               );
//             },
//           ),
//           actions: [
//             if (FirebaseAuth.instance.currentUser!.uid == widget.uploadedBy)
//               IconButton(
//                 icon: Icon(Icons.edit, color: Colors.white),
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) => EditJobBetaScreen(
//                             uploadedBy: widget.uploadedBy,
//                             jobID: widget.jobID,
//                             userID: widget.userID)),
//                   );
//                 },
//               ),
//           ],
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(4.0),
//                 child: Card(
//                   color: Colors.black54,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(left: 4),
//                           child: Text(
//                             (jobTitle ?? '').toUpperCase(),
//                             maxLines: 3,
//                             style: const TextStyle(
//                               color: Colors.yellow,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 22,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             GestureDetector(
//                               onTap: () {
//                                 _showFullImage(userImageUrl ?? '');
//                               },
//                               child: Container(
//                                 height: 60,
//                                 width: 60,
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     width: 3,
//                                     color: Colors.grey,
//                                   ),
//                                   shape: BoxShape.rectangle,
//                                   image: DecorationImage(
//                                     image: NetworkImage(
//                                       userImageUrl ??
//                                           'https://as2.ftcdn.net/v2/jpg/02/29/75/83/1000_F_229758328_7x8jwCwjtBMmC6rgFzLFhZoEpLobB6L8.jpg',
//                                     ),
//                                     fit: BoxFit.fill,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 10),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     authorName ?? '',
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 5),
//                                   Text(
//                                     locationCompany ?? '',
//                                     style: const TextStyle(color: Colors.grey),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         dividerWidget(),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               applicants.toString(),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                               ),
//                             ),
//                             const SizedBox(width: 6),
//                             const Text(
//                               'Người xin việc',
//                               style: TextStyle(color: Colors.grey),
//                             ),
//                             const SizedBox(width: 10),
//                             IconButton(
//                               onPressed: () {},
//                               icon: const Icon(
//                                 Icons.how_to_reg_sharp,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                         if (FirebaseAuth.instance.currentUser!.uid ==
//                             widget.uploadedBy)
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               dividerWidget(),
//                               const Text(
//                                 'Tuyển dụng',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 5),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   TextButton(
//                                     onPressed: () {
//                                       User? user = _auth.currentUser;
//                                       final _uid = user!.uid;
//                                       if (_uid == widget.uploadedBy) {
//                                         try {
//                                           FirebaseFirestore.instance
//                                               .collection('jobs')
//                                               .doc(widget.jobID)
//                                               .update({'recruitment': true});
//                                         } catch (error) {
//                                           GlobalMethod.showErrorDialog(
//                                             error:
//                                                 'Hành động không thể được thực hiện',
//                                             ctx: context,
//                                           );
//                                         }
//                                       } else {
//                                         GlobalMethod.showErrorDialog(
//                                             error:
//                                                 'Bạn không thể thực hiện hành động này',
//                                             ctx: context);
//                                       }
//                                       getJobData();
//                                     },
//                                     child: const Text(
//                                       'ON',
//                                       style: TextStyle(
//                                           fontStyle: FontStyle.italic,
//                                           color: Colors.black,
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                   Opacity(
//                                     opacity: recruitment == true ? 1 : 0,
//                                     child: const Icon(
//                                       Icons.check_box,
//                                       color: Colors.green,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 40),
//                                   TextButton(
//                                     onPressed: () {
//                                       User? user = _auth.currentUser;
//                                       final _uid = user!.uid;
//                                       if (_uid == widget.uploadedBy) {
//                                         try {
//                                           FirebaseFirestore.instance
//                                               .collection('jobs')
//                                               .doc(widget.jobID)
//                                               .update({'recruitment': false});
//                                         } catch (error) {
//                                           GlobalMethod.showErrorDialog(
//                                             error:
//                                                 'Hành động không thể được thực hiện',
//                                             ctx: context,
//                                           );
//                                         }
//                                       } else {
//                                         GlobalMethod.showErrorDialog(
//                                             error:
//                                                 'Bạn không thể thực hiện hành động này',
//                                             ctx: context);
//                                       }
//                                       getJobData();
//                                     },
//                                     child: const Text(
//                                       'OFF',
//                                       style: TextStyle(
//                                           fontStyle: FontStyle.italic,
//                                           color: Colors.black,
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                   Opacity(
//                                     opacity: recruitment == false ? 1 : 0,
//                                     child: const Icon(
//                                       Icons.check_box,
//                                       color: Colors.red,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         dividerWidget(),
//                         const Text(
//                           'Mô tả công việc',
//                           style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           jobDescription ?? '',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         dividerWidget(),
//                         const Text(
//                           'Mức lương cho công việc',
//                           style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           jobSalary ?? 'Mức lương chưa được điền',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         dividerWidget(),
//                         const Text(
//                           'Loại công việc',
//                           style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           jobStyle ?? 'Loại công việc chưa được điền',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         dividerWidget(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(4.0),
//                 child: Card(
//                   color: Colors.black54,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Center(
//                           child: Text(
//                             isDeadlineAvailable
//                                 ? 'Tích cực tuyển dụng, Gửi CV/Tiếp tục'
//                                 : 'Hạn công việc đã qua',
//                             style: TextStyle(
//                               color: isDeadlineAvailable
//                                   ? Colors.green
//                                   : Colors.red,
//                               fontWeight: FontWeight.normal,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         if (FirebaseAuth.instance.currentUser!.uid !=
//                             widget.uploadedBy)
//                           Center(
//                             child: MaterialButton(
//                               onPressed: () async {
//                                 applyForJob();
//                               },
//                               color: Colors.blueAccent,
//                               elevation: 0,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(13),
//                               ),
//                               child: const Padding(
//                                 padding: EdgeInsets.symmetric(vertical: 14),
//                                 child: Text(
//                                   'Ứng Tuyển Công Việc',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         dividerWidget(),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               'Tải Lên vào ngày: ',
//                               style: TextStyle(
//                                 color: Colors.white,
//                               ),
//                             ),
//                             Text(
//                               postedDate ?? '',
//                               style: const TextStyle(
//                                   color: Colors.grey,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 15),
//                             )
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 12,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               'Hạn công việc vào ngày: ',
//                               style: TextStyle(
//                                 color: Colors.white,
//                               ),
//                             ),
//                             Text(
//                               deadlineDate ?? '',
//                               style: const TextStyle(
//                                   color: Colors.grey,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 15),
//                             )
//                           ],
//                         ),
//                         dividerWidget(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(4.0),
//                 child: Card(
//                   color: Colors.black54,
//                   child: Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         AnimatedSwitcher(
//                           duration: const Duration(milliseconds: 500),
//                           child: _isCommenting
//                               ? Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Flexible(
//                                       flex: 3,
//                                       child: TextField(
//                                         controller: _commentController,
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                         ),
//                                         maxLength: 200,
//                                         keyboardType: TextInputType.text,
//                                         maxLines: 6,
//                                         decoration: InputDecoration(
//                                           filled: true,
//                                           fillColor: Theme.of(context)
//                                               .scaffoldBackgroundColor,
//                                           enabledBorder:
//                                               const UnderlineInputBorder(
//                                                   borderSide: BorderSide(
//                                                       color: Colors.white)),
//                                           focusedBorder:
//                                               const OutlineInputBorder(
//                                                   borderSide: BorderSide(
//                                                       color: Colors.pink)),
//                                         ),
//                                       ),
//                                     ),
//                                     Flexible(
//                                       child: Column(
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 8),
//                                             child: MaterialButton(
//                                               onPressed: () async {
//                                                 if (_commentController
//                                                         .text.length <
//                                                     7) {
//                                                   GlobalMethod.showErrorDialog(
//                                                     error:
//                                                         'Bình luận không thể nhỏ hơn 7 ký tự',
//                                                     ctx: context,
//                                                   );
//                                                 } else {
//                                                   final _generatedId =
//                                                       Uuid().v4();
//                                                   await FirebaseFirestore
//                                                       .instance
//                                                       .collection('jobs')
//                                                       .doc(widget.jobID)
//                                                       .update({
//                                                     'jobComments':
//                                                         FieldValue.arrayUnion([
//                                                       {
//                                                         'userId': FirebaseAuth
//                                                             .instance
//                                                             .currentUser!
//                                                             .uid,
//                                                         'commentId':
//                                                             _generatedId,
//                                                         'name': name,
//                                                         'userImageUrl':
//                                                             userImage,
//                                                         'commentBody':
//                                                             _commentController
//                                                                 .text,
//                                                         'time': Timestamp.now(),
//                                                       }
//                                                     ]),
//                                                   });
//                                                   await Fluttertoast.showToast(
//                                                       msg:
//                                                           'Bình luận của bạn đã được đăng',
//                                                       toastLength:
//                                                           Toast.LENGTH_LONG,
//                                                       backgroundColor:
//                                                           Colors.grey,
//                                                       fontSize: 18);
//                                                   _commentController.clear();
//                                                 }
//                                                 setState(() {
//                                                   showComment = true;
//                                                 });
//                                               },
//                                               color: Colors.blueAccent,
//                                               elevation: 0,
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(8),
//                                               ),
//                                               child: const Text(
//                                                 'Đăng',
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 14,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           TextButton(
//                                             onPressed: () {
//                                               setState(() {
//                                                 _isCommenting = !_isCommenting;
//                                                 showComment = false;
//                                               });
//                                             },
//                                             child: const Text('Hủy'),
//                                           )
//                                         ],
//                                       ),
//                                     )
//                                   ],
//                                 )
//                               : Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     IconButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           _isCommenting = !_isCommenting;
//                                         });
//                                       },
//                                       icon: const Icon(
//                                         Icons.add_comment,
//                                         color: Colors.blueAccent,
//                                         size: 40,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 10),
//                                     IconButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           showComment = true;
//                                         });
//                                       },
//                                       icon: const Icon(
//                                         Icons.arrow_drop_down_circle,
//                                         color: Colors.blueAccent,
//                                         size: 40,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                         ),
//                         if (showComment)
//                           Padding(
//                             padding: EdgeInsets.all(16.0),
//                             child: FutureBuilder<DocumentSnapshot>(
//                               future: FirebaseFirestore.instance
//                                   .collection('jobs')
//                                   .doc(widget.jobID)
//                                   .get(),
//                               builder: (context, snapshot) {
//                                 if (snapshot.connectionState ==
//                                     ConnectionState.waiting) {
//                                   return const Center(
//                                     child: CircularProgressIndicator(),
//                                   );
//                                 } else {
//                                   if (!snapshot.hasData ||
//                                       snapshot.data == null ||
//                                       snapshot.data!['jobComments'] == null ||
//                                       (snapshot.data!['jobComments'] as List)
//                                           .isEmpty) {
//                                     return const Center(
//                                       child: Text(
//                                           'Không có bình luận cho công việc này'),
//                                     );
//                                   } else {
//                                     return ListView.separated(
//                                       shrinkWrap: true,
//                                       physics:
//                                           const NeverScrollableScrollPhysics(),
//                                       itemBuilder: (context, index) {
//                                         return CommentsWidget(
//                                           commentId:
//                                               snapshot.data!['jobComments']
//                                                   [index]['commentId'],
//                                           commenterId:
//                                               snapshot.data!['jobComments']
//                                                   [index]['userId'],
//                                           commenterName:
//                                               snapshot.data!['jobComments']
//                                                   [index]['name'],
//                                           commentBody:
//                                               snapshot.data!['jobComments']
//                                                   [index]['commentBody'],
//                                           commenterImageUrl:
//                                               snapshot.data!['jobComments']
//                                                   [index]['userImageUrl'],
//                                         );
//                                       },
//                                       separatorBuilder: (context, index) =>
//                                           const Divider(
//                                         thickness: 1,
//                                         color: Colors.grey,
//                                       ),
//                                       itemCount:
//                                           snapshot.data!['jobComments'].length,
//                                     );
//                                   }
//                                 }
//                               },
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _JobDetailsBetaScreenState extends State<JobDetailsBetaScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isCommenting = false;

  final TextEditingController _commentController = TextEditingController();

  String? authorName;
  String? userImageUrl;
  String? jobCategory;
  String? jobDescription;
  String? jobSalary;
  String? jobTitle;
  bool? recruitment;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadlineDateTimeStamp;
  String? emailCompany;
  String? postedDate;
  //String? deadlineDate;
  String? locationCompany = '';
  String? jobStyle;
  int applicants = 0;
  bool isDeadlineAvailable = false;
  bool showComment = false;
  DateTime? deadlineDateTime;
  String? jobLocation;

  void getJobData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uploadedBy)
        .get();

    if (userDoc == null) {
      return;
    } else {
      setState(() {
        authorName = userDoc.get('name');
        userImageUrl = userDoc.get('userImage');
      });
    }
    final DocumentSnapshot jobDatabase = await FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobID)
        .get();

    if (jobDatabase == null) {
      return;
    } else {
      setState(() {
        jobTitle = jobDatabase.get('jobTitle');
        jobDescription = jobDatabase.get('jobDescription');
        jobSalary = jobDatabase.get('jobSalary');
        recruitment = jobDatabase.get('recruitment');
        emailCompany = jobDatabase.get('email');
        locationCompany = jobDatabase.get('location');
        applicants = jobDatabase.get('applicants');
        postedDateTimeStamp = jobDatabase.get('createAt');
        deadlineDateTimeStamp = jobDatabase.get('deadlineDateTimeStamp');
        //deadlineDate = jobDatabase.get('deadlineDate');
        var postDate = postedDateTimeStamp!.toDate();
        postedDate = '${postDate.year} - ${postDate.month} - ${postDate.day}';
        jobStyle = jobDatabase.get('jobStyle');
        jobLocation = jobDatabase.get('jobLocation');
      });

      var date = deadlineDateTimeStamp!.toDate();
      isDeadlineAvailable = date.isAfter(DateTime.now());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getJobData();
  }

  Widget dividerWidget() {
    return const Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Divider(
          thickness: 1,
          color: Colors.grey,
        )
      ],
    );
  }

  applyForJob() {
    final Uri params = Uri(
      scheme: 'mailto',
      path: emailCompany,
      query:
          'subject=Applying for $jobTitle&body=Hello,please attach Resume CV file',
    );
    final url = params.toString();
    launchUrlString(url);
    addNewApplicant();
  }

  void addNewApplicant() {
    var docRef = FirebaseFirestore.instance.collection('jobs').doc(widget.jobID);
    // Lấy thời gian hiện tại
    Timestamp currentTime = Timestamp.now();

    // Cập nhật số lượng ứng viên và thêm thời gian nộp đơn vào danh sách
    docRef.update({
      'applicants': FieldValue.increment(1), // Tăng số lượng ứng viên
      'applicationTimes': FieldValue.arrayUnion([currentTime]), // Thêm thời gian nộp đơn vào mảng
    }).then((_) {
      // Điều hướng tới JobDetailsScreen sau khi cập nhật thành công
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => JobDetailsBetaScreen(
            uploadedBy: widget.uploadedBy,
            jobID: widget.jobID,
            userID: widget.userID,
          ),
        ),
      );
    }).catchError((error) {
      // Xử lý lỗi nếu có
      print("Error updating document: $error");
    });
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            Navigator.of(ctx).pop();
          },
          child: Center(
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => UserJobScreen(userID: widget.userID)),
              );
            },
          ),
          actions: [
            if (FirebaseAuth.instance.currentUser!.uid == widget.uploadedBy)
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditJobBetaScreen(
                            uploadedBy: widget.uploadedBy,
                            jobID: widget.jobID,
                            userID: widget.userID)),
                  );
                },
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black38,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            (jobTitle ?? '').toUpperCase(),
                            maxLines: 3,
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showFullImage(userImageUrl ?? '');
                              },
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.grey,
                                  ),
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      userImageUrl ??
                                          'https://as2.ftcdn.net/v2/jpg/02/29/75/83/1000_F_229758328_7x8jwCwjtBMmC6rgFzLFhZoEpLobB6L8.jpg',
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authorName ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    locationCompany ?? '',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        dividerWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              applicants.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Người xin việc',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.how_to_reg_sharp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        if (FirebaseAuth.instance.currentUser!.uid ==
                            widget.uploadedBy)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              dividerWidget(),
                              const Text(
                                'Tuyển dụng',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      User? user = _auth.currentUser;
                                      final _uid = user!.uid;
                                      if (_uid == widget.uploadedBy) {
                                        try {
                                          FirebaseFirestore.instance
                                              .collection('jobs')
                                              .doc(widget.jobID)
                                              .update({'recruitment': true});
                                        } catch (error) {
                                          GlobalMethod.showErrorDialog(
                                            error:
                                                'Hành động không thể được thực hiện',
                                            ctx: context,
                                          );
                                        }
                                      } else {
                                        GlobalMethod.showErrorDialog(
                                            error:
                                                'Bạn không thể thực hiện hành động này',
                                            ctx: context);
                                      }
                                      getJobData();
                                    },
                                    child: const Text(
                                      'ON',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.green,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Opacity(
                                    opacity: recruitment == true ? 1 : 0,
                                    child: const Icon(
                                      Icons.check_box,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 40),
                                  TextButton(
                                    onPressed: () {
                                      User? user = _auth.currentUser;
                                      final _uid = user!.uid;
                                      if (_uid == widget.uploadedBy) {
                                        try {
                                          FirebaseFirestore.instance
                                              .collection('jobs')
                                              .doc(widget.jobID)
                                              .update({'recruitment': false});
                                        } catch (error) {
                                          GlobalMethod.showErrorDialog(
                                            error:
                                                'Hành động không thể được thực hiện',
                                            ctx: context,
                                          );
                                        }
                                      } else {
                                        GlobalMethod.showErrorDialog(
                                            error:
                                                'Bạn không thể thực hiện hành động này',
                                            ctx: context);
                                      }
                                      getJobData();
                                    },
                                    child: const Text(
                                      'OFF',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.red,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Opacity(
                                    opacity: recruitment == false ? 1 : 0,
                                    child: const Icon(
                                      Icons.check_box,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        dividerWidget(),
                        const Text(
                          'Địa điểm',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          jobLocation ?? 'Địa điểm chưa được điền',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.yellow,
                          ),
                        ),
                        dividerWidget(),
                        const Text(
                          'Mô tả công việc',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          jobDescription ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.yellow,
                          ),
                        ),
                        dividerWidget(),
                        const Text(
                          'Mức lương cho công việc',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          jobSalary != null
                              ? '$jobSalary\$'
                              : 'Mức lương chưa được điền',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.yellow,
                          ),
                        ),
                        dividerWidget(),
                        const Text(
                          'Loại công việc',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          jobStyle ?? 'Loại công việc chưa được điền',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.yellow,
                          ),
                        ),
                        dividerWidget(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black38,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            isDeadlineAvailable
                                ? 'Tích cực tuyển dụng, Gửi CV/Tiếp tục'
                                : 'Hạn công việc đã qua',
                            style: TextStyle(
                              color: isDeadlineAvailable
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (FirebaseAuth.instance.currentUser!.uid !=
                            widget.uploadedBy)
                          Center(
                            child: MaterialButton(
                              onPressed: () async {
                                applyForJob();
                              },
                              color: Colors.blueAccent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text(
                                  'Ứng Tuyển Công Việc',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        dividerWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tải lên vào ngày: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              postedDate ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Hạn công việc vào ngày: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              deadlineDateTimeStamp != null
                                  ? DateFormat('yyyy - MM - dd').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          deadlineDateTimeStamp!
                                              .millisecondsSinceEpoch))
                                  : 'Chưa có hạn chót',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        dividerWidget(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black38,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: _isCommenting
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      flex: 3,
                                      child: TextField(
                                        controller: _commentController,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        maxLength: 200,
                                        keyboardType: TextInputType.text,
                                        maxLines: 6,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white)),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.pink)),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: MaterialButton(
                                              onPressed: () async {
                                                if (_commentController
                                                        .text.length <
                                                    7) {
                                                  GlobalMethod.showErrorDialog(
                                                    error:
                                                        'Bình luận không thể nhỏ hơn 7 ký tự',
                                                    ctx: context,
                                                  );
                                                } else {
                                                  final _generatedId =
                                                      Uuid().v4();
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('jobs')
                                                      .doc(widget.jobID)
                                                      .update({
                                                    'jobComments':
                                                        FieldValue.arrayUnion([
                                                      {
                                                        'userId': FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid,
                                                        'commentId':
                                                            _generatedId,
                                                        'name': name,
                                                        'userImageUrl':
                                                            userImage,
                                                        'commentBody':
                                                            _commentController
                                                                .text,
                                                        'time': Timestamp.now(),
                                                      }
                                                    ]),
                                                  });
                                                  await Fluttertoast.showToast(
                                                      msg:
                                                          'Bình luận của bạn đã được đăng',
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      backgroundColor:
                                                          Colors.grey,
                                                      fontSize: 18);
                                                  _commentController.clear();
                                                }
                                                setState(() {
                                                  showComment = true;
                                                });
                                              },
                                              color: Colors.blueAccent,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Đăng',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _isCommenting = !_isCommenting;
                                                showComment = false;
                                              });
                                            },
                                            child: const Text('Hủy'),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _isCommenting = !_isCommenting;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.add_comment,
                                        color: Colors.blueAccent,
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          showComment = true;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.arrow_drop_down_circle,
                                        color: Colors.blueAccent,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        if (showComment)
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('jobs')
                                  .doc(widget.jobID)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else {
                                  if (!snapshot.hasData ||
                                      snapshot.data == null ||
                                      snapshot.data!['jobComments'] == null ||
                                      (snapshot.data!['jobComments'] as List)
                                          .isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'Không có bình luận cho công việc này',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    );
                                  } else {
                                    return ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return CommentsWidget(
                                          commentId:
                                              snapshot.data!['jobComments']
                                                  [index]['commentId'],
                                          commenterId:
                                              snapshot.data!['jobComments']
                                                  [index]['userId'],
                                          commenterName:
                                              snapshot.data!['jobComments']
                                                  [index]['name'],
                                          commentBody:
                                              snapshot.data!['jobComments']
                                                  [index]['commentBody'],
                                          commenterImageUrl:
                                              snapshot.data!['jobComments']
                                                  [index]['userImageUrl'],
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          const Divider(
                                        thickness: 1,
                                        color: Colors.grey,
                                      ),
                                      itemCount:
                                          snapshot.data!['jobComments'].length,
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
