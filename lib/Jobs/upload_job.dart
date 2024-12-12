import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findjob_app/Services/global_method.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import '../Persistent/persistent.dart';
import '../Services/global_variables.dart';
import '../Widgets/bottom_nav_bar.dart';

class UploadJobNow extends StatefulWidget {
  const UploadJobNow({super.key});

  @override
  State<UploadJobNow> createState() => _UploadJobNowState();
}

class _UploadJobNowState extends State<UploadJobNow> {
  final TextEditingController _jobCategoryController = TextEditingController(text: 'Kiến trúc và Xây dựng');
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobDecriptionController = TextEditingController();
  final TextEditingController _jobSalaryController = TextEditingController();
  final TextEditingController _jobLocationController = TextEditingController();
  final List<String> _jobStyle = ['Offline', 'Online'];
  String _selectedJobStyle = 'Offline';
  final TextEditingController _datelineDateController =
      TextEditingController(text: 'Ngày đến hạn công việc');

  final _formKey = GlobalKey<FormState>();
  DateTime? picked;
  Timestamp? deadlineDateTimeStamp;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _jobCategoryController.dispose();
    _jobTitleController.dispose();
    _jobDecriptionController.dispose();
    _jobSalaryController.dispose();
    _jobLocationController.dispose();
    _datelineDateController.dispose();
  }

  Widget _textTitles({required String label}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _textFormFields({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'Dữ liệu đang bị thiếu';
            }
            return null;
          },
          controller: controller,
          enabled: enabled,
          key: Key(valueKey),
          style: const TextStyle(
            color: Colors.white,
          ),
          maxLines: valueKey == 'Mô tả công việc' ? 3 : 1,
          maxLength: maxLength,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.black54,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  _showTaskCategoriesDialog({required Size size}) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: const Text(
              'Các mục công việc',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Persistent.jobCategoryList.length,
                itemBuilder: (ctx, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _jobCategoryController.text =
                            Persistent.jobCategoryList[index];
                      });
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_right_alt_outlined,
                          color: Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            Persistent.jobCategoryList[index],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: const Text(
                    'Hủy',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                  ))
            ],
          );
        });
  }

  void _pickDateDialog() async {
    picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 0)),
        lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        _datelineDateController.text =
            '${picked!.year} - ${picked!.month} - ${picked!.day}';
        deadlineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(
            picked!.microsecondsSinceEpoch);
      });
    }
  }

  void _uploadTask() async {
    final jobId = Uuid().v4();
    User? user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      if (_datelineDateController.text == 'Hãy chọn hạn cho công việc' ||
          _jobCategoryController.text == 'Hãy chọn mục công việc') {
        GlobalMethod.showErrorDialog(
            error: 'Hãy chọn mọi thứ cần chọn', ctx: context);
        return;
      }

      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance.collection('jobs').doc(jobId).set({
          'jobId': jobId,
          'uploadedBy': uid,
          'email': user.email,
          'jobTitle': _jobTitleController.text,
          'jobDescription': _jobDecriptionController.text,
          'jobLocation': _jobLocationController.text,
          'deadlineDate': _datelineDateController.text,
          'deadlineDateTimeStamp': deadlineDateTimeStamp,
          'jobCategory': _jobCategoryController.text,
          'jobSalary': _jobSalaryController.text,
          'jobStyle': _selectedJobStyle,
          'jobComments': [],
          'recruitment': true,
          'createAt': Timestamp.now(),
          'name': name,
          'userImage': userImage,
          'location': location,
          'applicants': 0,
        });
        await Fluttertoast.showToast(
          msg: 'Mục này đã được đăng lên',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18,
        );
        _jobTitleController.clear();
        _jobSalaryController.clear();
        _jobDecriptionController.clear();
        _jobLocationController.clear();
        setState(() {
          _jobCategoryController.text = 'Hãy chọn mục việc làm';
          _datelineDateController.text = 'Chọn hạn làm việc';
          _selectedJobStyle = 'Online';
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Nó không hợp lệ');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

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
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 2),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white10,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(1),
                        child: Text(
                          'ĐĂNG CÔNG VIỆC',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _textTitles(label: 'Các mục công việc: '),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: TextFormField(
                                key: ValueKey('Các mục công việc'),
                                controller: _jobCategoryController,
                                enabled: true,
                                readOnly: true,
                                onTap: () {
                                  _showTaskCategoriesDialog(size: size);
                                },
                                maxLength: 100,
                                decoration: const InputDecoration(
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  suffixIcon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                  filled: true,
                                  fillColor: Colors.black54,
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            _textTitles(
                              label: 'Tiêu đề công việc: ',
                            ),
                            _textFormFields(
                              valueKey: 'Tiêu đề công việc',
                              controller: _jobTitleController,
                              enabled: true,
                              fct: () {},
                              maxLength: 100,
                            ),
                            _textTitles(
                              label: 'Địa điểm công việc: ',
                            ),
                            _textFormFields(
                              valueKey: 'Địa điểm công việc',
                              controller: _jobLocationController,
                              enabled: true,
                              fct: () {},
                              maxLength: 100,
                            ),
                            _textTitles(
                              label: 'Mô tả công việc: ',
                            ),
                            _textFormFields(
                              valueKey: 'Mô tả công việc',
                              controller: _jobDecriptionController,
                              enabled: true,
                              fct: () {},
                              maxLength: 100,
                            ),
                            _textTitles(
                              label: 'Mức lương cho công việc: ',
                            ),
                            _textFormFields(
                              valueKey: 'Mức lương cho công việc',
                              controller: _jobSalaryController,
                              enabled: true,
                              fct: () {},
                              maxLength: 100,
                            ),
                            Row(
                              children: [
                                _textTitles(
                                  label: 'Loại công việc: ',
                                ),
                                const SizedBox(
                                  width: 30,
                                ),
                                DropdownButton<String>(
                                  value: _selectedJobStyle,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    //fontWeight: FontWeight.bold,
                                  ),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedJobStyle = newValue!;
                                    });
                                  },
                                  items: _jobStyle.map((style) {
                                    return DropdownMenuItem<String>(
                                      value: style,
                                      child: Text(style),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            _textTitles(
                              label: 'Ngày hạn công việc: ',
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: TextFormField(
                                key: ValueKey('Deadline'),
                                controller: _datelineDateController,
                                enabled: true, // Cho phép tương tác với form
                                readOnly:
                                    true, // Ngăn người dùng nhập liệu nhưng vẫn cho phép nhấn vào
                                onTap: () {
                                  _pickDateDialog();
                                },
                                maxLength: 100,
                                decoration: const InputDecoration(
                                  labelStyle: TextStyle(
                                      color: Colors
                                          .white), // Màu chữ trắng cho tiêu đề
                                  suffixIcon: Icon(Icons.arrow_drop_down,
                                      color: Colors
                                          .white), // Mũi tên xuống màu trắng
                                  filled: true, // Bật nền cho form
                                  fillColor: Colors.black54, // Nền đen
                                  enabledBorder: UnderlineInputBorder(
                                    // Đường viền dưới khi không được chọn
                                    borderSide: BorderSide(
                                        color: Colors.white,
                                        width: 1), // Đậm màu trắng
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    // Đường viền dưới khi được chọn
                                    borderSide: BorderSide(
                                        color: Colors.blueAccent,
                                        width:
                                            1.5), // Đậm hơn và đổi màu khi chọn
                                  ),
                                  errorBorder: UnderlineInputBorder(
                                    // Đường viền khi có lỗi
                                    borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 1.5), // Màu đỏ khi có lỗi
                                  ),
                                  focusedErrorBorder: UnderlineInputBorder(
                                    // Đường viền khi chọn vào và có lỗi
                                    borderSide: BorderSide(
                                        color: Colors.redAccent, width: 1.5),
                                  ),
                                ),
                                style: const TextStyle(
                                    color: Colors.white), // Màu chữ trắng
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng chọn hạn công việc'; // Thông báo lỗi khi chưa chọn ngày
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : MaterialButton(
                                onPressed: () {
                                  _uploadTask();
                                },
                                color: Colors.black,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Đăng Ngay',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(width: 9),
                                      Icon(
                                        Icons.upload_file,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
