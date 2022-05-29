import 'package:crazy_notes/controllers/local_home_controller.dart';
import 'package:crazy_notes/controllers/theme_manager.dart';
import 'package:crazy_notes/pages/home.dart';
import 'package:crazy_notes/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/google_auth.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //FlutterNativeSplash.removeAfter(initialization);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
      // options: const FirebaseOptions(
      //     apiKey: "AIzaSyDIBITChHcPb1C9KAglFM2gAfewibrQ1Kw",
      //     projectId: "crazy-notes-12b1d",
      //     messagingSenderId: "1023547289875",
      //     appId: "1:1023547289875:web:450fd2e52ef8d7b923eae6",
      // ),
      );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool result = auth.currentUser?.uid != null;
  late bool isLocalAuthenticated;


  @override
  void initState() {
    setupAuth();
    super.initState();
  }

  setupAuth() async
  {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool toAuth = prefs.getBool("auth") ?? false;
    await LocalAuthController().authenticateUser();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(builder: (context, _brightness) {
      EasyLoading.instance
        ..indicatorType = EasyLoadingIndicatorType.ring
        ..loadingStyle = EasyLoadingStyle.dark
        ..indicatorSize = 45.0
        ..radius = 10.0
        ..maskColor = Colors.blue.withOpacity(0.5)
        ..userInteractions = true
        ..dismissOnTap = false;
      return MaterialApp(
          theme: ThemeData(
            floatingActionButtonTheme:
                const FloatingActionButtonThemeData(backgroundColor: Colors.limeAccent),
            primarySwatch: Colors.lime,
            brightness: _brightness,
            iconTheme: IconThemeData(
                color: _brightness == ThemeMode.dark
                    ? Colors.white
                    : Colors.black),
            popupMenuTheme: PopupMenuThemeData(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
          builder: EasyLoading.init(),
          debugShowCheckedModeBanner: false,
          home: result ? const MyHomePage() : const LoginPage());
    });
  }
}
