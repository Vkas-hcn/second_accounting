import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

import '../showint/ShowAdFun.dart';

class AppUtils {
  static Future<Image> getImagePath(String name) async {
    print('Loading image: $name');
    if (name.startsWith('assets/')) {
      return Image.asset(
        name,
        fit: BoxFit.cover,
      );
    } else {
      try {
        final String persistentPath = await getPersistentImagePath(name);
        return Image.file(
          File(persistentPath),
          fit: BoxFit.cover,
        );
      } catch (e) {
        print('Error loading image file: $e');
        throw e;
      }
    }
  }

  static Future<Image> getImagePath2(String name) async {
    if (name.startsWith('assets/')) {
      return Image.asset(
        name,
        fit: BoxFit.fill,
      );
    } else {
      try {
        final String persistentPath = await getPersistentImagePath(name);
        return Image.file(
          File(persistentPath),
          fit: BoxFit.fill,
        );
      } catch (e) {
        print('Error loading image file: $e');
        throw e;
      }
    }
  }

  static Future<String> getPersistentImagePath(String originalPath) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String fileName = originalPath.split('/').last; // 获取文件名
    final String newPath = '${appDocDir.path}/$fileName';
    return newPath;
  }

  static ShowAdFun getMobUtils(BuildContext context) {
    final adManager = ShowAdFun(context);
    return adManager;
  }

  // static Future<void> showScanAd(
  //   BuildContext context,
  //   AdWhere adPosition,
  //   int moreTime,
  //   bool isTwo,
  //   Function() loadingFun,
  //   Function() nextFun,
  // ) async {
  //   final Completer<void> completer = Completer<void>();
  //   var isCancelled = false;
  //
  //   void cancel() {
  //     isCancelled = true;
  //     completer.complete();
  //   }
  //
  //   Future<void> _checkAndShowAd() async {
  //     bool colckState = await ShowAdFun.blacklistBlocking();
  //     if (colckState) {
  //       nextFun();
  //       return;
  //     }
  //     if (isTwo && !AppUtils.shouldLoadAd()) {
  //       nextFun();
  //       return;
  //     }
  //     // 判断广告是否可以展示
  //     if (!getMobUtils(context).canShowAd(adPosition)) {
  //       // 加载广告
  //       getMobUtils(context).loadAd(adPosition);
  //     }
  //
  //     // 等待广告加载完成
  //     if (getMobUtils(context).canShowAd(adPosition)) {
  //       loadingFun();
  //       getMobUtils(context).showAd(context, adPosition, () {
  //         // 广告展示后，确保广告数据被清理
  //         getMobUtils(context).clearAdCache(adPosition); // 清理广告缓存
  //         getMobUtils(context).loadAd(adPosition); // 重新加载广告
  //         nextFun();
  //       });
  //       return;
  //     }
  //
  //     // 如果广告未加载成功，重新检查
  //     if (!isCancelled) {
  //       await Future.delayed(const Duration(milliseconds: 500));
  //       await _checkAndShowAd();
  //     }
  //   }
  //
  //   // 超过指定时间取消广告展示
  //   Future.delayed(Duration(seconds: moreTime), cancel);
  //   await Future.any([
  //     _checkAndShowAd(),
  //     completer.future,
  //   ]);
  //
  //   if (!completer.isCompleted) {
  //     return;
  //   }
  //   print("插屏广告展示超时");
  //   nextFun();
  // }

  static int _loadCount = 0;

  static bool shouldLoadAd() {
    print('shouldLoadAd');

    _loadCount++;
    return _loadCount % 3 == 0;
  }
}
