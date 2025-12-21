import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final bool isPrimary;
  final VoidCallback? onPressed;
  final double? size;

  const AppIconButton({super.key, required this.icon, this.isPrimary = false, this.onPressed, this.size});

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? 40.w;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: effectiveSize,
        height: effectiveSize,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: isPrimary ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10.r, offset: Offset(0, 4.h))] : null,
        ),
        child: Icon(icon, color: isPrimary ? Colors.white : Theme.of(context).iconTheme.color, size: (effectiveSize * 0.55).w),
      ),
    );
  }
}
