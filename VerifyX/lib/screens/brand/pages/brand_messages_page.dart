import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// BRAND MESSAGES PAGE - Tab tin nhắn
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Tab 4 của Brand - Tin nhắn và hỗ trợ
/// - Nhắn tin với khách hàng
/// - Hỗ trợ khách hàng
/// - Xử lý câu hỏi về sản phẩm
/// 
/// ═══════════════════════════════════════════════════════════════════════════
class BrandMessagesPage extends StatefulWidget {
  const BrandMessagesPage({super.key});

  @override
  State<BrandMessagesPage> createState() => _BrandMessagesPageState();
}

class _BrandMessagesPageState extends State<BrandMessagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tin nhắn',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tìm kiếm tin nhắn đang phát triển')),
              );
            },
          ),
        ],
      ),
      body: _buildEmptyState(),
    );
  }

  /// Hiển thị trạng thái rỗng khi chưa có tin nhắn
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có tin nhắn nào',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tin nhắn từ khách hàng sẽ hiển thị ở đây',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Tạo tin nhắn mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
