import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../controllers/chat_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../repositories/auth_repository.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/chat_list_item.dart';
import '../widgets/story_avatar.dart';

class ChatsScreen extends StatefulWidget {
  final ChatController controller;

  const ChatsScreen({super.key, required this.controller});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  void initState() {
    super.initState();
    // Load data after first frame to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Scaffold(
          body: widget.controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Column(
                    children: [
                      _buildAppBar(context),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: widget.controller.loadData,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(children: [_buildStories(context), _buildChatList(context)]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          bottomNavigationBar: _buildBottomNavigationBar(context),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    final localUser = authRepo.localUser;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: User Profile
          Stack(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                      localUser?.avatarUrl ??
                          "https://lh3.googleusercontent.com/aida-public/AB6AXuD2DnFUqRBuPDmNRnWMsdqBs7auLTV8D8Jg2i0ppK5X54Dt_blCDjQTGGzNU96CQ9zsCYSQd1FjCKiknoZqondG-yt5EB0HdzrC1PHdK51hZ0A1mkUq7zq9YVeWIJsXGgb4wWjGr8a0GxgHF-y0A-19wwwAha9_uOSCtE2812CcdVWqZ_Qlveu11o_e44UMNBLajp358vAch2FfRPzSi33CT2WTUAVYO0A5tcdtR3e1-yI3uFMwDfY7-Cw-oZ4asSjHGIHdO9XTeC0",
                    ),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.grey.shade100, width: 2.w),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppColors.notification, // Red-500
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2.w),
                  ),
                ),
              ),
            ],
          ),

          // Center: Title
          Text(
            "Chats",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5, fontSize: 20.sp),
          ),

          // Right: Actions
          Row(
            children: [
              const AppIconButton(icon: Icons.search),
              SizedBox(width: 12.w),
              const AppIconButton(icon: Icons.edit_square, isPrimary: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStories(BuildContext context) {
    return Container(
      height: 110.h, // Adjust height to fit avatar + active text
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: widget.controller.stories.length,
        separatorBuilder: (context, index) => SizedBox(width: 20.w), // gap-5 (20px)
        itemBuilder: (context, index) {
          final story = widget.controller.stories[index];
          return StoryAvatar(story: story);
        },
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.w), // px-2
      physics: const NeverScrollableScrollPhysics(), // Scroll handled by parent
      shrinkWrap: true,
      itemCount: widget.controller.chats.length,
      itemBuilder: (context, index) {
        final chat = widget.controller.chats[index];
        return ChatListItem(chat: chat);
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 80.h, // h-20 spacer + nav height logic approx
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5))),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.chat_bubble, "Chats", isSelected: true),
            _buildNavItem(context, Icons.videocam, "Calls", isSelected: false),
            _buildNavItem(context, Icons.people, "People", isSelected: false),
            _buildNavItem(context, Icons.amp_stories, "Stories", isSelected: false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, {required bool isSelected}) {
    final color = isSelected
        ? AppColors.primary
        : Theme.of(context).brightness == Brightness.light
        ? Colors.grey[400]
        : Colors.grey[500];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 26.w),
        SizedBox(height: 4.h),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 10.sp),
        ),
      ],
    );
  }
}
