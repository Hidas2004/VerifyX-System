import 'package:flutter/material.dart';

// --- THÊM IMPORT (ĐÃ SỬA LỖI) ---
// Thêm './' ở đầu để đảm bảo đường dẫn chính xác
import './widgets/ai_chat_popup.dart';
// --- KẾT THÚC THÊM IMPORT ---

// Import 2 cột widget (file gốc của bạn)
import './widgets/web_left_sidebar.dart';
import './widgets/web_right_sidebar.dart';

class WebHomeLayout extends StatefulWidget {
  /// Nhận danh sách pages từ HomeScreen
  final List<Widget> pages;

  const WebHomeLayout({
    super.key,
    required this.pages,
  });

  @override
  State<WebHomeLayout> createState() => _WebHomeLayoutState();
}

class _WebHomeLayoutState extends State<WebHomeLayout> {
  /// State riêng để quản lý tab nào đang được chọn trên web
  int _webCurrentIndex = 0;

  // --- THÊM STATE ĐIỀU KHIỂN CHAT ---
  bool _isChatOpen = false;
  // --- KẾT THÚC THÊM STATE ---

  void _onSelectPage(int index) {
    setState(() {
      _webCurrentIndex = index;
    });
  }

  // --- THÊM HÀM ĐỂ BẬT/TẮT CHAT ---
  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });
  }
  // --- KẾT THÚC THÊM HÀM ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),

      // --- SỬ DỤNG STACK ĐỂ CÁC WIDGET CÓ THỂ NỔI LÊN TRÊN NHAU ---
      body: Stack(
        children: [
          // 1. NỘI DUNG CHÍNH (3 CỘT CỦA BẠN)
          Row(
            children: [
              // 1. CỘT TRÁI (MENU)
              WebLeftSidebar(
                currentIndex: _webCurrentIndex,
                onSelectPage: _onSelectPage,
              ),

              // 2. CỘT GIỮA (NỘI DUNG CHÍNH)
              Expanded(
                flex: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  child: widget.pages[_webCurrentIndex],
                ),
              ),

              // 3. CỘT PHẢI (GỢI Ý)
              const WebRightSidebar(),
            ],
          ),

          // 2. HỘP CHAT POP-UP (NẾU MỞ)
          // Nó sẽ nổi ở góc dưới bên phải
          if (_isChatOpen)
            Positioned(
              bottom: 90, // Cách đáy 90px (để hở nút FAB)
              right: 24, // Cách phải 24px
              child: AiChatPopup(
                onClose: _toggleChat, // Truyền hàm đóng vào
              ),
            ),
        ],
      ),

      // --- THÊM NÚT BẤM CHAT NỔI ---
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleChat,
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'Chat với trợ lý AI',
        child: Icon(
          _isChatOpen ? Icons.close : Icons.chat_bubble_outline_rounded,
          color: Colors.white,
        ),
      ),
      // --- KẾT THÚC THÊM NÚT BẤM ---
    );
  }
}