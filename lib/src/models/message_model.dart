import 'user_model.dart';

enum MessageContentType { text, audio, location }

class Message {
  final String id;
  final AppUser sender;
  final String content; // Text content or Audio duration or Location Name
  final MessageContentType type;
  final DateTime timestamp;
  final bool isMe;

  // Specific Metadata
  final String? audioUrl;
  final String? locationImageUrl;
  final String? locationAddress;

  const Message({
    required this.id,
    required this.sender,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isMe,
    this.audioUrl,
    this.locationImageUrl,
    this.locationAddress,
  });
}
