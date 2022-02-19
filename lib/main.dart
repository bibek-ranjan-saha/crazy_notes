import 'package:crazy_notes/constants/colors.dart';
import 'package:crazy_notes/pages/home.dart';
import 'package:crazy_notes/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'controllers/google_auth.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //FlutterNativeSplash.removeAfter(initialization);
  await Firebase.initializeApp(
      // options: const FirebaseOptions(
      //     apiKey: "AIzaSyDIBITChHcPb1C9KAglFM2gAfewibrQ1Kw",
      //     projectId: "crazy-notes-12b1d",
      //     messagingSenderId: "1023547289875",
      //     appId: "1:1023547289875:web:450fd2e52ef8d7b923eae6",
      // ),
      );
  bool result = auth.currentUser?.uid != null;
  runApp(
    MaterialApp(
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeManager.themeMode,
        builder: EasyLoading.init(),
        debugShowCheckedModeBanner: false,
        home: result ? const MyHomePage() : const LoginPage()),
  );
}
