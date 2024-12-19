import 'package:flutter/material.dart';
import 'dart:convert';

class ZhiShouData {
  int state;
  String num;
  int type;
  String bgImageList;
  String note;
  String id;

  ZhiShouData({
    required this.state,
    required this.num,
    required this.type,
    required this.bgImageList,
    required this.note,
    required this.id,
  });

  factory ZhiShouData.fromJson(Map<String, dynamic> json) {
    return ZhiShouData(
      state: json['state'],
      num: json['num'],
      type: json['type'],
      bgImageList: json['bgImageList'],
      note: json['note'],
      id: json['id'],
    );
  }
}


class RecordBean {
  Map<String, MonthData> monthlyData;
  String dateMonth;

  RecordBean({required this.monthlyData, required this.dateMonth});

  factory RecordBean.fromJson(Map<String, dynamic> json) {
    var monthlyData = <String, MonthData>{};
    json.forEach((key, value) {
      if (key != 'dateMonth') {
        monthlyData[key] = MonthData.fromJson(value['zhiShouList']);
      }
    });
    return RecordBean(
      monthlyData: monthlyData,
      dateMonth: json['dateMonth'],
    );
  }

  static RecordBean? getDataByMonth(String month, List<RecordBean> records) {
    for (var record in records) {
      if (record.dateMonth == month) {
        return record;
      }
    }
    return null; // 如果找不到对应月份，返回 null
  }

  static Future<List<RecordBean>> loadRecords() async {
    // 模拟从本地或网络加载数据
    await Future.delayed(Duration(seconds: 1));
    const jsonStr = '''[{
      "dateMonth": "2024-08",
      "08-01": {"zhiShouList": [
        {"state": 1, "num": "10.0", "type": 1, "bgImageList": "", "note": "Income", "id": "2024-08-01-1"},
        {"state": 1, "num": "5.0", "type": 1, "bgImageList": "", "note": "Income", "id": "2024-08-01-2"}
      ]},
      "08-02": {"zhiShouList": [{"state": 1, "num": "15.0", "type": 1, "bgImageList": "", "note": "Income", "id": "2024-08-02-1"}]},
      "08-03": {"zhiShouList": [{"state": 1, "num": "20.0", "type": 1, "bgImageList": "", "note": "Income", "id": "2024-08-03-1"}]}
    }]''';

    List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((json) => RecordBean.fromJson(json as Map<String, dynamic>)).toList();
  }
}

class MonthData {
  List<ZhiShouData> zhiShouList;

  MonthData({required this.zhiShouList});

  factory MonthData.fromJson(List<dynamic> jsonList) {
    return MonthData(
      zhiShouList: jsonList.map((e) => ZhiShouData.fromJson(e)).toList(),
    );
  }

  // 按日期分组
  Map<String, List<ZhiShouData>> groupByDay() {
    Map<String, List<ZhiShouData>> grouped = {};
    for (var data in zhiShouList) {
      final day = data.id.split('-')[0]; // 假设 `id` 以 "yyyy-mm-dd" 格式存储
      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(data);
    }
    return grouped;
  }
}

class BillListPage extends StatefulWidget {
  @override
  _BillListPageState createState() => _BillListPageState();
}

class _BillListPageState extends State<BillListPage> {
  String? _selectedMonth;
  List<RecordBean> _records = [];
  Map<String, MonthData>? _monthlyBills;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    List<RecordBean> records = await RecordBean.loadRecords();
    setState(() {
      _records = records;
    });
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      final String selectedMonth = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}';
      setState(() {
        _selectedMonth = selectedMonth;
        _loadMonthlyBills(selectedMonth);
      });
    }
  }

  void _loadMonthlyBills(String month) {
    final RecordBean? record = RecordBean.getDataByMonth(month, _records);
    if (record != null) {
      setState(() {
        _monthlyBills = record.monthlyData;
      });
    } else {
      setState(() {
        _monthlyBills = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("账单列表")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => _selectMonth(context),
              child: Text(_selectedMonth == null ? "选择月份" : "选择月份: $_selectedMonth"),
            ),
            SizedBox(height: 20),
            if (_monthlyBills != null)
              Expanded(
                child: ListView.builder(
                  itemCount: _monthlyBills!.length,
                  itemBuilder: (context, index) {
                    String day = _monthlyBills!.keys.elementAt(index);
                    MonthData monthData = _monthlyBills![day]!;

                    // 获取按天分组后的账单数据
                    Map<String, List<ZhiShouData>> groupedData = monthData.groupByDay();

                    // 确保 groupedData 包含当前的 day
                    if (!groupedData.containsKey(day)) {
                      return Container(); // 如果没有该日期的数据，返回空容器
                    }

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text('日期: $day'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: groupedData[day]!.map((item) {
                            return Text(
                                '类型: ${item.type == 1 ? "收入" : "支出"}, 数额: ${item.num}, 备注: ${item.note}');
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Center(child: Text("未选择任何月份或没有数据")),
          ],
        ),
      ),
    );
  }
}


void main() {
  runApp(MaterialApp(
    home: BillListPage(),
  ));
}
