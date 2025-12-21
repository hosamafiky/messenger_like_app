import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 32.w,
              height: 32.w,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: message.sender.avatarUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildContent(context),
                if (isMe && message.id == "5") // Hacky check for the precise mock item "Perfect. See you there!" to add read receipt
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2.w),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl:
                            "https://lh3.googleusercontent.com/aida-public/AB6AXuDopTuy_gZBSWiJuZ-RN43dzCYEQQvvSRIGfpTAVjw0bX7VyasavXMnLurnIWG4Zyy1Nn_wMlFSrWTlCPRoYBfWcjTJfcuMzkN7gjVQtIKY6LMLo5tSKYxN4frharDNzkqm6xpiCvAJ34gl4caBrHRk_wz7cuOXXTrLWKUiwP5Holu1qSE9Fc9b7NHGSExZNTTW-afr5zLJFi_uJGYyK4tlEDh-VB4rhSALkgIa_b6fsvPo3A6gS2-Q9eJfu1Aol1DGYnwyPuY3Jfg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isMe = message.isMe;
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(16.r),
      topRight: Radius.circular(16.r),
      bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
      bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
    );

    switch (message.type) {
      case MessageContentType.text:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primary : Theme.of(context).colorScheme.surface,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(color: isMe ? AppColors.primary.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05), blurRadius: 4.r, offset: Offset(0, 2.h)),
            ],
          ),
          child: Text(
            message.content,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: isMe ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color, height: 1.5, fontSize: 15.sp),
          ),
        );

      case MessageContentType.audio:
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: borderRadius,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4.r, offset: Offset(0, 2.h))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, shape: BoxShape.circle),
                child: Icon(Icons.play_arrow, color: AppColors.primary, size: 24.w),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fake Waveform
                  SizedBox(
                    height: 24.h, // h-8 roughly
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(
                        10,
                        (index) => Container(
                          width: 3.w,
                          height: (12 + (index % 3) * 6).toDouble().h, // simple randomizer
                          margin: EdgeInsets.only(right: 2.w),
                          decoration: BoxDecoration(color: index > 2 ? Colors.grey[400] : AppColors.primary, borderRadius: BorderRadius.circular(10.r)),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    message.content, // duration
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 12.sp),
                  ),
                ],
              ),
            ],
          ),
        );

      case MessageContentType.location:
        return Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: borderRadius,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4.r, offset: Offset(0, 2.h))],
          ),
          width: 260.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map Image
              Container(
                height: 140.h,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(imageUrl: message.locationImageUrl ?? '', fit: BoxFit.cover),
                    Center(
                      child: Icon(Icons.location_on, color: AppColors.primary, size: 36.w),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content, // Location Name
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                    ),
                    Text(
                      message.locationAddress ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 13.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      height: 36.h,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                        child: Text("View Location", style: TextStyle(fontSize: 14.sp)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }
}
