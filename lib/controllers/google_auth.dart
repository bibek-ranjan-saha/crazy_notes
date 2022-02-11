import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crazy_notes/pages/home.dart';
import 'package:crazy_notes/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn googleSignIn = GoogleSignIn();

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore fireStoreInstance = FirebaseFirestore.instance;
CollectionReference users = fireStoreInstance.collection('users');

String email = "";
String name = "";
String photoURL = "";

getProfileData() async {
  var profile = await users.doc(auth.currentUser?.uid).get();
    email = profile["email"];
    name = profile["name"];
    photoURL = profile["photoURL"];
}

signInWithGoogle(BuildContext context) async {
  try {
    if (kDebugMode) {
      print("done");
    }
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (builder) {
          return AlertDialog(
              shape: const CircleBorder(),
              elevation: 20,
              content: Builder(
                builder: (ctx) {
                  return Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    width: 40,
                    height: 40,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.orange,
                      ),
                    ),
                  );
                },
              ));
        });
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
            MaterialPageRoute(builder: (context) => const MyHomePage()),
            (route) => false);
      });
    }
  } on PlatformException catch (e) {
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
  try {
    await googleSignIn.disconnect().whenComplete(() async {
      auth.signOut();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false);
    });
  } on Exception {
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
