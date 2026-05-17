import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Clean Wise-style list row with leading icon container, title, subtitle, trailing.
class WiseListTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBg;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool showChevron;

  const WiseListTile({
    super.key,
    required this.icon,
    this.iconColor,
    this.iconBg,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          splashColor: kAccent.withValues(alpha: 0.05),
          highlightColor: kAccent.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBg ?? kElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor ?? kSecondaryText),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          style: const TextStyle(
                            color: kPrimaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          )),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!,
                            style: const TextStyle(color: kSecondaryText, fontSize: 13)),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!
                else if (showChevron)
                  const Icon(Icons.chevron_right_rounded, color: kTertiaryText, size: 20),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 0, indent: 68),
      ],
    );
  }
}

/// Section wrapper with optional header.
class WiseListSection extends StatelessWidget {
  final String? header;
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  const WiseListSection({
    super.key,
    this.header,
    required this.children,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
            child: Text(header!.toUpperCase(),
                style: const TextStyle(
                  color: kSecondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                )),
          ),
        ],
        Container(
          margin: margin,
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
        ),
      ],
    );
  }
}
