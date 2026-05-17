import 'package:flutter/cupertino.dart';
import '../constants/app_colors.dart';

class CupertinoAppTheme {
  static CupertinoThemeData get dark => const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: kPrimaryText,
        primaryContrastingColor: kBlack,
        scaffoldBackgroundColor: kBlack,
        barBackgroundColor: Color(0xCC000000),
        textTheme: CupertinoTextThemeData(
          primaryColor: kPrimaryText,
          textStyle: TextStyle(color: kPrimaryText, fontSize: 17),
          navTitleTextStyle: TextStyle(
            color: kPrimaryText,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          navLargeTitleTextStyle: TextStyle(
            color: kPrimaryText,
            fontSize: 34,
            fontWeight: FontWeight.w700,
          ),
          tabLabelTextStyle: TextStyle(color: kSecondaryText, fontSize: 10),
        ),
      );
}
