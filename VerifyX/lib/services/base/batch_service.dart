import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/brand/batch_model.dart';

class BatchService {
  final Dio _dio = Dio();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // --- 1. API TẠO LÔ HÀNG (GHI) ---
  Future<Map<String, dynamic>?> createBatch({
    required String brandId,
    required String brandName,
    required String batchNumber,
    required String productName,
    required DateTime manufactureDate,
    required DateTime expiryDate,
    required int quantity,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "brandId": brandId,
        "brandName": brandName,
        "batchNumber": batchNumber,
        "productName": productName,
        "manufactureDate": manufactureDate.toIso8601String(),
        "expiryDate": expiryDate.toIso8601String(),
        "quantity": quantity,
      };

      debugPrint('🚀 [BatchService] Connecting to: $_baseUrl'); 
      
      final response = await _dio.post(
        '$_baseUrl/batch/create', 
        data: body,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        debugPrint('✅ Tạo Batch thành công! Block: ${response.data['blockNumber']}');
        return response.data;
      } else {
        debugPrint('❌ Lỗi server trả về: ${response.data}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Lỗi kết nối ($_baseUrl): $e');
      rethrow; 
    }
  }

  // --- 2. HÀM LẤY DANH SÁCH TỪ FIREBASE (ĐỌC) ---
  Future<List<BatchModel>> getBatches(String brandId) async {
    try {
      final snapshot = await _firestore
          .collection('batches')
          .where('brandId', isEqualTo: brandId)
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        // Đảm bảo blockchainData không bị null
        if (data['blockchainData'] == null) {
             data['blockchainData'] = {};
        }
        return BatchModel.fromMap(data);
      }).toList();
      
    } catch (e) {
      debugPrint('❌ Lỗi tải danh sách lô hàng: $e');
      return [];
    }
  }

  // --- 3. CẬP NHẬT TRẠNG THÁI (GỌI API NODEJS -> BLOCKCHAIN) ---
  Future<Map<String, dynamic>?> updateBatchStatus({
    required int blockchainId,
    required String status,
    required String location,
  }) async {
    try {
      final body = {
        "id": blockchainId,
        "status": status,
        "location": location,
      };

      debugPrint('🚀 [BatchService] Cập nhật trạng thái lô: $blockchainId -> $status');

      final response = await _dio.post(
        '$_baseUrl/batch/scan', 
        data: body,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        debugPrint('✅ Cập nhật Blockchain thành công! Hash: ${response.data['txHash']} | Block: ${response.data['blockNumber']}');
        return response.data;
      } else {
        debugPrint('❌ Lỗi server: ${response.data}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Lỗi gọi API updateBatchStatus: $e');
      return null;
    }
  }
}