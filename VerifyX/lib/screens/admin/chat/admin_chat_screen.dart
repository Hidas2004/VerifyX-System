import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../models/chat_thread_model.dart';
import '../../../providers/chat_provider.dart';
import '../../../utils/formatters.dart';
import 'admin_chat_detail_screen.dart';

/// Admin inbox listing all support conversations.
class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().listenToThreads();
    });
  }

  @override
  void dispose() {
    context.read<ChatProvider>().stopListeningThreads();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminInbox),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          if (chatProvider.isLoadingThreads && chatProvider.threads.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final threads = chatProvider.threads;

          if (threads.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: threads.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, index) {
              final thread = threads[index];
              return _ThreadTile(thread: thread);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.mark_chat_read_outlined,
            size: 96,
            color: AppColors.divider,
          ),
          SizedBox(height: 24),
          Text(
            'Chưa có yêu cầu hỗ trợ nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Khi người dùng cần hỗ trợ, tin nhắn sẽ xuất hiện tại đây.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.thread});

  final ChatThread thread;

  @override
  Widget build(BuildContext context) {
    final initials = _buildInitials();
    final subtitle = thread.lastMessage.isNotEmpty
        ? Formatters.truncate(thread.lastMessage, 50)
        : 'Chưa có tin nhắn';

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primary.withOpacity(0.12),
        child: Text(
          initials,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
      title: Text(
        thread.userDisplayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Formatters.relativeTime(thread.updatedAt),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (thread.hasUnreadForAdmin) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${thread.unreadByAdmin}',
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AdminChatDetailScreen(thread: thread),
          ),
        );
      },
    );
  }

  String _buildInitials() {
    final name = thread.userDisplayName.trim();
    if (name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      final buffer = StringBuffer();
      for (final part in parts) {
        if (part.isNotEmpty) {
          buffer.write(part[0]);
        }
        if (buffer.length == 2) {
          break;
        }
      }
      final letters = buffer.toString();
      if (letters.isNotEmpty) {
        return letters.substring(0, 1).toUpperCase();
      }
    }

    if (thread.userEmail.isNotEmpty) {
      return thread.userEmail[0].toUpperCase();
    }

    return 'U';
  }
}
