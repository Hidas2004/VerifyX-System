import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single message inside a support chat between consumer and admin.
class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderType; // 'consumer' or 'admin'
  final String text;
  final DateTime timestamp;
  final bool isReadByAdmin;
  final bool isReadByUser;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.text,
    required this.timestamp,
    required this.isReadByAdmin,
    required this.isReadByUser,
  });

  /// True when the message was sent by an admin account.
  bool get isFromAdmin => senderType.toLowerCase() == 'admin';

  /// Creates a [ChatMessage] from Firestore map data.
  factory ChatMessage.fromMap({
    required String id,
    required String chatId,
    required Map<String, dynamic> data,
  }) {
    final rawTimestamp = data['timestamp'];
    DateTime parsedTimestamp;

    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is DateTime) {
      parsedTimestamp = rawTimestamp;
    } else if (rawTimestamp is String) {
      parsedTimestamp = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else {
      parsedTimestamp = DateTime.now();
    }

    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? 'Unknown',
      senderType: data['senderType'] as String? ?? 'consumer',
      text: data['text'] as String? ?? '',
      timestamp: parsedTimestamp,
      isReadByAdmin: data['isReadByAdmin'] as bool? ?? false,
      isReadByUser: data['isReadByUser'] as bool? ?? false,
    );
  }

  /// Converts the message to Firestore map data.
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isReadByAdmin': isReadByAdmin,
      'isReadByUser': isReadByUser,
    };
  }
}
