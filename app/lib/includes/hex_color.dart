import 'package:flutter/material.dart';

class HexColor extends Color {
  static int _getColorFromHex(String? hex) {
    try {
      hex = (hex ?? "#000000").toUpperCase().replaceAll("#", "");
      if(hex.length == 6) {
        hex = "FF$hex";
      }
      return int.parse(hex, radix: 16);
    } catch(e){
      return int.parse("FFFFFFFF", radix: 16);
    }
  }


  static String getHexFromColor(Color color) {
    return '#${color.value.toRadixString(16).toUpperCase()}';
  }

  HexColor(final String? hexColor) : super(_getColorFromHex(hexColor));
}

Color darken(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(
        c.alpha,
        (c.red * f).round(),
        (c.green  * f).round(),
        (c.blue * f).round()
    );
}

Color lighten(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var p = percent / 100;
    return Color.fromARGB(
        c.alpha,
        c.red + ((255 - c.red) * p).round(),
        c.green + ((255 - c.green) * p).round(),
        c.blue + ((255 - c.blue) * p).round()
    );
}