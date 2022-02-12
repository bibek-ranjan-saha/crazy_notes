import 'package:flutter/material.dart';
import 'package:crazy_notes/menus/menu_item.dart';

class MenuItems {

 static List<MenuItem> item = [
  itemSettings,
  itemShare,
  itemLogout
 ];

  static MenuItem itemShare = MenuItem("Share", Icons.share);
  static MenuItem itemSettings = MenuItem("Settings", Icons.settings);
  static MenuItem itemLogout = MenuItem("Log out", Icons.logout);
}
