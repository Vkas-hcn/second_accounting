import 'package:flutter/material.dart';

class LTFDW extends WidgetsBindingObserver {
  final Function onAppResumed;
  final Function onAppPaused;

  LTFDW({required this.onAppResumed, required this.onAppPaused});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        onAppResumed();
        break;
      case AppLifecycleState.paused:
        onAppPaused();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
      default:
        break;
    }
  }
}
