import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Applicantstatistics extends StatefulWidget {
  final String uid;

  const Applicantstatistics({super.key, required this.uid});

  @override
  State<Applicantstatistics> createState() => _ApplicantstatisticsState();
}

class _ApplicantstatisticsState extends State<Applicantstatistics> {
  List<BarChartGroupData> barGroups = [];
  bool isLoading = true;
  int maxApplicants = 0;
  DateTime? lastDateWithApplicants;

  @override
  void initState() {
    super.initState();
    fetchApplicantData();
  }

  Future<void> fetchApplicantData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore
        .collection('jobs')
        .where('uploadedBy', isEqualTo: widget.uid)
        .get();

    Map<String, int> applicantsByDate = {};
    DateTime latestDate = DateTime.now(); // Biến để lưu ngày có người apply gần nhất

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('applicationTimes')) {
        List<dynamic> applicationTimes = data['applicationTimes'] ?? [];

        for (var time in applicationTimes) {
          DateTime applicationTime = (time as Timestamp).toDate();
          String dateKey = '${applicationTime.year}-${applicationTime.month.toString().padLeft(2, '0')}-${applicationTime.day.toString().padLeft(2, '0')}';

          // Cập nhật ngày cuối cùng có người apply
          if (applicationTime.isAfter(latestDate)) {
            latestDate = applicationTime;
          }

          if (applicantsByDate.containsKey(dateKey)) {
            applicantsByDate[dateKey] = applicantsByDate[dateKey]! + 1;
            if (applicantsByDate[dateKey]! > maxApplicants) {
              maxApplicants = applicantsByDate[dateKey]!;
            }
          } else {
            applicantsByDate[dateKey] = 1;
            if (maxApplicants < 1) {
              maxApplicants = 1;
            }
          }
        }
      }
    }

    lastDateWithApplicants = latestDate; // Lưu lại ngày cuối cùng có người apply

    List<BarChartGroupData> chartData = [];
    DateTime startDate = latestDate.subtract(Duration(days: 6)); // Ngày bắt đầu là 6 ngày trước

    // Tạo các nhóm dữ liệu cho biểu đồ, từ ngày trước đến ngày sau ngày cuối cùng có dữ liệu
    for (int i = 0; i <= 6; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      String dateKey = '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';

      // Đảm bảo rằng trục X luôn hiển thị đúng cột với ngày thích hợp
      int applicantsCount = applicantsByDate[dateKey] ?? 0;

      chartData.add(
        BarChartGroupData(
          x: i,  // Giữ chỉ số tuần tự từ 0 đến 6, nhưng mỗi chỉ số tương ứng với một ngày cố định
          barRods: [
            BarChartRodData(
              fromY: 0,
              toY: applicantsCount.toDouble(),
              color: Colors.red,
              width: 16,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      );
    }

    setState(() {
      barGroups = chartData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    int maxY = (maxApplicants * 3).ceil();
    int stepY = 3;

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          isLoading
              ? CircularProgressIndicator()
              : Expanded(
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: false, // Ẩn lưới
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: stepY.toDouble(),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        // Tạo tên ngày cho trục X từ ngày nhỏ đến ngày lớn
                        DateTime date = lastDateWithApplicants!
                            .subtract(Duration(days: (6 - value.toInt()))); // Adjust to start from the first day
                        return Text(
                          '${date.month}-${date.day}',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(width: 1, color: Colors.black),
                    bottom: BorderSide(width: 1, color: Colors.black),
                  ),
                ),
                barGroups: barGroups,
                maxY: maxY.toDouble(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
