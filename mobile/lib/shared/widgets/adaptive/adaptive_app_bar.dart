import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? leading;

  const AdaptiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.leading,
  });

  @override
  Size get preferredSize => Platform.isIOS
      ? const Size.fromHeight(44)
      : const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoNavigationBar(
        middle: Text(title, style: const TextStyle(color: kPrimaryText, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: kBorder, width: 0.5)),
        leading: showBack && Navigator.canPop(context)
            ? CupertinoNavigationBarBackButton(color: kPrimaryText)
            : leading,
        trailing: actions != null ? Row(mainAxisSize: MainAxisSize.min, children: actions!) : null,
      );
    }
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: showBack,
    );
  }
}
