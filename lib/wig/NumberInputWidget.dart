import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:second_accounting/utils/LocalStorage.dart';

import '../utils/DataUtils.dart';

class NumberInputWidget extends StatefulWidget {
  final void Function(String) onAdd;
  final void Function(String) again;
  final void Function(String) seassets;

  final String stateImage;

  const NumberInputWidget(
      {Key? key,
        required this.onAdd,
        required this.stateImage,
        required this.again,
        required this.seassets})
      : super(key: key);

  @override
  _NumberInputWidgetState createState() => _NumberInputWidgetState();
}

class _NumberInputWidgetState extends State<NumberInputWidget> {
  String _input = '';
  String formattedDate = '';
  DateTime selectedDate = DateTime.now();

  Widget _buildNumberButton(String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_input.length > 5) return;
          _input += value;
        });
      },
      child: Container(
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: Text(
          textAlign: TextAlign.center,
          value,
          style: const TextStyle(fontSize: 21),
        ),
      ),
    );
  }

  void _deleteLastCharacter() {
    if (_input.isNotEmpty) {
      setState(() {
        _input = _input.substring(0, _input.length - 1);
      });
    }
  }

  void addFun(bool isAdd) async {
    if (_input.isEmpty || _input == '0' || _input == "") {
      DataUtils.showToast("The amount is incorrect");
      return;
    }
    RegExp regExp = RegExp(r'^[0-9]+(\.[0-9]+)?$');
    if (!regExp.hasMatch(_input)) {
      DataUtils.showToast("Please enter a valid number");
      return;
    }
    await LocalStorage().setSelectedDateLocal(formattedDate);
    if (isAdd) {
      widget.onAdd(_input);
    } else {
      widget.again(_input);
    }
    setState(() {
      _input = ''; // 清空输入
    });
  }

  @override
  Widget build(BuildContext context) {
    formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _input.isEmpty ? '0' : _input,
                  style: const TextStyle(
                      fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  selectDate(context);
                },
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
                  alignment: Alignment.topLeft,
                  decoration: BoxDecoration(
                    color: const Color(0xFF85FFC8),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    formattedDate,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              widget.stateImage.isNotEmpty
                  ? SizedBox(
                width: 48,
                height: 48,
                child: Image.asset(widget.stateImage),
              )
                  : SizedBox(),
            ],
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Color(0xFFE6DDCA),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(flex: 2, child: _buildNumberButton('1')),
                  Expanded(flex: 2, child: _buildNumberButton('2')),
                  Expanded(flex: 2, child: _buildNumberButton('3')),
                  Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () {
                          widget.seassets(_input);
                        },
                        child: Container(
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            textAlign: TextAlign.center,
                            "",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(flex: 2, child: _buildNumberButton('4')),
                  Expanded(flex: 2, child: _buildNumberButton('5')),
                  Expanded(flex: 2, child: _buildNumberButton('6')),
                  Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () {
                          _deleteLastCharacter();
                        },
                        child: Container(
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            textAlign: TextAlign.center,
                            "X",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(flex: 2, child: _buildNumberButton('7')),
                  Expanded(flex: 2, child: _buildNumberButton('8')),
                  Expanded(flex: 2, child: _buildNumberButton('9')),
                  Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () {
                          addFun(true);
                        },
                        child: Container(
                          height: 60,
                          alignment: Alignment.bottomCenter,
                          decoration: const BoxDecoration(
                            color: Color(0xFF7FE3DB),
                            border: Border(
                              right: BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                              left: BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                              top: BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            textAlign: TextAlign.center,
                            "Record",
                            style: TextStyle(fontSize: 21),
                          ),
                        ),
                      )),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          addFun(false);
                        },
                        child: Container(
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xFFFF8370),
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            textAlign: TextAlign.center,
                            "Record Again",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                  Expanded(flex: 2, child: _buildNumberButton('0')),
                  Expanded(flex: 2, child: _buildNumberButton('.')),
                  Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () {
                          addFun(true);
                        },
                        child: Container(
                          height: 60,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFF7FE3DB),
                            border: Border(
                              right: BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                              left: BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                              bottom: BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            textAlign: TextAlign.center,
                            "",
                            style: TextStyle(fontSize: 21),
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> selectDate(BuildContext context) async {
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
    }
  }
}
