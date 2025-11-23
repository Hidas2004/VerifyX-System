import 'dart:async';

import 'package:flutter/material.dart';

import '../models/chat_message_model.dart';
import '../models/chat_thread_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';

/// ChangeNotifier that exposes chat data streams and send actions to the UI.
class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatMessage> _messages = [];
  List<ChatThread> _threads = [];
  bool _isLoadingMessages = false;
  bool _isLoadingThreads = false;
  bool _isSending = false;
  String? _errorMessage;
  String? _activeChatId;

  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  StreamSubscription<List<ChatThread>>? _threadsSubscription;

  List<ChatMessage> get messages => _messages;
  List<ChatThread> get threads => _threads;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isLoadingThreads => _isLoadingThreads;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  String? get activeChatId => _activeChatId;

  /// Listen to messages for a specific chat (consumer UID).
  void listenToMessages(String chatId) {
    if (_activeChatId == chatId && _messagesSubscription != null) {
      return;
    }

    _messagesSubscription?.cancel();
    _activeChatId = chatId;
    _isLoadingMessages = true;
    _errorMessage = null;
    _messages = [];
    notifyListeners();

    _messagesSubscription = _chatService
        .listenToMessages(chatId)
        .listen(
          (messages) {
            _messages = messages;
            _isLoadingMessages = false;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = error.toString();
            _isLoadingMessages = false;
            notifyListeners();
          },
        );
  }

  /// Stop listening to the currently active chat stream.
  void stopListeningMessages() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _messages = [];
    _activeChatId = null;
    _isLoadingMessages = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Listen to all threads (admin inbox).
  void listenToThreads() {
    if (_threadsSubscription != null) {
      return;
    }

    _isLoadingThreads = true;
    _errorMessage = null;
    _threads = [];
    notifyListeners();

    _threadsSubscription = _chatService.listenToThreads().listen(
      (threads) {
        _threads = threads;
        _isLoadingThreads = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoadingThreads = false;
        notifyListeners();
      },
    );
  }

  /// Stop listening to admin threads.
  void stopListeningThreads() {
    _threadsSubscription?.cancel();
    _threadsSubscription = null;
    _threads = [];
    _isLoadingThreads = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Sends a message from consumer to admin.
  Future<void> sendConsumerMessage({
    required UserModel consumer,
    required String message,
  }) async {
    if (message.trim().isEmpty) {
      return;
    }

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _chatService.sendConsumerMessage(
        consumer: consumer,
        message: message,
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isSending = false;
      notifyListeners();
    }
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

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _chatService.sendAdminMessage(
        adminId: adminId,
        adminName: adminName,
        adminEmail: adminEmail,
        targetUserId: targetUserId,
        targetUserDisplayName: targetUserDisplayName,
        targetUserEmail: targetUserEmail,
        message: message,
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> markConversationReadByAdmin(String chatId) {
    return _chatService.markConversationReadByAdmin(chatId);
  }

  Future<void> markConversationReadByConsumer(String chatId) {
    return _chatService.markConversationReadByConsumer(chatId);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _threadsSubscription?.cancel();
    super.dispose();
  }
}
