import 'package:flutter/material.dart';

// --- SỬA LỖI ĐƯỜNG DẪN IMPORT ---
// Đường dẫn đúng: đi ra 2 cấp (../..) để tới thư mục 'lib', rồi vào 'services'
import '../../../services/ai_service.dart'; 
// --- KẾT THÚC SỬA LỖI ---

class AiChatPopup extends StatefulWidget {
  final VoidCallback onClose; // Hàm callback để đóng pop-up
  const AiChatPopup({Key? key, required this.onClose}) : super(key: key);

  @override
  State<AiChatPopup> createState() => _AiChatPopupState();
}

class _AiChatPopupState extends State<AiChatPopup> {
  final AiService _aiService = AiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Tin nhắn chào mừng
    _messages.add(ChatMessage(
      text: "Chào bạn! Tôi là trợ lý AI của VerifyX. Bạn cần giúp gì?",
      isFromUser: false,
    ));
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Thêm tin nhắn của người dùng vào danh sách
    setState(() {
      _messages.add(ChatMessage(text: text, isFromUser: true));
      _isLoading = true; // Bắt đầu loading
    });
    _controller.clear();
    _scrollToBottom();

    // Gọi AI service
    final aiReply = await _aiService.getAiResponse(text);

    // Thêm tin nhắn của AI vào danh sách
    setState(() {
      _messages.add(ChatMessage(text: aiReply, isFromUser: false));
      _isLoading = false; // Dừng loading
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // Tự động cuộn xuống tin nhắn mới nhất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy màu chủ đạo từ Theme (giả định là màu xanh của bạn)
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      width: 350, // Chiều rộng hộp chat
      height: 500, // Chiều cao hộp chat
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header của hộp chat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Trợ lý AI VerifyX",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: widget.onClose, // Gọi hàm đóng
                  tooltip: 'Đóng',
                ),
              ],
            ),
          ),
          // Danh sách tin nhắn
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, primaryColor);
              },
            ),
          ),
          // Thanh loading (nếu đang tải)
          if (_isLoading)
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              backgroundColor: Colors.grey.shade200,
            ),
          // Khu vực nhập tin nhắn
          _buildTextInput(primaryColor),
        ],
      ),
    );
  }

  // Giao diện bong bóng chat
  Widget _buildMessageBubble(ChatMessage message, Color primaryColor) {
    final align =
        message.isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = message.isFromUser
        ? primaryColor.withOpacity(0.1)
        : Colors.grey.shade200;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  // Giao diện thanh nhập tin
  Widget _buildTextInput(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Nhập tin nhắn...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: primaryColor),
            onPressed: _sendMessage,
            tooltip: 'Gửi',
          ),
        ],
      ),
    );
  }
}