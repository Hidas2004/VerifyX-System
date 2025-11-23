import 'package:flutter/material.dart';

class BrandLeftSidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onSelectPage;

  const BrandLeftSidebar({
    super.key,
    required this.currentIndex,
    required this.onSelectPage,
  });

  @override
  Widget build(BuildContext context) {
    // Style màu tím đồng bộ
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
          // Logo
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

          // 💡 THAY ĐỔI: 6 mục menu của Brand
          _buildMenuItem(
            icon: Icons.home,
            title: 'Cộng đồng',
            index: 0,
            isActive: currentIndex == 0,
            activeColor: activeColor,
            textColor: textColor,
            activeBgColor: activeBgColor,
            onTapOverride: () => onSelectPage(0),
          ),
          _buildMenuItem(
            icon: Icons.inventory_2,
            title: 'Sản phẩm',
            index: 1,
            isActive: currentIndex == 1,
            activeColor: activeColor,
            textColor: textColor,
            activeBgColor: activeBgColor,
            onTapOverride: () => onSelectPage(1),
          ),
          _buildMenuItem(
            icon: Icons.qr_code_2,
            title: 'Lô hàng',
            index: 2,
            isActive: currentIndex == 2,
            activeColor: activeColor,
            textColor: textColor,
            activeBgColor: activeBgColor,
            onTapOverride: () => onSelectPage(2),
          ),
          _buildMenuItem(
            icon: Icons.verified_user,
            title: 'Xác thực',
            index: 3,
            isActive: currentIndex == 3,
            activeColor: activeColor,
            textColor: textColor,
            activeBgColor: activeBgColor,
            onTapOverride: () => onSelectPage(3),
          ),
          _buildMenuItem(
            icon: Icons.analytics,
            title: 'Báo cáo',
            index: 4,
            isActive: currentIndex == 4,
            activeColor: activeColor,
            textColor: textColor,
            activeBgColor: activeBgColor,
            onTapOverride: () => onSelectPage(4),
          ),
           _buildMenuItem(
            icon: Icons.person,
            title: 'Tài khoản',
            index: 5,
            isActive: currentIndex == 5,
            activeColor: activeColor,
            textColor: textColor,
            activeBgColor: activeBgColor,
            onTapOverride: () => onSelectPage(5),
          ),

          const Spacer(), // Đẩy mục cuối cùng xuống dưới

          // Nút Đăng xuất
          _buildMenuItem(
              icon: Icons.logout,
              title: 'Đăng xuất',
              index: 99,
              isActive: false,
              activeColor: activeColor,
              textColor: textColor,
              activeBgColor: activeBgColor,
              onTapOverride: () {
                debugPrint("Đăng xuất...");
              }),
        ],
      ),
    );
  }

  // Widget helper để build menu item (giữ nguyên style)
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