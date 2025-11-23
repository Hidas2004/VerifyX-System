import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// PRODUCT PROVIDER - Quản lý state (ĐÃ FIX TÊN HÀM)
/// ═══════════════════════════════════════════════════════════════════════════
class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();
  
  // State
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ==================== 1. TẢI DANH SÁCH SẢN PHẨM ====================
  // Đã đổi tên thành loadBrandProducts để khớp với UI cũ của bạn
  Future<void> loadBrandProducts(String brandId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _service.getProductsByBrand(brandId);
    } catch (e) {
      _error = e.toString();
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== 2. TẠO SẢN PHẨM MỚI ====================
  Future<bool> createProduct({
    required String brandId,
    required String brandName,
    required String serialNumber,
    required String name,
    required String description,
    required String ingredients,   
    required String category,
    required String batchId,       
    required int blockchainBatchId, 
    required DateTime manufacturingDate,
    required DateTime expiryDate,
    String? imageUrl,
    // Các tham số cũ (giữ lại để không lỗi nếu UI truyền vào, dù không dùng)
    String? initialLocation, 
    String? distributor,
    String? retailer,
    String? retailLocation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Gọi API Node.js
      final success = await _service.createProductApi(
        brandId: brandId,
        brandName: brandName,
        serialNumber: serialNumber,
        name: name,
        description: description,
        ingredients: ingredients,
        category: category,
        batchId: batchId,
        blockchainBatchId: blockchainBatchId,
        manufacturingDate: manufacturingDate,
        expiryDate: expiryDate,
        imageUrl: imageUrl,
      );

      if (success) {
        // Tải lại danh sách sau khi tạo thành công
        await loadBrandProducts(brandId);
      } else {
        _error = "Không thể tạo sản phẩm (Lỗi Server)";
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== 3. CÁC HÀM KHÁC ====================
  void clearError() {
    _error = null;
    notifyListeners();
  }
}