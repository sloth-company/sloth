import 'package:flutter/material.dart';
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
//          Container(
//            width: MediaQuery.of(context).size.width,
//            height: MediaQuery.of(context).size.height,
//            color: Colors.transparent,
//            child: GestureDetector(
//              onTap: () => _promptRemoveTodoItem(todoTask),
//            ),
//          ),
//          IconButton(
//              icon: Icon(Icons.create),
//              onPressed: () => _pushEditTodoScreen(todoTask),
//          ),
}