import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart' as custom_auth;
import '../auth/login_screen.dart';
import 'chat/admin_chat_screen.dart';
import 'tabs/admin_posts_tab.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedIndex = 0;
  
  // --- THÊM BIẾN LỌC ---
  // Mặc định là 'All' (Tất cả)
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

  Future<void> _loadStatistics() async {
    // ... (Giữ nguyên code load thống kê cũ) ...
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

  Future<void> _handleLogout() async {
    // ... (Giữ nguyên code đăng xuất) ...
    final authProvider = Provider.of<custom_auth.AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  // --- LOGIC XÓA USER ---
  Future<void> _confirmDeleteUser(String userId, String email) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa người dùng?"),
        content: Text("Bạn có chắc chắn muốn xóa tài khoản $email? Hành động này sẽ xóa dữ liệu khỏi hệ thống."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                // Xóa document trong Firestore collection 'users'
                await _firestore.collection('users').doc(userId).delete();
                
                // Lưu ý: Việc xóa user khỏi Authentication (Login) cần Admin SDK ở Backend. 
                // Ở đây ta chỉ xóa thông tin trong Database để họ không hiện lên danh sách.
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã xóa người dùng"), backgroundColor: Colors.green),
                  );
                  _loadStatistics(); // Load lại thống kê
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi khi xóa: $e"), backgroundColor: Colors.red),
                  );
                }
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
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 900;
        if (isMobile) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              iconTheme: const IconThemeData(color: Color(0xFF1A237E)),
              title: const Text('VERIFYX ADMIN', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminChatScreen())),
                )
              ],
            ),
            drawer: Drawer(child: _buildSidebar(isMobile: true)),
            body: _buildBodyContent(),
          );
        } else {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            body: Row(
              children: [
                _buildSidebar(isMobile: false),
                Expanded(
                  child: Column(
                    children: [
                      _buildWebHeader(),
                      Expanded(child: _buildBodyContent()),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // ... (Giữ nguyên _buildSidebar, _buildMenuItem, _buildWebHeader) ...
  Widget _buildSidebar({required bool isMobile}) {
    return Container(
      width: 260,
      color: const Color(0xFF1A237E),
      child: Column(
        children: [
          if (!isMobile)
            Container(
              height: 80,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text('VERIFYX', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          else
            const SizedBox(height: 40),
          const SizedBox(height: 20),
          _buildMenuItem(0, 'Dashboard', Icons.dashboard_outlined),
          _buildMenuItem(1, 'Quản lý Bài viết', Icons.article_outlined),
          _buildMenuItem(2, 'Text 1', Icons.text_fields),
          _buildMenuItem(3, 'Text 2', Icons.layers_outlined),
          const Spacer(),
          ListTile(
            onTap: _handleLogout,
            leading: const Icon(Icons.logout, color: Colors.white70),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.white70)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: () {
          setState(() => _selectedIndex = index);
          if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
        },
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.white60),
        title: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildWebHeader() {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedIndex == 0 ? 'Dashboard' : _selectedIndex == 1 ? 'Quản lý Bài viết' : 'Cấu hình',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminChatScreen())),
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Chip(
                avatar: CircleAvatar(child: Text(user?.displayName?[0] ?? 'A')),
                label: Text(user?.displayName ?? 'Admin'),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_selectedIndex == 0 && _isLoading) return const Center(child: CircularProgressIndicator());

    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return const AdminPostsTab();
      default:
        return Center(child: Text('Chức năng đang phát triển', style: TextStyle(fontSize: 18, color: Colors.grey)));
    }
  }

  // ==================== CẬP NHẬT DASHBOARD TAB ====================
  Widget _buildDashboardTab() {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 1000;

    // Query cơ sở dữ liệu dựa trên biến lọc _selectedUserFilter
    Query query = _firestore.collection('users').orderBy('createdAt', descending: true);

    // Áp dụng bộ lọc
    if (_selectedUserFilter != 'All') {
      // Lưu ý: Giá trị DB phải khớp chính xác (consumer, Brand, admin)
      String dbValue = '';
      if (_selectedUserFilter == 'Consumer') dbValue = 'consumer';
      else if (_selectedUserFilter == 'Brand') dbValue = 'Brand';
      else if (_selectedUserFilter == 'Admin') dbValue = 'admin';
      
      query = query.where('userType', isEqualTo: dbValue);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (Phần Thẻ Thống kê & Biểu đồ giữ nguyên) ...
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
          
          if (isSmallScreen) ...[
            Container(height: 300, padding: const EdgeInsets.all(16), decoration: _cardDecor(), child: _buildBarChart()),
            const SizedBox(height: 16),
            Container(height: 300, padding: const EdgeInsets.all(16), decoration: _cardDecor(), child: _buildPieChart()),
          ] else 
            SizedBox(
              height: 400,
              child: Row(
                children: [
                  Expanded(flex: 2, child: Container(padding: const EdgeInsets.all(24), decoration: _cardDecor(), child: Column(children: [const Text('Phân bố', style: TextStyle(fontWeight: FontWeight.bold)), Expanded(child: _buildBarChart())]))),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: Container(padding: const EdgeInsets.all(24), decoration: _cardDecor(), child: Column(children: [const Text('Tỷ lệ', style: TextStyle(fontWeight: FontWeight.bold)), Expanded(child: _buildPieChart())]))),
                ],
              ),
            ),

           const SizedBox(height: 24),

           // --- DANH SÁCH NGƯỜI DÙNG (ĐÃ SỬA) ---
           Container(
             padding: const EdgeInsets.all(20), 
             decoration: _cardDecor(),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 // Hàng tiêu đề + Nút lọc
                 Row(
                   children: [
                     const Text('Người dùng mới', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                     const Spacer(),
                     
                     // Các nút lọc
                     if (isSmallScreen) 
                       IconButton(onPressed: _showFilterDialog, icon: const Icon(Icons.filter_list))
                     else ...[
                       _buildFilterChip('All', Colors.grey),
                       const SizedBox(width: 8),
                       _buildFilterChip('Consumer', Colors.blue),
                       const SizedBox(width: 8),
                       _buildFilterChip('Brand', Colors.orange),
                       const SizedBox(width: 8),
                       _buildFilterChip('Admin', Colors.purple),
                     ],
                     
                     const SizedBox(width: 16),
                     IconButton(
                       onPressed: _loadStatistics, // Refresh
                       icon: const Icon(Icons.refresh),
                       tooltip: 'Làm mới',
                     )
                   ],
                 ),
                 
                 const SizedBox(height: 4),
                 if (isSmallScreen) Text("Đang lọc: $_selectedUserFilter", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                 const Divider(),

                 // StreamBuilder với Query đã lọc
                 StreamBuilder<QuerySnapshot>(
                   stream: query.limit(10).snapshots(),
                   builder: (context, snapshot) {
                     if (snapshot.hasError) return Text('Lỗi: ${snapshot.error}');
                     if (!snapshot.hasData) return const LinearProgressIndicator();
                     
                     if (snapshot.data!.docs.isEmpty) {
                       return const Padding(
                         padding: EdgeInsets.all(20),
                         child: Center(child: Text("Không tìm thấy người dùng nào")),
                       );
                     }

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

  // Widget nút lọc nhỏ
  Widget _buildFilterChip(String label, Color color) {
    final isSelected = _selectedUserFilter == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedUserFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // Dialog lọc cho màn hình nhỏ
  void _showFilterDialog() {
    showDialog(context: context, builder: (ctx) => SimpleDialog(
      title: const Text("Lọc theo loại"),
      children: ['All', 'Consumer', 'Brand', 'Admin'].map((f) => SimpleDialogOption(
        onPressed: () {
          setState(() => _selectedUserFilter = f);
          Navigator.pop(ctx);
        },
        child: Text(f, style: TextStyle(fontWeight: _selectedUserFilter == f ? FontWeight.bold : FontWeight.normal)),
      )).toList(),
    ));
  }

  // Widget hiển thị 1 dòng User (Đã thêm nút xóa)
  Widget _buildUserListItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final userType = data['userType'] ?? 'consumer';
    final displayName = data['displayName'] ?? 'Unknown';
    final email = data['email'] ?? '';

    // Màu sắc cho role chip
    Color typeColor;
    if (userType == 'admin') typeColor = Colors.purple;
    else if (userType == 'Brand') typeColor = Colors.orange;
    else typeColor = Colors.blue; // consumer

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      leading: CircleAvatar(
        backgroundColor: typeColor.withOpacity(0.1),
        child: Icon(
          userType == 'Brand' ? Icons.store : (userType == 'admin' ? Icons.security : Icons.person),
          size: 20, 
          color: typeColor
        ),
      ),
      title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(email, style: const TextStyle(fontSize: 13)),
      
      // --- PHẦN BÊN PHẢI (Role + Nút Xóa) ---
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Chip Role
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              userType,
              style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          
          const SizedBox(width: 12), // Khoảng cách
          
          // 2. Nút Xóa
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
            tooltip: 'Xóa tài khoản này',
            onPressed: () => _confirmDeleteUser(doc.id, email),
          ),
          
          // 3. Nút Edit (Giữ lại nút cũ)
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 22, color: Colors.grey),
            tooltip: 'Sửa quyền',
            onPressed: () => _showEditUserDialog(doc.id, displayName, email, userType),
          ),
        ],
      ),
    );
  }

  // ... (Giữ nguyên phần Helper widgets: _cardDecor, _buildStatCard, _buildBarChart, _buildPieChart, _showEditUserDialog) ...

  BoxDecoration _cardDecor() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]);

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecor(),
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

  Widget _buildBarChart() {
    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: (_totalUsers + 5).toDouble(),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) {
           String txt = '';
           if(val == 0) txt = 'User'; else if(val == 1) txt = 'Brand'; else if(val == 2) txt = 'Admin';
           return Text(txt, style: const TextStyle(fontSize: 12));
        })),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: false),
      barGroups: [
        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: _consumerUsers.toDouble(), color: Colors.blue, width: 20, borderRadius: BorderRadius.circular(4))]),
        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: _brandUsers.toDouble(), color: Colors.orange, width: 20, borderRadius: BorderRadius.circular(4))]),
        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: _adminUsers.toDouble(), color: Colors.purple, width: 20, borderRadius: BorderRadius.circular(4))]),
      ]
    ));
  }

  Widget _buildPieChart() {
    return PieChart(PieChartData(
      sections: [
        PieChartSectionData(value: _consumerUsers.toDouble(), color: Colors.blue, radius: 50, showTitle: false),
        PieChartSectionData(value: _brandUsers.toDouble(), color: Colors.orange, radius: 50, showTitle: false),
        PieChartSectionData(value: _adminUsers.toDouble(), color: Colors.purple, radius: 50, showTitle: false),
      ],
      centerSpaceRadius: 40,
    ));
  }

  Future<void> _showEditUserDialog(String uid, String name, String email, String currentType) async {
    String selected = currentType;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
        title: const Text('Sửa quyền hạn'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
           RadioListTile(title: const Text('Consumer'), value: 'consumer', groupValue: selected, onChanged: (v) => setState(() => selected = v!)),
           RadioListTile(title: const Text('Brand'), value: 'Brand', groupValue: selected, onChanged: (v) => setState(() => selected = v!)),
           RadioListTile(title: const Text('Admin'), value: 'admin', groupValue: selected, onChanged: (v) => setState(() => selected = v!)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
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