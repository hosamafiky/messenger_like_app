import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../repositories/auth_repository.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_wrapper.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name is required")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthRepository>().updateProfile(name: _nameController.text.trim());
      if (mounted) {
        _navigateToChats(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => _navigateToChats(context),
            child: Text(
              "Skip",
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 8.h),
                Text(
                  "Let's get you set up",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 28.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Create your profile to start chatting",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 16.sp),
                ),
                SizedBox(height: 48.h),
                // Avatar Selection
                _buildAvatarSelector(isDark),
                SizedBox(height: 48.h),
                // Form Fields
                AppTextField(
                  label: "Full Name",
                  controller: _nameController,
                  hint: "Your Name (Required)",
                  hasBorder: false,
                  backgroundColor: isDark ? Colors.grey[800]?.withValues(alpha: 0.5) : Colors.grey[100],
                  borderRadius: 32.r,
                ),
                SizedBox(height: 20.h),
                AppTextField(
                  label: "Username",
                  controller: _usernameController,
                  hint: "@username (Optional)",
                  optional: true,
                  hasBorder: false,
                  backgroundColor: isDark ? Colors.grey[800]?.withValues(alpha: 0.5) : Colors.grey[100],
                  borderRadius: 32.r,
                ),
                SizedBox(height: 24.h),
                Text(
                  "Your full name helps friends find you. You can always change this later in settings.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13.sp, height: 1.5),
                ),
                SizedBox(height: 120.h), // Space for bottom button
              ],
            ),
          ),
          // Bottom Continue Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0), Theme.of(context).scaffoldBackgroundColor],
                ),
              ),
              child: AppButton(label: "Continue", isLoading: _isLoading, onPressed: _handleContinue, icon: Icons.arrow_forward),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSelector(bool isDark) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 128.w,
              height: 128.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4.w),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10.r, offset: Offset(0, 4.h))],
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBF0Jl4D9mE-_su80YBI6lwRKbIapbAxijBYt8cAII-o9cQaYsX3gtfvtbkiA22LuVzw7_jAPDXAbvLDIU_sN-lPERt7SCw1ZaYl8aDm8CXxaBJFyeFwUDu-mbNS12tFujrB4F-oqK9HyyEB9EdRZqc2OR3aKkDN4_edtn7wvXsY2Z6axNTFCndCYHQSMacq2pFkbfTmfQEzJCrWwnpsSPBOc_uIrGmZWwoWqLNMxv4C8Xjya6voPiXW2KxQMsYjpXTfD0dwBNuSus',
                fit: BoxFit.cover,
                placeholder: (context, url) => Icon(Icons.person, size: 64.w, color: Colors.grey[400]),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3.w),
                ),
                child: Icon(Icons.photo_camera, color: Colors.white, size: 20.w),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          "Add a photo",
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
      ],
    );
  }

  void _navigateToChats(BuildContext context) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AuthWrapper()), (route) => false);
  }
}
