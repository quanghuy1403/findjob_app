import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findjob_app/Jobs/job_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Jobs/userjobscreen.dart';

class EditJobBetaScreen extends StatefulWidget {
  final String uploadedBy;
  final String jobID;
  final String userID;

  const EditJobBetaScreen({
    super.key,
    required this.uploadedBy,
    required this.jobID,
    required this.userID,
  });

  @override
  State<EditJobBetaScreen> createState() => _EditJobScreenState();
}

// class _EditJobScreenState extends State<EditJobBetaScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   DateTime? picked;
//   String? jobDescription;
//   String? jobSalary;
//   String? jobStyle;
//   String? deadlineDate;
//   TextEditingController _deadlineDateController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//   }
//
//   void _pickDateDialog() async {
//     DateTime initialDate = DateTime.now();
//     if (deadlineDate != null && deadlineDate!.isNotEmpty) {
//       List<String> dateParts = deadlineDate!.split(' - ');
//       int year = int.parse(dateParts[0]);
//       int month = int.parse(dateParts[1]);
//       int day = int.parse(dateParts[2]);
//       initialDate = DateTime(year, month, day);
//     }
//
//     picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime.now().subtract(const Duration(days: 0)),
//       lastDate: DateTime(2100),
//     );
//
//     if (picked != null) {
//       if (picked!.isBefore(DateTime.now())) {
//         // Show alert dialog for invalid date
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text('Thông báo'),
//               content: Text('Ngày bạn chọn không hợp lệ. Vui lòng chọn ngày sau ngày hiện tại.'),
//               actions: <Widget>[
//                 TextButton(
//                   child: Text('OK'),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       } else {
//         setState(() {
//           _deadlineDateController.text =
//           '${picked!.year} - ${picked!.month} - ${picked!.day}';
//           deadlineDate = '${picked!.year} - ${picked!.month} - ${picked!.day}';
//         });
//       }
//     }
//   }
//
//   void _fetchUserData() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final DocumentSnapshot jobDoc = await FirebaseFirestore.instance
//           .collection('jobs')
//           .doc(widget.jobID)
//           .get();
//
//       if (jobDoc.exists) {
//         setState(() {
//           jobDescription = jobDoc.get('jobDescription');
//           jobSalary = jobDoc.get('jobSalary');
//           deadlineDate = jobDoc.get('deadlineDate');
//           jobStyle = jobDoc.get('jobStyle');
//           _deadlineDateController.text = deadlineDate ?? '';
//         });
//       }
//     } catch (error) {
//       print('Error fetching job data: $error');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _updateJobProfile() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       setState(() {
//         _isLoading = true;
//       });
//
//       try {
//         // Update the job's data in the jobs collection
//         await FirebaseFirestore.instance.collection('jobs').doc(widget.jobID).update({
//           'jobDescription': jobDescription,
//           'jobSalary': jobSalary,
//           'deadlineDate': deadlineDate,
//           'jobStyle': jobStyle
//         });
//
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => JobDetailsScreen(
//               uploadedBy: widget.uploadedBy,
//               jobID: widget.jobID,
//               userID: widget.userID,
//             ),
//           ),
//         ); // Navigate back to JobDetailsScreen
//       } catch (error) {
//         print('Error updating job data: $error');
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _deleteJob() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//
//       // Delete the user's jobs from the jobs collection
//       final QuerySnapshot jobsSnapshot = await FirebaseFirestore.instance
//           .collection('jobs')
//           .where('jobId', isEqualTo: widget.jobID)
//           .get();
//
//       for (final job in jobsSnapshot.docs) {
//         await job.reference.delete();
//       }
//       // Navigate to UserState screen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => UserJobScreen(userID: widget.userID)),
//       );
//     } catch (error) {
//       print('Error deleting user account: $error');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
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
//           backgroundColor: Colors.transparent,
//           title: Text(
//             'Chỉnh Sửa Thông Tin',
//             style: TextStyle(color: Colors.white),
//           ),
//           centerTitle: true,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => JobDetailsBetaScreen(
//                     uploadedBy: widget.uploadedBy,
//                     jobID: widget.jobID,
//                     userID: widget.userID,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         body: _isLoading
//             ? Center(child: CircularProgressIndicator())
//             : Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   TextFormField(
//                     initialValue: jobDescription,
//                     key: ValueKey('jobDescription'),
//                     validator: (value) {
//                       if (value!.isEmpty) {
//                         return 'Vui lòng nhập mô tả công việc của bạn';
//                       }
//                       return null;
//                     },
//                     onSaved: (value) {
//                       jobDescription = value!;
//                     },
//                     decoration: const InputDecoration(
//                       labelText: 'Mô tả công việc',
//                       hintText: 'Nhập mô tả công việc của bạn',
//                       labelStyle: TextStyle(color: Colors.white),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.white),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.white),
//                       ),
//                       errorBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.red),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     initialValue: jobSalary,
//                     key: ValueKey('jobSalary'),
//                     validator: (value) {
//                       if (value!.isEmpty) {
//                         return 'Vui lòng nhập mức lương của bạn';
//                       }
//                       return null;
//                     },
//                     onSaved: (value) {
//                       jobSalary = value!;
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'Mức lương',
//                       hintText: 'Nhập mức lương công của bạn',
//                       labelStyle: TextStyle(color: Colors.white),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.white),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.white),
//                       ),
//                       errorBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.red),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   DropdownButtonFormField<String>(
//                     value: jobStyle,
//                     items: ['Online', 'Offline'].map((style) {
//                       return DropdownMenuItem(
//                         value: style,
//                         child: Text(style),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         jobStyle = value;
//                       });
//                     },
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Vui lòng chọn loại công việc';
//                       }
//                       return null;
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'Loại công việc',
//                       labelStyle: TextStyle(color: Colors.white),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.white),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.white),
//                       ),
//                       errorBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.red),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: _deadlineDateController,
//                     readOnly: true,
//                     onTap: _pickDateDialog,
//                     key: ValueKey('deadlineDate'),
//                     validator: (value) {
//                       if (value!.isEmpty) {
//                         return 'Vui lòng nhập ngày đến hạn công việc';
//                       }
//                       return null;
//                     },
//                     decoration: const InputDecoration(
//                       labelText: 'Ngày đến hạn công việc',
//                       hintText: 'Nhập ngày đến hạn công việc của bạn',
//                       labelStyle: TextStyle(color: Colors.white),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.white),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.white),
//                       ),
//                       errorBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.red),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _updateJobProfile,
//                     child: const Text(
//                       'Lưu thay đổi',
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   OutlinedButton(
//                     onPressed: _deleteJob,
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(color: Colors.red),
//                     ),
//                     child: const Text(
//                       'Xóa việc làm',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class _EditJobScreenState extends State<EditJobBetaScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Job data
  String? jobDescription;
  String? jobSalary;
  String? jobStyle;
  Timestamp? deadlineDateTimeStamp;
  String? jobLocation;
  String? jobTitle;

  // Controllers
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _deadlineDateController = TextEditingController();
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  final TextEditingController _jobSalaryController = TextEditingController();
  final TextEditingController _jobLocation = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchJobData();
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _jobLocation.dispose();
    _jobDescriptionController.dispose();
    _jobSalaryController.dispose();
    _deadlineDateController.dispose();
    super.dispose();
  }

  void _fetchJobData() async {
    setState(() => _isLoading = true);
    try {
      final DocumentSnapshot jobDoc = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobID)
          .get();

      if (jobDoc.exists) {
        setState(() {
          jobTitle = jobDoc.get('jobTitle');
          jobDescription = jobDoc.get('jobDescription');
          jobSalary = jobDoc.get('jobSalary');
          deadlineDateTimeStamp = jobDoc.get('deadlineDateTimeStamp');
          jobStyle = jobDoc.get('jobStyle');
          jobLocation = jobDoc.get('jobLocation');

          _jobTitleController.text = jobTitle ?? '';
          _jobDescriptionController.text = jobDescription ?? '';
          _jobSalaryController.text = jobSalary ?? '';
          _jobLocation.text = jobLocation ?? '';
          _deadlineDateController.text = deadlineDateTimeStamp != null
              ? DateTime.fromMillisecondsSinceEpoch(
                      deadlineDateTimeStamp!.millisecondsSinceEpoch)
                  .toLocal()
                  .toString()
                  .split(' ')[0]
              : '';
        });
      }
    } catch (error) {
      _showErrorSnackBar('Lỗi khi tải dữ liệu: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _updateJobProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.jobID)
            .update({
          'jobTitle': _jobTitleController.text,
          'jobDescription': jobDescription,
          'jobSalary': jobSalary,
          'deadlineDateTimeStamp': deadlineDateTimeStamp,
          'jobStyle': jobStyle,
          'jobLocation': jobLocation,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => JobDetailsScreen(
              uploadedBy: widget.uploadedBy,
              jobID: widget.jobID,
              userID: widget.userID,
            ),
          ),
        );
      } catch (error) {
        _showErrorSnackBar('Lỗi khi cập nhật: $error');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteJob() async {
    bool shouldDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Xác nhận xóa'),
            content: Text('Bạn có chắc chắn muốn xóa công việc này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobID)
          .delete();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UserJobScreen(userID: widget.userID)),
      );
    } catch (error) {
      _showErrorSnackBar('Lỗi khi xóa công việc: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _pickDateDialog() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: deadlineDateTimeStamp != null
          ? DateTime.fromMillisecondsSinceEpoch(
              deadlineDateTimeStamp!.millisecondsSinceEpoch)
          : DateTime.now(),
      firstDate: DateTime(2000), // Cho phép chọn từ năm 2000
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _deadlineDateController.text =
            "${picked.year}-${picked.month}-${picked.day}";
        deadlineDateTimeStamp = Timestamp.fromDate(picked);
      });
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
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'CHỈNH SỬA THÔNG TIN',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => JobDetailsScreen(
                  uploadedBy: widget.uploadedBy,
                  jobID: widget.jobID,
                  userID: widget.userID,
                ),
              ),
            ),
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _jobTitleController, // Title field
                          label: 'Tiêu đề công việc',
                          hintText: 'Nhập tiêu đề công việc',
                          onSave: (value) {}, // No direct saving needed
                          validator: (value) => value!.isEmpty
                              ? 'Vui lòng nhập tiêu đề công việc'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _jobDescriptionController,
                          label: 'Mô tả công việc',
                          hintText: 'Nhập mô tả công việc của bạn',
                          onSave: (value) => jobDescription = value,
                          validator: (value) => value!.isEmpty
                              ? 'Vui lòng nhập mô tả công việc'
                              : null,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _jobLocation,
                          label: 'Địa điểm công việc',
                          hintText: 'Nhập địa điểm công việc',
                          onSave: (value) => jobLocation = value,
                          validator: (value) =>
                              value!.isEmpty ? 'Vui lòng nhập địa điểm' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _jobSalaryController,
                          label: 'Mức lương',
                          hintText: 'Nhập mức lương công việc',
                          onSave: (value) => jobSalary = value,
                          validator: (value) =>
                              value!.isEmpty ? 'Vui lòng nhập mức lương' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildDropdownField(
                          label: 'Loại công việc',
                          value: jobStyle,
                          items: ['Online', 'Offline'],
                          onChanged: (value) =>
                              setState(() => jobStyle = value),
                        ),
                        const SizedBox(height: 20),
                        _buildDateField(),
                        const SizedBox(height: 30),
                        _buildSaveButton(),
                        const SizedBox(height: 20),
                        _buildDeleteButton(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required FormFieldSetter<String> onSave,
    required FormFieldValidator<String> validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      onSaved: onSave,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _deadlineDateController,
      readOnly: true,
      onTap: _pickDateDialog,
      validator: (value) =>
          value!.isEmpty ? 'Vui lòng chọn ngày hết hạn' : null,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Ngày hết hạn',
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _updateJobProfile,
      icon: const Icon(Icons.save, color: Colors.white),
      label: const Text('Lưu thay đổi',
          style: TextStyle(
            fontSize: 14,
          )),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return OutlinedButton(
      onPressed: _deleteJob,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete, color: Colors.red),
          SizedBox(width: 5),
          Text(
            'Xóa tài khoản',
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
      ),
    );
  }

// Widget _buildDeleteButton() {
//   return ElevatedButton.icon(
//     onPressed: _deleteJob,
//     icon: Icon(Icons.delete, color: Colors.white),
//     label: Text('Xóa công việc'),
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Colors.red,
//       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//     ),
//   );
// }
}
