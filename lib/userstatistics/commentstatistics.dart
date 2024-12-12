import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Commentstatistics extends StatefulWidget {
  final String uid; // Dành cho công việc mà người dùng tải lên

  // Constructor nhận vào uid và thông tin từ Firestore
  const Commentstatistics({super.key, required this.uid});

  @override
  _CommentstatisticsState createState() => _CommentstatisticsState();
}

class _CommentstatisticsState extends State<Commentstatistics> {
  List<BarChartGroupData> barGroups = [];
  bool isLoading = true;
  int maxComments = 0;
  Map<String, int> commentsByDate = {}; // Lưu số lượng bình luận theo ngày

  @override
  void initState() {
    super.initState();
    fetchCommentData();
  }

  Future<void> fetchCommentData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore
        .collection('jobs')
        .where('uploadedBy', isEqualTo: widget.uid)
        .get();

    DateTime latestDate = DateTime.now();
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('jobComments')) {
        List<dynamic> jobComments = data['jobComments'] ?? [];

        for (var comment in jobComments) {
          var commentData = comment as Map<String, dynamic>;
          Timestamp commentTimestamp = commentData['time'];
          DateTime commentTime = commentTimestamp.toDate();
          String dateKey = '${commentTime.year}-${commentTime.month.toString().padLeft(2, '0')}-${commentTime.day.toString().padLeft(2, '0')}';

          if (commentsByDate.containsKey(dateKey)) {
            commentsByDate[dateKey] = commentsByDate[dateKey]! + 1;
            if (commentsByDate[dateKey]! > maxComments) {
              maxComments = commentsByDate[dateKey]!;
            }
          } else {
            commentsByDate[dateKey] = 1;
            if (maxComments < 1) {
              maxComments = 1;
            }
          }
        }
      }
    }

    List<BarChartGroupData> chartData = [];
    DateTime startDate = latestDate.subtract(Duration(days: 6)); // 6 ngày trước để bắt đầu tính

    // Tạo các nhóm dữ liệu cho biểu đồ
    for (int i = 0; i <= 6; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      String dateKey = '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
      int commentsCount = commentsByDate[dateKey] ?? 0;

      chartData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              fromY: 0,
              toY: commentsCount.toDouble(),
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
    int maxY = (maxComments * 3).ceil();
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
