import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../models/verification_record_model.dart'; 
import 'product_service.dart'; 

/// ═══════════════════════════════════════════════════════════════════════════
/// VERIFICATION SERVICE - Xác thực sản phẩm (FINAL FIX)
/// ═══════════════════════════════════════════════════════════════════════════
class VerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();

  final String _apiUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

  // ==================== XÁC THỰC ====================

  Future<Map<String, dynamic>> verifyProduct({
    required String serialNumber,
    required String userId,
    required String userName,
    required String verificationMethod, 
    String? location,
    String? deviceInfo,
  }) async {
    try {
      // BƯỚC 1: Tìm sản phẩm trong Database bằng Serial Number
      final product = await _productService.verifyBySerial(serialNumber);

      if (product == null) {
        return {
          'success': false,
          'message': 'Sản phẩm không tồn tại trong hệ thống',
          'isAuthentic': false,
        };
      }

      // BƯỚC 2: Lấy Blockchain ID từ sản phẩm tìm được
      // (Code cũ bị sai ở đây vì dùng serialNumber để check blockchain)
      final String blockchainIdToCheck = product.blockchainBatchId.toString();

      List<dynamic> blockchainHistory = [];
      bool blockchainVerified = false;
      String blockchainMessage = 'Chưa xác thực trên Blockchain';

      try {
        if (product.blockchainBatchId > 0) {
           // Gọi Blockchain bằng ID số (blockchainBatchId) chứ không phải Serial
           blockchainHistory = await getBatchHistoryFromBlockchain(blockchainIdToCheck);
           
           if (blockchainHistory.isNotEmpty) {
             blockchainVerified = true;
             blockchainMessage = 'Đã xác thực trên Blockchain';
           }
        } else {
           debugPrint('⚠️ Sản phẩm này chưa được đưa lên Blockchain (ID = 0)');
        }
      } catch (e) {
        debugPrint('❌ Blockchain verification failed: $e');
        blockchainMessage = 'Lỗi kết nối Blockchain';
      }

      final now = DateTime.now();

      // BƯỚC 3: Lưu lịch sử (Kèm Brand ID)
      final recordData = {
        'id': '',
        'productId': product.id,
        'productName': product.name,
        'serialNumber': serialNumber,
        'userId': userId,
        'userName': userName,
        'verificationDate': now.toIso8601String(),
        'verifiedAt': now,
        'verificationMethod': verificationMethod,
        'isAuthentic': blockchainVerified,
        'location': location ?? '',
        'deviceInfo': deviceInfo,
        'blockchainHash': product.blockchainHash,
        'blockchainVerified': blockchainVerified,
        'createdAt': now,
        'result': blockchainVerified ? 'authentic' : 'fake', // Nếu không có trên blockchain -> Fake
        'brandId': product.brandId, 
      };

      await _firestore.collection('verifications').add(recordData);
      
      // Tăng lượt view
      await _productService.incrementVerificationCount(product.id, userId);

      return {
        'success': true,
        'message': blockchainMessage,
        'isAuthentic': blockchainVerified,
        'product': product, // Trả về ProductModel
        'blockchainHistory': blockchainHistory,
      };
    } catch (e) {
      debugPrint('❌ Error verifying product: $e');
      return {
        'success': false,
        'message': 'Lỗi khi xác thực sản phẩm',
        'isAuthentic': false,
      };
    }
  }

  // ==================== CÁC HÀM LẤY DATA (GIỮ NGUYÊN) ====================

  Future<List<VerificationRecordModel>> getUserVerificationHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('verifications')
          .where('userId', isEqualTo: userId)
          .orderBy('verifiedAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => VerificationRecordModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      final records = await getUserVerificationHistory(userId);
      return {
        'totalVerifications': records.length,
        'authenticProducts': records.where((r) => r.isAuthentic).length,
        'lastVerification': records.isNotEmpty ? records.first.verificationDate : null,
      };
    } catch (e) {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getBrandVerifications(String brandId) async {
    try {
      final querySnapshot = await _firestore
          .collection('verifications')
          .where('brandId', isEqualTo: brandId)
          .orderBy('verifiedAt', descending: true)
          .limit(100)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        if (data['verifiedAt'] is Timestamp) {
           data['verifiedAt'] = (data['verifiedAt'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting brand logs: $e');
      return [];
    }
  }

  // ==================== BLOCKCHAIN API (GIỮ NGUYÊN) ====================
  
  Future<String> createBatchOnBlockchain(String id, String name, String initialLocation) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/api/batch/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'name': name, 'initialLocation': initialLocation}),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body)['txHash'];
      }
      throw Exception('Lỗi server: ${response.body}');
    } catch (error) {
      rethrow;
    }
  }

  Future<String> scanBatchOnBlockchain(String id, String location, String status) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/api/batch/scan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'location': location, 'status': status}),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body)['txHash'];
      }
      throw Exception('Lỗi server: ${response.body}');
    } catch (error) {
      rethrow;
    }
  }

  Future<List<dynamic>> getBatchHistoryFromBlockchain(String id) async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/api/history/$id'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (error) {
      return [];
    }
  }
}