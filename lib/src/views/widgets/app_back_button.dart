import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBackButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onPressed;
  final bool isIosStyle;

  const AppBackButton({super.key, this.color, this.onPressed, this.isIosStyle = false});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isIosStyle ? Icons.arrow_back_ios_new : Icons.arrow_back, color: color ?? Theme.of(context).iconTheme.color, size: 24.w),
      onPressed: onPressed ?? () => Navigator.pop(context),
    );
  }
}
