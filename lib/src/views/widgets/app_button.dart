import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? fontSize;
  final bool isLoading;
  final bool isFullWidth;
  final bool isOutlined;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.borderRadius,
    this.fontSize,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = isOutlined
        ? OutlinedButton.styleFrom(
            side: BorderSide(color: backgroundColor ?? Theme.of(context).dividerColor),
            foregroundColor: foregroundColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? 28.r)),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: foregroundColor ?? Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? 28.r)),
          );

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height ?? 56.h,
      child: isOutlined
          ? OutlinedButton(onPressed: isLoading ? null : onPressed, style: style, child: _buildChild(context))
          : ElevatedButton(onPressed: isLoading ? null : onPressed, style: style, child: _buildChild(context)),
    );
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 24.w,
        height: 24.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor ?? (isOutlined ? AppColors.primary : Colors.white)),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 22.w), SizedBox(width: 10.w)],
        Text(
          label,
          style: TextStyle(fontSize: fontSize ?? 17.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
