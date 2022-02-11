import 'package:flutter/material.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<AppSettings> {
  bool enableAuth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Card(
              elevation: 18,
              child: Column(
                children: [
                  Expanded(
                    child: Text(
                      enableAuth
                          ? "Disable local auth methods"
                          : "Enable local auth method",
                      style: const TextStyle(
                          fontSize: 22,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                    ),
                  ),
                  Switch.adaptive(
                      value: enableAuth,
                      onChanged: (value) {
                        setState(() {
                          enableAuth = !enableAuth;
                        });
                      }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
