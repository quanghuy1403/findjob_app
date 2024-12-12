import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Persistent/persistent.dart';
import '../Search/search_job.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/job_widget.dart';

class JobScreen extends StatefulWidget {
  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  List<String> selectedJobCategories = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _showTaskCategoriesDialog({required Size size}) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                  itemCount: PersistentBeta.jobCategoryListWithSalary.length,
                  itemBuilder: (ctx, index) {
                    final category =
                        PersistentBeta.jobCategoryListWithSalary[index];
                    final isSelected = selectedJobCategories.contains(category);
                    return CheckboxListTile(
                      title: Text(
                        category,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedJobCategories.add(category);
                          } else {
                            selectedJobCategories.remove(category);
                          }
                        });
                      },
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
                    'Đóng',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedJobCategories.clear();
                    });
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.red, fontSize: 20),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(
                        () {}); // Update the state to reflect the selected categories
                    Navigator.pop(context); // Close the dialog
                    setState(
                        () {}); // Trigger a state update in the parent widget
                  },
                  child: const Text(
                    'Xác nhận',
                    style: TextStyle(color: Colors.green, fontSize: 20),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Call setState to refresh the jobs list after the dialog is closed
      setState(() {});
    });
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _getJobs() async {
    final collectionRef = FirebaseFirestore.instance
        .collection('jobs')
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) => snapshot.data()!,
          toFirestore: (data, _) => data,
        );

    Query<Map<String, dynamic>> query = collectionRef;

    // Apply recruitment filter
    query = query.where('recruitment', isEqualTo: true);

    // Determine if 'Làm việc Online' or 'Offline' is selected
    bool applyOnlineFilter = selectedJobCategories.contains('Làm việc Online');
    bool applyOfflineFilter =
        selectedJobCategories.contains('Làm việc Offline');

    if (applyOnlineFilter && applyOfflineFilter) {
      // If both Online and Offline are selected, get jobs that are either Online or Offline
      query = query.where('jobStyle', whereIn: ['Online', 'Offline']);
    } else if (applyOnlineFilter) {
      // If only Online is selected
      query = query.where('jobStyle', isEqualTo: 'Online');
    } else if (applyOfflineFilter) {
      // If only Offline is selected
      query = query.where('jobStyle', isEqualTo: 'Offline');
    }

    // Apply salary filters
    List<String> salaryCategories = selectedJobCategories
        .where((category) => category.startsWith('Mức lương'))
        .toList();
    if (salaryCategories.isNotEmpty) {
      for (var category in salaryCategories) {
        int minSalary = 0;
        int maxSalary = 999999999;
        if (category == 'Mức lương 0-4999\$') {
          minSalary = 1000;
          maxSalary = 5000;
        } else if (category == 'Mức lương trên 5000\$') {
          minSalary = 5000;
        }
        query = query
            .where('jobSalary', isGreaterThanOrEqualTo: minSalary.toString())
            .where('jobSalary', isLessThanOrEqualTo: maxSalary.toString());
      }
    }

    // Apply job category filters
    List<String> jobCategories = selectedJobCategories
        .where((category) =>
            !category.startsWith('Làm việc') &&
            !category.startsWith('Mức lương'))
        .toList();
    if (jobCategories.isNotEmpty) {
      query = query.where('jobCategory', whereIn: jobCategories);
    }

    // Execute query and return results ordered by createAt
    final querySnapshot =
        await query.orderBy('createAt', descending: true).get();
    //final querySnapshot = await query.get();

    return querySnapshot.docs;
  }

  @override
  void initState() {
    super.initState();
    Persistent persistentObject = Persistent();
    persistentObject.getMyData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBarForApp(indexNum: 0),
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'CÔNG VIỆC',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
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
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
          onPressed: () {
            _showTaskCategoriesDialog(size: size);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SearchScreen()),
              );
            },
            icon: const Icon(Icons.search_outlined, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepOrange.shade300, Colors.blueAccent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.2, 0.9],
          ),
        ),
        child: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          future: _getJobs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    var jobData = snapshot.data![index];
                    return JobWidget(
                      jobTitle: jobData['jobTitle'],
                      jobDescription: jobData['jobDescription'],
                      jobId: jobData['jobId'],
                      uploadedBy: jobData['uploadedBy'],
                      userImageUrl: jobData['userImage'],
                      name: jobData['name'],
                      recruitment: jobData['recruitment'],
                      email: jobData['email'],
                      location: jobData['location'],
                      jobSalary: jobData.data().containsKey('jobSalary')
                          ? jobData['jobSalary']
                          : 'Mức lương chưa được điền',
                      jobStyle: jobData.data().containsKey('jobStyle')
                          ? jobData['jobStyle']
                          : '',
                      deadlineDateTimeStamp: jobData['deadlineDateTimeStamp'],
                      createAt: jobData['createAt'],
                      jobCategory: jobData['jobCategory'],
                      jobLocation: jobData['jobLocation'],
                      //deadlineDate: jobData['deadlineDate'],
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text(
                    'Ở đây đang không có công việc nào',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
            }
            return const Center(
              child: Text(
                'Có gì đó sai ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
