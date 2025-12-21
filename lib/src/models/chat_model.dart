import 'user_model.dart';

enum MessageType { text, audio, location, image, video }

enum ChatStatus { none, sent, delivered, read }

class Chat {
  final String id;
  final AppUser sender;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final MessageType messageType;
  final ChatStatus status; // For sent/delivered/read status
  final String? audioDuration; // For audio messages

  const Chat({
    required this.id,
    required this.sender,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.messageType = MessageType.text,
    this.status = ChatStatus.none,
    this.audioDuration,
  });
}
