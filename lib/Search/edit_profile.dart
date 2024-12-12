import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../user_state.dart';
import 'profile_company.dart';

class EditProfileScreen extends StatefulWidget {
  final String userID;

  const EditProfileScreen({required this.userID});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _name;
  String _email = '';
  String _phoneNumber = '';
  String _location = '';
  String _imageUrl = '';
  File? imageFile;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get();

      if (userDoc.exists) {
        setState(() {
          _name = userDoc.get('name');
          _phoneNumber = userDoc.get('phoneNumber');
          _location = userDoc.get('location');
          _imageUrl = userDoc.get('userImage');
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        // Update the user's profile picture if a new one is selected
        if (imageFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child('${widget.userID}.jpg');
          await storageRef.putFile(imageFile!);
          _imageUrl = await storageRef.getDownloadURL();
        }

        // Update the user's data in the users collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userID)
            .update({
          'name': _name,
          'phoneNumber': _phoneNumber,
          'location': _location,
          'userImage': _imageUrl,
        });

        // Fetch and update the user's jobs in the jobs collection
        final QuerySnapshot jobsSnapshot = await FirebaseFirestore.instance
            .collection('jobs')
            .where('uploadedBy', isEqualTo: widget.userID)
            .get();

        for (final job in jobsSnapshot.docs) {
          await job.reference.update({
            'name': _name,
            'location': _location,
            'userImage': _imageUrl,
          });
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ProfileScreen(userID: widget.userID)),
        ); // Navigate back to ProfileScreen
      } catch (error) {
        print('Error updating user data: $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteUserAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Delete the user's data from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .delete();

      // Delete the user's jobs from the jobs collection
      final QuerySnapshot jobsSnapshot = await FirebaseFirestore.instance
          .collection('jobs')
          .where('uploadedBy', isEqualTo: widget.userID)
          .get();

      for (final job in jobsSnapshot.docs) {
        await job.reference.delete();
      }

      // Delete the user's profile picture from Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${widget.userID}.jpg');

      try {
        await storageRef.delete();
      } catch (e) {
        print('Error deleting user image: $e');
      }

      // Delete the user account from FirebaseAuth
      User? user = _auth.currentUser;
      await user?.delete();

      // Navigate to UserState screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UserState()),
      );
    } catch (error) {
      print('Error deleting user account: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chọn ảnh'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  _getFromCamera();
                },
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.camera,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      'Camera',
                      style: TextStyle(
                        color: Colors.purple,
                      ),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  _getFromGallery();
                },
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.image,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      'Thư viện',
                      style: TextStyle(
                        color: Colors.purple,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _getFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _cropImage(pickedFile.path);
    }
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _cropImage(pickedFile.path);
    }
    Navigator.pop(context);
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
          backgroundColor: Colors.transparent,
          title: Text(
            'CHỈNH SỬA THÔNG TIN',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileScreen(userID: widget.userID)),
              );
            },
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: imageFile != null
                              ? FileImage(imageFile!)
                              : (_imageUrl.isNotEmpty
                                  ? NetworkImage(_imageUrl)
                                  : null) as ImageProvider?,
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          child: _imageUrl.isEmpty && imageFile == null
                              ? Icon(Icons.person, size: 60)
                              : null,
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            _showImageDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text(
                            'Chọn ảnh',
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          initialValue: _name,
                          key: ValueKey('name'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Vui lòng nhập tên của bạn';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _name = value!;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Tên',
                              hintText: 'Nhập tên của bạn',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              )),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          initialValue: _phoneNumber,
                          key: ValueKey('phoneNumber'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Vui lòng nhập số điện thoại';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _phoneNumber = value!;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Số điện thoại',
                              hintText: 'Nhập số điện thoại của bạn',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              )),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          initialValue: _location,
                          key: ValueKey('location'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Vui lòng nhập địa chỉ';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _location = value!;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Địa chỉ',
                              hintText: 'Nhập địa chỉ của bạn',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              )),
                        ),
                        const SizedBox(height: 50),
                        ElevatedButton.icon(
                          onPressed: _updateUserProfile,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text('Lưu thay đổi',
                              style: TextStyle(
                                fontSize: 14,
                              )),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // OutlinedButton(
                        //   onPressed: _deleteUserAccount,
                        //   icon: const Icon(Icons.delete, color: Colors.red),
                        //   style: OutlinedButton.styleFrom(
                        //     side: BorderSide(color: Colors.red),
                        //   ),
                        //   child: const Text(
                        //     'Xóa tài khoản',
                        //     style: TextStyle(color: Colors.red),
                        //   ),
                        // ),
                        OutlinedButton(
                          onPressed: _deleteUserAccount,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Xóa tài khoản',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
