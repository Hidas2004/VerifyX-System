import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// BRAND PROFILE PAGE - Tab thông tin tài khoản
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Tab 5 của Brand - Thông tin tài khoản và cài đặt
/// - Thông tin Brand
/// - Cài đặt tài khoản
/// - Đăng xuất
/// 
/// ═══════════════════════════════════════════════════════════════════════════
class BrandProfilePage extends StatefulWidget {
  const BrandProfilePage({super.key});

  @override
  State<BrandProfilePage> createState() => _BrandProfilePageState();
}

class _BrandProfilePageState extends State<BrandProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Chưa đăng nhập')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông tin tài khoản',
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
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BCD4)),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Không thể tải thông tin'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          final displayName = userData?['displayName'] ?? 'Chưa có tên';
          final email = userData?['email'] ?? user.email ?? 'Chưa có email';
          final brandName = userData?['brandName'] ?? 'Chưa có tên thương hiệu';
          final phone = userData?['phone'] ?? 'Chưa có số điện thoại';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Avatar và tên Brand
              _buildProfileHeader(brandName, email),
              
              const SizedBox(height: 24),
              
              // Thông tin Brand
              _buildSectionTitle('Thông tin Brand'),
              _buildInfoCard([
                _buildInfoRow(Icons.business, 'Tên thương hiệu', brandName),
                _buildInfoRow(Icons.person, 'Người đại diện', displayName),
                _buildInfoRow(Icons.email, 'Email', email),
                _buildInfoRow(Icons.phone, 'Số điện thoại', phone),
              ]),
              
              const SizedBox(height: 24),
              
              // Cài đặt
              _buildSectionTitle('Cài đặt'),
              _buildSettingsCard(),
              
              const SizedBox(height: 24),
              
              // Nút đăng xuất
              _buildLogoutButton(),
            ],
          );
        },
      ),
    );
  }

  /// Header với avatar và tên
  Widget _buildProfileHeader(String brandName, String email) {
    return Center(
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.business,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Tên brand
          Text(
            brandName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Email
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

  /// Tiêu đề section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  /// Card thông tin
  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  /// Row thông tin
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF00BCD4)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card cài đặt
  Widget _buildSettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildSettingsTile(
            Icons.edit,
            'Chỉnh sửa thông tin',
            'Cập nhật thông tin Brand',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chỉnh sửa thông tin đang phát triển')),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            Icons.lock,
            'Đổi mật khẩu',
            'Thay đổi mật khẩu đăng nhập',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đổi mật khẩu đang phát triển')),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            Icons.notifications,
            'Thông báo',
            'Cài đặt thông báo',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cài đặt thông báo đang phát triển')),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            Icons.help,
            'Trợ giúp',
            'Hướng dẫn sử dụng',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trợ giúp đang phát triển')),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Tile cài đặt
  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00BCD4)),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  /// Nút đăng xuất
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Đăng xuất'),
              content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
          );

          if (confirm == true && mounted) {
            await _auth.signOut();
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Đăng xuất'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[400],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
