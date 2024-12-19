import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const accountJson = 'account_json_data';
  static const cateJson = 'cateJson';
  static String clockData = "asdrddsgytu";
  static bool isInBack = false;
  static String umpState = "uuuuuummmppp";
  static bool int_ad_show = false;
  static bool clone_ad = false;

  static const selectedDateLocal = "selectedDateLocal";
  static final LocalStorage _instance = LocalStorage._internal();
  late SharedPreferences _prefs;
  static const categoryTextKey = "category_text_key";
  static const incomeTextCategoryKey = "income_text_category_key";

  static const categoryImageKey = "category_image_key";
  static const incomeImageCategoryKey = "income_image_category_key";
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  factory LocalStorage() {
    return _instance;
  }

  LocalStorage._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Set value by key
  Future<void> setValue(String key, dynamic value) async {
    if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    }
  }

  // Get value by key
  dynamic getValue(String key) {
    return _prefs.get(key);
  }

  Future<String> getSelectedDateLocal() async {
    return _prefs.getString(selectedDateLocal) ?? '';
  }

  Future<void> setSelectedDateLocal(String data) async {
    await _prefs.setString(selectedDateLocal, data);
  }

  // Save categoryText
  Future<void> saveCategoryText(List<String> categoryText) async {
    await _prefs.setStringList(categoryTextKey, categoryText);
  }

  // Get categoryText
  List<String> getCategoryText() {
    return _prefs.getStringList(categoryTextKey) ?? [];
  }

  // Save incomeTextCategory
  Future<void> saveIncomeTextCategory(List<String> incomeTextCategory) async {
    await _prefs.setStringList(incomeTextCategoryKey, incomeTextCategory);
  }

  // Get incomeTextCategory
  List<String> getIncomeTextCategory() {
    return _prefs.getStringList(incomeTextCategoryKey) ?? [];
  }





  // Save categoryText
  Future<void> saveCategoryImage(List<String> categoryText) async {
    await _prefs.setStringList(categoryImageKey, categoryText);
  }

  // Get categoryText
  List<String> getCategoryImage() {
    return _prefs.getStringList(categoryImageKey) ?? [];
  }

  // Save incomeTextCategory
  Future<void> saveIncomeImageCategory(List<String> incomeTextCategory) async {
    await _prefs.setStringList(incomeImageCategoryKey, incomeTextCategory);
  }

  // Get incomeTextCategory
  List<String> getIncomeImageCategory() {
    return _prefs.getStringList(incomeImageCategoryKey) ?? [];
  }
}
