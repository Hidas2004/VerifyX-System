import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart' as custom_auth;
import '../../auth/login_screen.dart';
import '../../brand/brand_home_screen.dart';
import '../../debug/update_usertype_screen.dart';

/// Trang menu cài đặt
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // Bỏ AppBar mặc định để làm Header cong tự tạo
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get(),
        builder: (context, snapshot) {
          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          final displayName = userData?['displayName'] ?? 'User';
          final email = userData?['email'] ?? currentUser?.email ?? '';
          final photoURL = userData?['photoURL'];

          return SingleChildScrollView(
            child: Column(
              children: [
                // HEADER CONG (Sửa lại cho đẹp)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF00BCD4),
                        backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
                        child: photoURL == null ? Text(displayName[0].toUpperCase(), style: const TextStyle(fontSize: 30, color: Colors.white)) : null,
                      ),
                      const SizedBox(height: 12),
                      Text(displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(email, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),

                // Brand Management (Chỉ hiện nếu là brand)
                if (userData?['userType'] == 'brand') 
                  _buildBrandCard(context),

                // Menu items
                _buildMenuItem(context, icon: Icons.person_outline, title: 'Thông tin cá nhân', onTap: () {}),
                _buildMenuItem(context, icon: Icons.history_outlined, title: 'Lịch sử kiểm tra', onTap: () {}),
                _buildMenuItem(context, icon: Icons.settings_outlined, title: 'Cài đặt', onTap: () {}),
                _buildMenuItem(context, icon: Icons.info_outline, title: 'Về VerifyX', onTap: () => _showAboutDialog(context)),
                
                // 💡 ĐÃ ẨN NÚT DEBUG
                // _buildMenuItem(context, icon: Icons.bug_report, title: 'DEBUG', onTap: ...),

                const Divider(height: 32),
                _buildMenuItem(context, icon: Icons.logout, title: 'Đăng xuất', titleColor: Colors.red, iconColor: Colors.red, onTap: () => _showLogoutDialog(context)),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Header profile user
  Widget _buildProfileHeader(String displayName, String email, String? photoURL) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00BCD4).withValues(alpha: 0.1),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF00BCD4),
            backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
            child: photoURL == null
                ? Text(
                    displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Menu item
  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color? titleColor, Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey[700]),
      title: Text(title, style: TextStyle(fontSize: 16, color: titleColor ?? Colors.black87, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      onTap: onTap,
    );
  }
  Widget _buildBrandCard(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
            leading: const Icon(Icons.store, color: Colors.white, size: 30),
            title: const Text("Trang Brand", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text("Quản lý sản phẩm", style: TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BrandHomeScreen())),
        ),
    );
  }

  /// Dialog đăng xuất
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<custom_auth.AuthProvider>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  /// Dialog về VerifyX
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Về VerifyX'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VerifyX v1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Hệ thống xác thực sản phẩm chính hãng'),
            Text('Ứng dụng AI và Blockchain'),
            SizedBox(height: 16),
            Text('© 2025 VerifyX Team'),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
