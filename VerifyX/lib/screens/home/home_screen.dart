import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Import các trang con
import './pages/home_page.dart';
import './pages/search_page.dart';
import './pages/scan_page.dart';
import './pages/messages_page.dart';
import './pages/menu_page.dart';

// Import Web Layout
import 'web_home_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),        // 0: Home
    const SearchPage(),      // 1: Search
    const SizedBox(),        // 2: Placeholder
    const MessagesPage(),    // 3: Chat
    const MenuPage(),        // 4: Profile
  ];

  void _onTabTapped(int index) {
    if (index == 2) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. WEB LAYOUT
    if (kIsWeb) {
      return WebHomeLayout(pages: _pages);
    }

    // 2. MOBILE LAYOUT
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      // --- SỬA: Nút QR Code đồng bộ màu Brand ---
      floatingActionButton: Container(
        width: 68,
        height: 68,
        margin: const EdgeInsets.only(top: 30),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00BCD4).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanPage()));
          },
          backgroundColor: const Color(0xFF00BCD4), // Màu Cyan Brand
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- Thanh Menu dưới đáy ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 20,
        surfaceTintColor: Colors.white,
        height: 70,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 0),
            _buildNavItem(Icons.search_rounded, 1),
            const SizedBox(width: 48), // Khoảng trống cho nút QR
            _buildNavItem(Icons.chat_bubble_outline_rounded, 3),
            _buildNavItem(Icons.person_outline_rounded, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return IconButton(
      onPressed: () => _onTabTapped(index),
      icon: Icon(
        icon,
        size: 28,
        color: isSelected ? const Color(0xFF00BCD4) : Colors.grey[400],
      ),
    );
  }
}