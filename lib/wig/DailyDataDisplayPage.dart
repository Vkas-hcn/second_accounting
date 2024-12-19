import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
void main() {
  runApp(MaterialApp(
    home: DailyDataDisplayPage(month: '2024-12',),
  ));
}
class DailyDataDisplayPage extends StatelessWidget {
  final String month; // 传入的月份，例如 "2024-12"

  DailyDataDisplayPage({required this.month});

  Future<List<Map<String, dynamic>>> getDailyData() async {
    // 假设这是通过 getMonthlyDataByDate 获取到的结果
    // 调用这个方法获取指定月份的数据
    return await getMonthlyDataByDate(month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('每日数据展示'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getDailyData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('暂无数据'));
          }

          // 数据处理
          var dailyData = snapshot.data!;

          return ListView.builder(
            itemCount: dailyData.length,
            itemBuilder: (context, index) {
              var dayData = dailyData[index];
              String day = dayData['day'];  // 日期
              List<dynamic> records = dayData['records'];  // 每天的记录

              return ExpansionTile(
                title: Text('日期: $day'),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    itemBuilder: (context, recordIndex) {
                      var record = records[recordIndex];
                      return ListTile(
                        title: Text('金额: ${record['num']}'),
                        subtitle: Text('备注: ${record['note']}'),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> getMonthlyDataByDate(String month) async {
  // 模拟获取数据，根据实际情况调用适当的函数
  List<Map<String, dynamic>> result = [];

  // 模拟的数据，实际代码中应根据业务逻辑获取数据
  Map<String, dynamic> dataFor9th = {
    "day": "9",
    "records": [
      {"num": "88.0", "note": "", "type": 1, "state": 1, "id": "1733821831395"},
    ],
  };
  Map<String, dynamic> dataFor10th = {
    "day": "10",
    "records": [
      {"num": "12.0", "note": "", "type": 1, "state": 4, "id": "1733813903125"},
      {"num": "25.0", "note": "", "type": 1, "state": 5, "id": "1733813907395"},
      {"num": "2.0", "note": "", "type": 1, "state": 4, "id": "1733817207253"},
      {"num": "23.0", "note": "", "type": 1, "state": 5, "id": "1733821684201"},
    ],
  };

  // 将数据按日期（9日和10日）组织
  result.add(dataFor9th);
  result.add(dataFor10th);

  return result;
}
