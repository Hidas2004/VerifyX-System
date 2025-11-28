import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart' as custom_auth;
import '.././auth/login_screen.dart';

// Các trang con (Đã bỏ BrandDashboardPage)
import './pages/brand_community_page.dart';
import './pages/product_management_page.dart';
import './pages/batch_tracking_page.dart';
import './pages/verification_logs_page.dart';
import './pages/reports_management_page.dart';
import './pages/brand_profile_page.dart';

class BrandHomeScreen extends StatefulWidget {
  const BrandHomeScreen({super.key});

  @override
  State<BrandHomeScreen> createState() => _BrandHomeScreenState();
}

class _BrandHomeScreenState extends State<BrandHomeScreen> {
  int _selectedIndex = 0; // Mặc định vào trang đầu tiên (Cộng đồng)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 🟢 DANH SÁCH MỚI: Bỏ Dashboard, đưa Cộng đồng lên đầu
  final List<Widget> _pages = [
    const BrandCommunityPage(),      // Index 0
    const ProductManagementPage(),   // Index 1
    const BatchTrackingPage(),       // Index 2
    const VerificationLogsPage(),    // Index 3
    const ReportsManagementPage(),   // Index 4
    const BrandProfilePage(),        // Index 5
  ];

  final List<String> _titles = [
    "Quản trị Cộng đồng", // Tên mới chuyên nghiệp hơn
    "Sản phẩm",
    "Lô hàng",
    "Nhật ký",
    "Báo cáo",
    "Hồ sơ"
  ];

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<custom_auth.AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _onMenuTap(int index) {
    setState(() => _selectedIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.adminBackground,
      drawer: !isDesktop ? Drawer(child: _buildSidebarContent()) : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) SizedBox(width: 260, child: _buildSidebarContent()),
          Expanded(
            child: Column(
              children: [
                _buildHeader(isDesktop),
                Expanded(
                  // Dùng IndexedStack để không bị reload lại khi chuyển tab (quan trọng cho ProductPage)
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _pages,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Logo
          Container(
            height: 70,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
            child: Row(
              children: [
                const Icon(Icons.verified_user, color: AppColors.kpiBlue, size: 28),
                const SizedBox(width: 10),
                Text('VerifyX Brand', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft, 
              child: Text("QUẢN LÝ", style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold))
            ),
          ),

          // Menu Items - Đã cập nhật index
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMenuItem(0, 'Cộng đồng', Icons.forum_outlined), // Mới
                  _buildMenuItem(1, 'Sản phẩm', Icons.inventory_2_outlined),
                  _buildMenuItem(2, 'Lô hàng', Icons.local_shipping_outlined),
                  _buildMenuItem(3, 'Xác thực', Icons.qr_code_scanner),
                  _buildMenuItem(4, 'Báo cáo', Icons.bar_chart_outlined),
                  const Divider(),
                  _buildMenuItem(5, 'Cấu hình', Icons.settings_outlined),
                ],
              ),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Đăng xuất", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: _handleLogout,
          )
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onMenuTap(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kpiBlue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.kpiBlue : Colors.grey[600], size: 22),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(color: isSelected ? AppColors.kpiBlue : Colors.grey[800], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: Row(
        children: [
          if (!isDesktop) IconButton(icon: const Icon(Icons.menu), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
          Text(_titles[_selectedIndex], style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}