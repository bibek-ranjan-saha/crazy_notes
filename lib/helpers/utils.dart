import '../menus/menu_item.dart';
import 'package:flutter/material.dart';

PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem(
  value: item,
  child: Row(
    children: [
      Icon(
        item.icon,
        size: 20,
      ),
      const SizedBox(
        width: 10,
      ),
      Text(item.text),
    ],
  ),
);