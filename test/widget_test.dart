// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:second_accounting/main.dart';

void main() {
  runApp(ExpensesPage());
}

class ExpensesPage extends StatefulWidget {
  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final int itemsPerPage = 8; // 每页显示的最大项数
    final totalItems = DataUtils.expensesText.length;
    final totalPages = (totalItems / itemsPerPage).ceil();

    // 分页数据
    List<List<int>> pagedData = List.generate(totalPages, (pageIndex) {
      int start = pageIndex * itemsPerPage;
      int end = (start + itemsPerPage > totalItems)
          ? totalItems
          : start + itemsPerPage;
      return List.generate(end - start, (index) => start + index);
    });

    return Scaffold(
      body: Padding(
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
                    Spacer(),
                    Row(
                      children: [
                        const Text(
                          'Expenses',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'san',
                            fontSize: 12,
                            color: Color(0xFF6ADB81),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Image.asset(
                            'assets/images/ic_expen.webp',
                            fit: BoxFit.cover,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  itemCount: totalPages,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, pageIndex) {
                    return GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 30,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: pagedData[pageIndex].map((index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              // selectedIndex = index;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Color(0xFFF3AA20),
                                      width: 1,
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: Image.asset(
                                            DataUtils.expensesImage[index]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  DataUtils.expensesText[index],
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width *
                                        0.03,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    totalPages,
                        (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.orange
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DataUtils {
  static List<String> expensesText = [
    "Food",
    "Transport",
    "Shopping",
    "Utilities",
    "Health",
    "Travel",
    "Entertainment",
    "Other",
    "Education",
    "Groceries",
    "Investment",
  ];

  static List<String> expensesImage = List.generate(
      expensesText.length, (index) => "assets/images/ic_expen.webp");
}

