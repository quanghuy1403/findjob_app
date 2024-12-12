import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EachComments extends StatefulWidget {
  final String jobID; // Job ID for the specific job

  const EachComments({super.key, required this.jobID});

  @override
  State<EachComments> createState() => _EachCommentsState();
}

class _EachCommentsState extends State<EachComments> {
  List<BarChartGroupData> barGroups = [];
  bool isLoading = true;
  int maxCommenters = 0;
  DateTime? lastDateWithComments;

  @override
  void initState() {
    super.initState();
    fetchCommentData();
  }

  Future<void> fetchCommentData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Query for comments related to the specific jobID
    DocumentSnapshot jobSnapshot = await firestore.collection('jobs').doc(widget.jobID).get();

    Map<String, int> commentersByDate = {}; // Sử dụng int để đếm số lượng commenterID

    DateTime latestDate = DateTime.now();

    if (jobSnapshot.exists) {
      var data = jobSnapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('jobComments')) {
        List<dynamic> jobComments = data['jobComments'] ?? [];

        for (var comment in jobComments) {
          // Đảm bảo comment là Map<String, dynamic>
          if (comment is Map<String, dynamic>) {
            DateTime jobComments = (comment['time'] as Timestamp).toDate();
            String dateKey = '${jobComments.year}-${jobComments.month.toString().padLeft(2, '0')}-${jobComments.day.toString().padLeft(2, '0')}';

            // Đếm số lượng commenterID cho mỗi ngày
            commentersByDate[dateKey] = (commentersByDate[dateKey] ?? 0) + 1;
          }
        }
      }
    }

    // Prepare data for chart
    List<BarChartGroupData> chartData = [];
    DateTime startDate = latestDate.subtract(Duration(days: 6)); // Show the last 7 days

    for (int i = 0; i <= 6; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      String dateKey = '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
      int commenterCount = commentersByDate[dateKey] ?? 0;

      if (commenterCount > maxCommenters) {
        maxCommenters = commenterCount;
      }

      chartData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              fromY: 0,
              toY: commenterCount.toDouble(),
              color: Colors.yellow,
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
    int maxY = (maxCommenters * 3).ceil(); // Y-axis scale
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
                        DateTime date = DateTime.now().subtract(Duration(days: (6 - value.toInt())));
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
