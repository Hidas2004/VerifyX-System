import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart' as custom_auth;
import '../auth/login_screen.dart';
import 'chat/admin_chat_screen.dart';
// Import các tab
import 'tabs/admin_users_tab.dart';     
import 'tabs/admin_posts_tab.dart';      
import 'tabs/admin_dashboard_tab.dart'; 

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0; 
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<custom_auth.AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.adminBackground,
      drawer: !isDesktop ? Drawer(child: _buildSidebar()) : null,
      body: Row(
        children: [
          if (isDesktop) SizedBox(width: 280, child: _buildSidebar()),
          Expanded(
            child: Column(
              children: [
                _buildHeader(isDesktop),
                Expanded(child: _buildBodyContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SIDEBAR ---
  Widget _buildSidebar() {
    return Container(
      color: AppColors.adminSurface,
      child: Column(
        children: [
          // Logo Area
          Container(
            height: 80,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.kpiBlue, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.verified_user, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text('VerifyX', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.adminTextPrimary)),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            child: Align(alignment: Alignment.centerLeft, child: Text("MENU", style: GoogleFonts.inter(color: AppColors.adminTextSecondary, fontSize: 12, fontWeight: FontWeight.w600))),
          ),

          _buildMenuItem(0, 'Dashboard', Icons.grid_view),
          _buildMenuItem(1, 'Doanh nghiệp & Users', Icons.people_outline),
          _buildMenuItem(2, 'Quản lý Bài viết', Icons.article_outlined),
          _buildMenuItem(3, 'Cấu hình Hệ thống', Icons.settings_outlined),
          
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: InkWell(
              onTap: _handleLogout,
              child: Row(
                children: [
                  const Icon(Icons.logout, color: AppColors.kpiRed),
                  const SizedBox(width: 10),
                  Text("Đăng xuất", style: GoogleFonts.inter(color: AppColors.kpiRed, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kpiBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppColors.adminIcon, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : AppColors.adminTextSecondary,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) const Icon(Icons.chevron_right, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.adminSurface,
        border: Border(bottom: BorderSide(color: AppColors.adminBorder, width: 1)),
      ),
      child: Row(
        children: [
          if (!isDesktop) IconButton(icon: const Icon(Icons.menu), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
          
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isDesktop ? 20 : 10),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm thông tin...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: AppColors.adminIcon),
                ),
                style: GoogleFonts.inter(),
              ),
            ),
          ),

          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: AppColors.adminIcon)),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminChatScreen())),
            icon: const Icon(Icons.chat_bubble_outline, color: AppColors.adminIcon),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(user?.displayName ?? 'Admin', style: GoogleFonts.inter(color: AppColors.adminTextPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('System Admin', style: GoogleFonts.inter(color: AppColors.adminTextSecondary, fontSize: 12)),
                ],
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: AppColors.adminBackground,
                child: Text(user?.displayName?[0] ?? 'A', style: const TextStyle(color: AppColors.kpiBlue)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0: return const AdminDashboardTab();
      case 1: return const AdminUsersTab();
      case 2: return const AdminPostsTab();
      default: return const Center(child: Text("Coming Soon"));
    }
  }
}