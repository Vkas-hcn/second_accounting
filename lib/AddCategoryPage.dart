import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:second_accounting/showint/AdShowui.dart';
import 'package:second_accounting/showint/ShowAdFun.dart';
import 'package:second_accounting/utils/AppUtils.dart';
import 'package:second_accounting/utils/DataUtils.dart';
import 'package:second_accounting/utils/LocalStorage.dart';
import 'package:second_accounting/wig/ImageDialog.dart';
import 'MainApp.dart';
import 'data/CateBean.dart';
import 'data/ZhiShou.dart';

class AddCategoryPage extends StatefulWidget {
  final int type;

  AddCategoryPage({super.key, required this.type});

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  final TextEditingController _textEditingController = TextEditingController();
  int selectedIndex = 0;
  List<CateBean> cateBeanList = [];
  late ShowAdFun adManager;
  final AdShowui _loadingOverlay = AdShowui();

  @override
  void initState() {
    super.initState();
    adManager = AppUtils.getMobUtils(context);
    initData();
  }

  void initData() {
    getImageData(0);
    setState(() {});
  }

  Future<String> getImageData(index) async {
    return await DataUtils.getImageByText(DataUtils.zongText[index]);
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

  //增加分类数据
  void addCategory() async {
    if (_textEditingController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter the name');
      return;
    }
    List<String> categoryText = LocalStorage().getCategoryText();
    List<String> categoryImage = LocalStorage().getCategoryImage();
    List<String> categoryInComeText = LocalStorage().getIncomeTextCategory();
    List<String> categoryIncomeImage = LocalStorage().getIncomeImageCategory();
    if (widget.type == 1) {
      DataUtils.expensesText.add(_textEditingController.text);
      DataUtils.expensesImage.add(await getImageData(selectedIndex));
      categoryText.add(_textEditingController.text);
      categoryImage.add(await getImageData(selectedIndex));
      LocalStorage().saveCategoryText(categoryText);
      LocalStorage().saveCategoryImage(categoryImage);
    } else {
      DataUtils.incomeText.add(_textEditingController.text);
      DataUtils.incomeImage.add(await getImageData(selectedIndex));
      categoryInComeText.add(_textEditingController.text);
      categoryIncomeImage.add(await getImageData(selectedIndex));
      LocalStorage().saveIncomeTextCategory(categoryInComeText);
      LocalStorage().saveIncomeImageCategory(categoryIncomeImage);
    }
    CateBean newCateBean = CateBean(
      cateName: _textEditingController.text,
      cateImage: await getImageData(selectedIndex),
    );
    cateBeanList = await CateBean.getCateList();
    cateBeanList.add(newCateBean);
    CateBean.saveCateList(cateBeanList);
    final String? jsonStr =
        await LocalStorage().getValue(LocalStorage.cateJson);

    print("cateBeanList==${jsonStr}");
    Fluttertoast.showToast(msg: 'Saved successfully');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(
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
                      const SizedBox(width: 4),
                      const Text(
                        'Add Category',
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
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Name",
                        style: TextStyle(
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                Padding(
                    padding:
                        const EdgeInsets.only(top: 2.0, left: 20, right: 20),
                    child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF000000)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            maxLength: 25,
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
                              hintText: 'Enter',
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFA8A8A8),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ))),
                const Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Icon",
                        style: TextStyle(
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: DataUtils.zongText.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FutureBuilder<String>(
                              future: getImageData(index),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: selectedIndex == index
                                              ? Color(0xFFF3AA20)
                                              : Color(0xFFDCDCDC),
                                          width: 1,
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: Image.asset(snapshot.data!),
                                      ),
                                    );
                                  }
                                } else {
                                  return Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: selectedIndex == index
                                            ? Color(0xFFF3AA20)
                                            : Color(0xFFDCDCDC),
                                        width: 1,
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DataUtils.zongText[index],
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
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    addCategory();
                  },
                  child: SizedBox(
                    width: 220,
                    height: 48,
                    child: Image.asset('assets/images/ic_add_ca.webp'),
                  ),
                ),
                const SizedBox(
                  height: 12,
                )
              ],
            )),
      ),
    );
  }
}
