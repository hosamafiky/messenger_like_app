import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../models/chat_model.dart';
import '../screens/chat_detail_screen.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;

  const ChatListItem({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailScreen(chatId: chat.id)));
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: chat.sender.avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Icon(Icons.error, size: 24.w),
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.sender.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 17.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  _buildMessageContent(context),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Meta (Time & Unread/Read Status)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                if (chat.unreadCount > 0)
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  )
                else if (chat.status == ChatStatus.read && chat.sender.id == 'design') // Specific check for the 'Design Team' small avatar read receipt
                  Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl:
                          "https://lh3.googleusercontent.com/aida-public/AB6AXuDtJcghI5DbIDJ3pdnniCcppPrC3qMVrNlLDYRwJOxzremnLv8ZoHKyPSIQu9mgfu9UGOWhRdLa-3PxJjByQCDDknGrpRfRwpZJUnAb0pSuM476ggccUAEJQPJ27N0MyAFDcaOkUv1IXmAg6mDiEcvwj1JA8I_QwntpJwZp7m_rhJ4CSXUOBRNSiNTnr1jGg8-A8vaGscGOQ8YP8XTR-0fJzSV0hbtevIgt2CO1xEAvUBeDrUvwpoHfGvt0h5qwSfT-HVy8RAAH5UU", // Small avatar from mockup
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
      color: chat.unreadCount > 0 ? Theme.of(context).textTheme.bodyMedium?.color : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
      fontSize: 15.sp,
    );

    switch (chat.messageType) {
      case MessageType.audio:
        return Row(
          children: [
            Icon(Icons.mic, size: 18.w, color: textStyle?.color),
            SizedBox(width: 4.w),
            Text(chat.audioDuration ?? '0:00', style: textStyle),
          ],
        );
      case MessageType.location:
        return Row(
          children: [
            Icon(Icons.location_on, size: 18.w, color: textStyle?.color), // Filled variant in HTML
            SizedBox(width: 4.w),
            Text(chat.lastMessage, style: textStyle),
          ],
        );
      default:
        return Text(chat.lastMessage, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
  }
}
