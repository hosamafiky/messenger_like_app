import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../repositories/auth_repository.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = context.read<AuthRepository>();
      if (_isLogin) {
        await authRepo.loginWithEmail(_emailController.text.trim(), _passwordController.text.trim());
      } else {
        await authRepo.signUpWithEmail(_emailController.text.trim(), _passwordController.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account created! Please log in.")));
          setState(() {
            _isLogin = true;
          });
        }
      }
      // AuthWrapper will handle navigation
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
        leading: AppBackButton(isIosStyle: true, color: isDark ? Colors.white : const Color(0xFF0F172A)),
        title: Text(
          _isLogin ? "Log In" : "Sign Up",
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 32.h),
              // Headline
              Text(
                _isLogin ? "Welcome Back" : "Create Account",
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 28.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                _isLogin ? "Please enter your details to sign in" : "Enter your email and password to get started",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 13.sp),
              ),
              SizedBox(height: 48.h),
              // Form
              AppTextField(controller: _emailController, hint: "Email", keyboardType: TextInputType.emailAddress),
              SizedBox(height: 16.h),
              AppTextField(
                controller: _passwordController,
                hint: "Password",
                isPassword: true,
                isPasswordVisible: _isPasswordVisible,
                onToggleVisibility: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
              if (_isLogin) ...[
                SizedBox(height: 12.h),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14.sp),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 32.h),
              // Auth Button
              AppButton(label: _isLogin ? "Log In" : "Sign Up", isLoading: _isLoading, onPressed: _handleAuth),
              SizedBox(height: 24.h),
              // Toggle Login/Signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? "Don't have an account?" : "Already have an account?",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? "Sign Up" : "Log In",
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
