import 'dart:async';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';
import 'chat_repository.dart';

class MockChatRepository implements ChatRepository {
  @override
  Future<List<Chat>> getChats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const Chat(
        id: '1',
        sender: AppUser(
          id: 'alex',
          name: 'Alex Johnson',
          avatarUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBNHTYPx13c--htkFnylZQdFDzSFmQx3gEedvjC4MDq0i9eXa3S6Ofe5pCJ4Qjiy575UNb2b1trFjryFu6RXvKm2W5TTStVFlzCnnI4se79liABGP2Tt1GlH_i-SO03enpKlc-P1dHcOdhOrvw1S-lEAaVIu6GFCDFepzYxGRQUg6Y0L_8Ql1HsmDl_3M2EXZF0dRDKbaUg11qnRC2z2f_78GtAXUvdEz0yIYNZWPEkSV8s8SXM8pGreG9qpNjAcONx7o9YFc1tehg',
        ),
        lastMessage: 'Are we still on for 5? 🏀',
        time: '10:42 AM',
        unreadCount: 1,
        messageType: MessageType.text,
      ),
    ];
  }

  @override
  Future<List<Story>> getStories() async {
    return [
      const Story(
        id: '1',
        user: AppUser(
          id: 'me',
          name: 'Your Story',
          avatarUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCJwELoI1TLC1DnOPkwtA_sT4wPP46T3YvkpNhAT_GHgvvP9t6ba8To1sDaQAUD_On5bhbazIrKP591QXAaSeJdAZgjkPXrFA5huRlNyd5FOHKomJO7m_PkHNsU5rSMe39eYvw4lFrlHiHFbFzZ_30O_DBJOgDqCWsFp90dgJnAHVP7dvukcGIRxY5eZglsMcuDG0TZUImUvj9edt2f2vK7LBHRKlbY2Ju43cZP8nFCF-pLeVkNfhehCYwaOrMwugcynS-aJ_rtw4I',
        ),
        isViewed: false,
      ),
    ];
  }

  @override
  Future<List<Message>> getMessages(String chatId) async {
    return [];
  }

  @override
  Future<void> sendMessage(String chatId, String content, MessageContentType type) async {}

  @override
  Stream<List<Message>> watchMessages(String chatId) {
    return Stream.value([]);
  }

  @override
  Stream<List<Chat>> watchChats() {
    return Stream.value([]);
  }
}
