import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../controllers/chat_detail_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/message_model.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _textController = TextEditingController();
  bool _hasText = false;
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }

    if (hasText && !_isTyping) {
      _isTyping = true;
      context.read<ChatDetailController>().setMyTypingStatus(true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        context.read<ChatDetailController>().setMyTypingStatus(false);
      }
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final controller = context.read<ChatDetailController>();
    _textController.clear();

    try {
      await controller.sendMessage(text, MessageContentType.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to send message: $e")));
      }
    }
  }

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
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildActionButton(Icons.add_circle),
            SizedBox(width: 8.w),
            _buildActionButton(Icons.camera_alt),
            SizedBox(width: 8.w),
            _buildActionButton(Icons.image),
            SizedBox(width: 8.w),
            Expanded(
              child: Container(
                constraints: BoxConstraints(minHeight: 44.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        onSubmitted: (_) => _handleSend(),
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
            _buildActionButton(_hasText ? Icons.send : Icons.mic, onTap: _hasText ? _handleSend : null),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Center(
          child: Icon(icon, color: AppColors.primary, size: 28.w),
        ),
      ),
    );
  }
}
