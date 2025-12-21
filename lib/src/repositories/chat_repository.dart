import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/story_model.dart';

abstract class ChatRepository {
  Future<List<Chat>> getChats();
  Future<List<Story>> getStories();
  Future<List<Message>> getMessages(String chatId);
  Future<void> sendMessage(String chatId, String content, MessageContentType type);
  Stream<List<Message>> watchMessages(String chatId);
  Stream<List<Chat>> watchChats();
}
