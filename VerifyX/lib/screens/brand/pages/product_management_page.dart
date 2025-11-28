import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/constants.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';
import 'add_product_screen.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String _filterStatus = 'all';
  String? _brandId;
  String? _brandName;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _brandId = user.uid;
      _brandName = user.displayName ?? "Thương hiệu";
      await _fetchProducts();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchProducts() async {
    if (_brandId == null) return;
    try {
      final products = await _productService.getProductsByBrand(_brandId!);
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ProductModel> get _filteredProducts {
    if (_filterStatus == 'all') return _products;
    if (_filterStatus == 'active') return _products.where((p) => p.isActive).toList();
    return _products.where((p) => !p.isActive).toList();
  }

  Map<String, String> get _stats {
    int total = _products.length;
    int active = _products.where((p) => p.isActive).length;
    int inactive = total - active;
    String hotProduct = "N/A";
    if (_products.isNotEmpty) {
      final sorted = List<ProductModel>.from(_products)
        ..sort((a, b) => b.verificationCount.compareTo(a.verificationCount));
      hotProduct = sorted.first.name;
    }
    return {
      "total": "$total",
      "active": "$active",
      "inactive": "$inactive",
      "hot": hotProduct,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder( // Dùng LayoutBuilder để lấy chiều rộng màn hình
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. HEADER THỐNG KÊ
                      _buildQuickStatsHeader(),
                      const SizedBox(height: 24),

                      // 2. THANH CÔNG CỤ & LỌC
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Danh sách sản phẩm",
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _filterStatus,
                                icon: const Icon(Icons.filter_list, size: 18),
                                items: const [
                                  DropdownMenuItem(value: 'all', child: Text('Tất cả', style: TextStyle(fontSize: 13))),
                                  DropdownMenuItem(value: 'active', child: Text('Đang bán', style: TextStyle(fontSize: 13))),
                                  DropdownMenuItem(value: 'inactive', child: Text('Ngừng bán', style: TextStyle(fontSize: 13))),
                                ],
                                onChanged: (val) => setState(() => _filterStatus = val!),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3. BẢNG DỮ LIỆU (FULL WIDTH)
                      _filteredProducts.isEmpty
                          ? _buildEmptyState()
                          : _buildProductTable(constraints.maxWidth), // Truyền chiều rộng vào
                    ],
                  ),
                );
              }
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_brandId == null) return;
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductScreen(brandId: _brandId!, brandName: _brandName ?? "Brand"),
            ),
          );
          if (result == true) _fetchProducts();
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm Mới'),
        backgroundColor: Colors.blue[800],
      ),
    );
  }

  Widget _buildQuickStatsHeader() {
    final stats = _stats;
    return Row(
      children: [
        _buildStatCard("Tổng SP", stats['total']!, Icons.inventory_2, Colors.blue),
        const SizedBox(width: 12),
        _buildStatCard("Đang bán", stats['active']!, Icons.check_circle, Colors.green),
        const SizedBox(width: 12),
        _buildStatCard("Ngưng bán", stats['inactive']!, Icons.warning, Colors.orange),
        const SizedBox(width: 12),
        _buildStatCard("Hot nhất", stats['hot']!, Icons.local_fire_department, Colors.red, isWide: true),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool isWide = false}) {
    return Expanded(
      flex: isWide ? 2 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTable(double screenWidth) {
    return Container(
      width: double.infinity, // Quan trọng: Ép Container full width
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.grey[200]),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox( // Quan trọng: Ép bảng tối thiểu bằng chiều rộng màn hình
            constraints: BoxConstraints(minWidth: screenWidth - 40), // Trừ padding 2 bên
            child: DataTable(
              horizontalMargin: 20,
              columnSpacing: 20, // Khoảng cách cột
              dataRowMinHeight: 70, // SỬA LỖI OVERFLOW: Tăng chiều cao dòng
              dataRowMaxHeight: 70, 
              headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
              columns: const [
                DataColumn(label: Text('Sản phẩm', style: TextStyle(fontWeight: FontWeight.bold))), // Cột to nhất
                DataColumn(label: Text('Mã Serial', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Ngày tạo', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Hành động', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: _filteredProducts.map((product) {
                return DataRow(cells: [
                  // Cột 1: Sản phẩm (Ép độ rộng tối thiểu để đẩy bảng ra)
                  DataCell(
                    Container(
                      width: 220, // Trick: Set cứng width này để cột này chiếm 40%
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 50, height: 50, color: Colors.grey[100],
                              child: product.imageUrl != null 
                                  ? Image.network(product.imageUrl!, fit: BoxFit.cover) 
                                  : const Icon(Icons.image, size: 20, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded( // Text tự xuống dòng nếu dài quá
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(product.category, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(Text(product.serialNumber, style: GoogleFonts.robotoMono(fontSize: 12))),
                  DataCell(_buildStatusBadge(product.isActive)),
                  DataCell(Text(DateFormat('dd/MM/yyyy').format(product.createdAt), style: const TextStyle(fontSize: 13))),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.qr_code_2, size: 20, color: Colors.black54),
                        tooltip: "Xuất QR",
                        onPressed: () => _showQRCodeDialog(product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                        tooltip: "Sửa",
                        onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng đang phát triển")));
                        },
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE6F4EA) : const Color(0xFFFCE8E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isActive ? const Color(0xFF1E8E3E) : const Color(0xFFD93025),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text('Chưa có dữ liệu sản phẩm', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  void _showQRCodeDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("QR Code", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(
                "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${product.qrCode}",
                width: 180, height: 180,
                errorBuilder: (_,__,___) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(product.serialNumber, style: GoogleFonts.robotoMono(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng")),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.download, size: 16),
            label: const Text("Tải xuống"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          )
        ],
      ),
    );
  }
}