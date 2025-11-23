import 'package:flutter/material.dart';

/// Widget Card Sản Phẩm Đã Kiểm Tra Gần Đây
/// 
/// Hiển thị thông tin sản phẩm đã được xác thực trong lịch sử
/// Bao gồm: Hình ảnh, tên sản phẩm, thương hiệu, trạng thái xác thực
/// 
/// Sử dụng:
/// ```dart
/// RecentProductCard(
///   productName: 'iPhone 15 Pro Max',
///   brand: 'Apple',
///   status: 'Chính hãng',
///   statusColor: Colors.green,
///   onTap: () {
///     // Xem chi tiết sản phẩm
///   },
/// )
/// ```
class RecentProductCard extends StatelessWidget {
  // Tên sản phẩm (vd: "iPhone 15 Pro Max")
  final String productName;
  
  // Thương hiệu (vd: "Apple")
  final String brand;
  
  // Trạng thái xác thực (vd: "Chính hãng", "Nghi ngờ giả")
  final String status;
  
  // Màu của trạng thái (Xanh = chính hãng, Đỏ = giả)
  final Color statusColor;
  
  // Hàm callback khi người dùng nhấn vào card để xem chi tiết
  final VoidCallback onTap;

  const RecentProductCard({
    super.key,
    required this.productName,
    required this.brand,
    required this.status,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12), // Khoảng cách giữa các card
      elevation: 2, // Độ nổi (shadow)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Bo góc
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12), // Padding bên trong
        
        // Leading: Hình ảnh sản phẩm (placeholder)
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200], // Màu nền placeholder
            borderRadius: BorderRadius.circular(8), // Bo góc
          ),
          // Icon tạm thời, sau này thay bằng ảnh thật
          child: const Icon(
            Icons.phone_android,
            size: 32,
            color: Colors.grey,
          ),
        ),
        
        // Title: Tên sản phẩm
        title: Text(
          productName,
          style: const TextStyle(
            fontWeight: FontWeight.bold, // Text đậm
          ),
        ),
        
        // Subtitle: Thương hiệu
        subtitle: Text(brand),
        
        // Trailing: Badge trạng thái xác thực
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            // Background màu nhạt (10% opacity)
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20), // Bo góc oval
            border: Border.all(color: statusColor), // Viền màu status
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor, // Text cùng màu với viền
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        
        // Sự kiện tap để xem chi tiết
        onTap: onTap,
      ),
    );
  }
}
