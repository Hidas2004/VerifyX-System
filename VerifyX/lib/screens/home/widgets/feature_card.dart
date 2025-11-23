import 'package:flutter/material.dart';

/// Widget Card Tính Năng - Có thể tái sử dụng
/// 
/// Hiển thị một card với icon và tiêu đề, dùng cho grid tính năng
/// trên trang chủ (Quét QR, Chụp ảnh, Lịch sử, Yêu thích...)
/// 
/// Sử dụng:
/// ```dart
/// FeatureCard(
///   icon: Icons.qr_code_scanner,
///   title: 'Quét QR',
///   color: Colors.blue,
///   onTap: () {
///     // Xử lý khi nhấn
///   },
/// )
/// ```
class FeatureCard extends StatelessWidget {
  // Icon hiển thị (vd: Icons.qr_code_scanner)
  final IconData icon;
  
  // Tiêu đề hiển thị dưới icon (vd: "Quét QR")
  final String title;
  
  // Màu của icon và background circle (vd: Colors.blue)
  final Color color;
  
  // Hàm callback khi người dùng nhấn vào card
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Độ nổi của card (shadow)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bo góc card
      ),
      child: InkWell(
        onTap: onTap, // Xử lý sự kiện tap
        borderRadius: BorderRadius.circular(16), // Bo góc hiệu ứng ripple
        child: Container(
          padding: const EdgeInsets.all(16), // Khoảng cách bên trong
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container chứa icon với background tròn
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // Background màu nhạt của icon (10% opacity)
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle, // Hình tròn
                ),
                child: Icon(
                  icon,
                  color: color, // Màu của icon
                  size: 32, // Kích thước icon
                ),
              ),
              const SizedBox(height: 12), // Khoảng cách giữa icon và text
              
              // Tiêu đề của card
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600, // Text đậm
                ),
                textAlign: TextAlign.center, // Căn giữa
              ),
            ],
          ),
        ),
      ),
    );
  }
}
