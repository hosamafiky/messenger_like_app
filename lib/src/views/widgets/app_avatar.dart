import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double size;
  final bool showOnlineStatus;
  final bool isOnline;
  final double? borderWidth;
  final Color? borderColor;
  final double? padding;

  const AppAvatar({
    super.key,
    this.avatarUrl,
    required this.name,
    this.size = 40,
    this.showOnlineStatus = false,
    this.isOnline = false,
    this.borderWidth,
    this.borderColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').where((s) => s.isNotEmpty).map((s) => s[0].toUpperCase()).take(2).join();

    Widget avatar = Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: (borderWidth != null && borderColor != null) ? Border.all(color: borderColor!, width: borderWidth!.w) : null,
      ),
      padding: padding != null ? EdgeInsets.all(padding!.w) : null,
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle),
        clipBehavior: Clip.antiAlias,
        child: avatarUrl?.isNotEmpty == true
            ? CachedNetworkImage(
                imageUrl: avatarUrl!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => _buildInitialsPlaceholder(context, initials),
                placeholder: (context, url) => Container(color: Colors.grey[200]),
              )
            : _buildInitialsPlaceholder(context, initials),
      ),
    );

    if (showOnlineStatus) {
      return Stack(
        children: [
          avatar,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: (size * 0.3).w,
              height: (size * 0.3).w,
              decoration: BoxDecoration(
                color: isOnline ? const Color(0xFF4CAF50) : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2.w),
              ),
            ),
          ),
        ],
      );
    }

    return avatar;
  }

  Widget _buildInitialsPlaceholder(BuildContext context, String initials) {
    return Container(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: (size * 0.4).sp),
        ),
      ),
    );
  }
}
