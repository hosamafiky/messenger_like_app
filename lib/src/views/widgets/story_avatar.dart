import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../models/story_model.dart';
import 'app_avatar.dart';

class StoryAvatar extends StatelessWidget {
  final Story story;

  const StoryAvatar({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    // Check if it's the "Add Story" type (simplistic check for "Your Story")
    final isMyStory = story.user.id == 'me';

    return Column(
      children: [
        Stack(
          children: [
            AppAvatar(
              avatarUrl: story.user.avatarUrl,
              name: story.user.name,
              size: 72,
              borderColor: isMyStory ? Colors.transparent : (story.isViewed ? Colors.transparent : AppColors.primary),
              borderWidth: isMyStory ? 0 : 2,
              padding: isMyStory ? 0 : 3,
            ),
            // Online indicator or Add button
            if (isMyStory)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3.w),
                  ),
                  child: Center(
                    child: Icon(Icons.add, size: 16.w, color: AppColors.textMainLight),
                  ),
                ),
              )
            else if (!story.isViewed)
              Positioned(
                bottom: 2.h,
                right: 2.w,
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: AppColors.online,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2.w),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          story.user.name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}
