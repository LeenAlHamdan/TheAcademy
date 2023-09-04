import 'package:flutter/material.dart';

class Themes {
  static Color textColor = Colors.black;
  static Color greenColor = Color(0xFF17B471);
  static Color offerColor = Color(0xffffb610);
  static Color gradientColor1 = Color(0xff3ccaff);
  static Color gradientColor2 = Color(0xffff83f1);
  static Color gradientMerged = Color(0xff95AAF9);
  static Color primaryColor = Color(0xFF2184C7);
  static Color primaryColorDark = Color(0xFF6E6E6E);
  static Color primaryColorDarkLighted = Color(0xFFC5C5C5);
  static Color buttonColor = Color(0xFFF2F3F8);
  static Color primaryColorLight = Colors.white;
  static Color primaryColorLightDark = Color.fromARGB(255, 215, 208, 208);
  static Color appBarBackground = Colors.transparent;
  static Color chatBackground = Color.fromARGB(255, 214, 211, 211);

  static final Gradient linearGradient = LinearGradient(
    colors: <Color>[gradientColor1, gradientColor2],
  );
  static final Gradient linearGradientReversed = LinearGradient(
    colors: <Color>[gradientColor2, gradientColor1],
  );

  static final Shader linearGradientShader =
      linearGradient.createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  static late ThemeData customLightTheme = ThemeData.light().copyWith(
    primaryColor: primaryColor,
    primaryColorLight: primaryColorLight,
    primaryColorDark: primaryColorDark,
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(backgroundColor: appBarBackground),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: primaryColor),
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'MarkaziText',
        ),
  );

  static late ThemeData customDarkTheme = ThemeData.dark().copyWith(
    primaryColor: primaryColor,
    primaryColorLight: primaryColorDark,
    primaryColorDark: primaryColorLightDark,
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(backgroundColor: appBarBackground),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: primaryColor,
      brightness: Brightness.dark,
      background: ThemeData.dark().colorScheme.background,
    ),
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'MarkaziText',
        ),
  );

  static Color textColorDark = Colors.white;
}

extension ColorX on Color {
  String toHexTriplet() =>
      '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
