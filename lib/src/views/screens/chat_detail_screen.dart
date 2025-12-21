import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../controllers/chat_detail_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../repositories/chat_repository.dart';
import '../widgets/app_avatar.dart';
import '../widgets/app_back_button.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailScreen({super.key, required this.chatId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late ChatDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChatDetailController(chatId: widget.chatId, repository: context.read<ChatRepository>());

    // Use post frame callback to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(
              child: Consumer<ChatDetailController>(
                builder: (context, controller, _) {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                    itemCount: controller.messages.length + (controller.isOtherTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.messages.length) {
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: _buildTypingIndicator(context),
                        );
                      }

                      if (index == 0) {
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: Text(
                                "Today 10:23 AM",
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10.sp),
                              ),
                            ),
                            MessageBubble(message: controller.messages[index]),
                          ],
                        );
                      }

                      return MessageBubble(message: controller.messages[index]);
                    },
                  );
                },
              ),
            ),
            const ChatInputBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
      elevation: 0.5,
      leading: const AppBackButton(color: AppColors.primary),
      titleSpacing: 0,
      title: Row(
        children: [
          Consumer<ChatDetailController>(
            builder: (context, controller, _) {
              final recipient = controller.recipient;
              return AppAvatar(avatarUrl: recipient?.avatarUrl, name: recipient?.name ?? "U", size: 40, showOnlineStatus: true, isOnline: true);
            },
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<ChatDetailController>(
                builder: (context, controller, _) {
                  return Text(
                    controller.recipient?.name ?? "Loading...",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
                  );
                },
              ),
              Text(
                "Active now",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 12.sp),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.call, color: AppColors.primary, size: 24.w),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.videocam, color: AppColors.primary, size: 24.w),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.info, color: AppColors.primary, size: 24.w),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Consumer<ChatDetailController>(
            builder: (context, controller, _) {
              return AppAvatar(avatarUrl: controller.recipient?.avatarUrl, name: controller.recipient?.name ?? "U", size: 32);
            },
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
                bottomLeft: Radius.circular(4.r),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                SizedBox(width: 4.w),
                _buildDot(1),
                SizedBox(width: 4.w),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TypingIndicatorDot(index: index);
  }
}

class TypingIndicatorDot extends StatefulWidget {
  final int index;
  const TypingIndicatorDot({super.key, required this.index});

  @override
  State<TypingIndicatorDot> createState() => _TypingIndicatorDotState();
}

class _TypingIndicatorDotState extends State<TypingIndicatorDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(Duration(milliseconds: widget.index * 200), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          width: 6.w,
          height: 6.w,
          decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
