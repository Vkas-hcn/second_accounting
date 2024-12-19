import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:second_accounting/showint/AdShowui.dart';
import 'package:second_accounting/showint/ShowAdFun.dart';
import 'package:second_accounting/utils/AppUtils.dart';
import 'package:second_accounting/utils/DataUtils.dart';
import 'package:second_accounting/wig/ImageDialog.dart';
import 'MainApp.dart';
import 'data/ZhiShou.dart';

class DataDetailPage extends StatefulWidget {
  const DataDetailPage({super.key});

  @override
  _DataDetailPageState createState() => _DataDetailPageState();
}

class _DataDetailPageState extends State<DataDetailPage>
    with SingleTickerProviderStateMixin {
  int seletIndex = 2; //all:2,exp:1,income:0
  int type = 1; //,exp:1,income:0

  RecordBean? septemberRecord = null;
  List<ZhiShouData> stateList = [];
  String selectedDateText = "";
  String nowDate = '';
  DateTime selectedDate = DateTime.now();
  double totalNum = 0.0;
  late ShowAdFun adManager;
  final AdShowui _loadingOverlay = AdShowui();
  @override
  void initState() {
    super.initState();
    selectedDateText = DataUtils.getCurrentDateFormatted();
    adManager = AppUtils.getMobUtils(context);
    print("selectedDateText===${selectedDateText}");
    getListAccData(selectedDateText, 2);
  }

  void clickSelect(int index) {
    setState(() {
      seletIndex = index;
    });
    displayMonthlyData(nowDate, index);
  }

  List<String> getBgList(List<ZhiShouData> zhiShouData, index1) {
    List<dynamic> dynamicList = jsonDecode(zhiShouData[index1].bgImageList);
    List<String> bgImageList =
    dynamicList.map((item) => item.toString()).toList();
    return bgImageList;
  }

  void getListAccData(String? date, int type) async {
    setState(() {
      if (date == null) {
        nowDate = DataUtils.getCurrentDateFormatted().substring(0, 7);
      } else {
        nowDate = date.substring(0, 7);
      }
    });
    displayMonthlyData(nowDate, type);
  }

  void showImageDialog(BuildContext context, bgImageList) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImageDialog(
          img: bgImageList,
          onClose: () {},
        );
      },
    );
  }

  void displayMonthlyData(String month, int type) async {
    stateList = [];
    totalNum = 0.0;
    // 获取所有日期的数据
    var monthlyData = await RecordBean.getMonthlyDataByDate(month);

    // 如果没有数据，返回
    if (monthlyData.isEmpty) {
      stateList = [];
      return;
    }

    // 合并所有日期的数据
    monthlyData.forEach((day, dataList) {
      for (var data in dataList) {
        // 如果type是2，表示获取所有数据；如果type是1，表示只获取支出；如果type是0，表示只获取收入
        if (type == 2 || data.type == type) {
          stateList.add(data);
        }
      }
    });

    // 按时间戳排序数据
    stateList.sort((a, b) => a.date.compareTo(b.date));

    // 输出合并并排序后的数据
    stateList.forEach((data) {
      double amount = double.tryParse(data.num) ?? 0.0;

      // 根据 type 判断是收入（0）还是支出（1）
      if (data.type == 0) {
        // 收入
        totalNum += amount;
      } else if (data.type == 1) {
        // 支出
        totalNum -= amount; // 支出是负数，所以下面使用减法
      }
      print("totalNum==${totalNum}");
      print(
          "State: ${data.state}, Num: ${data.num}, Type: ${data.type}, Note: ${data.note}, BgImageList: ${data.bgImageList}");
    });

    setState(() {});
  }
  void showAdNextPaper(AdWhere adWhere, Function() nextJump) async {
    if (!adManager.canShowAd(adWhere)) {
      adManager.loadAd(adWhere);
    }
    setState(() {
      _loadingOverlay.show(context);
    });
    AppUtils.showScanAd(context, adWhere, 5, false, () {
      setState(() {
        _loadingOverlay.hide();
      });
    }, () {
      setState(() {
        _loadingOverlay.hide();
      });
      nextJump();
    });
  }

  void nextJump() {
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    nowDate = DateFormat('yyyy-MM').format(selectedDate);
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          showAdNextPaper(AdWhere.BACKINT, () {
            nextJump();
          });
          return false;
        },
        child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.only(top: 60.0, left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showAdNextPaper(AdWhere.BACKINT, () {
                              nextJump();
                            });
                          },
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: Image.asset('assets/images/icon_back.webp'),
                          ),
                        ),
                        SizedBox(width: 4),
                        const Text(
                          'Bills',
                          style: TextStyle(
                            color: Color(0xFF222222),
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          clickSelect(2);
                        },
                        child: Container(
                          width: 103,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: seletIndex == 2
                                ? Color(0xFF85FFC8)
                                : Color(0xFFE7E7E7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            'All',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: seletIndex == 2
                                  ? Color(0xFF222222)
                                  : Color(0xFF727272),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          clickSelect(1);
                        },
                        child: Container(
                          width: 103,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: seletIndex == 1
                                ? Color(0xFF85FFC8)
                                : Color(0xFFE7E7E7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            'Expense',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: seletIndex == 1
                                  ? Color(0xFF222222)
                                  : Color(0xFF727272),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          clickSelect(0);
                        },
                        child: Container(
                          width: 103,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: seletIndex == 0
                                ? Color(0xFF85FFC8)
                                : Color(0xFFE7E7E7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            'Income',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: seletIndex == 0
                                  ? Color(0xFF222222)
                                  : Color(0xFF727272),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  selectMonth(context);
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      nowDate,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'san',
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: Image.asset(
                                        'assets/images/icon_up_list.png',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Balance: ${totalNum>0?'+':''}${totalNum}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'san',
                                  fontSize: 15,
                                  color: Color(0xFF545454),
                                ),
                              ),
                            ],
                          ),
                          if (stateList.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemCount: stateList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    // backRefFun(index);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 9.0, left: 1, right: 9, bottom: 11),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            SizedBox(
                                              width: 36,
                                              height: 36,
                                              child: Image.asset(
                                                stateList[index].icon,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            const SizedBox(width: 9),
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    stateList[index].name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                      FontWeight.w700,
                                                      fontFamily: 'san',
                                                      fontSize: 14,
                                                      color:
                                                      Color(0xFF000000),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    stateList[index].note,
                                                    maxLines: 3,
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      fontFamily: 'san',
                                                      fontSize: 12,
                                                      color: Color(0xFF7B7B7B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                height: 68,
                                                // Specify the height here
                                                child: ListView.builder(
                                                  scrollDirection:
                                                  Axis.horizontal,
                                                  itemCount:
                                                  getBgList(stateList, index)
                                                      .length,
                                                  itemBuilder: (context, index2) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        showImageDialog(
                                                            context,
                                                            getBgList(stateList,
                                                                index)[index2]);
                                                      },
                                                      child: Container(
                                                        height: 68,
                                                        width: 68,
                                                        child: Stack(
                                                          alignment:
                                                          Alignment.topRight,
                                                          children: [
                                                            Center(
                                                              child: CustomCircle(
                                                                img: getBgList(
                                                                    stateList,
                                                                    index)[
                                                                index2],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  stateList[index].type == 1
                                                      ? '-${stateList[index].num}'
                                                      : '+${stateList[index].num}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'san',
                                                    fontSize: 12,
                                                    color:
                                                    stateList[index].type == 1
                                                        ? Color(0xFFFF9C50)
                                                        : Color(0xFF22C764),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  stateList[index].date,
                                                  style: const TextStyle(
                                                    fontWeight:
                                                    FontWeight.w700,
                                                    fontFamily: 'san',
                                                    fontSize: 12,
                                                    color:
                                                    Color(0xFF7B7B7B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (stateList.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 280.0),
                              child: Column(children: [
                                Text('No Data',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'san',
                                      fontSize: 24,
                                    ))
                              ]),
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Future<void> selectDate2(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      // 初始日期为今天
      firstDate: DateTime(2000),
      // 设置一个合理的过去日期
      lastDate: DateTime.now(),
      // 最后日期为今天
      // 设置一个合理的未来日期
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF031F3E),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF031F3E),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;

        print("pickedDate=====$pickedDate");
      });
      nowDate = DateFormat('yyyy-MM').format(selectedDate);
      displayMonthlyData(nowDate, seletIndex);
    }
  }

  Future<void> selectMonth(BuildContext context) async {
    DateTime initialDate = selectedDate ?? DateTime.now();
    DateTime currentDate = DateTime.now();

    final DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        int selectedYear = initialDate.year;
        int selectedMonth = initialDate.month;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select Month'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: selectedYear,
                    items: List.generate(
                      currentDate.year - 1999, // Generate years from 2000 to current year
                          (index) => DropdownMenuItem(
                        value: 2000 + index,
                        child: Text((2000 + index).toString()),
                      ),
                    ),
                    onChanged: (int? value) {
                      setState(() {
                        selectedYear = value!;
                      });
                    },
                  ),
                  DropdownButton<int>(
                    value: selectedMonth,
                    items: List.generate(
                      12,
                          (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text(DateFormat.MMMM().format(DateTime(0, index + 1))),
                      ),
                    ),
                    onChanged: (int? value) {
                      setState(() {
                        selectedMonth = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      DateTime(selectedYear, selectedMonth),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        print("pickedDate=====$pickedDate");
      });

      nowDate = DateFormat('yyyy-MM').format(selectedDate);
      displayMonthlyData(nowDate, seletIndex);
    }
  }

}
