import 'dart:async';

import 'package:flutter/material.dart';

import '../models/message_model.dart';
import '../models/user_model.dart';
import '../repositories/chat_repository.dart';

class ChatDetailController extends ChangeNotifier {
  final String chatId;
  final ChatRepository repository;

  List<Message> _messages = [];
  AppUser? _recipient;
  bool _isLoading = true;
  bool _isOtherTyping = false;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;

  ChatDetailController({required this.chatId, required this.repository});

  List<Message> get messages => _messages;
  AppUser? get recipient => _recipient;
  bool get isLoading => _isLoading;
  bool get isOtherTyping => _isOtherTyping;

  Future<void> loadMessages() async {
    if (!_isLoading) {
      _isLoading = true;
      Future.microtask(() => notifyListeners());
    }

    try {
      _recipient = await repository.getChatParticipant(chatId);
      _messages = await repository.getMessages(chatId);

      // Start watching for new messages
      _messageSubscription?.cancel();
      _messageSubscription = repository.watchMessages(chatId).listen((newMessages) {
        _messages = newMessages;
        Future.microtask(() => notifyListeners());
      });

      // Start watching for typing status
      _typingSubscription?.cancel();
      _typingSubscription = repository.watchTypingStatus(chatId).listen((isTyping) {
        _isOtherTyping = isTyping;
        notifyListeners();
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
    _typingSubscription?.cancel();
    super.dispose();
  }

  Future<void> setMyTypingStatus(bool isTyping) async {
    try {
      await repository.setTypingStatus(chatId, isTyping);
    } catch (e) {
      debugPrint("Error setting typing status: $e");
    }
  }

  Future<void> sendMessage(String content, MessageContentType type) async {
    try {
      await repository.sendMessage(chatId, content, type);
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }
}
