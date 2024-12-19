import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:second_accounting/showint/LTFDW.dart';
import 'package:second_accounting/showint/ShowAdFun.dart';
import 'package:second_accounting/utils/AppUtils.dart';
import 'package:second_accounting/utils/LocalStorage.dart';
import 'package:user_messaging_platform/user_messaging_platform.dart';

import 'MainApp.dart';

class Guide extends StatelessWidget {
  const Guide({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  Timer? _timerProgress;
  bool restartState = false;
  final Duration checkInterval = const Duration(milliseconds: 500);
  late LTFDW Ltfdw;
  final _ump = UserMessagingPlatform.instance;
  final String _testDeviceId = "F8F8F8A6A1ECD38483E6997F3C5220BB";
  late StreamSubscription _umpStateSubscription;
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    requestConsentInfoUpdate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startProgress();
    });
    Ltfdw = LTFDW(
      onAppResumed: _handleAppResumed,
      onAppPaused: _handleAppPaused,
    );
    WidgetsBinding.instance.addObserver(Ltfdw);
  }

  @override
  void dispose() {
    super.dispose();
  }
  void _handleAppResumed() {
    LocalStorage.isInBack = false;
    if (_pausedTime != null) {
      final timeInBackground =
          DateTime.now().difference(_pausedTime!).inSeconds;
      if (LocalStorage.clone_ad == true) {
        return;
      }
      if (timeInBackground > 3 && LocalStorage.int_ad_show == false) {
        restartState = true;
        restartApp();
      }
    }
  }

  void _handleAppPaused() {
    LocalStorage.isInBack = true;
    LocalStorage.clone_ad = false;
    _pausedTime = DateTime.now();
  }

  void restartApp() {
    LocalStorage.navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Guide()),
      (route) => false,
    );
  }

  void loadingGuideAd() {
    AppUtils.getMobUtils(context).loadAd(AdWhere.OPEN);
    Future.delayed(const Duration(seconds: 2), () {
      AppUtils.getMobUtils(context).loadAd(AdWhere.BACKINT);
      AppUtils.getMobUtils(context).loadAd(AdWhere.SAVE);
      showOpenAd();
    });
  }

  void showOpenAd() async {
    int elapsed = 0;
    const int timeout = 12000;
    const int interval = 500;
    print("准备展示open广告");
    Timer.periodic(const Duration(milliseconds: interval), (timer) {
      elapsed += interval;
      if (AppUtils.getMobUtils(context).canShowAd(AdWhere.OPEN)) {
        AppUtils.getMobUtils(context).showAd(context, AdWhere.OPEN, () {
          print("关闭广告-------");
          pageToHome();
        });
        timer.cancel();
      } else if (elapsed >= timeout) {
        print("超时，直接进入首页");
        pageToHome();
        timer.cancel();
      }
    });
  }

  void _startProgress() {
    const int totalDuration = 12000; // Total duration in milliseconds
    const int updateInterval = 50; // Update interval in milliseconds
    const int totalUpdates = totalDuration ~/ updateInterval;
    int currentUpdate = 0;
    _progress = 0.0;
    _timerProgress =
        Timer.periodic(const Duration(milliseconds: updateInterval), (timer) {
      setState(() {
        _progress = (currentUpdate + 1) / totalUpdates;
      });
      currentUpdate++;
      if (currentUpdate >= totalUpdates) {
        _timerProgress?.cancel();
      }
    });
  }

  void pageToHome() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => (MainApp())),
        (route) => route == null);
  }

  void _startMonitoringUmpState() {
    _umpStateSubscription = Stream.periodic(checkInterval).listen((_) async {
      bool umpState =
          await LocalStorage().getValue(LocalStorage.umpState) ?? false;
      if (umpState) {
        _umpStateSubscription.cancel();
        _startProgress();
        loadingGuideAd();
      }
    });
  }
  Future<void> requestConsentInfoUpdate() async {
    bool? data = await LocalStorage().getValue(LocalStorage.umpState);
    print("requestConsentInfoUpdate---${data}");
    if (data == true) {
      loadingGuideAd();
      return;
    }
    _startMonitoringUmpState();

    int retryCount = 0;
    const maxRetries = 1;

    while (retryCount <= maxRetries) {
      try {
        final info = await _ump
            .requestConsentInfoUpdate(_buildConsentRequestParameters());
        print("requestConsentInfoUpdate---->${info.consentStatus}");
        if (info.consentStatus == ConsentStatus.required) {
          showConsentForm();
        } else {
          LocalStorage().setValue(LocalStorage.umpState, true);
        }
        break;
      } catch (e) {
        if (e is PlatformException && e.code == 'timeout') {
          retryCount++;
          if (retryCount > maxRetries) {
            LocalStorage().setValue(LocalStorage.umpState, true);
            return;
          }
          print("Request timed out, retrying... ($retryCount/$maxRetries)");
          await Future.delayed(Duration(seconds: 1));
        } else {
          LocalStorage().setValue(LocalStorage.umpState, true);
          return;
        }
      }
    }
  }

  ConsentRequestParameters _buildConsentRequestParameters() {
    final parameters = ConsentRequestParameters(
      tagForUnderAgeOfConsent: false,
      debugSettings: ConsentDebugSettings(
        geography: DebugGeography.EEA,
        testDeviceIds: [_testDeviceId],
      ),
    );
    return parameters;
  }

  Future<void> showConsentForm() {
    return _ump.showConsentForm().then((info) {
      print("showConsentForm---->${info.consentStatus}");
      LocalStorage().setValue(LocalStorage.umpState, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 250),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 267,
                        height: 153,
                        child: Image.asset('assets/images/ic_s_logo.png'),
                      ),
                      const SizedBox(height: 23),
                      const Text(
                        'Daily Spend Logger',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: 'san',
                          fontSize: 24,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 67, right: 40, left: 40),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ProgressBar(
                                progress: _progress,
                                // Set initial progress here
                                height: 6,
                                borderRadius: 3,
                                backgroundColor: Color(0xFFEDEDED),
                                progressColor: Color(0xFFFE9738),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color progressColor;

  ProgressBar({
    required this.progress,
    required this.height,
    required this.borderRadius,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
