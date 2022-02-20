import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crazy_notes/pages/home.dart';
import 'package:crazy_notes/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn googleSignIn = GoogleSignIn();

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore fireStoreInstance = FirebaseFirestore.instance;
CollectionReference users = fireStoreInstance.collection('users');

signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    EasyLoading.show(
      status: "Signing in...",
    );
    if (googleSignInAccount != null) {
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);
      final UserCredential authResult =
          await auth.signInWithCredential(credential);
      final User? user = authResult.user;
      var userData = {
        'name': googleSignInAccount.displayName,
        'provider': "google",
        "email": googleSignInAccount.email,
        "photoURL": googleSignInAccount.photoUrl
      };

      users.doc(user?.uid).get().then((value) async {
        EasyLoading.showSuccess("Successful");
        if (value.exists) {
          //old account so just updating
          value.reference.update(userData);
        } else {
          //new account so creating its db
          users.doc(user?.uid).set(userData);
        }
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MyHomePage()),
            (route) => false);
      });
    }
  } on PlatformException catch (e) {
    EasyLoading.showError("failed : ${e.code.replaceAll("_", " ")}");
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
  EasyLoading.show(
    status: "Logging out...",
  );
  try {
    await googleSignIn.disconnect().whenComplete(() async {
      auth.signOut();
      EasyLoading.dismiss();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false);
    });
  } on Exception {
    EasyLoading.showError("failed");
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
