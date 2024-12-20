import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:second_accounting/showint/LTFDW.dart';
import 'package:second_accounting/showint/ShowAdFun.dart';
import 'package:second_accounting/utils/AppUtils.dart';
import 'package:second_accounting/utils/LocalStorage.dart';

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
  final String _testDeviceId = "202C0DAA36EB5148BDEA8A1E6E36A4B6";
  late StreamSubscription _umpStateSubscription;
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
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




  void _startProgress() {
    const int totalDuration = 2000; // Total duration in milliseconds
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
        pageToHome();
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
      }
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
