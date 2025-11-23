import 'package:flutter/foundation.dart' show kIsWeb; // 💡 THÊM IMPORT NÀY
import 'package:flutter/material.dart';

// Import các trang con
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/scan_page.dart';
import 'pages/messages_page.dart';
import 'pages/menu_page.dart';

// 💡 THÊM IMPORT CHO WEB LAYOUT MỚI (bạn sẽ tạo ở Bước 2)
import 'web_home_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Index của tab hiện tại đang được chọn (0-4)
  int _currentIndex = 0;

  /// Danh sách 5 trang tương ứng với 5 tabs
  final List<Widget> _pages = [
    const HomePage(),       // Index 0: Trang chủ
    const SearchPage(),     // Index 1: Tìm kiếm
    const ScanPage(),       // Index 2: Quét mã
    const MessagesPage(),   // Index 3: Tin nhắn
    const MenuPage(),       // Index 4: Menu
  ];

  @override
  Widget build(BuildContext context) {
    // 💡 LOGIC CHIA TÁCH WEB/APP
    if (kIsWeb) {
      // ➡️ NẾU LÀ WEB: Trả về layout 3 cột MỚI
      // Chúng ta truyền danh sách pages vào để web layout có thể sử dụng
      return WebHomeLayout(
        pages: _pages,
      );
    } else {
      // ➡️ NẾU LÀ APP: Trả về layout cũ của bạn
      return _buildAppLayout();
    }
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// 📱 WIDGET GIAO DIỆN APP (BottomNavigationBar)
  /// ───────────────────────────────────────────────────────────────────────
  Widget _buildAppLayout() {
    return Scaffold(
      // Body: Hiển thị page tương ứng với tab đang chọn
      body: _pages[_currentIndex],

      // Bottom Navigation Bar: 5 tabs
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Tab đang được chọn
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Cập nhật tab hiện tại
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00BCD4),
        unselectedItemColor: Colors.grey[600],
        iconSize: 32,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 8,
        items: const [
          // Tab 1: Trang chủ
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '',
          ),
          // Tab 2: Tìm kiếm
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: '',
          ),
          // Tab 3: Quét mã QR
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: '',
          ),
          // Tab 4: Tin nhắn
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: '',
          ),
          // Tab 5: Menu & Cài đặt
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_outlined),
            activeIcon: Icon(Icons.menu),
            label: '',
          ),
        ],
      ),
    );
  }
}