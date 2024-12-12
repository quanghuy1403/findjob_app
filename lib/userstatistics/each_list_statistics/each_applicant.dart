import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EachApplicant extends StatefulWidget {
  final String jobID;

  const EachApplicant({super.key, required this.jobID});

  @override
  State<EachApplicant> createState() => _EachApplicantState();
}

class _EachApplicantState extends State<EachApplicant> {
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

    // Retrieve only the specific job with the given jobID
    DocumentSnapshot jobSnapshot =
    await firestore.collection('jobs').doc(widget.jobID).get();

    Map<String, int> applicantsByDate = {};
    DateTime latestDate = DateTime.now();

    // Check if the job document exists and contains 'applicationTimes'
    if (jobSnapshot.exists) {
      var data = jobSnapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('applicationTimes')) {
        List<dynamic> applicationTimes = data['applicationTimes'] ?? [];

        // Process each application time
        for (var time in applicationTimes) {
          DateTime applicationTime = (time as Timestamp).toDate();
          String dateKey =
              '${applicationTime.year}-${applicationTime.month.toString().padLeft(2, '0')}-${applicationTime.day.toString().padLeft(2, '0')}';

          // Update the latest application date
          if (applicationTime.isAfter(latestDate)) {
            latestDate = applicationTime;
          }

          // Count applicants by date
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

    lastDateWithApplicants = latestDate;

    List<BarChartGroupData> chartData = [];
    DateTime startDate = latestDate.subtract(Duration(days: 6));

    // Prepare chart data for the past 7 days
    for (int i = 0; i <= 6; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      String dateKey =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';

      int applicantsCount = applicantsByDate[dateKey] ?? 0;

      chartData.add(
        BarChartGroupData(
          x: i,
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
                  show: false,
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
                        DateTime date = lastDateWithApplicants!
                            .subtract(Duration(days: (6 - value.toInt())));
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
