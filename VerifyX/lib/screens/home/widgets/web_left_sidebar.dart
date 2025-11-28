import 'package:flutter/material.dart';

class WebLeftSidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onSelectPage;

  const WebLeftSidebar({
    super.key,
    required this.currentIndex,
    required this.onSelectPage,
  });

  @override
  Widget build(BuildContext context) {
    // --- BẢNG MÀU MỚI (COPY TỪ BRAND ADMIN) ---
    const Color primaryColor = Color(0xFF4A4DE6); // Màu xanh thương hiệu
    const Color sidebarBgColor = Colors.white;    // Nền trắng
    final Color inactiveTextColor = Colors.grey[600]!; // Chữ xám
    final Color activeTextColor = primaryColor;   // Chữ xanh khi active
    final Color activeBgColor = primaryColor.withOpacity(0.08); // Nền xanh siêu nhạt khi active
    final Color borderColor = Colors.grey[200]!;  // Đường kẻ ngăn cách

    return Container(
      width: 260, // Rộng hơn chút cho thoáng
      decoration: BoxDecoration(
        color: sidebarBgColor,
        border: Border(right: BorderSide(color: borderColor)), // Đường kẻ bên phải
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. LOGO (Màu Xanh trên nền Trắng)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.verified_user, color: primaryColor, size: 32),
                const SizedBox(width: 12),
                Text(
                  "VerifyX",
                  style: TextStyle(
                    color: Colors.black87, // Chữ đen đậm
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // 2. MENU ITEMS (Style Dashboard)
          Text(
            "MENU CHÍNH",
            style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 8),

          _buildMenuItem(
            icon: Icons.home_outlined, // Dùng icon outlined cho tinh tế
            activeIcon: Icons.home,
            title: 'Trang chủ',
            index: 0,
            isActive: currentIndex == 0,
            activeTextColor: activeTextColor,
            inactiveTextColor: inactiveTextColor,
            activeBgColor: activeBgColor,
            onTap: () => onSelectPage(0),
          ),
          _buildMenuItem(
            icon: Icons.search,
            activeIcon: Icons.search,
            title: 'Tìm kiếm',
            index: 1,
            isActive: currentIndex == 1,
            activeTextColor: activeTextColor,
            inactiveTextColor: inactiveTextColor,
            activeBgColor: activeBgColor,
            onTap: () => onSelectPage(1),
          ),
          _buildMenuItem(
            icon: Icons.qr_code_scanner,
            activeIcon: Icons.qr_code_scanner,
            title: 'Quét mã',
            index: 2,
            isActive: currentIndex == 2,
            activeTextColor: activeTextColor,
            inactiveTextColor: inactiveTextColor,
            activeBgColor: activeBgColor,
            onTap: () => onSelectPage(2),
          ),
          _buildMenuItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            title: 'Tin nhắn',
            index: 3,
            isActive: currentIndex == 3,
            activeTextColor: activeTextColor,
            inactiveTextColor: inactiveTextColor,
            activeBgColor: activeBgColor,
            onTap: () => onSelectPage(3),
          ),

          const Spacer(), // Đẩy mục dưới xuống đáy

          const Divider(),
          _buildMenuItem(
            icon: Icons.logout,
            activeIcon: Icons.logout,
            title: 'Đăng xuất',
            index: 99,
            isActive: false,
            activeTextColor: Colors.red, // Riêng logout màu đỏ
            inactiveTextColor: Colors.redAccent,
            activeBgColor: Colors.red.withOpacity(0.1),
            onTap: () {
               // Logic logout
               debugPrint("Logout");
            },
          ),
        ],
      ),
    );
  }

  // Helper Widget đã được Style lại
  Widget _buildMenuItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required int index,
    required bool isActive,
    required Color activeTextColor,
    required Color inactiveTextColor,
    required Color activeBgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4), // Khoảng cách giữa các nút nhỏ hơn
      decoration: BoxDecoration(
        color: isActive ? activeBgColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          isActive ? activeIcon : icon, 
          color: isActive ? activeTextColor : inactiveTextColor,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? activeTextColor : inactiveTextColor,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        dense: true, // Làm nút gọn lại giống Admin Panel
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}