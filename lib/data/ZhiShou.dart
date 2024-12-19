import 'dart:convert';

import '../utils/LocalStorage.dart';

// 定义 ZhiShou 类，用于表示 "zhi" 和 "shou" 列表的每个元素
class ZhiShouData {
  int state;
  String num;
  int type;
  String bgImageList;
  String note;
  String id;
  String icon;
  String name;
  String date;
  ZhiShouData({
    required this.state,
    required this.num,
    required this.type,
    required this.bgImageList,
    required this.note,
    required this.id,
    required this.icon,
    required this.name,
    required this.date,

  });

  factory ZhiShouData.fromJson(Map<String, dynamic> json) {
    return ZhiShouData(
      state: json['state'] as int,
      num: json['num'] as String,
      type: json['type'] as int,
      bgImageList: json['bgImageList'] as String,
      note: json['note'] as String,
      id: json['id'] as String,
      icon: json['icon'] as String,
      name: json['name'] as String,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'num': num,
      'type': type,
      'bgImageList': bgImageList,
      'note': note,
      'id': id,
      'icon': icon,
      'name': name,
      'date': date,
    };
  }

  static Future<void> removeAndSaveRecord(
      String day, String type, String state, String num) async {
    // 1. 从本地读取最新数据
    List<RecordBean> records = await RecordBean.loadRecords();

    // 2. 找到相应的 RecordBean 并删除记录
    for (var record in records) {
      record.removeDataByDate(day, type, state, num);
    }

    // 3. 更新数据保存到本地
    await RecordBean.saveRecords(records);
    print("数据删除并更新成功");
  }
}

// 定义 MonthData 类，用于表示每个月的支出收入
class MonthData {
  List<ZhiShouData> zhiShouList;

  MonthData({required this.zhiShouList});

  factory MonthData.fromJson(List<dynamic> jsonList) {
    return MonthData(
      zhiShouList: jsonList.map((e) => ZhiShouData.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zhiShouList': zhiShouList.map((e) => e.toJson()).toList(),
    };
  }
}

class RecordBean {
  Map<String, MonthData> monthlyData;
  String dateMonth;
  String yu;

  RecordBean(
      {required this.monthlyData, required this.dateMonth, required this.yu});

  factory RecordBean.fromJson(Map<String, dynamic> json) {
    Map<String, MonthData> parsedMonthlyData = {};
    json.forEach((key, value) {
      if (key != 'dateMonth' && key != 'yu') {
        // 修正为从 Map<String, dynamic> 转换为 MonthData
        parsedMonthlyData[key] =
            MonthData.fromJson(value['zhiShouList'] as List<dynamic>);
      }
    });

    return RecordBean(
      monthlyData: parsedMonthlyData,
      dateMonth: json['dateMonth'] as String,
      yu: json['yu'] as String,
    );
  }

  // 更新指定月份的yu值，并保存修改前后的数据
  static Future<void> updateYuByMonth(String month, String newYu) async {
    month = month.substring(0, 7);
    // 1. 从本地加载记录
    List<RecordBean> records = await loadRecords();

    // 2. 查找指定月份的记录
    RecordBean? recordToUpdate = getDataByMonth(month, records);

    if (recordToUpdate == null) {
      print("未找到指定月份的记录: $month");
      return;
    }

    // 3. 打印修改前的记录
    print("修改前的yu值: ${recordToUpdate.yu}");

    // 4. 更新 yu 字段的值
    recordToUpdate.yu = newYu;

    // 5. 打印修改后的记录
    print("修改后的yu值: ${recordToUpdate.yu}");

    // 6. 保存修改后的记录到本地
    await saveRecords(records);
    print("记录已更新并保存成功");
  }

  static Future<void> updateRecord(
      String recordId, ZhiShouData updatedData) async {
    // Step 1: 读取最新的本地数据
    List<RecordBean> records = await loadRecords();

    // Step 2: 遍历查找并修改记录
    bool recordFound = false; // 用于检查是否找到对应的记录

    for (var record in records) {
      // 遍历 monthlyData 查找支出或收入记录
      record.monthlyData.forEach((day, monthData) {
        for (int i = 0; i < monthData.zhiShouList.length; i++) {
          if (monthData.zhiShouList[i].id == recordId) {
            // 根据 recordId 找到要修改的记录
            monthData.zhiShouList[i] = updatedData; // 更新记录数据
            recordFound = true;
            break; // 找到后跳出循环
          }
        }
      });
      if (recordFound) {
        break; // 找到后跳出外部循环
      }
    }

    if (!recordFound) {
      throw Exception("Record with ID $recordId not found.");
    }

    // Step 3: 更新本地数据
    await saveRecords(records); // 保存修改后的数据到本地
  }

  static Map<String, double> calculateDailyTotals(
      MonthData dailyData, String dayKey) {
    double totalZhi = 0.0;
    double totalShou = 0.0;

    for (var zhiShouData in dailyData.zhiShouList) {
      if (zhiShouData.type == "zhi") {
        totalZhi += double.tryParse(zhiShouData.num) ?? 0.0;
      } else if (zhiShouData.type == "shou") {
        totalShou += double.tryParse(zhiShouData.num) ?? 0.0;
      }
    }
    totalZhi = double.parse(totalZhi.toStringAsFixed(2));
    totalShou = double.parse(totalShou.toStringAsFixed(2));

    return {
      "totalZhi": totalZhi,
      "totalShou": totalShou,
    };
  }

  // 删除某条记录
  void removeDataByDate(String day, String type, String state, String num) {
    if (!monthlyData.containsKey(day)) {
      print("该日期没有记录: $day");
      return;
    }

    MonthData dayData = monthlyData[day]!;

    List<ZhiShouData> dataList = type == "zhi"
        ? dayData.zhiShouList.where((e) => e.type == "zhi").toList()
        : dayData.zhiShouList.where((e) => e.type == "shou").toList();

    // 删除符合条件的记录
    dataList
        .removeWhere((element) => element.state == state && element.num == num);

    if (type == "zhi") {
      dayData.zhiShouList = dataList +
          dayData.zhiShouList.where((e) => e.type == "shou").toList();
    } else {
      dayData.zhiShouList =
          dayData.zhiShouList.where((e) => e.type == "zhi").toList() + dataList;
    }

    print("记录已删除: $state, $num, $type");
  }

  // 静态方法从本地读取记录数据
  static Future<List<RecordBean>> loadRecords() async {
    final String? jsonStr =
        await LocalStorage().getValue(LocalStorage.accountJson);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      List<dynamic> jsonList = json.decode(jsonStr);
      // 将 JSON 列表映射为 RecordBean 列表
      List<RecordBean> records = jsonList
          .map((json) => RecordBean.fromJson(json as Map<String, dynamic>))
          .toList();

      // 对每个 RecordBean 的 monthlyData 按日期进行排序
      for (var record in records) {
        // 获取 monthlyData 的键值对，按日期排序
        List<MapEntry<String, MonthData>> sortedEntries =
            record.monthlyData.entries.toList()
              ..sort((a, b) {
                // 将键（日期字符串）转换为整数进行比较，例如 '11' 和 '10'
                int dayA = int.parse(a.key);
                int dayB = int.parse(b.key);
                return dayB.compareTo(dayA); // 日期大的排前面
              });

        // 重新赋值排序后的 monthlyData
        record.monthlyData = Map.fromEntries(sortedEntries);
      }

      return records;
    } else {
      return []; // 如果本地没有数据则返回空列表
    }
  }

  /// 获取该月份中的所有支出金额和收入金额
  Map<String, double> calculateMonthlyTotals() {
    double totalZhi = 0.0;
    double totalShou = 0.0;

    // 遍历每一天的数据
    monthlyData.forEach((day, monthData) {
      for (var zhiShouData in monthData.zhiShouList) {
        // 根据 type 区分支出和收入
        if (zhiShouData.type == "zhi") {
          totalZhi += double.tryParse(zhiShouData.num) ?? 0.0;
        } else if (zhiShouData.type == "shou") {
          totalShou += double.tryParse(zhiShouData.num) ?? 0.0;
        }
      }
    });
    totalZhi = double.parse(totalZhi.toStringAsFixed(2));
    totalShou = double.parse(totalShou.toStringAsFixed(2));
    return {
      "totalZhi": totalZhi,
      "totalShou": totalShou,
    };
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'dateMonth': dateMonth,
      'yu': yu,
    };
    monthlyData.forEach((key, value) {
      data[key] = value.toJson();
    });
    return data;
  }

  // 保存数据到本地存储
  static Future<void> saveRecords(List<RecordBean> records) async {
    final String jsonStr =
        json.encode(records.map((record) => record.toJson()).toList());
    await LocalStorage().setValue(LocalStorage.accountJson, jsonStr);
  }

  // 添加支出或收入数据，输入日期进行月份判断
  void addDataByDate(
      String inputDate,
      int type,
      int state,
      String num,
      String bgList,
      String note,
      List<RecordBean>? records,
      String icon,
      String name) {
    DateTime inputDateTime = DateTime.parse(inputDate);
    //DateTime.parse(inputDate)转换成2020-12-01
    String dayString =
        '${inputDateTime.year}-${inputDateTime.month.toString().padLeft(2, '0')}-${inputDateTime.day.toString().padLeft(2, '0')}';
    String monthString =
        '${inputDateTime.year}-${inputDateTime.month.toString().padLeft(2, '0')}'; // 2024-10
    String day = inputDateTime.day.toString();

    if (records == null || records.isEmpty) {
      records = [];
    }

    RecordBean? currentMonthRecord;

    for (var record in records) {
      if (record.dateMonth == monthString) {
        currentMonthRecord = record;
        break;
      }
    }

    if (currentMonthRecord == null) {
      // 查找上一个月的数据
      String prevMonthString =
          "${inputDateTime.year}-${inputDateTime.month - 1}";
      RecordBean? prevMonthRecord = records.firstWhere(
        (record) => record.dateMonth == prevMonthString,
        orElse: () =>
            RecordBean(monthlyData: {}, dateMonth: monthString, yu: '50'),
      );

      String newYuValue = prevMonthRecord != null ? prevMonthRecord.yu : '50';

      currentMonthRecord = RecordBean(
        monthlyData: {},
        dateMonth: monthString,
        yu: newYuValue,
      );
      records.add(currentMonthRecord);
    }

    if (!currentMonthRecord.monthlyData.containsKey(day)) {
      currentMonthRecord.monthlyData[day] = MonthData(zhiShouList: []);
    }

    MonthData dayData = currentMonthRecord.monthlyData[day]!;

    // 根据 type 来添加支出或收入
    dayData.zhiShouList.add(ZhiShouData(
      state: state,
      num: num,
      type: type,
      bgImageList: bgList,
      note: note,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      icon: icon,
      name: name,
      date: dayString,
    ));

    final String jsonStr =
        json.encode(records.map((record) => record.toJson()).toList());
    print("object==jsonStr==${jsonStr}");
    saveRecords(records);
  }

  static RecordBean? getDataByMonth(String month, List<RecordBean> records) {
    for (var record in records) {
      if (record.dateMonth == month) {
        return record;
      }
    }
    return null; // 如果找不到对应月份，返回 null
  }

  static List<RecordBean> parseRecords(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    final List<dynamic> jsonData = json.decode(jsonStr);
    return jsonData.map((data) => RecordBean.fromJson(data)).toList();
  }

  // 计算当月各个state类型的总金额
  Map<int, double> calculateStateTotals() {
    Map<int, double> stateTotals = {};
    double totalAmount = 0.0; // 当月总金额

    // 遍历当月的每日数据
    monthlyData.forEach((day, monthData) {
      for (var zhiShouData in monthData.zhiShouList) {
        int state = zhiShouData.state;
        double amount = double.tryParse(zhiShouData.num) ?? 0.0;

        // 根据state进行分类统计
        if (stateTotals.containsKey(state)) {
          stateTotals[state] = stateTotals[state]! + amount;
        } else {
          stateTotals[state] = amount;
        }

        // 累加当月总金额
        totalAmount += amount;
      }
    });

    // 计算每个state的总金额占当月总金额的百分比
    stateTotals.forEach((state, total) {
      double percentage = (total / totalAmount) * 100;
      stateTotals[state] = percentage; // 用百分比替换金额
    });

    return stateTotals;
  }

  // 获取state总金额列表
  Future<List<Map<String, dynamic>>?> getStateTotalList(
      String month, int type) async {
    List<Map<String, dynamic>> stateList = [];
    double totalAmount = 0.0; // 当月总金额
    Map<int, double> stateTotals = {};
    List<RecordBean> recordBeanList = await loadRecords();
    // 2. 查找指定月份的记录
    RecordBean? recordToUpdate = getDataByMonth(month, recordBeanList);
    if (recordToUpdate == null) {
      return null;
    }
    // 遍历当月的每日数据
    recordToUpdate.monthlyData.forEach((day, monthData) {
      for (var zhiShouData in monthData.zhiShouList) {
        // 只计算与传入的type匹配的数据
        if (zhiShouData.type == type) {
          int state = zhiShouData.state;
          double amount = double.tryParse(zhiShouData.num) ?? 0.0;

          // 根据state进行分类统计
          if (stateTotals.containsKey(state)) {
            stateTotals[state] = stateTotals[state]! + amount;
          } else {
            stateTotals[state] = amount;
          }

          // 累加当月总金额
          totalAmount += amount;
        }
      }
    });

    // 构建每个state的详细数据
    stateTotals.forEach((state, total) {
      double percentage = (total / totalAmount) * 100;
      stateList.add({
        'state': state,
        'total': total,
        'percentage': percentage,
      });
    });
    print("object-stateList${stateList.length}");
    return stateList;
  }

  static Future<Map<String, List<ZhiShouData>>> getMonthlyDataByDate(
      String month) async {
    // 1. 从本地加载记录数据
    List<RecordBean> records = await RecordBean.loadRecords();

    // 2. 查找指定月份的记录
    RecordBean? recordToUpdate = RecordBean.getDataByMonth(month, records);
    if (recordToUpdate == null) {
      print("未找到指定月份的数据: $month");
      return {}; // 如果没有找到该月份的记录，返回空数据
    }

    // 3. 按日期分类显示数据
    Map<String, List<ZhiShouData>> dailyData = {};

    // 遍历每一天的数据
    recordToUpdate.monthlyData.forEach((day, monthData) {
      // 获取每天的数据列表
      List<ZhiShouData> zhiShouList = monthData.zhiShouList;

      // 按日期分类添加
      dailyData[day] = zhiShouList;
    });

    // 返回按日期分类的结果
    return dailyData;
  }
}
