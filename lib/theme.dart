import 'package:flutter/material.dart';

final ThemeData booksyTheme = getBooksyTheme();

TextTheme _getBooksyTextTheme(TextTheme base) {
  return base.copyWith(
    bodyText2: base.bodyText2!.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 16.0
    ),
    button: base.button!.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 16.0,
        color: Colors.white
    ),
  ).apply(
      fontFamily: 'NotoSans'
  );
}

ThemeData getBooksyTheme() {
  final ThemeData base = ThemeData.light();

  return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
          primary: const Color.fromRGBO(94, 23, 235, 1.0),
          secondary: const Color.fromRGBO(94, 23, 235, 0.7)
      ),
      iconTheme: base.iconTheme.copyWith(
          size: 16.0
      ),
      textTheme: _getBooksyTextTheme(base.textTheme)
  );
}