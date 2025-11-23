import 'package:flutter/material.dart';
import 'product_management_page.dart';
import 'batch_tracking_page.dart';
import 'verification_logs_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// BRAND PRODUCTS PAGE - Tab quản lý sản phẩm tổng hợp
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Tab 2 của Brand - Gộp 3 chức năng:
/// 1. Quản lý sản phẩm (Product Management)
/// 2. Theo dõi lô hàng (Batch Tracking)
/// 3. Lịch sử xác thực (Verification Logs)
/// 
/// Sử dụng TabBar để chuyển đổi giữa 3 chức năng
/// ═══════════════════════════════════════════════════════════════════════════
class BrandProductsPage extends StatefulWidget {
  const BrandProductsPage({super.key});

  @override
  State<BrandProductsPage> createState() => _BrandProductsPageState();
}

class _BrandProductsPageState extends State<BrandProductsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý sản phẩm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.inventory_2_outlined),
              text: 'Sản phẩm',
            ),
            Tab(
              icon: Icon(Icons.qr_code_2_outlined),
              text: 'Lô hàng',
            ),
            Tab(
              icon: Icon(Icons.verified_user_outlined),
              text: 'Xác thực',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Tab 1: Quản lý sản phẩm
          ProductManagementPage(),
          
          // Tab 2: Theo dõi lô hàng
          BatchTrackingPage(),
          
          // Tab 3: Lịch sử xác thực
          VerificationLogsPage(),
        ],
      ),
    );
  }
}
