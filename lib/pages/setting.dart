import 'package:crazy_notes/controllers/theme_manager.dart';
import 'package:flutter/material.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<AppSettings> {
  bool enableAuth = false;
  bool mode = false;

  @override
  void initState() {
    mode = ThemeBuilder.of(context).getBrightness();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              elevation: 18,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      enableAuth
                          ? "  Disable local auth methods"
                          : "  Enable local auth method",
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
            ),
            Card(
              elevation: 18,
              child: Row(
                children: [
                  Expanded(
                    child: Text(mode
                          ? "  change to light mode"
                          : "  change to dark mode",
                      style: const TextStyle(
                          fontSize: 22,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                    ),
                  ),
                  Switch.adaptive(
                      value: mode,
                      onChanged: (value) {
                        setState(() {
                          ThemeBuilder.of(context).changeTheme();
                          mode = !mode;
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
