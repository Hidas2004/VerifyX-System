import 'package:flutter/material.dart';

class WebLeftSidebar extends StatelessWidget {
  /// Index hiện tại để biết nút nào đang active
  final int currentIndex;

  /// Callback để báo cho WebHomeLayout thay đổi trang
  final Function(int) onSelectPage;

  const WebLeftSidebar({
    super.key,
    required this.currentIndex,
    required this.onSelectPage,
  });

  @override
  Widget build(BuildContext context) {
    // Giữ nguyên các màu sắc mới
    const Color sidebarColor = Color(0xFF4A4DE6);
    const Color activeColor = Colors.white;
    final Color textColor = Colors.white.withOpacity(0.8);
    final Color activeBgColor = Colors.white.withOpacity(0.15);

    return Container(
      width: 250, // Chiều rộng cố định
      color: sidebarColor,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 💡 SỬA LẠI: Trả lại logo "VerifyX"
          const Text(
            "VerifyX",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          // 💡 SỬA LẠI: Trả lại các mục menu GỐC của bạn
          _buildMenuItem(
            icon: Icons.home,
            title: 'Trang chủ',
            index: 0,
            isActive: currentIndex == 0,
            activeColor: activeColor,
            textColor: textColor,
            activeBgColor: activeBgColor,
            onTapOverride: () => onSelectPage(0),
          ),
          _buildMenuItem(
            icon: Icons.search,
            title: 'Tìm kiếm',
            index: 1,
            isActive: currentIndex == 1,
            activeColor: activeColor,
            textColor: textColor,
            activeBgColor: activeBgColor,
            onTapOverride: () => onSelectPage(1),
          ),
          _buildMenuItem(
            icon: Icons.qr_code_scanner,
            title: 'Quét mã',
            index: 2,
            isActive: currentIndex == 2,
            activeColor: activeColor,
            textColor: textColor,
            activeBgColor: activeBgColor,
            onTapOverride: () => onSelectPage(2),
          ),
          _buildMenuItem(
            icon: Icons.chat_bubble,
            title: 'Tin nhắn',
            index: 3,
            isActive: currentIndex == 3,
            activeColor: activeColor,
            textColor: textColor,
            activeBgColor: activeBgColor,
            onTapOverride: () => onSelectPage(3),
          ),
          _buildMenuItem(
            icon: Icons.menu,
            title: 'Menu',
            index: 4,
            isActive: currentIndex == 4,
            activeColor: activeColor,
            textColor: textColor,
            activeBgColor: activeBgColor,
            onTapOverride: () => onSelectPage(4),
          ),

          const Spacer(), // Đẩy mục cuối cùng xuống dưới

          // 💡 SỬA LẠI: Trả lại nút Đăng xuất
          _buildMenuItem(
              icon: Icons.logout,
              title: 'Đăng xuất',
              index: 99, // Index không trùng lặp
              isActive: false,
              activeColor: activeColor,
              textColor: textColor,
              activeBgColor: activeBgColor,
              onTapOverride: () {
                // TODO: Xử lý logic đăng xuất
                debugPrint("Đăng xuất...");
              }),
          
          // 💡 SỬA LẠI: Đã xóa "Go Pro"
        ],
      ),
    );
  }

  // Giữ nguyên widget helper với style mới
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
    required bool isActive,
    required Color activeColor,
    required Color textColor,
    required Color activeBgColor,
    VoidCallback? onTapOverride,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? activeBgColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? activeColor : textColor),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? activeColor : textColor,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTapOverride,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}