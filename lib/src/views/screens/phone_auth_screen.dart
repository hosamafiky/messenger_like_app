import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../repositories/auth_repository.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'otp_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    final phone = "+1 ${_phoneController.text.trim()}";
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid phone number")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthRepository>().loginWithPhone(phone);
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => OtpScreen(phoneNumber: phone)));
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
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: const AppBackButton()),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 8.h),
              Text(
                "Enter your phone number",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 28.sp),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  "We'll send you a verification code so we know it's really you.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 16.sp),
                ),
              ),
              SizedBox(height: 48.h),
              Row(
                children: [
                  // Country Code Selector (Mocked)
                  Container(
                    height: 56.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[100], borderRadius: BorderRadius.circular(16.r)),
                    child: Row(
                      children: [
                        Text("🇺🇸", style: TextStyle(fontSize: 24.sp)),
                        SizedBox(width: 8.w),
                        Text(
                          "+1",
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                        Icon(Icons.expand_more, color: Colors.grey, size: 20.w),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Phone Input
                  Expanded(
                    child: AppTextField(
                      controller: _phoneController,
                      hint: "(000) 000-0000",
                      height: 56.h,
                      autofocus: true,
                      hasBorder: false,
                      keyboardType: TextInputType.phone,
                      borderRadius: 16.r,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      horizontalPadding: 16.w,
                      textStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                "Carrier rates may apply.",
                style: TextStyle(color: Colors.grey[500], fontSize: 12.sp, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              // Next Button
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 360.w),
                child: AppButton(label: "Next", isLoading: _isLoading, onPressed: _handleNext),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
