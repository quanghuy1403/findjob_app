import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';
import '../Persistent/persistent.dart';
import '../Services/global_method.dart';
import '../Widgets/bottom_nav_bar.dart';

class CVScreen extends StatefulWidget {
  const CVScreen({super.key});

  @override
  _CVScreenState createState() => _CVScreenState();
}

class _CVScreenState extends State<CVScreen> {
  String? selectedJobCategory;
  File? imageFile;
  bool showError = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? cvimageUrl;

  Future <void > _validateFormAndGeneratePdf() async {
    setState(() {
      showError = true; // Kích hoạt hiển thị lỗi khi nhấn "Tạo CV"
    });

    if (phoneController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        facebookController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        selectedJobCategory != null &&
        goalController.text.isNotEmpty &&
        imageFile != null) {
      _generatePdf(); // Chỉ tạo CV khi tất cả các trường đã được điền
    }
  }

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController goalController = TextEditingController();

  bool hasExperience = false;
  List<Map<String, TextEditingController>> workExperienceControllers = [];
  void updateHasExperience() {
    hasExperience = workExperienceControllers.any((controllers) =>
        controllers.values.any((controller) => controller.text.isNotEmpty));
  }

  bool hasEducation = false;
  List<Map<String, TextEditingController>> educationControllers = [];
  void updateHasEducation() {
    hasEducation = educationControllers.any((controllers) =>
        controllers.values.any((controller) => controller.text.isNotEmpty));
  }

  bool hasSkill = false;
  List<Map<String, TextEditingController>> skillsController = [];
  void updateHasSkill() {
    hasSkill = skillsController.any((controllers) =>
        controllers.values.any((controller) => controller.text.isNotEmpty));
  }

  bool hasHobby = false;
  List<Map<String, TextEditingController>> hobbyController = [];
  void updateHasHobby() {
    hasHobby = hobbyController.any((controllers) =>
        controllers.values.any((controller) => controller.text.isNotEmpty));
  }

  bool hasCertificate = false;
  List<Map<String, TextEditingController>> certificateController = [];
  void updateHasCertificate() {
    hasCertificate = certificateController.any((controllers) =>
        controllers.values.any((controller) => controller.text.isNotEmpty));
  }

  bool hasActivity = false;
  List<Map<String, TextEditingController>> activitiesController = [];
  void updateHasActivity() {
    hasActivity = activitiesController.any((controllers) =>
        controllers.values.any((controller) => controller.text.isNotEmpty));
  }

  bool hasReferee = false;
  List<Map<String, TextEditingController>> refereeController = [];
  void updateHasReferee() {
    hasReferee = refereeController.any((controllers) =>
        controllers.values.any((controller) => controller.text.isNotEmpty));
  }

  bool hasAward = false;
  List<Map<String, TextEditingController>> awardsController = [];
  void updateHasAward() {
    hasAward = awardsController.any((controllers) =>
        controllers.values.any((controller) => controller.text.isNotEmpty));
  }

  bool hasProject = false;
  List<Map<String, TextEditingController>> projectController = [];

  void updateHasProject() {
    hasProject = projectController.any((controllers) =>
        controllers.values.any((controller) => controller.text.isNotEmpty));
  }

  @override
  void dispose(){
    super.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    facebookController.dispose();
    nameController.dispose();
    goalController.dispose();

    for (var map in workExperienceControllers) {
      // Duyệt qua từng TextEditingController trong Map và gọi dispose()
      for (var controller in map.values) {
        controller.dispose();
      }
    }
    for (var map in educationControllers) {
      // Duyệt qua từng TextEditingController trong Map và gọi dispose()
      for (var controller in map.values) {
        controller.dispose();
      }
    }
    for (var map in skillsController) {
      // Duyệt qua từng TextEditingController trong Map và gọi dispose()
      for (var controller in map.values) {
        controller.dispose();
      }
    }
    for (var map in hobbyController) {
      // Duyệt qua từng TextEditingController trong Map và gọi dispose()
      for (var controller in map.values) {
        controller.dispose();
      }
    }
    for (var map in certificateController) {
      // Duyệt qua từng TextEditingController trong Map và gọi dispose()
      for (var controller in map.values) {
        controller.dispose();
      }
    }
    for (var map in activitiesController) {
      // Duyệt qua từng TextEditingController trong Map và gọi dispose()
      for (var controller in map.values) {
        controller.dispose();
      }
    }
    for (var map in refereeController) {
      // Duyệt qua từng TextEditingController trong Map và gọi dispose()
      for (var controller in map.values) {
        controller.dispose();
      }
    }
    for (var map in awardsController) {
      // Duyệt qua từng TextEditingController trong Map và gọi dispose()
      for (var controller in map.values) {
        controller.dispose();
      }
    }
    for (var map in projectController) {
      // Duyệt qua từng TextEditingController trong Map và gọi dispose()
      for (var controller in map.values) {
        controller.dispose();
      }
    }

  }

  void _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _cropImage(pickedFile.path);
    }
  }

  void _cropImage(String filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 1080,
      maxWidth: 1080,
    );

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void _deleteImage() {
    setState(() {
      imageFile = null;
    });
  }

  void clearAllControllers() {
    workExperienceControllers.forEach((map) => map.values.forEach((controller) => controller.clear()));
    educationControllers.forEach((map) => map.values.forEach((controller) => controller.clear()));
    skillsController.forEach((map) => map.values.forEach((controller) => controller.clear()));
    hobbyController.forEach((map) => map.values.forEach((controller) => controller.clear()));
    certificateController.forEach((map) => map.values.forEach((controller) => controller.clear()));
    activitiesController.forEach((map) => map.values.forEach((controller) => controller.clear()));
    refereeController.forEach((map) => map.values.forEach((controller) => controller.clear()));
    awardsController.forEach((map) => map.values.forEach((controller) => controller.clear()));
    projectController.forEach((map) => map.values.forEach((controller) => controller.clear()));
    imageFile = null;
  }

  Future<void> _generatePdf() async {
    updateHasExperience();
    updateHasEducation();
    updateHasSkill();
    updateHasHobby();
    updateHasCertificate();
    updateHasActivity();
    updateHasReferee();
    updateHasAward();
    updateHasProject();
    final pdf = pw.Document();
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    // tạo một file pdf
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children:   [
              pw.Row(
                children: [
                  pw.Text('Số điện thoại: ${phoneController.text}', style: pw.TextStyle(font: ttf)),
                  pw.SizedBox(width: 10),
                  pw.Text('Email: ${emailController.text}', style: pw.TextStyle(font: ttf)),
                  pw.SizedBox(width: 10),
                  pw.Text('Địa chỉ: ${addressController.text}', style: pw.TextStyle(font: ttf)),
                  pw.SizedBox(width: 10),
                  pw.Text('Facebook: ${facebookController.text}', style: pw.TextStyle(font: ttf)),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start, // Space items evenly
                children: [
                  pw.Container(
                    width: 180,
                    height: 690,
                    color: PdfColors.yellow, // Set background color to yellow
                    child: pw.Padding(
                        padding: const pw.EdgeInsets.all(12.0),
                        child:  pw.Container(
                            width: 160,
                            height: 670,
                            child: pw.Column(
                              children: [
                                (imageFile != null)
                                    ? pw.Image(
                                  width: 130,
                                  height: 130,
                                  pw.MemoryImage(imageFile!.readAsBytesSync()),
                                  fit: pw.BoxFit.cover,
                                )
                                    : pw.Container(
                                  width: 130,
                                  height: 130,
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(color: PdfColors.grey, width: 1),
                                  ),
                                  child: pw.Center(
                                    child: pw.Text(
                                      'Ảnh',
                                      style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.white), // Change text color to white for contrast
                                    ),
                                  ),
                                ),
                                pw.SizedBox(height: 8),
                                pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start, // Space items evenly
                                    children: [
                                      pw.Text('${nameController.text}', style: pw.TextStyle(font: ttf,fontSize: 20)),
                                      pw.SizedBox(height: 8),
                                      pw.Text('${selectedJobCategory ?? ''}', style: pw.TextStyle(font: ttf)),
                                      pw.Divider(thickness: 0.5, color: PdfColors.black),
                                    ]
                                ),
                                // học vấn
                                  pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        if(hasEducation)
                                          pw.Text('Học vấn:', style: pw.TextStyle(font: ttf)),
                                          for (var controllers in educationControllers) ...[
                                              pw.Column(
                                                children: [
                                                  pw.Row(
                                                      children: [
                                                        pw.SizedBox(width: 12),
                                                        pw.Column(
                                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                          children: [
                                                            pw.Row(
                                                              children: [
                                                                pw.Text('${controllers['schoolname']!.text}', style: pw.TextStyle(font: ttf, fontSize: 10)),
                                                                pw.SizedBox(width: 30),
                                                                pw.Text('${controllers['schoolstart']!.text} - ${controllers['schoolend']!.text}', style: pw.TextStyle(font: ttf, fontSize: 10)),
                                                              ],
                                                            ),
                                                            pw.Column(
                                                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                              children: [
                                                                pw.Text('Ngành: ${controllers['major']!.text}', style: pw.TextStyle(font: ttf,fontSize: 10)),
                                                                pw.Row(
                                                                  children: [
                                                                    pw.Text('Tốt nghiệp bằng ${controllers['typecertificate']!.text}', style: pw.TextStyle(font: ttf,fontSize: 10)),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            pw.SizedBox(height: 10),
                                                          ],
                                                        ),
                                                      ]
                                                  ),
                                                ],
                                              ),
                                            ],
                                          pw.Divider(thickness: 0.5, color: PdfColors.black),
                                      ]
                                  ),
                                // các kĩ năng
                                  pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        if(hasSkill)
                                          pw.Text('Các kỹ năng: ', style: pw.TextStyle(font: ttf)),
                                          for (var controllers in skillsController) ...[
                                              pw.Column(
                                                children: [
                                                  pw.Text('* ${controllers['typeskill']!.text}', style: pw.TextStyle(font: ttf, fontSize: 10)),
                                                ],
                                              ),
                                            ],
                                          pw.Divider(thickness: 0.5, color: PdfColors.black),
                                      ]
                                  ),
                                // chứng chỉ
                                  pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                          if(hasCertificate)
                                            pw.Text('Chứng chỉ:', style: pw.TextStyle(font: ttf)),
                                            for (var controllers in certificateController) ...[
                                              pw.Column(
                                                children: [
                                                  pw.Row(
                                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                    children: [
                                                      pw.SizedBox(width: 10),
                                                      pw.Text('${controllers['yearcertificate']!.text}: ', style: pw.TextStyle(font: ttf, fontSize: 10)),
                                                      pw.Text('${controllers['namecertificate']!.text}', style: pw.TextStyle(font: ttf, fontSize: 10)),
                                                    ],
                                                  ),
                                                  pw.SizedBox(width: 30),
                                                ],
                                              ),
                                            ],
                                            pw.Divider(thickness: 0.5, color: PdfColors.black),
                                      ]
                                  ),
                                // Hoạt động
                                  pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                          if(hasActivity)
                                            pw.Text('Hoạt động:', style: pw.TextStyle(font: ttf)),
                                            for (var controllers in activitiesController) ...[
                                              pw.Column(
                                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                children: [
                                                  pw.Row(
                                                    children: [
                                                      pw.SizedBox(width: 10),
                                                      pw.Text(
                                                        controllers['yearactivity']?.text ?? 'Chưa có năm hoạt động', // Fallback text if null
                                                        style: pw.TextStyle(font: ttf, fontSize: 10),
                                                      ),
                                                      pw.SizedBox(width: 10),
                                                      pw.Text(
                                                        controllers['nameactivity']?.text ?? 'Chưa có tên hoạt động', // Fallback text if null
                                                        style: pw.TextStyle(font: ttf, fontSize: 10),
                                                      ),
                                                    ],
                                                  ),
                                                  pw.SizedBox(height: 5)
                                                ],
                                              ),
                                            ],
                                            pw.Divider(thickness: 0.5, color: PdfColors.black),
                                      ]
                                  ),
                                // sở thích
                                  pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                          if(hasHobby)
                                            pw.Text('Sở thích: ', style: pw.TextStyle(font: ttf)),
                                            for (var controllers in hobbyController) ...[
                                              pw.Column(
                                                children: [
                                                  pw.Text('* ${controllers['namehobby']!.text}', style: pw.TextStyle(font: ttf, fontSize: 10)),
                                                ],
                                              ),
                                            ],
                                            pw.Divider(thickness: 0.5, color: PdfColors.black),
                                      ]
                                  ),
                                //   người giới thiệu
                                  pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                          if(hasReferee)
                                            pw.Text('Người giới thiệu:', style: pw.TextStyle(font: ttf)),
                                            for (var controllers in refereeController) ...[
                                              pw.Row(
                                                  children: [
                                                    pw.SizedBox(width: 10),
                                                    pw.Column(
                                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                      children: [
                                                        pw.Text(
                                                          controllers['namereferee']?.text ?? 'Chưa có tên người giới thiệu', // Fallback text if null
                                                          style: pw.TextStyle(font: ttf, fontSize: 10),
                                                        ),
                                                        pw.Row(
                                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                          children: [
                                                            pw.Text("số điện thoại: ",style: pw.TextStyle(font: ttf,fontSize: 10)),
                                                            pw.Text(
                                                              controllers['phonereferee']?.text ?? 'Chưa có số điện thoại', // Fallback text if null
                                                              style: pw.TextStyle(font: ttf, fontSize: 10),
                                                            ),
                                                          ],
                                                        ),
                                                        pw.SizedBox(height: 5),
                                                      ],
                                                    ),
                                                  ]
                                              ),
                                            ],
                                            pw.Divider(thickness: 0.5, color: PdfColors.black),
                                      ]
                                  ),
                                //   danh hiệu và giải thưởng
                                  pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                          if(hasAward)
                                            pw.Text('Danh hiệu và giải thưởng:', style: pw.TextStyle(font: ttf)),
                                            for (var controllers in awardsController) ...[
                                            pw.Column(
                                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                                              children: [

                                                pw.Row(
                                                  children: [
                                                    pw.SizedBox(width: 20),
                                                    pw.Text(
                                                      controllers['yearaward']?.text ?? '', // Fallback text if null
                                                      style: pw.TextStyle(font: ttf, fontSize: 10),
                                                    ),
                                                    pw.SizedBox(width: 5),
                                                    pw.Text(
                                                      controllers['nameaward']?.text ?? 'Chưa có tên', // Fallback text if null
                                                      style: pw.TextStyle(font: ttf, fontSize: 10),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                      ]
                                  ),
                              ],
                            )
                        )
                    ),
                  ),
                  pw.Container(
                      width: 330,
                      height: 690,
                      // color: PdfColors.red,
                      child: pw.Padding(
                          padding: pw.EdgeInsets.all(12.0),
                          child: pw.Container(
                              width: 310,
                              height: 670,
                              child: pw.Column(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  children: [
                                    // Mục tiêu làm việc
                                    pw.Column(
                                        mainAxisAlignment: pw.MainAxisAlignment.start,
                                        children:   [
                                          if(goalController.text.isNotEmpty)...[
                                            pw.Row(
                                              mainAxisAlignment: pw.MainAxisAlignment.start,
                                              children: [
                                                  pw.Text('Mục tiêu nghề nghiệp', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold,fontSize: 15,color: PdfColors.green)),
                                                pw.SizedBox(width: 20),
                                                pw.Align(
                                                  alignment: pw.Alignment.center,
                                                  child: pw.Container(
                                                    width: 170,
                                                    child: pw.Divider(thickness: 1, color: PdfColors.green),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            pw.SizedBox(height: 5),
                                            pw.Container(
                                              width: 330,
                                              child: pw.Text('${goalController!.text}', style: pw.TextStyle(font: ttf)),
                                            ),
                                            pw.SizedBox(height: 5),
                                          ]
                                        ]
                                    ),

                                    // Kinh nghiệm làm việc
                                    pw.Column(
                                        mainAxisAlignment: pw.MainAxisAlignment.start,
                                        children:   [
                                          if(hasExperience)
                                            pw.Row(
                                              mainAxisAlignment: pw.MainAxisAlignment.start,
                                              children: [
                                                pw.Text('Kinh nghiệm làm việc', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold,fontSize: 15,color: PdfColors.green)),
                                                pw.SizedBox(width: 20),
                                                pw.Align(
                                                  alignment: pw.Alignment.center,
                                                  child: pw.Container(
                                                    width: 170,
                                                    child: pw.Divider(thickness: 1, color: PdfColors.green),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          pw.Column(
                                            children: [
                                              pw.Column(
                                                children: [
                                                  for (var controllers in workExperienceControllers) ...[
                                                    pw.Row(
                                                      children:[
                                                        pw.Column(
                                                          mainAxisAlignment: pw.MainAxisAlignment.start,
                                                          children: [
                                                            pw.Row(
                                                              children: [
                                                                pw.Text('Làm ${controllers['jobname']!.text} tại ', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                                                                pw.Text('${controllers['companyname']!.text}', style: pw.TextStyle(font: ttf)),
                                                                pw.SizedBox(width: 50),
                                                                pw.Text('${controllers['datebegin']!.text} - ${controllers['dateend']!.text}', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                                                              ],
                                                            ),
                                                            pw.SizedBox(height: 5),
                                                            pw.Container(
                                                              width: 310,
                                                              child: pw.Text('${controllers['discustion']!.text}', style: pw.TextStyle(font: ttf,fontSize: 11)),
                                                            ),
                                                            pw.SizedBox(width: 10),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    pw.SizedBox(height: 10),
                                                  ],
                                                ],
                                              ),

                                            ],
                                          )
                                        ]
                                    ),

                                    // Dự án
                                    pw.Column(
                                        mainAxisAlignment: pw.MainAxisAlignment.start,
                                        children:   [
                                            if(hasProject)
                                              pw.Row(
                                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                                children: [
                                                    pw.Text('Dự án:', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold,fontSize: 15,color: PdfColors.green)),
                                                    pw.SizedBox(width: 20),
                                                    pw.Align(
                                                      alignment: pw.Alignment.center,
                                                      child: pw.Container(
                                                        width: 170,
                                                        child: pw.Divider(thickness: 1, color: PdfColors.green),
                                                      ),
                                                    ),
                                                  ],
                                              ),
                                            pw.Column(
                                                children: [
                                                  pw.Column(
                                                    children: [
                                                      for (var controllers in projectController) ...[
                                                        pw.Row(
                                                          children:[
                                                            pw.Column(
                                                              mainAxisAlignment: pw.MainAxisAlignment.start,
                                                              children: [
                                                                pw.Row(
                                                                  children: [
                                                                    pw.Text('Dự án ${controllers['projectname']!.text}', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                                                                    pw.SizedBox(width: 50),
                                                                    pw.Text('${controllers['dateprojectbegin']!.text} - ${controllers['dateprojectend']!.text}', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                                                                  ],
                                                                ),
                                                                pw.SizedBox(height: 5),
                                                                pw.Text('Số lượng thành viên: ${controllers['numbermember']!.text}', style: pw.TextStyle(font: ttf)),
                                                                pw.SizedBox(height: 5),
                                                                pw.Container(
                                                                  width: 310,
                                                                  child: pw.Text('${controllers['projectdiscustion']!.text}', style: pw.TextStyle(font: ttf,fontSize: 11)),
                                                                ),
                                                                pw.SizedBox(width: 10),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        pw.SizedBox(height: 10),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                            )
                                        ]
                                    ),
                                  ]
                              )
                          )
                      )
                  )
                ],
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> _uploadFirebase() async {
    final cvId = Uuid().v4();
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('User is not logged in');
      return;
    }

    final uid = user.uid;
    final ref = FirebaseStorage.instance.ref().child('usercvImages').child('$uid.jpg');
    await ref.putFile(imageFile!);
    cvimageUrl = await ref.getDownloadURL();

    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance.collection('cvs').doc(cvId).set({
          'uid': uid,
          'cvid': cvId,
          'phone': phoneController.text,
          'email': emailController.text,
          'address': addressController.text,
          'facebook': facebookController.text,
          'name': nameController.text,
          'goal': goalController.text,
          'jobCategory': selectedJobCategory,
          'usercvImages': cvimageUrl,
          'workExperience': workExperienceControllers.map((controllers) {
            return {
              'jobname': controllers['jobname']?.text ?? '',
              'datebegin': controllers['datebegin']?.text ?? '',
              'dateend': controllers['dateend']?.text ?? '',
              'companyname': controllers['companyname']?.text ?? '',
              'discustion': controllers['discustion']?.text ?? '',
            };
          }).toList(),
          'education': educationControllers.map((controllers) {
            return {
              'major': controllers['major']?.text ?? '',
              'schoolstart': controllers['schoolstart']?.text ?? '',
              'schoolend': controllers['schoolend']?.text ?? '',
              'typecertificate': controllers['typecertificate']?.text ?? '',
            };
          }).toList(),
          'skill': skillsController.map((controllers) {
            return {
              'typeskill': controllers['typeskill']?.text ?? '',
            };
          }).toList(),
          'hobby': hobbyController.map((controllers) {
            return {
              'namehobby': controllers['namehobby']?.text ?? '',
            };
          }).toList(),
          'certificate': certificateController.map((controllers) {
            return {
              'namecertificate': controllers['namecertificate']?.text ?? '',
              'yearcertificate': controllers['yearcertificate']?.text ?? '',
            };
          }).toList(),
          'activities': activitiesController.map((controllers) {
            return {
              'nameactivity': controllers['nameactivity']?.text ?? '',
              'yearactivity': controllers['yearactivity']?.text ?? '',
            };
          }).toList(),
          'referee': refereeController.map((controllers) {
            return {
              'namereferee': controllers['namereferee']?.text ?? '',
              'phonereferee': controllers['phonereferee']?.text ?? '',
            };
          }).toList(),
          'award': awardsController.map((controllers) {
            return {
              'nameaward': controllers['nameaward']?.text ?? '',
              'yearaward': controllers['yearaward']?.text ?? '',
            };
          }).toList(),
          'project': projectController.map((controllers) {
            return {
              'projectname': controllers['projectname']?.text ?? '',
              'dateprojectbegin': controllers['dateprojectbegin']?.text ?? '',
              'dateprojectend': controllers['dateprojectend']?.text ?? '',
              'numbermember': controllers['numbermember']?.text ?? '',
              'projectdiscustion': controllers['projectdiscustion']?.text ?? '',
            };
          }).toList(),
        });

        if (kDebugMode) {
          print('cvId: $cvId');
        } // In ra cvId để kiểm tra
        await Fluttertoast.showToast(
          msg: 'Tạo CV thành công',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18,
        );

        phoneController.clear();
        emailController.clear();
        addressController.clear();
        facebookController.clear();
        nameController.clear();
        goalController.clear();
        setState(() {
          selectedJobCategory = 'Vị trí ứng tuyển';
          clearAllControllers();
        });
      } catch (error) {
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Form is not valid');
    }
  }


  void _addExperience() {
    setState(() {
      workExperienceControllers.add({
        'jobname': TextEditingController(),
        'datebegin': TextEditingController(),
        'dateend': TextEditingController(),
        'companyname': TextEditingController(),
        'discustion': TextEditingController(),
      });
    });
  }

  void _addEducation() {
    setState(() {
      educationControllers.add({
        'major': TextEditingController(),
        'schoolstart': TextEditingController(),
        'schoolend': TextEditingController(),
        'typecertificate': TextEditingController(),
        'schoolname': TextEditingController(),
      });
    });
  }

  void _addSkill() {
    setState(() {
      skillsController.add({
        'typeskill': TextEditingController(),
      });
    });
  }

  void _addHobby() {
    setState(() {
      hobbyController.add({
        'namehobby': TextEditingController(),
      });
    });
  }

  void _addCertificate() {
    setState(() {
      certificateController.add({
        'namecertificate': TextEditingController(),
        'yearcertificate': TextEditingController(),
      });
    });
  }

  void _addActivity() {
    setState(() {
      activitiesController.add({
        'nameactivity': TextEditingController(),
        'yearactivity': TextEditingController(), // Ensure all expected keys are initialized
      });
    });
  }

  void _addReferee() {
    setState(() {
      refereeController.add({
        'namereferee': TextEditingController(),
        'phonereferee': TextEditingController(), // Ensure all expected keys are initialized
      });
    });
  }

  void _addAward() {
    setState(() {
      awardsController.add({
        'nameaward': TextEditingController(),
        'yearaward': TextEditingController(), // Ensure all expected keys are initialized
      });
    });
  }

  void _addProject() {
    setState(() {
      projectController.add({
        'projectname': TextEditingController(),
        'dateprojectbegin': TextEditingController(),
        'dateprojectend': TextEditingController(),
        'numbermember': TextEditingController(),
        'projectdiscustion': TextEditingController(),
      });
    });
  }

  void _removeExperience(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc muốn xóa không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Có'),
            ),
          ],
        );
      },
    );

    if (confirmDelete ?? false) {
      setState(() {
        workExperienceControllers.removeAt(index);
      });
    }
  }

  void _removeEducation(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc muốn xóa không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Có'),
            ),
          ],
        );
      },
    );

    if (confirmDelete ?? false) {
      setState(() {
        educationControllers.removeAt(index);
      });
    }
  }

  void _removeSkill(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc muốn xóa không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Có'),
            ),
          ],
        );
      },
    );

    if (confirmDelete ?? false) {
      setState(() {
        skillsController.removeAt(index);
      });
    }
  }

  void _removeHobby(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc muốn xóa không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Có'),
            ),
          ],
        );
      },
    );

    if (confirmDelete ?? false) {
      setState(() {
        hobbyController.removeAt(index);
      });
    }
  }

  void _removeCertificate(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc muốn xóa không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Có'),
            ),
          ],
        );
      },
    );

    if (confirmDelete ?? false) {
      setState(() {
        certificateController.removeAt(index);
      });
    }
  }

  void _removeActivity(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc muốn xóa không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Có'),
            ),
          ],
        );
      },
    );

    if (confirmDelete ?? false) {
      setState(() {
        activitiesController.removeAt(index);
      });
    }
  }

  void _removeReferee(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc muốn xóa không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Có'),
            ),
          ],
        );
      },
    );

    if (confirmDelete ?? false) {
      setState(() {
        refereeController.removeAt(index);
      });
    }
  }

  void _removeAward(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc muốn xóa không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Có'),
            ),
          ],
        );
      },
    );

    if (confirmDelete ?? false) {
      setState(() {
        awardsController.removeAt(index);
      });
    }
  }

  void _removeProject(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc muốn xóa không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Có'),
            ),
          ],
        );
      },
    );

    if (confirmDelete ?? false) {
      setState(() {
        projectController.removeAt(index);
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
          stops: const [0.2, 0.9],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Mẫu CV'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 1),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildContactField(Icons.phone, 'Số điện thoại', phoneController),
                    const SizedBox(height: 16),
                    buildContactField(Icons.email, 'Email', emailController),
                    const SizedBox(height: 16),
                    buildContactField(Icons.location_on, 'Địa chỉ', addressController),
                    const SizedBox(height: 16),
                    buildContactField(Icons.facebook, 'Facebook', facebookController),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildErrorTextField('Tên của bạn', nameController),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Vị trí ứng tuyển',
                                  border: OutlineInputBorder(),
                                ),
                                items: Persistent.jobCategoryList.map((String job) {
                                  return DropdownMenuItem<String>(
                                    value: job,
                                    child: Text(job),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedJobCategory = newValue;
                                  });
                                },
                                value: Persistent.jobCategoryList.contains(selectedJobCategory) ? selectedJobCategory : null,
                              )

                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: imageFile == null
                              ? IconButton(
                            icon: const Icon(Icons.person),
                            onPressed: _getFromGallery,
                          )
                              : GestureDetector(
                            onTap: _deleteImage,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(imageFile!, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    buildTextField('Mục tiêu', goalController),
                    const SizedBox(height: 16),
                    Text("Kinh nghiệm làm việc"),
                    ...workExperienceControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      var controllers = entry.value;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 1100,
                          height: 430,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    const Text("Tên công việc: "),
                                    Expanded(
                                      child: buildTextField('Tên Công việc', controllers['jobname']!),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text("Thời gian bắt đầu: "),
                                    Expanded(child: buildTextField('Thời gian bắt đầu', controllers['datebegin']!)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text("Thời gian kết thúc: "),
                                    Expanded(child: buildTextField('Thời gian kết thúc', controllers['dateend']!)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text("Tên công ty: "),
                                    Expanded(child: buildTextField('Tên công ty', controllers['companyname']!)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text("Mô tả: "),
                                    Expanded(child: buildTextField('Mô tả ', controllers['discustion']!)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeExperience(index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    TextButton(onPressed: _addExperience, child: const Text("Thêm")),
                    const SizedBox(height: 16),
                    Text('Học vấn'),
                    ...educationControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      var controllers = entry.value;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 1100,
                          height: 430,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    const Text("Tên ngành: "),
                                    Expanded(
                                      child: buildTextField('Tên ngành', controllers['major']!),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text("Thời gian bắt đầu: "),
                                    Expanded(child: buildTextField('Thời gian bắt đầu', controllers['schoolstart']!)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text("Thời gian kết thúc: "),
                                    Expanded(child: buildTextField('Thời gian kết thúc', controllers['schoolend']!)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text("Bằng tốt Nghiêp : "),
                                    Expanded(child: buildTextField('Bằng tốt nghiệp', controllers['typecertificate']!)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text("Tên trường : "),
                                    Expanded(child: buildTextField('Tên trường', controllers['schoolname']!)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeEducation(index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    TextButton(onPressed: _addEducation, child: const Text("Thêm")),
                    const SizedBox(height: 16),
                    Text('Các kỹ năng'),
                    ...skillsController.asMap().entries.map((entry) {
                      int index = entry.key;
                      var controllers = entry.value;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 1100,
                          height: 160,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    const Text("Tên kỹ năng: "),
                                    Expanded(
                                      child: buildTextField('Tên kỹ năng', controllers['typeskill']!),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeSkill(index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    TextButton(onPressed: _addSkill, child: const Text("Thêm")),
                    const SizedBox(height: 16),
                    Text('Chứng chỉ'),
                    ...certificateController.asMap().entries.map((entry) {
                      int index = entry.key;
                      var controllers = entry.value;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 1100,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    const Text("Tên chứng chỉ: "),
                                    Expanded(
                                      child: buildTextField('Tên chứng chỉ', controllers['namecertificate']!),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text("Năm nhận: "),
                                    Expanded(
                                      child: buildTextField('Năm nhận', controllers['yearcertificate']!),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeCertificate(index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    TextButton(onPressed: _addCertificate, child: const Text("Thêm")),
                    const SizedBox(height: 16),
                    Text('Dự án'),
                    ...projectController.asMap().entries.map((entry) {
                      int index = entry.key;
                      var controllers = entry.value;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 1100,
                          height: 430,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    const Text("Tên Dự án: "),
                                    Expanded(
                                      child: buildTextField('Tên dự án', controllers['projectname']!),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text("Thời gian bắt đầu: "),
                                    Expanded(child: buildTextField('Thời gian bắt đầu', controllers['dateprojectbegin']!)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text("Thời gian kết thúc: "),
                                    Expanded(child: buildTextField('Thời gian kết thúc', controllers['dateprojectend']!)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text("Số lượng thành viên: "),
                                    Expanded(child: buildTextField('Số lượng thành viên', controllers['numbermember']!)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text("Mô tả dự án: "),
                                    Expanded(child: buildTextField('Mô tả dự án', controllers['projectdiscustion']!)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeProject(index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    TextButton(onPressed: _addProject, child: const Text("Thêm")),
                    const SizedBox(height: 16),
                    Text('Hoạt động'),
                    ...activitiesController.asMap().entries.map((entry) {
                      int index = entry.key;
                      var controllers = entry.value;

                      final nameController = controllers['nameactivity'];
                      final yearController = controllers['yearactivity'];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 1100,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    const Text("Tên hoạt động: "),
                                    Expanded(
                                      child: buildTextField('Tên hoạt động', nameController!),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text("Năm hoạt động: "),
                                    Expanded(
                                      child: buildTextField('Năm hoạt động', yearController!),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeActivity(index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    TextButton(onPressed: _addActivity, child: const Text("Thêm")),
                    const SizedBox(height: 16),
                    Text('Sở thích'),
                    ...hobbyController.asMap().entries.map((entry) {
                      int index = entry.key;
                      var controllers = entry.value;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 1100,
                          height: 160,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    const Text("Tên Sở thích: "),
                                    Expanded(
                                      child: buildTextField('Tên sở thích', controllers['namehobby']!),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeHobby(index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    TextButton(onPressed: _addHobby, child: const Text("Thêm")),
                    const SizedBox(height: 16),
                    Text('Người giới thiệu'),
                    ...refereeController.asMap().entries.map((entry) {
                      int index = entry.key;
                      var controllers = entry.value;

                      final refereenameController = controllers['namereferee'] as TextEditingController?;
                      final referreephoneController = controllers['phonereferee'] as TextEditingController?;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 1100,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    const Text("Tên người giới thiệu: "),
                                    Expanded(
                                      child: buildTextField('Tên người giới thiệu', refereenameController ?? TextEditingController()),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text("Số điện thoại: "),
                                    Expanded(
                                      child: buildTextField('Số điện thoại', referreephoneController ?? TextEditingController()),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeReferee(index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    TextButton(onPressed: _addReferee, child: const Text("Thêm")),
                    const SizedBox(height: 16),
                    Text('Danh hiệu và giải thưởng'),
                    ...awardsController.asMap().entries.map((entry) {
                      int index = entry.key;
                      var controllers = entry.value;

                      final awardnameController = controllers['nameaward'] as TextEditingController?;
                      final awardyearController = controllers['yearaward'] as TextEditingController?;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 1100,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    const Text("Tên giải thưởng: "),
                                    Expanded(
                                      child: buildTextField('Tên giải thưởng', awardnameController ?? TextEditingController()),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text("Năm nhận: "),
                                    Expanded(
                                      child: buildTextField('Năm nhận', awardyearController ?? TextEditingController()),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeAward(index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    TextButton(onPressed: _addAward, child: const Text("Thêm")),
                    const SizedBox(height: 20),
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()  // Hiển thị CircularProgressIndicator khi đang tải
                          : ElevatedButton(
                        onPressed: () async {
                          // Gọi cả hai hàm
                          await _validateFormAndGeneratePdf();
                          await _uploadFirebase();
                        },
                        child: const Text("Tạo CV"),
                      ),
                    )
                  ],
                ),
            )
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget buildErrorTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(8),
        errorText: showError && controller.text.isEmpty ? '' : null,
        errorStyle: TextStyle(color: Colors.red, fontSize: 10), // Đặt màu đỏ cho cảnh báo
      ),
    );
  }

  Widget buildContactField(IconData icon, String label, TextEditingController controller) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 4),
        Flexible(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
              contentPadding: const EdgeInsets.all(8),
              errorText: showError && controller.text.isEmpty ? 'Mục này đang bị để trống' : null,
              errorStyle: TextStyle(color: Colors.red), // Đặt màu đỏ cho cảnh báo
            ),
          ),
        ),
      ],
    );
  }
}