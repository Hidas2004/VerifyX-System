import 'package:flutter/material.dart';

class WebRightSidebar extends StatelessWidget {
  const WebRightSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: ListView(
        padding: const EdgeInsets.only(right: 24),
        children: [
          // 🟢 ĐỔI NỘI DUNG: CẢNH BÁO LỪA ĐẢO
          _buildInfoCard(
            title: "⚠️ Cảnh báo lừa đảo",
            child: Column(
              children: [
                _buildUserTile("Shop Quần Áo XYZ", "Giả mạo thương hiệu", isWarning: true),
                _buildUserTile("Mỹ Phẩm Giá Rẻ", "Hàng không rõ nguồn gốc", isWarning: true),
                _buildUserTile("Đại lý Vé Fake", "Lừa đảo chuyển khoản", isWarning: true),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 🟢 ĐỔI NỘI DUNG: SẢN PHẨM HOT
          _buildInfoCard(
            title: "🔥 Sản phẩm xác thực nhiều",
            child: Column(
              children: [
                _buildProductTile("Nike Air Jordan 1", "2.5k lượt check"),
                _buildProductTile("iPhone 15 Pro Max", "1.8k lượt check"),
                _buildProductTile("Son MAC Chili", "900 lượt check"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(String name, String reason, {bool isWarning = false}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isWarning ? Colors.red[50] : Colors.grey[100],
        child: Icon(isWarning ? Icons.warning_amber : Icons.store, color: isWarning ? Colors.red : Colors.blue),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(reason, style: TextStyle(color: isWarning ? Colors.red[300] : Colors.grey, fontSize: 12)),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildProductTile(String name, String checks) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.check_circle_outline, color: Colors.blue),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(checks, style: const TextStyle(fontSize: 12)),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      dense: true,
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}