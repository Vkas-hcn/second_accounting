import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:second_accounting/data/CateBean.dart';
import 'package:second_accounting/utils/LocalStorage.dart';

class DataUtils {
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static String getCurrentDateFormatted() {
    DateTime now = DateTime.now();
    // 格式化日期为 yyyy-MM-dd
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return formattedDate;
  }

  static Future<int> getSameSubscript(int type, String expense) async {
    List<String> list;
    if (type == 1) {
      // 创建一个副本
      list = List.from(expensesImage); // 使用副本，确保原数据不会被修改
    } else {
      // income
      list = List.from(incomeImage); // 同样为 incomeText 创建副本
    }
    String datatext = await DataUtils.getImageByText(expense);
    int index = list.indexOf(datatext);
    print("getSameSubscript-list=$list");
    print("getSameSubscript-list-image=$expensesImage");
    print("getSameSubscript-list-index=$index");
    return index;
  }

  static Future<String> getSameSubscript2(String expense) async {
    return DataUtils.getTextByImage(expense);
  }

  static saveCategory(
      List<String> categoryText, List<String> categoryImage, int type) async {
    if (type == 1) {
      LocalStorage().saveCategoryText(categoryText);
      LocalStorage().saveCategoryImage(categoryImage);
    } else {
      LocalStorage().saveIncomeTextCategory(categoryText);
      LocalStorage().saveIncomeImageCategory(categoryImage);
    }
  }

  static List<String> getHomeListImageData(int type) {
    List<String> expensesImageLocal = LocalStorage().getCategoryImage();
    List<String> incomeImageLocal = LocalStorage().getIncomeImageCategory();
    if (type == 1) {
      // expenses
      return expensesImageLocal.isEmpty ? expensesImage : expensesImageLocal;
    } else {
      // income
      return incomeImageLocal.isEmpty ? incomeImage : incomeImageLocal;
    }
  }

  static List<String> getHomeListTextData(int type) {
    List<String> expensesTextLocal = LocalStorage().getCategoryText();
    List<String> incomeTextLocal = LocalStorage().getIncomeTextCategory();
    if (type == 1) {
      // expenses
      return expensesTextLocal.isEmpty ? expensesText : expensesTextLocal;
    } else {
      // income
      return incomeTextLocal.isEmpty ? incomeText : incomeTextLocal;
    }
  }

  static List<String> getHomeListImageData2(int type) {
    if (type == 1) {
      // expenses
      return expensesImage;
    } else {
      // income
      return incomeImage;
    }
  }

  static List<String> getHomeListTextData2(int type) {
    if (type == 1) {
      // expenses
      return expensesText;
    } else {
      // income
      return incomeText;
    }
  }

  static List<String> expensesText = [
    "Dining",
    "Transportation",
    "Housing",
    "Entertainment",
    "Medical",
    "Home",
    "Social",
    "Insurance",
    "Investment",
    "Pets",
    "Hobbies",
    "Other Expenses"
  ];

  static List<String> expensesImage = [
    'assets/images/group_dinning.webp',
    'assets/images/group_travel.webp',
    'assets/images/group_housing.webp',
    'assets/images/group_entertainment.webp',
    'assets/images/group_medical.webp',
    'assets/images/group_home.webp',
    'assets/images/group_social.webp',
    'assets/images/group_insurance.webp',
    'assets/images/group_investment.webp',
    'assets/images/group_pets.webp',
    'assets/images/group_hobbies.webp',
    'assets/images/group_expenser.webp',
  ];

  static List<String> incomeText = [
    "Salary",
    "Bonus",
    "Investment",
    "Gift Money",
    "Other Income"
  ];

  static List<String> zongText = [
    "Dining",
    "Transportation",
    "Housing",
    "Entertainment",
    "Medical",
    "Home",
    "Social",
    "Insurance",
    "Investment",
    "Pets",
    "Hobbies",
    "Other Expenses",
    "Salary",
    "Bonus",
    "Investment",
    "Gift Money",
    "Other Income",
    "Shopping",
    "Sports",
    "ALL",
  ];

  static List<String> incomeImage = [
    'assets/images/group_salary.webp',
    'assets/images/group_bonus.webp',
    'assets/images/group_investment.webp',
    'assets/images/group_gift_money.webp',
    'assets/images/group_income.webp',
  ];

// 根据文字返回对应图片
  static Future<String> getImageByText(String expense) async {
    switch (expense) {
      case "Dining":
        return "assets/images/group_dinning.webp";
      case "Transportation":
        return "assets/images/group_travel.webp";
      case "Housing":
        return "assets/images/group_housing.webp";
      case "Entertainment":
        return "assets/images/group_entertainment.webp";
      case "Medical":
        return "assets/images/group_medical.webp";
      case "Home":
        return "assets/images/group_home.webp";
      case "Social":
        return "assets/images/group_social.webp";
      case "Insurance":
        return "assets/images/group_insurance.webp";
      case "Investment":
        return "assets/images/group_investment.webp";
      case "Pets":
        return "assets/images/group_pets.webp";
      case "Hobbies":
        return "assets/images/group_hobbies.webp";
      case "Other Expenses":
        return "assets/images/group_expenser.webp";
      case "Salary":
        return "assets/images/group_salary.webp";
      case "Bonus":
        return "assets/images/group_bonus.webp";
      case "Gift Money":
        return "assets/images/group_gift_money.webp";
      case "Other Income":
        return "assets/images/group_income.webp";
      case "Shopping":
        return "assets/images/group_shopping.webp";
      case "Sports":
        return "assets/images/group_sports.webp";
      case "ALL":
        return "assets/images/group_all.webp";
      default:
        return await CateBean.getCateImageByName(expense);
    }
  }

  //根据t图片返回文字
  static Future<String> getTextByImage(String image) async {
    switch (image) {
      case "assets/images/group_dinning.webp":
        return "Dining";
      case "assets/images/group_travel.webp":
        return "Transportation";
      case "assets/images/group_housing.webp":
        return "Housing";
      case "assets/images/group_entertainment.webp":
        return "Entertainment";
      case "assets/images/group_medical.webp":
        return "Medical";
      case "assets/images/group_home.webp":
        return "Home";
      case "assets/images/group_social.webp":
        return "Social";
      case "assets/images/group_insurance.webp":
        return "Insurance";
      case "assets/images/group_investment.webp":
        return "Investment";
      case "assets/images/group_pets.webp":
        return "Pets";
      case "assets/images/group_hobbies.webp":
        return "Hobbies";
      case "assets/images/group_expenser.webp":
        return "Other Expenses";
      case "assets/images/group_salary.webp":
        return "Salary";
      case "assets/images/group_bonus.webp":
        return "Bonus";
      case "assets/images/group_gift_money.webp":
        return "Gift Money";
      case "assets/images/group_income.webp":
        return "Other Income";
      case "assets/images/group_shopping.webp":
        return "Shopping";
      case "assets/images/group_sports.webp":
        return "Sports";
      case "assets/images/group_all.webp":
        return "ALL";
      default:
        return await CateBean.getCateNameByImage(image);
    }
  }
}
