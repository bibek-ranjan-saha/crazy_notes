import 'package:crazy_notes/controllers/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:switcher_button/switcher_button.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<AppSettings> {
  late SharedPreferences prefs;
  bool enableAuth = false;
  bool mode = false;

  @override
  void initState() {
    super.initState();
    getInstance();
    mode = ThemeBuilder.of(context).getBrightness();
  }

  getInstance() async {
    setState(() async {
      prefs = await SharedPreferences.getInstance();
      enableAuth = prefs.getBool("auth") ?? false;
    });
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
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        // enableAuth
                        //     ? "  Disable local auth methods"
                        //     : "  Enable local auth method",
                        "use biometric authentication",
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w700),
                        maxLines: 1,
                      ),
                    ),
                    SwitcherButton(
                        value: enableAuth,
                        onColor: Colors.black,
                        offColor: Colors.limeAccent,
                        onChange: (value) async {
                          setState(() {
                            enableAuth = !enableAuth;
                          });
                          await prefs.setBool("auth", enableAuth);
                        }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        // !mode ? "  turn on dark mode" : "  turn off dark mode",
                        "wanna use dark mode",
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w700),
                        maxLines: 1,
                      ),
                    ),
                    SwitcherButton(
                        value: mode,
                        onColor: Colors.black,
                        offColor: Colors.limeAccent,
                        onChange: (value) {
                          setState(() {
                            ThemeBuilder.of(context).changeTheme();
                            mode = !mode;
                          });
                        }),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
