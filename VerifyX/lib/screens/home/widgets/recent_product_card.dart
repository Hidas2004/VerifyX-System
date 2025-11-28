import 'package:flutter/material.dart';

/// Widget Card Sản Phẩm - Giao diện "Tem chứng nhận số"
class RecentProductCard extends StatelessWidget {
  final String productName;
  final String brand;
  final String status;
  final Color statusColor;
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
    bool isAuthentic = statusColor == Colors.green || status.toLowerCase().contains("chính hãng");
    // Màu nền nhạt cho thẻ để trông sạch sẽ (Clean UI)
    Color bgColor = isAuthentic ? const Color(0xFFF1F8E9) : const Color(0xFFFFEBEE);
    Color borderColor = isAuthentic ? Colors.green.shade200 : Colors.red.shade200;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 1. ICON TRẠNG THÁI (Thay vì ảnh sản phẩm nhỏ xíu)
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Icon(
                  isAuthentic ? Icons.verified_user_outlined : Icons.gpp_bad_outlined,
                  size: 30,
                  color: statusColor,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 2. THÔNG TIN CHÍNH
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.business, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text("SX bởi: $brand", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Giả lập mã Hash ngắn để trông "Blockchain" hơn
                    Text(
                      "Hash: 0x${productName.hashCode.toRadixString(16).toUpperCase()}...A7",
                      style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey[400]),
                    )
                  ],
                ),
              ),

              // 3. BADGE TRẠNG THÁI (Dạng con dấu)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor, // Nền màu đậm luôn cho nổi
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                  ]
                ),
                child: Text(
                  isAuthentic ? "CHÍNH HÃNG" : "CẢNH BÁO",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.5
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}