import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onToggleVisibility;
  final TextInputType? keyboardType;
  final String? prefixText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  final TextAlign textAlign;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? height;
  final double? horizontalPadding;
  final TextStyle? textStyle;
  final bool hasBorder;
  final String? label;
  final bool optional;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onToggleVisibility,
    this.keyboardType,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.autofocus = false,
    this.backgroundColor,
    this.borderRadius,
    this.height,
    this.horizontalPadding,
    this.textStyle,
    this.hasBorder = true,
    this.label,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBackgroundColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;

    Widget textField = Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 28.r),
        border: hasBorder ? Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)) : null,
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        textAlign: textAlign,
        maxLength: maxLength,
        focusNode: focusNode,
        onChanged: onChanged,
        autofocus: autofocus,
        style: textStyle ?? TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 16.sp, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixText: prefixText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[500], size: 20.w) : null,
          prefixStyle: textStyle ?? TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 16.sp, fontWeight: FontWeight.w500),
          counterText: "",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 24.w, vertical: height != null ? (height! - 24.sp) / 2 : 16.h),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey, size: 20.w),
                  onPressed: onToggleVisibility,
                )
              : suffixIcon,
        ),
      ),
    );

    if (label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
            child: RichText(
              text: TextSpan(
                text: label!,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 14.sp, fontWeight: FontWeight.bold),
                children: [
                  if (optional)
                    TextSpan(
                      text: " (Optional)",
                      style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.normal, fontSize: 13.sp),
                    ),
                ],
              ),
            ),
          ),
          textField,
        ],
      );
    }

    return textField;
  }
}
