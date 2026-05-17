import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformTheme {
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;

  static Widget adaptive({
    required BuildContext context,
    required Widget Function(BuildContext) material,
    required Widget Function(BuildContext) cupertino,
  }) =>
      isIOS ? cupertino(context) : material(context);
}

extension PlatformContext on BuildContext {
  bool get isIOS => Platform.isIOS;
  bool get isAndroid => Platform.isAndroid;
}
