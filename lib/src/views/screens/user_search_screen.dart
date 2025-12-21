import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../controllers/chat_controller.dart';
import '../../models/user_model.dart';
import '../widgets/app_avatar.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_text_field.dart';
import 'chat_detail_screen.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AppUser> _searchResults = [];
  bool _isSearching = false;

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await context.read<ChatController>().searchUsers(query);
      setState(() => _searchResults = results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _handleUserTap(AppUser user) async {
    setState(() => _isSearching = true);
    try {
      final chatId = await context.read<ChatController>().startChat(user.id);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatDetailScreen(chatId: chatId)));
      }
    } catch (e) {
      log("Error starting chat: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(
          "New Chat",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: AppTextField(controller: _searchController, hint: "Search by name...", prefixIcon: Icons.search, onChanged: _handleSearch, autofocus: true),
          ),
          if (_isSearching && _searchResults.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
            const Expanded(child: Center(child: Text("No users found")))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return ListTile(
                    leading: AppAvatar(avatarUrl: user.avatarUrl, name: user.name, size: 48),
                    title: Text(
                      user.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                    ),
                    subtitle: Text(
                      "@${user.name.toLowerCase().replaceAll(' ', '_')}",
                      style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                    ),
                    onTap: () => _handleUserTap(user),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
