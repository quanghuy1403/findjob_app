// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:findjob_app/Jobs/jobs_screen.dart';
// import 'package:findjob_app/Widgets/job_widget.dart';
// import 'package:flutter/material.dart';
//
// class SearchScreen extends StatefulWidget {
//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _searchQueryController = TextEditingController();
//   String searchQuery = '';
//   String searchField = 'jobTitle'; // Default search field
//
//   Widget _buildSearchField() {
//     return TextField(
//       controller: _searchQueryController,
//       autocorrect: true,
//       decoration: const InputDecoration(
//         hintText: 'Tìm kiếm...',
//         border: InputBorder.none,
//         hintStyle: TextStyle(
//           color: Colors.white,
//         ),
//       ),
//       style: const TextStyle(
//         color: Colors.white,
//         fontSize: 16,
//       ),
//       onChanged: (query) => updateSearchQuery(query),
//     );
//   }
//
//   List<Widget> _buildActions() {
//     return <Widget>[
//       DropdownButton<String>(
//         value: searchField,
//         dropdownColor: Colors.black,
//         items: const [
//           DropdownMenuItem(
//             value: 'jobTitle',
//             child: Text(
//               'Tên',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//           DropdownMenuItem(
//             value: 'location',
//             child: Text(
//               'Vị trí',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//           DropdownMenuItem(
//             value: 'jobSalary',
//             child: Text(
//               'Lương',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//         onChanged: (value) {
//           setState(() {
//             searchField = value!;
//           });
//         },
//       ),
//       IconButton(
//         icon: const Icon(Icons.clear, color: Colors.white),
//         onPressed: () {
//           _clearSearchQuery();
//         },
//       ),
//     ];
//   }
//
//   void _clearSearchQuery() {
//     setState(() {
//       _searchQueryController.clear();
//       updateSearchQuery('');
//     });
//   }
//
//   void updateSearchQuery(String newQuery) {
//     setState(() {
//       searchQuery = newQuery.toLowerCase();
//     });
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
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => JobScreen()),
//               );
//             },
//             icon: Icon(Icons.arrow_back, color: Colors.white),
//           ),
//           title: _buildSearchField(),
//           actions: _buildActions(),
//         ),
//         body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//           stream: FirebaseFirestore.instance
//               .collection('jobs')
//               .where('recruitment', isEqualTo: true)
//               .snapshots(),
//           builder: (context, AsyncSnapshot snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             } else if (snapshot.connectionState == ConnectionState.active) {
//               if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
//                 var filteredDocs = snapshot.data!.docs.where((doc) {
//                   var jobData = doc.data() as Map<String, dynamic>;
//                   var matchesSearchQuery = jobData[searchField]
//                       .toString()
//                       .toLowerCase()
//                       .contains(searchQuery); // Sắp xếp theo ngày đăng
//                   return matchesSearchQuery;
//                 }).toList();
//
//                 return ListView.builder(
//                   itemCount: filteredDocs.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     var jobData = filteredDocs[index];
//                     var jobDataMap = jobData.data() as Map<String, dynamic>;
//                     return JobWidget(
//                       jobTitle: jobDataMap['jobTitle'],
//                       jobDescription: jobDataMap['jobDescription'],
//                       jobId: jobDataMap['jobId'],
//                       uploadedBy: jobDataMap['uploadedBy'],
//                       userImageUrl: jobDataMap['userImage'],
//                       name: jobDataMap['name'],
//                       recruitment: jobDataMap['recruitment'],
//                       email: jobDataMap['email'],
//                       location: jobDataMap['location'],
//                       jobSalary: jobDataMap.containsKey('jobSalary')
//                           ? jobDataMap['jobSalary']
//                           : 'Mức lương chưa được điền',
//                       jobStyle: jobDataMap['jobStyle'],
//                       deadlineDateTimeStamp:
//                           jobDataMap['deadlineDateTimeStamp'],
//                       createAt: jobDataMap['createAt'],
//                     );
//                   },
//                 );
//               } else {
//                 return const Center(
//                   child: Text('Không có công việc'),
//                 );
//               }
//             }
//             return const Center(
//               child: Text(
//                 'Có gì đó sai sai ở đây',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 30,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findjob_app/Jobs/jobs_screen.dart';
import 'package:findjob_app/Widgets/job_widget.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = '';
  String searchField = 'jobTitle'; // Default search field

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: const InputDecoration(
        hintText: 'Tìm kiếm...',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    return <Widget>[
      DropdownButton<String>(
        borderRadius: BorderRadius.circular(8),
        value: searchField,
        dropdownColor: Colors.blueGrey,
        items: const [
          DropdownMenuItem(
            value: 'jobTitle',
            child: Text(
              'Tên',
              style: TextStyle(color: Colors.white),
            ),
          ),
          DropdownMenuItem(
            value: 'jobLocation',
            child: Text(
              'Địa điểm',
              style: TextStyle(color: Colors.white),
            ),
          ),
          DropdownMenuItem(
            value: 'jobSalary',
            child: Text(
              'Lương',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            searchField = value!;
          });
        },
      ),
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.white),
        onPressed: () {
          _clearSearchQuery();
        },
      ),
    ];
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery('');
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery.toLowerCase();
    });
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
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => JobScreen()),
              );
            },
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: _buildSearchField(),
          actions: _buildActions(),
        ),
        body: searchQuery.isEmpty
            ? // Hiển thị 2 công việc gợi ý khi không có nội dung tìm kiếm
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('jobs')
                    .where('recruitment', isEqualTo: true)
                    // .orderBy('createAt', descending: true)
                    .where('deadlineDateTimeStamp',
                        isGreaterThan: Timestamp.now())
                    .orderBy('deadlineDateTimeStamp', descending: true)
                    .limit(2)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData &&
                      snapshot.data!.docs.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Gợi ý công việc mới nhất:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            var jobData = snapshot.data!.docs[index];
                            var jobDataMap =
                                jobData.data() as Map<String, dynamic>;
                            return JobWidget(
                              jobTitle: jobDataMap['jobTitle'],
                              jobDescription: jobDataMap['jobDescription'],
                              jobId: jobDataMap['jobId'],
                              uploadedBy: jobDataMap['uploadedBy'],
                              userImageUrl: jobDataMap['userImage'],
                              name: jobDataMap['name'],
                              recruitment: jobDataMap['recruitment'],
                              email: jobDataMap['email'],
                              location: jobDataMap['location'],
                              jobSalary: jobDataMap.containsKey('jobSalary')
                                  ? jobDataMap['jobSalary']
                                  : 'Mức lương chưa được điền',
                              jobStyle: jobDataMap['jobStyle'],
                              deadlineDateTimeStamp:
                                  jobDataMap['deadlineDateTimeStamp'],
                              createAt: jobDataMap['createAt'],
                              jobCategory: jobDataMap['jobCategory'],
                              jobLocation: jobDataMap['jobLocation'],
                              //deadlineDate: jobDataMap['deadlineDate'],
                            );
                          },
                        ),
                      ],
                    );
                  } else {
                    return const Center(
                      child: Text('Không có công việc'),
                    );
                  }
                },
              )
            : // Hiển thị kết quả tìm kiếm khi có nội dung tìm kiếm
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('jobs')
                    .where('recruitment', isEqualTo: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.active) {
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      var filteredDocs = snapshot.data!.docs.where((doc) {
                        var jobData = doc.data() as Map<String, dynamic>;
                        var matchesSearchQuery = jobData[searchField]
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery);
                        return matchesSearchQuery;
                      }).toList();
                      return ListView.builder(
                        itemCount: filteredDocs.length,
                        itemBuilder: (BuildContext context, int index) {
                          var jobData = filteredDocs[index];
                          var jobDataMap =
                              jobData.data() as Map<String, dynamic>;
                          return JobWidget(
                            jobTitle: jobDataMap['jobTitle'],
                            jobDescription: jobDataMap['jobDescription'],
                            jobId: jobDataMap['jobId'],
                            uploadedBy: jobDataMap['uploadedBy'],
                            userImageUrl: jobDataMap['userImage'],
                            name: jobDataMap['name'],
                            recruitment: jobDataMap['recruitment'],
                            email: jobDataMap['email'],
                            location: jobDataMap['location'],
                            jobSalary: jobDataMap.containsKey('jobSalary')
                                ? jobDataMap['jobSalary']
                                : 'Mức lương chưa được điền',
                            jobStyle: jobDataMap['jobStyle'],
                            deadlineDateTimeStamp:
                                jobDataMap['deadlineDateTimeStamp'],
                            createAt: jobDataMap['createAt'],
                            jobCategory: jobDataMap['jobCategory'],
                            jobLocation: jobDataMap['jobLocation'],
                            //deadlineDate: jobDataMap['deadlineDate'],
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text('Không có công việc'),
                      );
                    }
                  }
                  return const Center(
                    child: Text(
                      'Có gì đó sai ở đây',
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
