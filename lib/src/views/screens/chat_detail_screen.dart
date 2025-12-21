import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../controllers/chat_detail_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../repositories/chat_repository.dart';
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
                    itemCount: controller.messages.length + (controller.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.messages.length) {
                        return _buildTypingIndicator(context);
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
          Stack(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 1.w),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAxuCX03acSCsPLxrVxaTWKLwi5Dd8oOhV4y5xtz92VBiHQgzJucyerLgZ-eaYpRF-blo56cWrDBJb6oc_LkPybT4HpV-HJPq_FWMCRNKRpW2HlzxN4kh3w4gZra41Tzk5qonhrMpJ-NHFZIgkGosq77KVfPXh-UKOpLytw2eWgCV_6Y9ZoHaUiXkWATXqwzdoXBkunSpYv7tm6yPy5FJlzXfD-vt0B95Qwugxtdmj7X69uQ2npPKjuvhx9eLDSIMtwOhhwanoRO0Q',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppColors.online,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2.w),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Alice Johnson",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
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
          Container(
            width: 32.w,
            height: 32.w,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAxuCX03acSCsPLxrVxaTWKLwi5Dd8oOhV4y5xtz92VBiHQgzJucyerLgZ-eaYpRF-blo56cWrDBJb6oc_LkPybT4HpV-HJPq_FWMCRNKRpW2HlzxN4kh3w4gZra41Tzk5qonhrMpJ-NHFZIgkGosq77KVfPXh-UKOpLytw2eWgCV_6Y9ZoHaUiXkWATXqwzdoXBkunSpYv7tm6yPy5FJlzXfD-vt0B95Qwugxtdmj7X69uQ2npPKjuvhx9eLDSIMtwOhhwanoRO0Q',
              fit: BoxFit.cover,
            ),
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
                _buildDot(150),
                SizedBox(width: 4.w),
                _buildDot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          width: 6.w,
          height: 6.w,
          decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
        );
      },
    );
  }
}
