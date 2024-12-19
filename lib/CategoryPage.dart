import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:second_accounting/showint/AdShowui.dart';
import 'package:second_accounting/showint/ShowAdFun.dart';
import 'package:second_accounting/utils/AppUtils.dart';
import 'package:second_accounting/utils/DataUtils.dart';
import 'package:second_accounting/utils/LocalStorage.dart';
import 'package:second_accounting/wig/ImageDialog.dart';
import 'AddCategoryPage.dart';
import 'MainApp.dart';
import 'data/ZhiShou.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with SingleTickerProviderStateMixin {
  int seletIndex = 1; //exp:1,income:0
  DateTime selectedDate = DateTime.now();
  List<String> categoryText = [];
  List<String> categoryImage = [];
  late ShowAdFun adManager;
  final AdShowui _loadingOverlay = AdShowui();

  @override
  void initState() {
    super.initState();
    adManager = AppUtils.getMobUtils(context);
    clickSelect(seletIndex);
  }

  void clickSelect(int index) {
    setState(() {
      seletIndex = index;
      categoryText = DataUtils.getHomeListTextData(seletIndex);
      categoryImage = DataUtils.getHomeListImageData(seletIndex);
      print("categoryText===expenses===${seletIndex}==${categoryText}");
      DataUtils.saveCategory(categoryText, categoryImage, seletIndex);
    });
  }

  Future<String> getImageData(index) async {
    return await DataUtils.getImageByText(categoryText[index]) ??
        'assets/images/group_dinning.webp';
  }

  void jumpToAddCategoryPage() {
    showAdNextPaper(AdWhere.SAVE, () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddCategoryPage(
              type: seletIndex,
            )),
      ).then((value) {
        clickSelect(seletIndex);
      });
    });
  }

  void deleteCategory(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm deletion"),
          content: const Text("Are you sure you want to delete this category?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () =>
                  {deleteData(index), Navigator.of(context).pop(true)},
              child: const Text("delete"),
            ),
          ],
        );
      },
    );
  }

  void deleteData(int index) {
    categoryText = DataUtils.getHomeListTextData(seletIndex);
    categoryImage = DataUtils.getHomeListImageData(seletIndex);
    if (index >= 0 && index < categoryText.length) {
      categoryText.removeAt(index);
      categoryImage.removeAt(index);
    } else {
      print("Invalid index: $index");
    }
    DataUtils.saveCategory(categoryText, categoryImage, seletIndex);
    setState(() {});
  }

  void showAdNextPaper(AdWhere adWhere, Function() nextJump) async {
    if (!adManager.canShowAd(adWhere)) {
      adManager.loadAd(adWhere);
    }
    setState(() {
      _loadingOverlay.show(context);
    });
    AppUtils.showScanAd(context, adWhere, 5, false,() {
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
                      SizedBox(width: 4),
                      const Text(
                        'Category Management',
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
                GestureDetector(
                  onTap: () {
                    jumpToAddCategoryPage();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 20.0, right: 15, left: 15, bottom: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Color(0xFFE7E7E7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        '+ Add Category',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF727272),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                if (categoryText.isNotEmpty)
                  Expanded(
                    child: ReorderableListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: categoryText.length,
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = categoryText.removeAt(oldIndex);
                        categoryText.insert(newIndex, item);
                        print(
                            "object----oldIndex=${oldIndex}---newIndex=${newIndex}");
                        print("object----categoryText=${categoryText}");
                        print(
                            "getImageData====${categoryText[newIndex]}-----${seletIndex}");
                        DataUtils.saveCategory(
                            categoryText, categoryImage, seletIndex);
                        setState(() {});
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          key: ValueKey(categoryText[index]),
                          // 确保 Key 唯一
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 11),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              FutureBuilder<String>(
                                future: getImageData(index),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError ||
                                      snapshot.data == null) {
                                    return SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: Image.asset(
                                        'assets/images/default_image.png',
                                        fit: BoxFit.fill,
                                      ),
                                    );
                                  }
                                  return SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: Image.asset(
                                      snapshot.data!,
                                      fit: BoxFit.fill,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 9),
                              Flexible(
                                child: Text(
                                  categoryText[index],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'san',
                                    fontSize: 14,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      deleteCategory(index);
                                    },
                                    child: SizedBox(
                                      width: 18,
                                      height: 16,
                                      child: Image.asset(
                                        'assets/images/ic_list_delete.png',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: SizedBox(
                                      width: 18,
                                      height: 16,
                                      child: Image.asset(
                                        'assets/images/icon_list_more.png',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                if (categoryText.isEmpty)
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
            )),
      ),
    );
  }
}
