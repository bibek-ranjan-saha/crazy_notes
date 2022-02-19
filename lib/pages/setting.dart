import 'package:flutter/material.dart';
import '../controllers/google_auth.dart';
import '../controllers/theme_manager.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<AppSettings> {
  bool enableAuth = false;

  @override
  void dispose() {
    themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    themeManager = ThemeManager();
    themeManager.addListener(themeListener);
    super.initState();
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
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
                    child: Text(
                      themeManager.themeMode == ThemeMode.dark
                          ? "  Disable dark mode"
                          : "  Enable dark mode",
                      style: const TextStyle(
                          fontSize: 22,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                    ),
                  ),
                  Switch.adaptive(
                      value: themeManager.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        setState(() {
                          themeManager.toggleTheme(value);
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
