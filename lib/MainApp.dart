import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:second_accounting/CategoryPage.dart';
import 'package:second_accounting/DataDetailPage.dart';
import 'package:second_accounting/SettingIndexPage.dart';
import 'package:second_accounting/showint/AdShowui.dart';
import 'package:second_accounting/showint/ShowAdFun.dart';
import 'package:second_accounting/utils/AppUtils.dart';
import 'package:second_accounting/utils/DataUtils.dart';
import 'package:second_accounting/utils/LocalStorage.dart';
import 'package:second_accounting/wig/ImageDialog.dart';
import 'package:second_accounting/wig/NumberInputWidget.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import 'data/ZhiShou.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool intPutDialog = false;
  int currentPageIndex = 0;
  List<String> _expensesText = [];
  List<RecordBean> recordsListMain = [];
  List<ZhiShouData> stateList = [];
  int type = 1;
  List<String> bgImageList = [];
  final TextEditingController _textEditingController = TextEditingController();
  double totalNum = 0.0;
  String tListDate = "";
  late ShowAdFun adManager;
  final AdShowui _loadingOverlay = AdShowui();

  @override
  void initState() {
    super.initState();
    adManager = AppUtils.getMobUtils(context);
    getHomeListData(type);
    displayMonthlyData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> getImageData(index) async {
    return await DataUtils.getImageByText(_expensesText[index]);
  }

  void getHomeListData(int type) async {
    List<RecordBean> records = await RecordBean.loadRecords();
    setState(() {
      _expensesText = DataUtils.getHomeListTextData(type);
      // _expensesImage = DataUtils.getHomeListImageData(type);
      recordsListMain = records;
    });
  }

  void displayMonthlyData2() async {
    String month = DataUtils.getCurrentDateFormatted().substring(0, 7);
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
        stateList.add(data);
      }
    });

    // 按时间戳排序数据
    stateList.sort((a, b) => a.date.compareTo(b.date));
    // 只保留前3条数据
    stateList = stateList.take(3).toList();
    // 输出合并并排序后的数据
    stateList.forEach((data) {
      double amount = double.tryParse(data.num) ?? 0.0;
      if (data.type == 0) {
        // 收入
        totalNum += amount;
      } else if (data.type == 1) {
        // 支出
        totalNum -= amount;
      }
      //转换成2024-12
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(int.parse(data.id));
      tListDate = DateFormat('yyyy-MM').format(dateTime);
    });
    getToNum();
    setState(() {});
  }

  void displayMonthlyData() async {
    String month = DataUtils.getCurrentDateFormatted().substring(0, 7);
    // 获取所有日期的数据
    var monthlyData = await RecordBean.getMonthlyDataByDate(month);

    // 如果没有数据，返回
    if (monthlyData.isEmpty) {
      stateList = [];
      return;
    }

    // 当前时间戳（毫秒）
    int nowTimestamp = DateTime.now().millisecondsSinceEpoch;
    // 最近三天的时间戳范围
    int threeDaysAgoTimestamp = nowTimestamp - 3 * 24 * 60 * 60 * 1000;

    // 过滤最近三天的数据
    List<ZhiShouData> recentData = [];
    monthlyData.forEach((day, dataList) {
      for (var data in dataList) {
        int dataTimestamp = int.tryParse(data.id) ?? 0;
        if (dataTimestamp >= threeDaysAgoTimestamp &&
            dataTimestamp <= nowTimestamp) {
          recentData.add(data);
        }
      }
    });

    // 按时间戳排序数据（降序，最近的在前）
    recentData.sort((a, b) => int.parse(b.id).compareTo(int.parse(a.id)));
    stateList = recentData;
    // 计算总收入和总支出
    totalNum = 0.0; // 重置总数
    for (var data in stateList) {
      double amount = double.tryParse(data.num) ?? 0.0;
      if (data.type == 0) {
        // 收入
        totalNum += amount;
      } else if (data.type == 1) {
        // 支出
        totalNum -= amount;
      }
      // 转换成 2024-12 格式
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(int.parse(data.id));
      tListDate = DateFormat('yyyy-MM').format(dateTime);
    }

    // 更新状态
    getToNum();
    setState(() {});
  }

  String banlance = "";
  String expenses = "";
  String income = "";

  void getToNum() async {
    String month = DataUtils.getCurrentDateFormatted().substring(0, 7);
    // 获取所有日期的数据
    var monthlyData = await RecordBean.getMonthlyDataByDate(month);

    // 初始化收入、支出和结余
    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    // 如果没有数据，返回
    if (monthlyData.isEmpty) {
      banlance = '0.00';
      expenses = '-0.00';
      income = '+0.00';
      setState(() {});
      return;
    }

    // 合并所有日期的数据并计算收入和支出
    monthlyData.forEach((day, dataList) {
      for (var data in dataList) {
        double amount = double.tryParse(data.num) ?? 0.0;
        if (data.type == 0) {
          // 收入
          totalIncome += amount;
        } else if (data.type == 1) {
          // 支出
          totalExpenses += amount;
        }
      }
    });
    double balance = totalIncome - totalExpenses;
    banlance = NumberFormat('#,##0.00').format(balance);
    expenses = '-${NumberFormat('#,##0.00').format(totalExpenses)}';
    income = '+${NumberFormat('#,##0.00').format(totalIncome)}';
    setState(() {});
  }

  void jumpToSetting() {
    showAdNextPaper(AdWhere.SAVE, false, () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingIndexPage()),
      );
    });
  }

  void jumpToDetailPage() {
    showAdNextPaper(AdWhere.SAVE, false, () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DataDetailPage()),
      );
    });
  }

  void jumpToCategoryPage() {
    showAdNextPaper(AdWhere.SAVE, false, () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CategoryPage()),
      ).then((value) {
        getHomeListData(type);
      });
    });
  }

  void swishtPage() {
    if (type == 1) {
      type = 0;
    } else {
      type = 1;
    }
    currentPageIndex = 0;
    setState(() {
      getHomeListData(type);
    });
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

  List<String> getBgList(List<ZhiShouData> zhiShouData, index1) {
    List<dynamic> dynamicList = jsonDecode(zhiShouData[index1].bgImageList);
    List<String> bgImageList =
        dynamicList.map((item) => item.toString()).toList();
    return bgImageList;
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? images = await picker.pickMultiImage(
        imageQuality: 90,
        maxWidth: 1080,
      );
      if (images != null && images.isNotEmpty) {
        final directory = await getApplicationDocumentsDirectory();
        for (final image in images) {
          if (bgImageList.length >= 3) {
            Fluttertoast.showToast(msg: "You can only select up to 3 images");
            break; // 如果已经选择了3张图片，则停止选择
          }

          // 检查图片格式
          final String extension = image.path.split('.').last.toLowerCase();
          if (extension != 'jpg' && extension != 'jpeg' && extension != 'png') {
            Fluttertoast.showToast(msg: "Unsupported image format");
            continue; // 不支持的格式
          }

          // 检查图片大小
          final int imageSize = await image.length();
          if (imageSize > 5 * 1024 * 1024) {
            Fluttertoast.showToast(msg: "Image size exceeds 5MB");
            continue; // 图片大小超过5MB
          }

          final String newPath =
              '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.${extension}';
          final File newImage = await File(image.path).copy(newPath);
          setState(() {
            bgImageList.insert(0, newImage.path);
          });
        }
      } else {}
    } catch (e) {
      Fluttertoast.showToast(
          msg:
          "Access to your photo album is required to select images to add to the bill.");
    }
  }


    void showAdNextPaper(AdWhere adWhere, bool isTwo, Function() nextJump) async {
    if (!adManager.canShowAd(adWhere)) {
      adManager.loadAd(adWhere);
    }
    setState(() {
      _loadingOverlay.show(context);
    });
    AppUtils.showScanAd(context, adWhere, 5, isTwo, () {
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _buildMainApp(context),
            if (intPutDialog) _buildInputApp(context),
          ],
        ),
      ),
    );
  }

  Future<void> addAccountFun(String num) async {
    double? amount = double.tryParse(num);
    // 从本地读取数据
    String? jsonStr = await LocalStorage().getValue(LocalStorage.accountJson);
    print("从本地读取数据---${jsonStr}");
    // 解析本地数据
    List<RecordBean> records = RecordBean.parseRecords(jsonStr);
    String selectedDateText = await LocalStorage().getSelectedDateLocal();
    String jsonImages = json.encode(bgImageList);
    print("jsonImages---${jsonImages}---${bgImageList.length}");
    print(" _textEditingController.text---${_textEditingController.text}---");
    int finishIndex =
        await DataUtils.getSameSubscript(type, _expensesText[currentPageIndex]);
    print("ddddd---${finishIndex}---type---${type}-----");
    String imageData = await getImageData(finishIndex);
    // 添加一条新数据
    if (records.isNotEmpty) {
      records[0].addDataByDate(
          selectedDateText,
          type,
          finishIndex,
          amount.toString(),
          jsonImages,
          _textEditingController.text,
          records,
          imageData,
          _expensesText[currentPageIndex]);
    } else {
      // 如果本地没有记录，创建一个新的记录
      RecordBean newRecord = RecordBean(
        monthlyData: {},
        dateMonth: selectedDateText.substring(0, 7),
        yu: '50',
      );
      newRecord.addDataByDate(
          selectedDateText,
          type,
          finishIndex,
          amount.toString(),
          jsonImages,
          _textEditingController.text,
          records,
          imageData,
          _expensesText[currentPageIndex]);
      records.add(newRecord);
    }
    String? datra = await LocalStorage().getValue(LocalStorage.accountJson);
    print("打印当前数据 ---${datra}");
    DataUtils.showToast("Added successfully!");
    displayMonthlyData();
  }

  void saveToNextPaper(String value, bool dialogState) async {
    await addAccountFun(value);
    setState(() {
      _textEditingController.clear();
      bgImageList.clear();
      intPutDialog = dialogState;
    });
  }

  Widget _buildInputApp(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const BouncingScrollPhysics(),
      child: Container(
        width: double.infinity,
        height: 450,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 20, right: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: SizedBox(
                      width: 62,
                      height: 62,
                      child: Image.asset(
                        'assets/images/ic_add_file.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 78, // Specify the height here
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: bgImageList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              showImageDialog(context, bgImageList[index]);
                            },
                            child: SizedBox(
                              height: 78,
                              width: 78,
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Center(
                                    child: CustomCircle(
                                      img: bgImageList[index],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          bgImageList.removeAt(index);
                                        });
                                      },
                                      child: SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: Image.asset(
                                          'assets/images/ic_xxx.webp',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //带边框的输入框
            Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 20, right: 20),
                child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF000000)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        maxLength: 30,
                        maxLines: 1,
                        controller: _textEditingController,
                        buildCounter: (
                          BuildContext context, {
                          required int currentLength,
                          required bool isFocused,
                          required int? maxLength,
                        }) {
                          return null;
                        },
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF000000),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Enter Notes',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFA8A8A8),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ))),
            Expanded(
              child: FutureBuilder<String>(
                future: getImageData(currentPageIndex),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return NumberInputWidget(
                        onAdd: (value) {
                          showAdNextPaper(AdWhere.SAVE, true, () {
                            saveToNextPaper(value, false);
                          });
                        },
                        stateImage: snapshot.data!,
                        again: (value) {
                          showAdNextPaper(AdWhere.SAVE, true, () {
                            saveToNextPaper(value, true);
                          });
                        },
                        seassets: (value) {},
                      );
                    }
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainApp(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const BouncingScrollPhysics(),
      child: GestureDetector(
        onTap: () {
          setState(() {
            intPutDialog = false;
          });
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
          ),
          child: Stack(children: [
            Padding(
              padding: const EdgeInsets.only(top: 56),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: Image.asset(
                                    'assets/images/ic_main_top.webp'),
                              ),
                              const SizedBox(width: 8),
                              const Text("Daily Spend Logger",
                                  style: TextStyle(
                                    fontFamily: "san",
                                    fontSize: 20,
                                    color: Color(0xFF000000),
                                  )),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            jumpToSetting();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child:
                                  Image.asset('assets/images/ic_setting.webp'),
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFA5A3B1),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                children: [
                                  const Text(
                                    'Quick Add',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'san',
                                      fontSize: 15,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      swishtPage();
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          type == 1 ? 'Expenses' : "Income",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'san',
                                            fontSize: 12,
                                            color: type == 1
                                                ? const Color(0xFF6ADB81)
                                                : const Color(0xFFFF9C50),
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: type == 1
                                              ? Image.asset(
                                                  'assets/images/ic_expen.webp',
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.asset(
                                                  'assets/images/ic_income.webp',
                                                  fit: BoxFit.cover,
                                                ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 220, // 调整高度以适应网格
                              child: PageView.builder(
                                onPageChanged: (index) {},
                                itemCount: (_expensesText.length / 8).ceil(),
                                itemBuilder: (context, pageIndex) {
                                  final startIndex = pageIndex * 8;
                                  final endIndex =
                                      (startIndex + 8) > _expensesText.length
                                          ? _expensesText.length
                                          : startIndex + 8;
                                  final items = _expensesText.sublist(
                                      startIndex, endIndex);

                                  return GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      mainAxisSpacing: 2,
                                      crossAxisSpacing: 5,
                                    ),
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final actualIndex = startIndex + index;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            currentPageIndex = actualIndex;
                                            intPutDialog = true;
                                          });
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FutureBuilder<String>(
                                              future: getImageData(actualIndex),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.done) {
                                                  if (snapshot.hasError) {
                                                    return Text(
                                                        'Error: ${snapshot.error}');
                                                  } else {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        border: Border.all(
                                                          color: currentPageIndex ==
                                                                  actualIndex
                                                              ? Color(
                                                                  0xFFF3AA20)
                                                              : Color(
                                                                  0xFFE5E5E5),
                                                          width: 1,
                                                        ),
                                                        color: Colors.white,
                                                      ),
                                                      child: SizedBox(
                                                        width: 54,
                                                        height: 54,
                                                        child: Image.asset(
                                                            snapshot.data!),
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  return const CircularProgressIndicator(); // 显示加载中的指示器
                                                }
                                              },
                                            ),
                                            Text(
                                              items[index],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                (_expensesText.length / 8).ceil(),
                                (index) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: CircleAvatar(
                                    radius: 4,
                                    backgroundColor: currentPageIndex == index
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              jumpToDetailPage();
                            },
                            child: Container(
                              width: 112,
                              height: 53,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                        'assets/images/group_bg_2.webp'),
                                    fit: BoxFit.fill,
                                  )),
                              child: const Padding(
                                padding: EdgeInsets.only(top: 15.0, left: 20),
                                child: Text(
                                  'Bills',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'san',
                                    fontSize: 12,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              jumpToCategoryPage();
                            },
                            child: Container(
                              width: 112,
                              height: 53,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                        'assets/images/group_bg_3.webp'),
                                    fit: BoxFit.fill,
                                  )),
                              child: const Padding(
                                padding: EdgeInsets.only(top: 15.0, left: 20),
                                child: Text(
                                  'Categories',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'san',
                                    fontSize: 12,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFA5A3B1),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    'This Month',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'san',
                                      fontSize: 15,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          banlance,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'san',
                                            fontSize: 20,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                        const Text(
                                          'Banlance',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'san',
                                            fontSize: 12,
                                            color: Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          expenses,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'san',
                                            fontSize: 20,
                                            color: Color(0xFFFF9C50),
                                          ),
                                        ),
                                        const Text(
                                          'Expenses',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'san',
                                            fontSize: 12,
                                            color: Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          income,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'san',
                                            fontSize: 20,
                                            color: Color(0xFF22C764),
                                          ),
                                        ),
                                        const Text(
                                          'Income',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'san',
                                            fontSize: 12,
                                            color: Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Bills',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'san',
                                    fontSize: 18,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    jumpToDetailPage();
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 30,
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color(0xFFF5F5F5),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0xFFE4E4E4),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: const Color(0xFFE4E4E4),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      'More',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'san',
                                        fontSize: 12,
                                        color: Color(0xFF36B8E8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  tListDate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'san',
                                    fontSize: 12,
                                    color: Color(0xFF828282),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  totalNum.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'san',
                                    fontSize: 15,
                                    color: totalNum > 0
                                        ? Color(0xFF22C764)
                                        : Color(0xFFEB5757),
                                  ),
                                ),
                              ],
                            ),
                            if (stateList.isNotEmpty == true)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                itemCount: stateList.length,
                                itemBuilder: (context, index1) {
                                  return GestureDetector(
                                    onTap: () {
                                      // backRefFun(index);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 9.0,
                                          left: 1,
                                          right: 9,
                                          bottom: 11),
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
                                                  stateList[index1].icon,
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
                                                      stateList[index1].name,
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
                                                      stateList[index1].note,
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                              ),
                                              Expanded(
                                                child: SizedBox(
                                                  height: 68,
                                                  // Specify the height here
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: getBgList(
                                                            stateList, index1)
                                                        .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          showImageDialog(
                                                              context,
                                                              getBgList(
                                                                      stateList,
                                                                      index1)[
                                                                  index]);
                                                        },
                                                        child: Container(
                                                          height: 68,
                                                          width: 68,
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .topRight,
                                                            children: [
                                                              Center(
                                                                child:
                                                                    CustomCircle(
                                                                  img: getBgList(
                                                                      stateList,
                                                                      index1)[index],
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
                                                    stateList[index1].type == 1
                                                        ? '-${stateList[index1].num}'
                                                        : '+${stateList[index1].num}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFamily: 'san',
                                                      fontSize: 12,
                                                      color: stateList[index1]
                                                                  .type ==
                                                              1
                                                          ? Color(0xFFFF9C50)
                                                          : Color(0xFF22C764),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    stateList[index1].date,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFamily: 'san',
                                                      fontSize: 12,
                                                      color: Color(0xFF7B7B7B),
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
                                padding: EdgeInsets.only(top: 10.0),
                                child: Column(children: [
                                  Text('No Data',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'san',
                                        fontSize: 24,
                                      ))
                                ]),
                              ),
                            const SizedBox(height: 200),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class CustomCircle extends StatelessWidget {
  final String img;

  const CustomCircle({Key? key, required this.img}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 83,
      height: 103,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 100,
            height: 130,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FutureBuilder<Image>(
                future: AppUtils.getImagePath(img),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return snapshot.data!;
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
