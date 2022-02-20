import 'package:flutter/material.dart';

class ThemeBuilder extends StatefulWidget {
  const ThemeBuilder({Key? key, required this.builder}) : super(key: key);

  final Widget Function(BuildContext context, Brightness brightness) builder;

  @override
  _ThemeBuilderState createState() => _ThemeBuilderState();

  static _ThemeBuilderState of(BuildContext context) {
    return context.findAncestorStateOfType<_ThemeBuilderState>()!;
  }
}

class _ThemeBuilderState extends State<ThemeBuilder> {
  late Brightness _brightness;

  @override
  void initState() {
    _brightness = Brightness.light;
    super.initState();
  }

  void changeTheme() {
    setState(() {
      _brightness =
          _brightness == Brightness.dark ? Brightness.light : Brightness.dark;
    });
  }

  bool getBrightness() {
    return _brightness == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _brightness);
  }
}
