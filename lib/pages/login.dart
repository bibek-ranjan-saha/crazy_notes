import 'package:crazy_notes/controllers/google_auth.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            "📔",
            style: TextStyle(
                fontSize: 154,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Create an Account to join the CrazyCommunity",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 28,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              signInWithGoogle(context);
            },
            child: const Text(
              "Continue With Google",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 56), primary: Colors.cyan),
          )
        ],
      ),
    );
  }
}
