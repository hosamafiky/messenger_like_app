import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';
import 'chat_repository.dart';

class SupabaseChatRepository implements ChatRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Simple cache for profiles to avoid empty users in streams
  final Map<String, AppUser> _profileCache = {};

  @override
  Future<List<Chat>> getChats() async {
    final response = await _client
        .from('chat_participants')
        .select('''
          chat_id,
          chats (
            id,
            last_message,
            updated_at
          ),
          profiles (
            id,
            name,
            avatar_url
          )
        ''')
        .eq('user_id', _client.auth.currentUser?.id ?? '');

    return (response as List).map((data) async {
      final chatId = data['chat_id'];
      final chatData = data['chats'];

      // Fetch other participants for this chat
      final otherParticipantResponse = await _client
          .from('chat_participants')
          .select('profiles(id, name, avatar_url)')
          .eq('chat_id', chatId)
          .neq('user_id', _client.auth.currentUser?.id ?? '')
          .maybeSingle();

      final otherParticipant = otherParticipantResponse?['profiles'];
      final user = otherParticipant != null
          ? AppUser(id: otherParticipant['id'], name: otherParticipant['name'], avatarUrl: otherParticipant['avatar_url'] ?? '')
          : const AppUser(id: 'unknown', name: 'Unknown User', avatarUrl: '');

      if (otherParticipant != null) {
        _profileCache[user.id] = user;
      }

      return Chat(id: chatId, sender: user, lastMessage: chatData['last_message'] ?? '', time: _formatTimestamp(chatData['updated_at']), unreadCount: 0);
    }).wait;
  }

  @override
  Future<List<Story>> getStories() async {
    // Return empty for now as it's a bonus feature
    return [];
  }

  @override
  Future<List<Message>> getMessages(String chatId) async {
    final response = await _client.from('messages').select('*, profiles(id, name, avatar_url)').eq('chat_id', chatId).order('created_at', ascending: true);

    return (response as List).map((data) {
      final senderData = data['profiles'];
      final sender = AppUser(id: senderData['id'], name: senderData['name'], avatarUrl: senderData['avatar_url'] ?? '');

      _profileCache[sender.id] = sender;
      final isMe = sender.id == _client.auth.currentUser?.id;

      return Message(
        id: data['id'],
        sender: sender,
        content: data['content'],
        type: _mapMessageType(data['type']),
        timestamp: DateTime.parse(data['created_at']),
        isMe: isMe,
      );
    }).toList();
  }

  @override
  Future<void> sendMessage(String chatId, String content, MessageContentType type) async {
    await _client.from('messages').insert({'chat_id': chatId, 'sender_id': _client.auth.currentUser?.id, 'content': content, 'type': type.name});

    // Update chat last message and timestamp
    await _client.from('chats').update({'last_message': content, 'updated_at': DateTime.now().toIso8601String()}).eq('id', chatId);
  }

  @override
  Stream<List<Message>> watchMessages(String chatId) {
    return _client.from('messages').stream(primaryKey: ['id']).eq('chat_id', chatId).order('created_at', ascending: true).map((records) {
      return records.map((data) {
        final senderId = data['sender_id'];
        final cachedUser = _profileCache[senderId];

        return Message(
          id: data['id'],
          sender: cachedUser ?? AppUser(id: senderId, name: 'User', avatarUrl: ''),
          content: data['content'],
          type: _mapMessageType(data['type']),
          timestamp: DateTime.parse(data['created_at']),
          isMe: senderId == _client.auth.currentUser?.id,
        );
      }).toList();
    });
  }

  @override
  Stream<List<Chat>> watchChats() {
    return _client.from('chats').stream(primaryKey: ['id']).order('updated_at', ascending: false).asyncMap((_) => getChats());
  }

  MessageContentType _mapMessageType(String type) {
    switch (type) {
      case 'audio':
        return MessageContentType.audio;
      case 'location':
        return MessageContentType.location;
      default:
        return MessageContentType.text;
    }
  }

  String _formatTimestamp(String timestamp) {
    final dt = DateTime.parse(timestamp);
    final now = DateTime.now();
    if (dt.day == now.day) return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    return "${dt.day}/${dt.month}";
  }
}
