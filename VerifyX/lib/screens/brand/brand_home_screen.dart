import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Import cột phải
import 'package:verifyx/screens/home/widgets/web_right_sidebar.dart'; 

// Import cột trái
import 'widgets/brand_left_sidebar.dart'; 

import 'pages/brand_community_page.dart';
import 'pages/product_management_page.dart';
import 'pages/batch_tracking_page.dart';
import 'pages/verification_logs_page.dart';
import 'pages/reports_management_page.dart';
import 'pages/brand_profile_page.dart';

class BrandHomeScreen extends StatefulWidget {
  const BrandHomeScreen({super.key});

  @override
  State<BrandHomeScreen> createState() => _BrandHomeScreenState();
}

class _BrandHomeScreenState extends State<BrandHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const BrandCommunityPage(), // Tab 1: Cộng đồng
    const ProductManagementPage(), // Tab 2: Sản phẩm
    const BatchTrackingPage(), // Tab 3: Lô hàng
    const VerificationLogsPage(), // Tab 4: Xác thực
    const ReportsManagementPage(), // Tab 5: Báo cáo
    const BrandProfilePage(), // Tab 6: Tài khoản
  ];

  void _onSelectPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // 1. GIAO DIỆN WEB (3 CỘT)
      return Scaffold(
        backgroundColor: const Color(0xFFF0F2F5), // Nền xám
        body: Row(
          children: [
            // Cột trái: Menu của Brand
            BrandLeftSidebar(
              currentIndex: _currentIndex,
              onSelectPage: _onSelectPage,
            ),

            // Cột giữa: Nội dung trang
            Expanded(
              flex: 2,
              child: Padding(
                // 💡 SỬA LỖI CÚ PHÁP: Bỏ "EdgeInsets:" thừa
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                
                // Bọc trong Builder để sửa lỗi 'deactivated widget'
                child: Builder(
                  builder: (context) {
                    return _pages[_currentIndex];
                  },
                ),

              ),
            ),

            // Cột phải: Sidebar phụ
            const WebRightSidebar(),
          ],
        ),
      );
    } else {
      // 2. GIAO DIỆN DI ĐỘNG (GIỮ NGUYÊN)
      return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF4A4DE6), // Màu xanh đậm
          unselectedItemColor: Colors.grey[600],
          iconSize: 32,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 8,
          items: const [
             BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_2_outlined),
              activeIcon: Icon(Icons.qr_code_2),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_outlined),
              activeIcon: Icon(Icons.verified_user),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '',
            ),
          ],
        ),
      );
    }
  }
}