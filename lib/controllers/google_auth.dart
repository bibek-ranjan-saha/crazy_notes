import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crazy_notes/controllers/theme_manager.dart';
import 'package:crazy_notes/pages/home.dart';
import 'package:crazy_notes/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';

ThemeManager themeManager = ThemeManager();

GoogleSignIn googleSignIn = GoogleSignIn();

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore fireStoreInstance = FirebaseFirestore.instance;
CollectionReference users = fireStoreInstance.collection('users');

signInWithGoogle(BuildContext context) async {
  try {
    if (kDebugMode) {
      print("done");
    }
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    // showDialog(
    //     barrierDismissible: false,
    //     context: context,
    //     builder: (builder) {
    //       return AlertDialog(
    //           shape: const CircleBorder(),
    //           elevation: 20,
    //           content: Builder(
    //             builder: (ctx) {
    //               return Container(
    //                 decoration: const BoxDecoration(shape: BoxShape.circle),
    //                 width: 40,
    //                 height: 40,
    //                 child: const Center(
    //                   child: CircularProgressIndicator(
    //                     color: Colors.orange,
    //                   ),
    //                 ),
    //               );
    //             },
    //           ));
    //     });
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..maskColor = Colors.lightGreenAccent
      ..userInteractions = false
      ..backgroundColor = Colors.lightGreenAccent
      ..dismissOnTap = false;
    EasyLoading.show(
      status: "Loading...",
    );
    if (kDebugMode) {
      print("done");
    }
    if (googleSignInAccount != null) {
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      if (kDebugMode) {
        print("done");
      }
      AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);

      if (kDebugMode) {
        print("done");
      }
      final UserCredential authResult =
          await auth.signInWithCredential(credential);

      if (kDebugMode) {
        print("done");
      }
      final User? user = authResult.user;

      if (kDebugMode) {
        print("done");
      }
      var userData = {
        'name': googleSignInAccount.displayName,
        'provider': "google",
        "email": googleSignInAccount.email,
        "photoURL": googleSignInAccount.photoUrl
      };

      if (kDebugMode) {
        print("done");
      }
      users.doc(user?.uid).get().then((value) async {
        EasyLoading.dismiss();
        if (value.exists) {
          //old account so just updating
          value.reference.update(userData);
        } else {
          //new account so creating its db
          users.doc(user?.uid).set(userData);
        }
        if (kDebugMode) {
          print("done login");
        }
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MyHomePage()),
            (route) => false);
      });
    }
  } on PlatformException catch (e) {
    EasyLoading.dismiss();
    if (kDebugMode) {
      print(e.message);
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text('sorry sign in failed due to ${e.code.replaceAll("_", " ")}'),
      action: SnackBarAction(
        label: 'retry',
        onPressed: () {
          signInWithGoogle(context);
        },
      ),
    ));
    if (kDebugMode) {
      print("Signing unsuccessful");
    }
  }
}

signOut(BuildContext context) async {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..userInteractions = false
    ..dismissOnTap = false;
  EasyLoading.show(
    status: "Loading...",
  );
  try {
    await googleSignIn.disconnect().whenComplete(() async {
      auth.signOut();
      //EasyLoading.dismiss();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false);
    });
  } on Exception {
    //EasyLoading.dismiss();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('sorry sign out failed'),
      action: SnackBarAction(
        label: 'retry',
        onPressed: () {
          signOut(context);
        },
      ),
    ));
  }
}
