import 'package:crazy_notes/pages/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: const FirebaseOptions(
    //     apiKey: "AIzaSyDIBITChHcPb1C9KAglFM2gAfewibrQ1Kw",
    //     projectId: "crazy-notes-12b1d",
    //     messagingSenderId: "1023547289875",
    //     appId: "1:1023547289875:web:450fd2e52ef8d7b923eae6",
    // ),
  );
  runApp(const MaterialApp(debugShowCheckedModeBanner: false,home: SplashScreen()));
}
