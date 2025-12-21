import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/app_button.dart';
import 'email_login_screen.dart';
import 'phone_auth_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              const Spacer(),
              // Logo Section
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF2563EB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(32.r),
                          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 32.r, offset: Offset(0, 8.h))],
                        ),
                        child: Center(
                          child: Icon(Icons.chat_bubble, color: Colors.white, size: 64.w),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      Text(
                        "ChatApp",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 28.sp),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "Fast, simple, and secure messaging",
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.w500, fontSize: 16.sp),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Actions Section
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    AppButton(
                      icon: Icons.call,
                      label: "Continue with Phone Number",
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneAuthScreen()));
                      },
                    ),
                    SizedBox(height: 12.h),
                    AppButton(
                      isOutlined: true,
                      icon: Icons.mail,
                      label: "Continue with Email",
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const EmailLoginScreen()));
                      },
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            height: 48.h,
                            isOutlined: true,
                            label: "Google",
                            icon: Icons.g_mobiledata,
                            fontSize: 14.sp,
                            borderRadius: 24.r,
                            onPressed: () {},
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: AppButton(
                            height: 48.h,
                            isOutlined: true,
                            label: "Apple",
                            icon: Icons.apple,
                            fontSize: 14.sp,
                            borderRadius: 24.r,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      "By continuing, you agree to our Terms of Service & Privacy Policy.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey, height: 1.5, fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
