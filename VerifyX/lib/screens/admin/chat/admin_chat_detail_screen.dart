import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../models/chat_message_model.dart';
import '../../../models/chat_thread_model.dart';
import '../../../providers/chat_provider.dart';
import '../../../utils/formatters.dart';

/// Detailed conversation view for admin ↔ consumer support chat.
class AdminChatDetailScreen extends StatefulWidget {
  const AdminChatDetailScreen({super.key, required this.thread});

  final ChatThread thread;

  @override
  State<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends State<AdminChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final VoidCallback _scrollListener;
  int _lastMessageCount = 0;
  bool _shouldStickToBottom = true;

  User? get _currentAdmin => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _scrollListener = () {
      if (!_scrollController.hasClients) {
        return;
      }
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      _shouldStickToBottom = (maxScroll - currentScroll) <= 120;
    };
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.listenToMessages(widget.thread.userId);
      chatProvider.markConversationReadByAdmin(widget.thread.userId);
    });
  }

  @override
  void dispose() {
    context.read<ChatProvider>().stopListeningMessages();
    _scrollController.removeListener(_scrollListener);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSend(ChatProvider chatProvider) async {
    final admin = _currentAdmin;
    final text = _messageController.text;

    if (admin == null || text.trim().isEmpty) {
      return;
    }

    final adminName = admin.displayName ?? '';
    final adminEmail = admin.email ?? 'admin@verifyx.com';

    await chatProvider.sendAdminMessage(
      adminId: admin.uid,
      adminName: adminName,
      adminEmail: adminEmail,
      targetUserId: widget.thread.userId,
      targetUserDisplayName: widget.thread.userDisplayName,
      targetUserEmail: widget.thread.userEmail,
      message: text,
    );

    await chatProvider.markConversationReadByAdmin(widget.thread.userId);
    FocusScope.of(context).unfocus();
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = _currentAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.thread.userDisplayName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (widget.thread.userEmail.isNotEmpty)
              Text(
                widget.thread.userEmail,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          final messages = chatProvider.messages;

          if (chatProvider.isLoadingMessages && messages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final hasUnreadFromConsumer = messages.any(
            (message) => !message.isFromAdmin && !message.isReadByAdmin,
          );

          if (hasUnreadFromConsumer) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              chatProvider.markConversationReadByAdmin(widget.thread.userId);
            });
          }

          if (messages.isEmpty) {
            _lastMessageCount = 0;
          } else if (messages.length != _lastMessageCount &&
              _shouldStickToBottom) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
          }
          _lastMessageCount = messages.length;

          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMine =
                              admin != null && message.senderId == admin.uid;
                          return _AdminMessageBubble(
                            message: message,
                            isMine: isMine,
                          );
                        },
                      ),
              ),
              if (chatProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    chatProvider.errorMessage!,
                    style: TextStyle(color: AppColors.error.withOpacity(0.9)),
                  ),
                ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          textCapitalization: TextCapitalization.sentences,
                          minLines: 1,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: AppStrings.chatInputHint,
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: chatProvider.isSending
                            ? null
                            : () => _handleSend(chatProvider),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(14),
                        ),
                        child: chatProvider.isSending
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_outlined, size: 90, color: AppColors.divider),
          const SizedBox(height: 16),
          const Text(
            'Bắt đầu cuộc trò chuyện với người dùng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn có thể hỗ trợ ${widget.thread.userDisplayName} trực tiếp tại đây.',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AdminMessageBubble extends StatelessWidget {
  const _AdminMessageBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine ? AppColors.primary : Colors.grey.shade200;
    final textColor = isMine ? Colors.white : AppColors.textPrimary;
    final alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final nameColor = isMine ? Colors.white70 : AppColors.textSecondary;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMine ? 18 : 6),
              bottomRight: Radius.circular(isMine ? 6 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!isMine)
                Text(
                  message.senderName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: nameColor,
                  ),
                ),
              if (!isMine) const SizedBox(height: 4),
              Text(
                message.text,
                style: TextStyle(color: textColor, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                Formatters.time(message.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: isMine ? Colors.white70 : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
