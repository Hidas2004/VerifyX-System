import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../utils/formatters.dart';
import '../../../models/chat_message_model.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.userModel != null) {
        context.read<ChatProvider>().listenToMessages(authProvider.userModel!.uid);
      }
    });
  }

  @override
  void dispose() {
    context.read<ChatProvider>().stopListeningMessages();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSend(ChatProvider chatProvider, AuthProvider authProvider) async {
    final user = authProvider.userModel;
    final text = _messageController.text;
    if (user == null || text.trim().isEmpty) return;
    await chatProvider.sendConsumerMessage(consumer: user, message: text);
    _messageController.clear();
    // Tự động cuộn xuống cuối khi gửi
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 50,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return _buildWebLayout(context);
    return _buildMobileLayout(context);
  }

  // --- MOBILE LAYOUT ---
  Widget _buildMobileLayout(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userModel;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8), // Màu nền xám xanh nhạt hiện đại
      appBar: AppBar(
        title: const Column(
          children: [
            Text("Hỗ trợ VerifyX", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18)),
            Text("Thường phản hồi trong 5 phút", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.green, fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: true,
        leading: const SizedBox(), // Ẩn nút back nếu nằm trong tabbar
      ),
      body: user == null
          ? const Center(child: Text("Vui lòng đăng nhập để chat"))
          : Column(
              children: [
                Expanded(
                  child: Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) {
                      final messages = chatProvider.messages;
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return _MessageBubble(message: msg, isMine: msg.senderId == user.uid);
                        },
                      );
                    },
                  ),
                ),
                _buildInputArea(context, authProvider),
              ],
            ),
    );
  }

  Widget _buildInputArea(BuildContext context, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _handleSend(context.read<ChatProvider>(), authProvider),
              decoration: InputDecoration(
                hintText: "Nhập tin nhắn...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Nút gửi đổi sang màu xanh đậm luôn cho đồng bộ
          Material(
            color: Colors.blue[700], 
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => _handleSend(context.read<ChatProvider>(), authProvider),
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWebLayout(BuildContext context) {
     return const Scaffold(body: Center(child: Text("Web Layout"))); 
  }
}

// --- TINH CHỈNH BONG BÓNG CHAT ---
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});
  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    // Màu sắc chuyên nghiệp hơn
    // - Tin nhắn của tôi: Blue 700 (Đậm đà, tin cậy)
    // - Tin nhắn người khác: Trắng (Sạch sẽ)
    final bubbleColor = isMine ? Colors.blue[700] : Colors.white;
    final textColor = isMine ? Colors.white : Colors.black87;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMine ? 20 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 20),
          ),
          // Thêm bóng nhẹ cho tin nhắn người khác để nổi trên nền xám
          boxShadow: !isMine 
            ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))]
            : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              Formatters.time(message.timestamp),
              style: TextStyle(
                // Chữ thời gian mờ đi một chút
                color: isMine ? Colors.white.withOpacity(0.7) : Colors.grey[400],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}