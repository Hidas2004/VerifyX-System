import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message_model.dart';
import '../models/chat_thread_model.dart';
import '../models/user_model.dart';

/// Handles Firebase reads/writes for the consumer ↔ admin support chat.
class ChatService {
  ChatService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _chatCollection =>
      _firestore.collection('supportChats');

  /// Streams messages for a given chat (chatId == consumer UID).
  Stream<List<ChatMessage>> listenToMessages(String chatId) {
    return _chatCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ChatMessage.fromMap(
                  id: doc.id,
                  chatId: chatId,
                  data: doc.data(),
                ),
              )
              .toList(),
        );
  }

  /// Streams all chat threads, ordered by latest activity (admin view).
  Stream<List<ChatThread>> listenToThreads() {
    return _chatCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ChatThread.fromDocument(doc)).toList(),
        );
  }

  /// Sends a message from the consumer to admin.
  Future<void> sendConsumerMessage({
    required UserModel consumer,
    required String message,
  }) async {
    if (message.trim().isEmpty) {
      return;
    }

    final trimmedMessage = message.trim();
    final chatRef = _chatCollection.doc(consumer.uid);
    final messageRef = chatRef.collection('messages').doc();
    final timestamp = Timestamp.now();
    final displayName = consumer.displayName?.isNotEmpty == true
        ? consumer.displayName!
        : consumer.email;

    final batch = _firestore.batch();

    batch.set(messageRef, {
      'senderId': consumer.uid,
      'senderName': displayName,
      'senderType': 'consumer',
      'text': trimmedMessage,
      'timestamp': timestamp,
      'isReadByAdmin': false,
      'isReadByUser': true,
    });

    batch.set(chatRef, {
      'userId': consumer.uid,
      'userDisplayName': displayName,
      'userEmail': consumer.email,
      'participants': [consumer.uid, 'admin'],
      'lastMessage': trimmedMessage,
      'lastMessageSenderId': consumer.uid,
      'lastMessageSenderType': 'consumer',
      'updatedAt': timestamp,
      'unreadByAdmin': FieldValue.increment(1),
      'unreadByUser': 0,
    }, SetOptions(merge: true));

    await batch.commit();
  }

  /// Sends a message from admin to the selected consumer.
  Future<void> sendAdminMessage({
    required String adminId,
    required String adminName,
    required String adminEmail,
    required String targetUserId,
    required String targetUserDisplayName,
    required String targetUserEmail,
    required String message,
  }) async {
    if (message.trim().isEmpty) {
      return;
    }

    final trimmedMessage = message.trim();
    final chatRef = _chatCollection.doc(targetUserId);
    final messageRef = chatRef.collection('messages').doc();
    final timestamp = Timestamp.now();
    final resolvedAdminName = adminName.isNotEmpty ? adminName : adminEmail;

    final batch = _firestore.batch();

    batch.set(messageRef, {
      'senderId': adminId,
      'senderName': resolvedAdminName,
      'senderType': 'admin',
      'text': trimmedMessage,
      'timestamp': timestamp,
      'isReadByAdmin': true,
      'isReadByUser': false,
    });

    batch.set(chatRef, {
      'userId': targetUserId,
      'userDisplayName': targetUserDisplayName,
      'userEmail': targetUserEmail,
      'participants': [targetUserId, 'admin'],
      'lastMessage': trimmedMessage,
      'lastMessageSenderId': adminId,
      'lastMessageSenderType': 'admin',
      'updatedAt': timestamp,
      'unreadByAdmin': 0,
      'unreadByUser': FieldValue.increment(1),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  /// Marks consumer messages as read by admin.
  Future<void> markConversationReadByAdmin(String chatId) async {
    final chatRef = _chatCollection.doc(chatId);

    final chatSnapshot = await chatRef.get();
    if (!chatSnapshot.exists) {
      return;
    }

    await chatRef.update({'unreadByAdmin': 0});

    final unreadMessages = await chatRef
        .collection('messages')
        .where('senderType', isEqualTo: 'consumer')
        .where('isReadByAdmin', isEqualTo: false)
        .get();

    if (unreadMessages.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isReadByAdmin': true});
    }

    await batch.commit();
  }

  /// Marks admin messages as read by the consumer.
  Future<void> markConversationReadByConsumer(String chatId) async {
    final chatRef = _chatCollection.doc(chatId);

    final chatSnapshot = await chatRef.get();
    if (!chatSnapshot.exists) {
      return;
    }

    await chatRef.update({'unreadByUser': 0});

    final unreadMessages = await chatRef
        .collection('messages')
        .where('senderType', isEqualTo: 'admin')
        .where('isReadByUser', isEqualTo: false)
        .get();

    if (unreadMessages.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isReadByUser': true});
    }

    await batch.commit();
  }
}
