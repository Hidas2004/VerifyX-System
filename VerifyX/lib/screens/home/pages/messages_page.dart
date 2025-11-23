import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../utils/formatters.dart';
import '../../../models/chat_message_model.dart';

/// Consumer chat page where users talk directly with the admin team.
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final VoidCallback _scrollListener;
  int _lastMessageCount = 0;
  bool _shouldStickToBottom = true;

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
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.userModel;
      if (user != null) {
        final chatProvider = context.read<ChatProvider>();
        chatProvider.listenToMessages(user.uid);
      }
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

  Future<void> _handleSend(
    ChatProvider chatProvider,
    AuthProvider authProvider,
  ) async {
    final user = authProvider.userModel;
    final text = _messageController.text;

    if (user == null || text.trim().isEmpty) {
      return;
    }

    await chatProvider.sendConsumerMessage(consumer: user, message: text);
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
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.supportChatTitle),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: user == null
          ? _buildUnauthenticatedState(context)
          : Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final messages = chatProvider.messages;

                if (chatProvider.isLoadingMessages && messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final hasUnreadFromAdmin = messages.any(
                  (message) => message.isFromAdmin && !message.isReadByUser,
                );

                if (hasUnreadFromAdmin) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    chatProvider.markConversationReadByConsumer(user.uid);
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
                          ? _buildEmptyState(context)
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                final isMine = message.senderId == user.uid;
                                return _MessageBubble(
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
                          style: TextStyle(
                            color: AppColors.error.withOpacity(0.9),
                          ),
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
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                                  : () =>
                                        _handleSend(chatProvider, authProvider),
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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

  Widget _buildUnauthenticatedState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 90, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'Vui lòng đăng nhập để sử dụng tính năng chat',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.chat_bubble_outline, size: 96, color: AppColors.divider),
            SizedBox(height: 24),
            Text(
              AppStrings.chatEmptyTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              AppStrings.chatEmptySubtitle,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

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
