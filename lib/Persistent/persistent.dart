import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Services/global_variables.dart';

class Persistent {
  static List<String> jobCategoryList = [
    'Kiến trúc và Xây dựng',
    'Giáo dục va Đào tạo',
    'Phát triển - Lập trình',
    'Việc kinh doanh',
    'Công nghệ thông tin',
    'Nguồn nhân lực',
    'Thiết kế',
    'Kế toán',
  ];

  void getMyData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    name = userDoc.get('name');
    userImage = userDoc.get('userImage');
    location = userDoc.get('location');
  }
}

class PersistentBeta extends Persistent {
  static List<String> jobCategoryListWithSalary = [
    'Kiến trúc và Xây dựng',
    'Giáo dục va Đào tạo',
    'Phát triển - Lập trình',
    'Việc kinh doanh',
    'Công nghệ thông tin',
    'Nguồn nhân lực',
    'Thiết kế',
    'Kế toán',
    'Làm việc Online',
    'Làm việc Offline',
    'Mức lương 0-4999\$',
    'Mức lương trên 5000\$',
  ];

  @override
  void getMyData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    name = userDoc.get('name');
    userImage = userDoc.get('userImage');
    location = userDoc.get('location');
    // Add additional functionality if needed for PersistentBeta
  }
}
