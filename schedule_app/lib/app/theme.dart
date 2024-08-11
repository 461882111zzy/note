import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;

final AccentColor lightBlue = AccentColor.swatch(const <String, Color>{
  'darkest': Color.fromARGB(255, 27, 125, 254),
  'darker': Color.fromARGB(255, 26, 125, 253),
  'dark': Color.fromARGB(255, 29, 127, 254),
  'normal': Color(0xFF2A85FF),
  'light': Color.fromARGB(255, 54, 136, 244),
  'lighter': Color.fromARGB(255, 70, 150, 255),
  'lightest': Color.fromARGB(255, 83, 155, 250),
});

class CardBoardColor extends ThemeExtension<CardBoardColor> {
  final Color color;
  const CardBoardColor(
    this.color,
  );

  @override
  ThemeExtension<CardBoardColor> copyWith() {
    return CardBoardColor(color);
  }

  static CardBoardColor defaultValue() {
    return const CardBoardColor(Colors.white);
  }

  @override
  ThemeExtension<CardBoardColor> lerp(
      covariant CardBoardColor? other, double t) {
    return CardBoardColor(
      Color.lerp(color, other?.color, t)!,
    );
  }
}

final lightTheme = FluentThemeData(
    brightness: Brightness.light,
    typography: Typography.fromBrightness(
        brightness: Brightness.light, color: const Color(0xFF4F4F4F)),
    fontFamily: Platform.isWindows ? '微软雅黑' : null,
    accentColor: lightBlue,
    cardColor: Colors.white,
    scaffoldBackgroundColor:const Color(0xefffffff),
    acrylicBackgroundColor: const Color(0xefffffff),
    extensions: const [CardBoardColor(Color(0xFFE6E4F0))]);

final darkTheme = FluentThemeData(
    brightness: Brightness.dark,
    fontFamily: Platform.isWindows ? '微软雅黑' : null,
    accentColor: lightBlue,
    extensions: const [CardBoardColor(Color(0xFF1E1E1E))]);

extension FluentThemeDataToThemeData on FluentThemeData {
  material.TextTheme getTextTheme(Typography typography) {
    return material.TextTheme(
      displayLarge: typography.display,
      displayMedium: typography.display, // h3
      displaySmall: typography.display, // h4
      titleLarge: typography.title,
      titleMedium: typography.title, // heading
      titleSmall: typography.subtitle, // subheading
      bodyMedium: typography.body, // body-regular
      bodySmall: typography.caption,
    );
  }

  material.ThemeData toThemeData() {
    return material.ThemeData(
      brightness: brightness,
      visualDensity: visualDensity,
      primaryColor: accentColor,
      secondaryHeaderColor: accentColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      bottomSheetTheme: material.BottomSheetThemeData(
        backgroundColor: Colors.blue,
      ),
      cardColor: cardColor,
      canvasColor: scaffoldBackgroundColor,
      textTheme: getTextTheme(typography),
      inputDecorationTheme: const material.InputDecorationTheme(
        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      ),
      dialogTheme: material.DialogTheme(
        backgroundColor: acrylicBackgroundColor,
        shadowColor: shadowColor,
        surfaceTintColor: micaBackgroundColor,
      ),
      dialogBackgroundColor: acrylicBackgroundColor,
      iconTheme: iconTheme,
      tooltipTheme: material.TooltipThemeData(
        textStyle: tooltipTheme.textStyle,
        height: tooltipTheme.height,
        padding: tooltipTheme.padding,
        margin: tooltipTheme.margin,
        verticalOffset: tooltipTheme.verticalOffset,
        preferBelow: tooltipTheme.preferBelow,
        decoration: tooltipTheme.decoration,
        waitDuration: tooltipTheme.waitDuration,
        showDuration: tooltipTheme.showDuration,
      ),
      cardTheme: material.CardTheme(
        color: cardColor,
        shadowColor: shadowColor,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accentColor,
        selectionHandleColor: selectionColor,
      ),
      popupMenuTheme: material.PopupMenuThemeData(
        color: acrylicBackgroundColor,
        shadowColor: shadowColor,
        surfaceTintColor: micaBackgroundColor,
      ),
      scrollbarTheme: material.ScrollbarThemeData(
        thumbColor: material.MaterialStateProperty.resolveWith((states) {
          return null;
        }),
      ), colorScheme: material.ColorScheme.fromSwatch(
        brightness: brightness,
        accentColor: accentColor,
        cardColor: cardColor,
        backgroundColor: scaffoldBackgroundColor,
        errorColor: Colors.red,
      ).copyWith(background: accentColor),
    );
  }
}
