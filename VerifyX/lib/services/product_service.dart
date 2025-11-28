import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:dio/dio.dart'; 
import '../models/product_model.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// PRODUCT SERVICE - Quản lý sản phẩm (API Node.js + Firestore Read)
/// ═══════════════════════════════════════════════════════════════════════════
class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Dio _dio = Dio(); 

  // --- LOGIC TỰ ĐỘNG CHỌN IP ---
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    } else {
      return 'http://localhost:3000/api';
    }
  }

  // ==================== TẠO SẢN PHẨM QUA API ====================
  Future<bool> createProductApi({
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
  }) async {
    try {
      final body = {
        "brandId": brandId,
        "brandName": brandName,
        "serialNumber": serialNumber,
        "name": name,
        "category": category,
        "description": description,
        "ingredients": ingredients,
        "batchId": batchId,
        "blockchainBatchId": blockchainBatchId,
        "manufacturingDate": manufacturingDate.toIso8601String(),
        "expiryDate": expiryDate.toIso8601String(),
        "imageUrl": imageUrl,
      };

      debugPrint('🚀 [ProductService] Creating product: $name in Batch: $blockchainBatchId');

      final response = await _dio.post(
        '$_baseUrl/product/create',
        data: body,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        debugPrint('✅ Tạo sản phẩm thành công: ${response.data['productId']}');
        return true;
      } else {
        debugPrint('❌ Lỗi server: ${response.data}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Lỗi kết nối API Product: $e');
      rethrow;
    }
  }

  // ==================== XÁC THỰC SẢN PHẨM ====================
  Future<ProductModel?> verifyBySerial(String serialNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('serialNumber', isEqualTo: serialNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return ProductModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      debugPrint('❌ Error verifying product: $e');
      return null;
    }
  }
  
  Future<ProductModel?> verifyByQRCode(String qrCode) async {
    try {
      final serialNumber = _extractSerialFromQR(qrCode);
      return await verifyBySerial(serialNumber);
    } catch (e) {
      debugPrint('❌ Error verifying by QR: $e');
      return null;
    }
  }

  // ==================== CẬP NHẬT ====================
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('products').doc(productId).update(data);
      debugPrint('✅ Product updated: $productId');
    } catch (e) {
      debugPrint('❌ Error updating product: $e');
      rethrow;
    }
  }
  
  Future<void> incrementVerificationCount(String productId, String userId) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'verificationCount': FieldValue.increment(1),
        'lastVerification': FieldValue.serverTimestamp(),
        'verificationHistory': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ Error incrementing verification: $e');
      rethrow;
    }
  }

  // ==================== QUERY (TRA CỨU) ====================
  
  Future<List<ProductModel>> getProductsByBrand(String brandId) async {
    try {
      final querySnapshot = await _firestore
        .collection('products')
        .where('brandId', isEqualTo: brandId)
        .get();

      final products = querySnapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();

      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    } catch (e) {
      debugPrint('❌ Error getting products: $e');
      return [];
    }
  }

  // --- [MỚI] LẤY SẢN PHẨM THEO BATCH ID (ĐỂ IN TEM) ---
  Future<List<ProductModel>> getProductsByBatch(String batchId) async {
    try {
      debugPrint('🔍 Lấy sản phẩm cho Batch ID: $batchId');
      final querySnapshot = await _firestore
        .collection('products')
        .where('batchId', isEqualTo: batchId) 
        .get();

      final products = querySnapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();

      debugPrint('✅ Tìm thấy ${products.length} sản phẩm trong lô.');
      return products;
    } catch (e) {
      debugPrint('❌ Lỗi lấy sản phẩm theo lô: $e');
      return [];
    }
  }
  
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(20)
          .get();
          
      return querySnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('❌ Error searching products: $e');
      return [];
    }
  }

  // ==================== HELPERS ====================
  String _generateQRCode(String serialNumber) {
    return 'VERIFYX://SERIAL/$serialNumber';
  }
  
  String _extractSerialFromQR(String qrCode) {
    if (qrCode.startsWith('VERIFYX://SERIAL/')) {
      return qrCode.replaceFirst('VERIFYX://SERIAL/', '');
    }
    return qrCode;
  }
}