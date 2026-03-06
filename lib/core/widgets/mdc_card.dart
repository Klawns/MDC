import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MdcCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  const MdcCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != null
              ? Border(left: BorderSide(color: borderColor!, width: 6))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
