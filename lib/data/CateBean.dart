import 'dart:convert';

import '../utils/LocalStorage.dart';

class CateBean {
  String? cateName;
  String? cateImage;

  CateBean({this.cateName, this.cateImage});
  Map<String, dynamic> toJson() {
    return {
      'cateName': cateName,
      'cateImage': cateImage,
    };
  }

  factory CateBean.fromJson(Map<String, dynamic> json) {
    return CateBean(
      cateName: json['cateName'],
      cateImage: json['cateImage'],
    );
  }

  //存储List<CateBean>到本地
  static void saveCateList(List<CateBean> cateBeanList) async {
    List<Map<String, dynamic>> jsonList =
    cateBeanList.map((cate) => cate.toJson()).toList();
    await LocalStorage().setValue(LocalStorage.cateJson, jsonEncode(jsonList));
  }

  // 读取本地 List<CateBean> 数据
  static Future<List<CateBean>> getCateList() async {
    final String? jsonStr = await LocalStorage().getValue(LocalStorage.cateJson);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((json) => CateBean.fromJson(json)).toList();
  }

  // 根据 cateName 返回 cateImage
  static Future<String> getCateImageByName(String cateName) async {
    print("getCateImageByName=${cateName}");
    final List<CateBean> cateList = await getCateList();
    print("cateList == cateList=${cateList[0].cateName}----${cateList[0].cateImage}");

    for (var cate in cateList) {
      if (cate.cateName == cateName) {
        print("cate.cateImage == cateImage=${cate.cateImage}");
        return cate.cateImage ?? "assets/images/group_dinning.webp";
      }
    }
    return "assets/images/group_dinning.webp";
  }


  // 根据 cateImage 返回 cateName
  static Future<String> getCateNameByImage(String cateImage) async {
    final List<CateBean> cateList = await getCateList();
    for (var cate in cateList) {
      if (cate.cateImage == cateImage) {
        return cate.cateName ?? "Dining";
      }
    }
    return "Dining";
  }
}
