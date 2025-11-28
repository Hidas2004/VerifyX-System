import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  // Dữ liệu giả lập: Đã xóa PRICE, thay bằng CODE (Mã lô/Mã định danh)
  final List<Map<String, String>> _dummyProducts = [
    {'name': 'Serum Vitamin C', 'code': 'BATCH-2025-A01', 'image': ''},
    {'name': 'Sữa rửa mặt Cetaphil', 'code': 'BATCH-2025-B92', 'image': ''},
    {'name': 'Kem chống nắng Anessa', 'code': 'BATCH-2024-X11', 'image': ''},
    {'name': 'Son BlackRouge A12', 'code': 'BATCH-2025-C03', 'image': ''},
    {'name': 'Nước tẩy trang L\'Oreal', 'code': 'BATCH-2024-Z55', 'image': ''},
    {'name': 'Toner Klairs', 'code': 'BATCH-2025-H88', 'image': ''},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // SEARCH BAR - Đổi placeholder để hướng dẫn người dùng nhập Mã
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tên, mã lô hoặc Hash...',
                    prefixIcon: const Icon(Icons.qr_code_scanner, color: Color(0xFF00BCD4)), // Icon Scan thay vì Search thường
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Tags
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTag("Tất cả", true),
                      _buildTag("Mỹ phẩm", false),
                      _buildTag("Dược phẩm", false),
                      _buildTag("Thực phẩm", false),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Tiêu đề nhỏ
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Sản phẩm trong hệ thống VerifyX",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),

                // GRID VIEW SẢN PHẨM
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      childAspectRatio: 0.68, // Tăng chiều cao thẻ chút để chứa nút bấm
                      crossAxisSpacing: 16,    
                      mainAxisSpacing: 16,     
                    ),
                    itemCount: _dummyProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(_dummyProducts[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF00BCD4) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildProductCard(Map<String, String> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200), // Thêm viền nhẹ
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh & Badge Trạng thái
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7F7),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Center(
                    child: Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey),
                  ),
                ),
                // Badge "Đã kiểm định" treo ở góc
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield, size: 10, color: Colors.white),
                        SizedBox(width: 4),
                        Text("Đã kiểm định", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          
          // Thông tin
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                
                // Thay giá tiền bằng MÃ LÔ HÀNG (Nhìn technical hơn)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4)
                  ),
                  child: Text(
                    "ID: ${product['code']}",
                    style: TextStyle(fontSize: 11, color: Colors.grey[700], fontFamily: 'monospace'),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Nút "Chi tiết nguồn gốc" thay vì Mua ngay
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00BCD4),
                      side: const BorderSide(color: Color(0xFF00BCD4)),
                      padding: const EdgeInsets.symmetric(vertical: 0), // Nút nhỏ gọn
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Chi tiết nguồn gốc", style: TextStyle(fontSize: 12)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}