import 'package:flutter/material.dart';
import 'package:second_accounting/showint/AdShowui.dart';
import 'package:second_accounting/showint/ShowAdFun.dart';
import 'package:second_accounting/utils/AppUtils.dart';
import 'package:second_accounting/utils/DataUtils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingIndexPage extends StatefulWidget {
  const SettingIndexPage({super.key});

  @override
  _SettingIndexPageState createState() => _SettingIndexPageState();
}

class _SettingIndexPageState extends State<SettingIndexPage>
    with SingleTickerProviderStateMixin {
  late ShowAdFun adManager;
  final AdShowui _loadingOverlay = AdShowui();

  @override
  void initState() {
    super.initState();
    adManager = AppUtils.getMobUtils(context);
  }

  void nextJump() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          nextJump();
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
                          nextJump();
                        },
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Image.asset('assets/images/icon_back.webp'),
                        ),
                      ),
                      SizedBox(width: 4),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          color: Color(0xFF222222),
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 48, bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      Share.share(
                          "https://book.flutterchina.club/chapter6/keepalive.html#_6-8-1-automatickeepalive");
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 20),
                        child: Row(
                          children: [
                            Image.asset(
                                width: 20,
                                height: 20,
                                'assets/images/ic_share.webp'),
                            const SizedBox(width: 12),
                            const Text(
                              'Share',
                              style: TextStyle(
                                color: Color(0xFF222222),
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Image.asset(
                                width: 20,
                                height: 20,
                                'assets/images/icon_be.webp')
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      launchURL();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 20),
                        child: Row(
                          children: [
                            Image.asset(
                                width: 20,
                                height: 20,
                                'assets/images/icon_pp.webp'),
                            const SizedBox(width: 12),
                            const Text(
                              'Privacy Policy',
                              style: TextStyle(
                                color: Color(0xFF222222),
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Image.asset(
                                width: 20,
                                height: 20,
                                'assets/images/icon_be.webp')
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      launchUserAgreement();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 20),
                        child: Row(
                          children: [
                            Image.asset(
                                width: 20,
                                height: 20,
                                'assets/images/icon_tos.webp'),
                            const SizedBox(width: 12),
                            const Text(
                              'Terms Of Service',
                              style: TextStyle(
                                color: Color(0xFF222222),
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Image.asset(
                                width: 20,
                                height: 20,
                                'assets/images/icon_be.webp')
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  void launchURL() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.blooming.unlimited.fast';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      DataUtils.showToast('Cant open web page $url');
    }
  }

  void launchComment() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.blooming.unlimited.fast';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      DataUtils.showToast('Cant open web page $url');
    }
  }

  void launchUserAgreement() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.blooming.unlimited.fast';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      DataUtils.showToast('Cant open web page $url');
    }
  }
}
