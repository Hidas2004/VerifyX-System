import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // --- BIẾN CŨ CỦA BẠN ---
  String _selectedUserFilter = 'All'; 
  int _totalUsers = 0;
  int _consumerUsers = 0;
  int _brandUsers = 0;
  int _adminUsers = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  // Logic load thống kê User cũ của bạn
  Future<void> _loadStatistics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      int total = 0;
      int consumers = 0;
      int brands = 0;
      int admins = 0;

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final userType = data['userType'] ?? 'consumer';
        total++;
        if (userType == 'consumer') consumers++;
        else if (userType == 'Brand') brands++;
        else if (userType == 'admin') admins++;
      }

      if (mounted) {
        setState(() {
          _totalUsers = total;
          _consumerUsers = consumers;
          _brandUsers = brands;
          _adminUsers = admins;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi load thống kê: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Logic xóa User cũ của bạn
  Future<void> _confirmDeleteUser(String userId, String email) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa người dùng?"),
        content: Text("Bạn có chắc chắn muốn xóa tài khoản $email?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _firestore.collection('users').doc(userId).delete();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa"), backgroundColor: Colors.green));
                  _loadStatistics();
                }
              } catch (e) {
                debugPrint("Lỗi xóa: $e");
              }
            },
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logic Lọc cũ của bạn
    Query query = _firestore.collection('users').orderBy('createdAt', descending: true);
    if (_selectedUserFilter != 'All') {
      String dbValue = '';
      if (_selectedUserFilter == 'Consumer') dbValue = 'consumer';
      else if (_selectedUserFilter == 'Brand') dbValue = 'Brand';
      else if (_selectedUserFilter == 'Admin') dbValue = 'admin';
      query = query.where('userType', isEqualTo: dbValue);
    }

    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 1000;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thống kê số lượng (Giữ lại giao diện cũ ở Tab này)
          if (isSmallScreen) ...[
             Row(children: [_buildStatCard('Tổng User', '$_totalUsers', Icons.people, Colors.blue), const SizedBox(width: 10), _buildStatCard('Consumers', '$_consumerUsers', Icons.person, Colors.green)]),
             const SizedBox(height: 10),
             Row(children: [_buildStatCard('Brands', '$_brandUsers', Icons.store, Colors.orange), const SizedBox(width: 10), _buildStatCard('Admins', '$_adminUsers', Icons.security, Colors.purple)]),
          ] else 
             Row(children: [
               _buildStatCard('Tổng User', '$_totalUsers', Icons.people, Colors.blue), const SizedBox(width: 16),
               _buildStatCard('Consumers', '$_consumerUsers', Icons.person, Colors.green), const SizedBox(width: 16),
               _buildStatCard('Brands', '$_brandUsers', Icons.store, Colors.orange), const SizedBox(width: 16),
               _buildStatCard('Admins', '$_adminUsers', Icons.security, Colors.purple),
             ]),

          const SizedBox(height: 24),

          // 2. Danh sách User (Code cũ)
          Container(
            padding: const EdgeInsets.all(20), 
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Danh sách người dùng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    // Nút lọc
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_list),
                      onSelected: (v) => setState(() => _selectedUserFilter = v),
                      itemBuilder: (ctx) => ['All', 'Consumer', 'Brand', 'Admin'].map((c) => PopupMenuItem(value: c, child: Text(c))).toList(),
                    ),
                    IconButton(onPressed: _loadStatistics, icon: const Icon(Icons.refresh)),
                  ],
                ),
                if (_selectedUserFilter != 'All') Text("Đang lọc: $_selectedUserFilter", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Divider(),
                
                StreamBuilder<QuerySnapshot>(
                  stream: query.limit(20).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();
                    if (snapshot.data!.docs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Không có dữ liệu")));

                    return ListView.separated(
                      shrinkWrap: true, 
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, i) => _buildUserListItem(snapshot.data!.docs[i]),
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: TextStyle(color: Colors.grey[600])), Icon(icon, color: color)]),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserListItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListTile(
      leading: CircleAvatar(child: Text((data['displayName'] ?? 'U')[0])),
      title: Text(data['displayName'] ?? 'Unknown'),
      subtitle: Text(data['email'] ?? ''),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(label: Text(data['userType'] ?? 'consumer')),
          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditUserDialog(doc.id, data['userType'] ?? 'consumer')),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDeleteUser(doc.id, data['email'] ?? '')),
        ],
      ),
    );
  }

  Future<void> _showEditUserDialog(String uid, String currentType) async {
    String selected = currentType;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
        title: const Text('Sửa quyền hạn'),
        content: Column(mainAxisSize: MainAxisSize.min, children: ['consumer', 'Brand', 'admin'].map((t) => RadioListTile(title: Text(t), value: t, groupValue: selected, onChanged: (v) => setState(() => selected = v!))).toList()),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx, selected), child: const Text('Lưu')),
        ],
      )),
    );
    if (result != null && result != currentType) {
       await _firestore.collection('users').doc(uid).update({'userType': result});
       _loadStatistics();
    }
  }
}