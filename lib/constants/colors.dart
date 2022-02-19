import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
      primaryColor: Colors.orange,
  appBarTheme: const AppBarTheme(foregroundColor: Colors.red,)
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.blueGrey,
  appBarTheme: const AppBarTheme(foregroundColor: Colors.green)
);