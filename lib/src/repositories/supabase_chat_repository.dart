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

  @override
  Future<List<AppUser>> searchUsers(String query) async {
    final response = await _client.from('profiles').select().ilike('name', '%$query%').neq('id', _client.auth.currentUser?.id ?? '').limit(20);

    return (response as List).map((data) {
      final user = AppUser(id: data['id'], name: data['name'], avatarUrl: data['avatar_url'] ?? '');
      _profileCache[user.id] = user;
      return user;
    }).toList();
  }

  @override
  Future<String> getOrCreateChat(String otherUserId) async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null) throw Exception("User not logged in");

    // 1. Find existing chat
    // Fetch all chat IDs current user is participant of
    final myParticipants = await _client.from('chat_participants').select('chat_id').eq('user_id', myId);

    if ((myParticipants as List).isNotEmpty) {
      final chatIds = (myParticipants as List).map((p) => p['chat_id']).toList();

      // Find if any of these chats also has the other user
      // Note: This logic assumes 1-on-1 chats.
      final existingChat = await _client.from('chat_participants').select('chat_id').inFilter('chat_id', chatIds).eq('user_id', otherUserId).maybeSingle();

      if (existingChat != null) {
        return existingChat['chat_id'] as String;
      }
    }

    // 2. Create new chat if not found
    final newChat = await _client.from('chats').insert({'last_message': '', 'updated_at': DateTime.now().toIso8601String()}).select().single();

    final chatId = newChat['id'];

    // 3. Add participants
    await _client.from('chat_participants').insert([
      {'chat_id': chatId, 'user_id': myId},
      {'chat_id': chatId, 'user_id': otherUserId},
    ]);

    return chatId;
  }

  @override
  Future<AppUser> getChatParticipant(String chatId) async {
    final response = await _client
        .from('chat_participants')
        .select('profiles(id, name, avatar_url)')
        .eq('chat_id', chatId)
        .neq('user_id', _client.auth.currentUser?.id ?? '')
        .maybeSingle();

    if (response == null || response['profiles'] == null) {
      return const AppUser(id: 'unknown', name: 'Unknown User', avatarUrl: '');
    }

    final data = response['profiles'];
    final user = AppUser(id: data['id'], name: data['name'], avatarUrl: data['avatar_url'] ?? '');
    _profileCache[user.id] = user;
    return user;
  }

  @override
  Future<void> setTypingStatus(String chatId, bool isTyping) async {
    final channel = _client.channel('chat:$chatId');
    channel.subscribe((status, _) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        if (isTyping) {
          await channel.track({'isTyping': true, 'userId': _client.auth.currentUser?.id});
        } else {
          await channel.untrack();
        }
      }
    });
  }

  @override
  Stream<bool> watchTypingStatus(String chatId) {
    final controller = StreamController<bool>();
    final channel = _client.channel('chat:$chatId');

    channel.onPresenceSync((payload) {
      final presenceState = channel.presenceState();
      bool isOtherTyping = false;

      for (final presence in presenceState) {
        for (final p in presence.presences) {
          final pPayload = p.payload;
          if (pPayload['isTyping'] == true && pPayload['userId'] != _client.auth.currentUser?.id) {
            isOtherTyping = true;
            break;
          }
        }
        if (isOtherTyping) break;
      }
      controller.add(isOtherTyping);
    }).subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
      controller.close();
    };

    return controller.stream;
  }
}
