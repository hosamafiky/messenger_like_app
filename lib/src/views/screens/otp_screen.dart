import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../repositories/auth_repository.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_button.dart';
import 'profile_setup_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter the full code")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthRepository>().verifyOtp(widget.phoneNumber, code);
      // AuthWrapper will handle navigation or we might need to go to ProfileSetup if it's new user
      // For now, let's assume it goes to profile setup if they don't have a name yet
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileSetupScreen()));
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
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(leading: const AppBackButton(), backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 24.h),
              // Icon
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.lock_open, color: AppColors.primary, size: 32.w),
              ),
              SizedBox(height: 24.h),
              Text(
                "Enter the code",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 28.sp),
              ),
              SizedBox(height: 12.h),
              Text(
                "We sent a 6-digit code to",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey, fontSize: 14.sp),
              ),
              Text(
                widget.phoneNumber,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Wrong number?",
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
              ),
              SizedBox(height: 32.h),
              // OTP Input
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(6, (index) => _buildOtpInput(index))),
              SizedBox(height: 32.h),
              // Timer
              if (_secondsRemaining > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Colors.grey[800],
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 18.w, color: Colors.grey),
                      SizedBox(width: 8.w),
                      Text(
                        "Resend code in ",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                      ),
                      Text(
                        "00:${_secondsRemaining.toString().padLeft(2, '0')}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 14.sp),
                      ),
                    ],
                  ),
                )
              else
                TextButton(
                  onPressed: _startTimer,
                  child: Text(
                    "Resend Code",
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                ),
              const Spacer(),
              // Verify Button
              AppButton(label: "Verify", isLoading: _isLoading, onPressed: _verifyOtp),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInput(int index) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF1A1A35),
        border: Border.all(color: _focusNodes[index].hasFocus ? AppColors.primary : Colors.grey[300]!, width: _focusNodes[index].hasFocus ? 2 : 1),
        shape: BoxShape.circle,
        boxShadow: [if (_focusNodes[index].hasFocus) BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 8.r, spreadRadius: 2.r)],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(counterText: "", border: InputBorder.none, contentPadding: EdgeInsets.zero),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {}); // Update border color
          if (value.length == 1 && index == 5) {
            _verifyOtp();
          }
        },
      ),
    );
  }
}
