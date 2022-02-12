import 'dart:async';
import 'package:crazy_notes/controllers/google_auth.dart';
import 'package:crazy_notes/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  doNow() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        if (auth.currentUser?.uid != null) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MyHomePage()));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()));
        }
      }
    });
  }

  @override
  void initState() {
    doNow();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Lottie.asset('assets/lottie/confusion.json', fit: BoxFit.cover),
        // Text(
        //   "Hey,\nNotes App Welcomes You",
        //   style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
        // ),
      ),
    );
  }
}
