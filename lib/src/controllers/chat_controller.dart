import 'dart:async';

import 'package:flutter/material.dart';

import '../models/chat_model.dart';
import '../models/story_model.dart';
import '../repositories/chat_repository.dart';

class ChatController extends ChangeNotifier {
  final ChatRepository repository;

  List<Chat> _chats = [];
  List<Story> _stories = [];
  bool _isLoading = false;
  StreamSubscription? _chatSubscription;

  ChatController({required this.repository});

  List<Chat> get chats => _chats;
  List<Story> get stories => _stories;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    if (!_isLoading) {
      _isLoading = true;
      Future.microtask(() => notifyListeners());
    }

    try {
      _chats = await repository.getChats();
      _stories = await repository.getStories();

      // Setup real-time listener
      _chatSubscription?.cancel();
      _chatSubscription = repository.watchChats().listen((newChats) {
        _chats = newChats;
        Future.microtask(() => notifyListeners());
      });
    } catch (e) {
      debugPrint("Error loading chats: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }
}
