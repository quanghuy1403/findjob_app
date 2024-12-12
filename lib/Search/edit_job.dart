import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findjob_app/Jobs/job_details.dart';
import 'package:findjob_app/Jobs/jobs_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditJobScreen extends StatefulWidget {
  final String uploadedBy;
  final String jobID;
  final String userID;

  const EditJobScreen({
    Key? key,
    required this.uploadedBy,
    required this.jobID,
    required this.userID,
  }) : super(key: key);

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Job data
  String? jobTitle;
  String? jobDescription;
  String? jobSalary;
  String? jobStyle;
  Timestamp? deadlineDateTimeStamp;
  String? jobLocation;

  // Controllers
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  final TextEditingController _jobSalaryController = TextEditingController();
  final TextEditingController _jobLocation = TextEditingController();
  final TextEditingController _deadlineDateController = TextEditingController();

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
        MaterialPageRoute(builder: (_) => JobScreen()),
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
            'Xóa việc làm',
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
