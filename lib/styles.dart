import 'package:flutter/cupertino.dart';

abstract class Styles {
  static const TextStyle userListRowText = TextStyle(
    color: Color.fromRGBO(0, 0, 0, 0.8),
    fontFamily: 'Hiragino Kaku Gothic ProN',
    fontSize: 20,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.normal,
    decoration: TextDecoration.none,
  );

  static const TextStyle userDetailNameText = TextStyle(
    color: Color.fromRGBO(0, 0, 0, 0.8),
    fontFamily: 'Hiragino Kaku Gothic ProN',
    fontSize: 40,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.none,
  );
}