import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:second_accounting/showint/Get2Data.dart';
import 'package:second_accounting/utils/LocalStorage.dart';

import 'Guide.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalStorage().init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: LocalStorage.navigatorKey,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    print("object=================main");
    Get2Data().getBlackList(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageToHome();
    });
  }

  void pageToHome() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Guide()),
        (route) => route == null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
