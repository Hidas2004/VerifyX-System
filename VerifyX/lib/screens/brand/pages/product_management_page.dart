import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Dùng trực tiếp Auth của Firebase
import '../../../core/constants/constants.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart'; // Gọi Service trực tiếp
import 'add_product_screen.dart';
import 'package:intl/intl.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  // Service & Data
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  
  // Trạng thái UI
  bool _isLoading = true;
  String _filterStatus = 'all';
  String? _errorMessage;

  // Thông tin User
  String? _brandId;
  String? _brandName;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // --- 1. HÀM TẢI DỮ LIỆU (QUAN TRỌNG) ---
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _brandId = user.uid;
      _brandName = user.displayName ?? "Thương hiệu";
      
      // Gọi hàm lấy danh sách từ Service
      await _fetchProducts();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "Chưa đăng nhập";
      });
    }
  }

  Future<void> _fetchProducts() async {
    if (_brandId == null) return;

    try {
      // Gọi trực tiếp Service (Đã test OK)
      final products = await _productService.getProductsByBrand(_brandId!);
      
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Lỗi tải dữ liệu: $e";
        });
      }
    }
  }

  // --- 2. LOGIC LỌC DANH SÁCH ---
  List<ProductModel> get _filteredProducts {
    if (_filterStatus == 'all') return _products;
    if (_filterStatus == 'active') return _products.where((p) => p.isActive).toList();
    return _products.where((p) => !p.isActive).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // AppBar đã được xử lý ở BrandProductsPage (Parent), 
      // nhưng nếu đây là page con trong TabView thì ta không cần AppBar nữa
      // hoặc giữ lại nếu muốn filter nằm riêng.
      body: Column(
        children: [
          // Thanh Filter (Tùy chọn)
          _buildFilterBar(),
          
          // Danh sách sản phẩm
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchProducts,
              child: _buildBody(),
            ),
          ),
        ],
      ),
      
      // Nút thêm sản phẩm
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'btnAddProduct',
        onPressed: () async {
          if (_brandId == null) return;

          // Chuyển sang màn hình thêm và đợi kết quả
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductScreen(
                brandId: _brandId!,
                brandName: _brandName ?? "Brand",
              ),
            ),
          );

          // Nếu thêm thành công (trả về true), load lại danh sách
          if (result == true) {
            _fetchProducts();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm SP'),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }

    final displayList = _filteredProducts;

    if (displayList.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        return _buildProductCard(displayList[index]);
      },
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tổng: ${_products.length} sản phẩm', 
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.blue),
            onSelected: (value) => setState(() => _filterStatus = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Tất cả')),
              const PopupMenuItem(value: 'active', child: Text('Đang bán')),
              const PopupMenuItem(value: 'inactive', child: Text('Ngừng bán')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Chưa có sản phẩm nào',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showProductDetails(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh sản phẩm
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? Image.network(
                        product.imageUrl!,
                        width: 80, height: 80, fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
              const SizedBox(width: 12),
              // Thông tin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text("Serial: ${product.serialNumber}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusChip(product.isActive),
                        const Spacer(),
                        if (product.blockchainHash.isNotEmpty)
                          const Icon(Icons.verified_user, size: 16, color: Colors.green),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80, height: 80, color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isActive ? Colors.green : Colors.red, width: 0.5),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(fontSize: 10, color: isActive ? Colors.green[700] : Colors.red[700]),
      ),
    );
  }

  // --- CHI TIẾT & ACTIONS ---
  void _showProductDetails(ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, color: Colors.grey[300])),
              const SizedBox(height: 20),
              Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Mã: ${product.serialNumber}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              const Divider(height: 30),
              _detailRow("Danh mục", product.category),
              _detailRow("Ngày SX", DateFormat('dd/MM/yyyy').format(product.manufacturingDate)),
              _detailRow("Hạn SD", DateFormat('dd/MM/yyyy').format(product.expiryDate)),
              const SizedBox(height: 10),
              const Text("Mô tả:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(product.description),
              const SizedBox(height: 20),
              if(product.blockchainHash.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Blockchain Hash:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(product.blockchainHash, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}