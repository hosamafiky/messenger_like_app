import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 32.h), // pb-32 approx for bottom safe area
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5), width: 0.5.h),
        ),
      ),
      child: SafeArea(
        // Ensure safe area as well
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildActionButton(context, Icons.add_circle, filled: true),
            SizedBox(width: 8.w),
            _buildActionButton(context, Icons.camera_alt, filled: true),
            SizedBox(width: 8.w),
            _buildActionButton(context, Icons.image, filled: true),
            SizedBox(width: 8.w),
            Expanded(
              child: Container(
                constraints: BoxConstraints(minHeight: 44.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(22.r), // rounded-full
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Aa",
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                        maxLines: null,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
                        cursorColor: AppColors.primary,
                      ),
                    ),
                    Icon(Icons.sentiment_satisfied, color: Colors.grey[400], size: 24.w),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            _buildActionButton(context, Icons.mic, filled: true),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, {bool filled = false}) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        // color: filled ? Colors.grey[200] : null, // Mockup has transparent bg for icon buttons except mic maybe?
        // HTML: hover:bg-slate-200. Default transparent. text-primary.
      ),
      child: Center(
        child: Icon(icon, color: AppColors.primary, size: 28.w),
      ),
    );
  }
}
