import 'package:flutter/material.dart';
import './widgets/ai_chat_popup.dart';
import './widgets/web_left_sidebar.dart'; 

class WebHomeLayout extends StatefulWidget {
  final List<Widget> pages;

  const WebHomeLayout({
    super.key,
    required this.pages,
  });

  @override
  State<WebHomeLayout> createState() => _WebHomeLayoutState();
}

class _WebHomeLayoutState extends State<WebHomeLayout> {
  int _webCurrentIndex = 0;
  bool _isChatOpen = false;

  void _onSelectPage(int index) {
    setState(() {
      _webCurrentIndex = index;
    });
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    // SỬA: Dùng màu nền xám chuẩn Admin (#F5F7FA)
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SIDEBAR (Bây giờ đã là màu trắng)
              WebLeftSidebar(
                currentIndex: _webCurrentIndex,
                onSelectPage: _onSelectPage,
              ),

              // 2. KHUNG NỘI DUNG CHÍNH
              Expanded(
                child: Center(
                  child: Container(
                    // Giữ nguyên max width để nội dung không bị bè
                    constraints: const BoxConstraints(maxWidth: 1100),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                    child: widget.pages[_webCurrentIndex],
                  ),
                ),
              ),
            ],
          ),

          // 3. AI CHAT POPUP
          if (_isChatOpen)
            Positioned(
              bottom: 90,
              right: 24,
              child: AiChatPopup(onClose: _toggleChat),
            ),
        ],
      ),

      // 4. FAB Button
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleChat,
        backgroundColor: const Color(0xFF4A4DE6), // Màu xanh Brand
        elevation: 4,
        tooltip: 'Chat với trợ lý AI',
        child: Icon(
          _isChatOpen ? Icons.close : Icons.chat_bubble_outline_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}