import 'package:cloud_firestore/cloud_firestore.dart';

/// Summary document for a support chat linked to a single consumer account.
class ChatThread {
  final String id;
  final String userId;
  final String userDisplayName;
  final String userEmail;
  final String lastMessage;
  final String lastMessageSenderId;
  final String lastMessageSenderType; // 'consumer' or 'admin'
  final DateTime updatedAt;
  final int unreadByAdmin;
  final int unreadByUser;

  const ChatThread({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    required this.userEmail,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastMessageSenderType,
    required this.updatedAt,
    required this.unreadByAdmin,
    required this.unreadByUser,
  });

  /// Returns true when there are new messages awaiting admin attention.
  bool get hasUnreadForAdmin => unreadByAdmin > 0;

  /// Returns true when there are new messages awaiting the consumer.
  bool get hasUnreadForUser => unreadByUser > 0;

  /// Factory to create a [ChatThread] from Firestore snapshot data.
  factory ChatThread.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawUpdatedAt = data['updatedAt'];

    DateTime parsedUpdatedAt;
    if (rawUpdatedAt is Timestamp) {
      parsedUpdatedAt = rawUpdatedAt.toDate();
    } else if (rawUpdatedAt is DateTime) {
      parsedUpdatedAt = rawUpdatedAt;
    } else if (rawUpdatedAt is String) {
      parsedUpdatedAt = DateTime.tryParse(rawUpdatedAt) ?? DateTime.now();
    } else {
      parsedUpdatedAt = DateTime.now();
    }

    return ChatThread(
      id: doc.id,
      userId: data['userId'] as String? ?? doc.id,
      userDisplayName: data['userDisplayName'] as String? ?? 'Người dùng',
      userEmail: data['userEmail'] as String? ?? '',
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageSenderId: data['lastMessageSenderId'] as String? ?? '',
      lastMessageSenderType:
          data['lastMessageSenderType'] as String? ?? 'consumer',
      updatedAt: parsedUpdatedAt,
      unreadByAdmin: (data['unreadByAdmin'] as num?)?.toInt() ?? 0,
      unreadByUser: (data['unreadByUser'] as num?)?.toInt() ?? 0,
    );
  }

  /// Converts this thread summary into Firestore map data.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userEmail': userEmail,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageSenderType': lastMessageSenderType,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'unreadByAdmin': unreadByAdmin,
      'unreadByUser': unreadByUser,
    };
  }
}
