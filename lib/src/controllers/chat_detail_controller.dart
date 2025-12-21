import 'dart:async';

import 'package:flutter/material.dart';

import '../models/message_model.dart';
import '../repositories/chat_repository.dart';

class ChatDetailController extends ChangeNotifier {
  final String chatId;
  final ChatRepository repository;

  List<Message> _messages = [];
  bool _isLoading = true;
  final bool _isTyping = false;
  StreamSubscription? _messageSubscription;

  ChatDetailController({required this.chatId, required this.repository});

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;

  Future<void> loadMessages() async {
    if (!_isLoading) {
      _isLoading = true;
      Future.microtask(() => notifyListeners());
    }

    try {
      _messages = await repository.getMessages(chatId);

      // Start watching for new messages
      _messageSubscription?.cancel();
      _messageSubscription = repository.watchMessages(chatId).listen((newMessages) {
        _messages = newMessages;
        Future.microtask(() => notifyListeners());
      });
    } catch (e) {
      debugPrint("Error loading messages: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  Future<void> sendMessage(String content, MessageContentType type) async {
    try {
      await repository.sendMessage(chatId, content, type);
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }
}
